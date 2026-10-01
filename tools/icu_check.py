#!/usr/bin/env python3
"""校验译文与英文原文的 ICU 结构是否一致。

用法：
  python3 tools/icu_check.py <英文 JSON> <译文 JSON> [--partial]

--partial：译文只覆盖英文的一部分（批次文件），不报告缺失的 key。
退出码：有错误时为 1。
"""
import json
import re
import sys

TAG_RE = re.compile(r"</?([A-Za-z0-9_]+)\s*/?>")
HAN_RE = re.compile(r"[一-鿿]")


def skeleton(msg):
    """返回消息的结构签名：参数名、参数类型、选择器分支（按出现顺序展开）。"""
    out = []
    i, n = 0, len(msg)

    def parse(i, depth):
        while i < n:
            c = msg[i]
            if c == "'" and i + 1 < n and msg[i + 1] in "{}'":
                # ICU 转义：'{' 或 '' 等，跳过被引用的内容
                j = msg.find("'", i + 1)
                i = n if j == -1 else j + 1
                continue
            if c == "{":
                i = parse_arg(i + 1, depth)
                continue
            if c == "}":
                return i + 1
            i += 1
        return i

    def parse_arg(i, depth):
        j = i
        while j < n and msg[j] not in ",}":
            j += 1
        name = msg[i:j].strip()
        if j < n and msg[j] == "}":
            out.append(("arg", depth, name))
            return j + 1
        # 有类型
        k = j + 1
        while k < n and msg[k] not in ",}":
            k += 1
        typ = msg[j + 1:k].strip()
        out.append(("arg", depth, name, typ))
        if k < n and msg[k] == "}":
            return k + 1
        if typ in ("plural", "select", "selectordinal"):
            k += 1
            while k < n:
                while k < n and msg[k].isspace():
                    k += 1
                if k < n and msg[k] == "}":
                    return k + 1
                m = re.match(r"offset:\s*\d+\s*", msg[k:])
                if m:
                    k += m.end()
                    continue
                s = k
                while k < n and msg[k] != "{" and not msg[k].isspace():
                    k += 1
                out.append(("case", depth, name, msg[s:k]))
                while k < n and msg[k] != "{":
                    k += 1
                k = parse(k + 1, depth + 1)
            return k
        # number/date/time 带样式
        while k < n and msg[k] != "}":
            k += 1
        return k + 1

    parse(0, 0)
    return out


def check_pair(key, en, zh):
    errs = []
    if not isinstance(zh, str) or not zh.strip():
        return ["译文为空"]
    try:
        if sorted(skeleton(en)) != sorted(skeleton(zh)):
            errs.append("占位符/ICU 结构不一致")
    except Exception as e:  # noqa: BLE001
        errs.append(f"ICU 解析失败: {e}")
    if sorted(TAG_RE.findall(en)) != sorted(TAG_RE.findall(zh)):
        errs.append("标签不一致")
    if en.count("{") != en.count("}") or zh.count("{") != zh.count("}"):
        if zh.count("{") - zh.count("}") != en.count("{") - en.count("}"):
            errs.append("花括号不配对")
    return errs


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    partial = "--partial" in sys.argv
    en = json.load(open(args[0], encoding="utf-8"))
    zh = json.load(open(args[1], encoding="utf-8"))
    errors, warns = [], []
    for k, v in zh.items():
        if k not in en:
            errors.append((k, "英文中不存在的 key"))
            continue
        for e in check_pair(k, en[k], v):
            errors.append((k, e))
        if not HAN_RE.search(v) and v != en[k] and re.search(r"[A-Za-z]{3,}", v):
            warns.append((k, "译文不含中文"))
    if not partial:
        for k in en:
            if k not in zh:
                errors.append((k, "缺少翻译"))
    for k, e in errors[:200]:
        print(f"错误 {k}: {e}\n  英: {en.get(k, '')[:150]}\n  中: {str(zh.get(k, ''))[:150]}")
    print(f"共 {len(zh)} 条，错误 {len(errors)}，提示 {len(warns)}")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
