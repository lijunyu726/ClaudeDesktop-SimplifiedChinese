#!/usr/bin/env python3
"""对照当前 Claude Desktop 的英文文件，生成或合并翻译。

用法：
  python3 tools/build_patches.py extract [Claude.app]   # 找出缺失/有问题的条目，拆成批次放到 scratch/chunks/
  python3 tools/build_patches.py merge   [Claude.app]   # 把 scratch/chunks/*.zh.json 合并进 patches/，并按当前英文裁剪

默认 Claude.app 路径为 /Applications/Claude.app。
"""
import glob
import json
import os
import pathlib
import sys

sys.path.insert(0, os.path.dirname(__file__))
from icu_check import check_pair  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parent.parent
CHUNK_SIZE = 800
LAYERS = {
    "b": ("Contents/Resources/en-US.json", "patches/zh-CN-layer-b.json"),
    "c": ("Contents/Resources/ion-dist/i18n/en-US.json", "patches/zh-CN-layer-c.json"),
    "d": ("Contents/Resources/ion-dist/i18n/dynamic/en-US.json", "patches/zh-CN-layer-c-dynamic.json"),
}


def load(p):
    return json.load(open(p, encoding="utf-8"))


def dump(obj, p):
    with open(p, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
        f.write("\n")


def extract(app):
    chunks = ROOT / "scratch/chunks"
    chunks.mkdir(parents=True, exist_ok=True)
    for layer, (en_rel, zh_rel) in LAYERS.items():
        en = load(app / en_rel)
        zh = load(ROOT / zh_rel)
        todo = [(k, v) for k, v in en.items() if k not in zh or check_pair(k, v, zh[k])]
        size = CHUNK_SIZE if layer == "c" else len(todo) or 1
        for i in range(0, len(todo), size):
            dump(dict(todo[i:i + size]), chunks / f"{layer}-{i // size:02d}.en.json")
        print(f"{layer}: 英文 {len(en)} 条，待译 {len(todo)} 条")


def merge(app):
    for layer, (en_rel, zh_rel) in LAYERS.items():
        en = load(app / en_rel)
        zh = load(ROOT / zh_rel)
        for p in sorted(glob.glob(str(ROOT / f"scratch/chunks/{layer}-*.zh.json"))):
            zh.update(load(p))
        out, bad, missing = {}, 0, 0
        for k, v in en.items():
            if k not in zh:
                missing += 1
            elif check_pair(k, v, zh[k]):
                bad += 1
            else:
                out[k] = zh[k]
        dump(out, ROOT / zh_rel)
        print(f"{layer}: 写入 {len(out)}/{len(en)} 条（缺失 {missing}，校验未通过 {bad}）")


if __name__ == "__main__":
    cmd = sys.argv[1]
    app = pathlib.Path(sys.argv[2] if len(sys.argv) > 2 else "/Applications/Claude.app")
    {"extract": extract, "merge": merge}[cmd](app)
