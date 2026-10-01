#!/usr/bin/env python3
"""让 Claude Desktop 前端识别 zh-CN。可重复执行（已打过补丁的文件会跳过）。

用法：python3 tools/patch_frontend.py <Claude.app 路径>

前端 bundle 里写死了支持的语言，补丁做三件事：
1. 支持语言数组 [..., "id-ID"] 追加 "zh-CN"（语言协商和“是否支持”判断用）
2. 语言名称表追加 "zh-CN": {name, localName}（设置里的语言下拉框显示用）
3. persona 语言 switch 追加 case "zh-CN"
"""
import pathlib
import re
import sys

LOCALE_ARRAY = re.compile(r'(\["en-US"(?:,"[a-zA-Z0-9-]+")*?,"id-ID")\]')
NAME_ENTRY = re.compile(r'("id-ID":\{name:"Indonesian \(Indonesia\)",localName:"[^"]*"\})')
PERSONA_CASE = re.compile(r'(case"id-ID":return\["language","id"\];)')

ZH_NAME = '"zh-CN":{name:"Chinese (Simplified)",localName:"\\u7B80\\u4F53\\u4E2D\\u6587"}'


def patch(text):
    count = 0
    if '"zh-CN"]' not in text:
        text, n = LOCALE_ARRAY.subn(r'\1,"zh-CN"]', text)
        count += n
    if '"zh-CN":{name:' not in text:
        text, n = NAME_ENTRY.subn(lambda m: m.group(1) + "," + ZH_NAME, text)
        count += n
    if 'case"zh-CN":return["language"' not in text:
        text, n = PERSONA_CASE.subn(r'\1case"zh-CN":return["language","zh"];', text)
        count += n
    return text, count


def main():
    app = pathlib.Path(sys.argv[1])
    assets = app / "Contents/Resources/ion-dist/assets"
    total = 0
    for f in assets.rglob("*.js"):
        src = f.read_text(encoding="utf-8")
        if '"id-ID"' not in src:
            continue
        out, n = patch(src)
        if n:
            f.write_text(out, encoding="utf-8")
            print(f"已修补 {f.name}（{n} 处）")
            total += n
    arrays = sum('"id-ID","zh-CN"]' in f.read_text(encoding="utf-8") for f in assets.rglob("*.js"))
    names = sum('"zh-CN":{name:' in f.read_text(encoding="utf-8") for f in assets.rglob("*.js"))
    print(f"本次修补 {total} 处；含 zh-CN 的语言数组文件 {arrays} 个，语言名称表 {names} 个")
    if arrays == 0 or names == 0:
        print("错误：没有找到需要修补的位置，Claude Desktop 的前端结构可能已变化", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
