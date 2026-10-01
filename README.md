<div align="center">

# Claude Desktop 简体中文语言包

### 让 Claude Desktop 说中文 —— 完整 33,000+ 条界面翻译

> 把 Claude Desktop 的英文界面完整汉化为简体中文，并提供 macOS 一键生成中文版的脚本。

---

![coverage](https://img.shields.io/badge/翻译覆盖-100%25-brightgreen?style=flat-square)
![version](https://img.shields.io/badge/对应版本-2.16120.0-blue?style=flat-square)
![locale](https://img.shields.io/badge/locale-zh--CN-blue?style=flat-square)
![license](https://img.shields.io/badge/许可-MIT-yellow?style=flat-square)

</div>

---

## ✨ 这是什么

本仓库提供 **Claude Desktop** 的简体中文（`zh-CN`）翻译文件，覆盖菜单栏、主聊天界面、设置面板、Code 标签页、Cowork、模型描述等全部用户可见文案，并附带：

- **macOS 安装脚本**：基于官方应用生成一份中文副本，**不修改官方应用**；
- **维护工具**：Claude Desktop 更新后，自动找出新增文案、校验译文结构。

---

## 📦 翻译文件

| 文件 | 层级 | 条目数 | 涵盖内容 |
|:-----|:-----|------:|:---------|
| `patches/zh-CN-layer-b.json` | 主进程 | **742** | 应用菜单、托盘、快捷键、系统对话框 |
| `patches/zh-CN-layer-c.json` | 前端 | **32,243** | 聊天界面、设置、连接器、技能、Code 标签页、Cowork |
| `patches/zh-CN-layer-c-dynamic.json` | 动态文案 | **49** | 模型描述、功能提示 |

翻译与 Claude Desktop **2.16120.0** 的英文文件逐条对齐，所有条目都通过了占位符 / ICU / 标签结构校验。

---

## 🚀 macOS 安装

```bash
git clone https://github.com/lijunyu726/ClaudeDesktop-SimplifiedChinese.git
cd ClaudeDesktop-SimplifiedChinese
tools/install-macos.sh
```

脚本会把 `/Applications/Claude.app` 复制为 `~/Applications/Claude-zh.app`，放入翻译文件、修补前端的语言列表，再做本机临时签名。然后：

1. 完全退出官方 Claude（Cmd+Q）。中文版和官方应用共用同一份账号数据，不能同时运行。
2. 打开 `~/Applications/Claude-zh.app`。
3. 首次启动如果弹出钥匙串“Claude Safe Storage”访问请求，输入 Mac 登录密码并选“始终允许”。
4. 在 **设置 → 语言** 中选择“简体中文”。

注意事项：

- 中文副本**不会自动更新**。官方应用更新后，重新运行 `tools/install-macos.sh` 即可（翻译需要先按下方流程补齐）。
- 屏幕录制、辅助功能等系统权限需要为副本重新授权。
- 不想用了：删除 `~/Applications/Claude-zh.app`，继续用官方应用即可。

Windows / Linux 暂无安装脚本，翻译文件的加载路径见 [AGENTS.md](AGENTS.md#加载机制关键设计决策)。

---

## 🔄 Claude Desktop 更新后补译

```bash
python3 tools/build_patches.py extract   # 对照新版英文，把缺失条目拆成批次到 scratch/chunks/
# 把每个 scratch/chunks/xx.en.json 翻译成同名 xx.zh.json，然后逐个校验：
python3 tools/icu_check.py scratch/chunks/c-00.en.json scratch/chunks/c-00.zh.json
python3 tools/build_patches.py merge     # 合并回 patches/，丢弃新版已不用的条目
```

翻译规则（占位符、ICU 语法、标签、用语）见 [AGENTS.md](AGENTS.md) 和 [CONTRIBUTING.md](CONTRIBUTING.md)。

---

## 🗂 仓库结构

```
claude-desktop-zh/
├── patches/                 # 翻译 JSON 文件
├── tools/
│   ├── install-macos.sh     # 生成中文版应用
│   ├── patch_frontend.py    # 让前端识别 zh-CN
│   ├── build_patches.py     # 提取缺失条目 / 合并翻译
│   └── icu_check.py         # 校验译文结构
├── AGENTS.md                # 维护说明与设计决策
├── CONTRIBUTING.md          # 翻译贡献指南
└── LICENSE
```

---

## 📋 已知边界

- Claude Desktop 每次更新都可能新增或改写文案，需要重新补译。
- 少量文案由服务器下发或在前端写死，不在翻译文件中，仍会显示英文。
- 前端补丁依赖当前 bundle 的代码结构；结构变化时 `patch_frontend.py` 会报错退出，需要更新匹配规则。
- 已在 2.16120.0 上验证脚本可生成并签名中文副本；界面显示效果需在启动中文副本后确认。

---

## 📄 许可证

[MIT License](LICENSE)

<div align="center">

<sub>⚠️ 本项目是非官方的社区翻译项目，与 Anthropic 无任何关联。使用风险自负。</sub>

</div>
