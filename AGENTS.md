# Claude Desktop 简体中文语言包

维护 Claude Desktop 的简体中文（zh-CN）翻译 JSON，并提供 macOS 本机安装脚本。

## 目录

```
patches/                          翻译文件（只包含当前版本英文中存在的 key）
  zh-CN-layer-b.json              主进程：菜单、对话框、托盘
  zh-CN-layer-c.json              前端：主界面、设置、Code 标签页等
  zh-CN-layer-c-dynamic.json      动态文案：模型描述等
tools/
  icu_check.py                    校验译文与英文的占位符 / ICU / 标签结构
  build_patches.py                extract：按当前版本找出缺失条目并分批；merge：合并批次回 patches/
  patch_frontend.py               修补前端 bundle，让它识别 zh-CN
  install-macos.sh                生成中文副本 ~/Applications/Claude-zh.app
scratch/                          临时文件（批次、参考表），已 gitignore
```

## 加载机制（关键设计决策）

- **最重要的限制（2.16120.0 实测）**：使用 Anthropic 账号登录时，主界面从 `https://claude.ai` 在线加载（日志 `~/Library/Logs/Claude/claude.ai-web.log`），本地 `ion-dist` 只通过 `app://localhost` 提供，实测访问次数为 0。语言列表、界面翻译都来自网站，下面的前端补丁和 `ion-dist/i18n/zh-CN.json` 对主界面不生效；只有主进程层（菜单、托盘、对话框）读取本地文件。判断一个改动是否生效前，先确认它影响的是本地渲染还是 claude.ai 在线页面。

- 主进程扫描 `Contents/Resources/` 下匹配 `xx-XX.json` 的文件作为可用语言，放入 `zh-CN.json` 即可，**不需要修改 app.asar**（修改会触发 Info.plist 中的 asar 完整性校验）。
- 前端从 `Resources/ion-dist/i18n/<locale>.json`、`dynamic/<locale>.json` 加载翻译，但 bundle 里写死了支持语言列表和语言名称表，必须由 `patch_frontend.py` 追加 zh-CN。补丁靠正则匹配 `"id-ID"` 相关代码，前端结构变化时脚本会报错退出。
- 安装采用“复制副本 + 本机临时签名”，不改 `/Applications/Claude.app`：官方应用受 macOS 应用管理保护，且自动更新会覆盖修改。副本与官方应用共用账号数据，不能同时运行，也不会自动更新。
- key 是英文原文的哈希，英文改一个词 key 就会变，旧翻译随之失效。`merge` 会丢弃当前版本已不存在的 key。

## 翻译规则

1. 只改 value，不改 key。
2. 占位符名、ICU 关键字与分支名、标签名和数量必须与英文一致（`icu_check.py` 会检查）。
3. 译文中不用英文单引号 `'`（ICU 转义符，会让占位符失效），不用未转义的英文双引号，改用 “ ” ‘ ’。
4. 中国大陆简体用语，称呼用户用“你”；中英文之间加空格。术语与已有翻译保持一致。
5. JSON 写入保持 UTF-8 原字符（`ensure_ascii=False`）。

## Claude Desktop 更新后的流程

```bash
python3 tools/build_patches.py extract     # 生成 scratch/chunks/*.en.json
# 翻译每个批次为同名 .zh.json，并逐个校验：
python3 tools/icu_check.py scratch/chunks/c-00.en.json scratch/chunks/c-00.zh.json
python3 tools/build_patches.py merge       # 合并回 patches/
tools/install-macos.sh                     # 重新生成中文副本
```

## 验证

- `python3 tools/icu_check.py <Resources 下的 en-US.json> patches/<对应文件>` 错误为 0。
- 修改 `patch_frontend.py` 后，在 `scratch/` 里对 `ion-dist/assets` 的副本运行它，并用 `node --check --input-type=module < 文件` 检查被修改的 bundle 语法。

## 安全边界与回退

- 不修改 `/Applications/Claude.app`，不提交 `en-US.json` 或其他官方原始文件。
- 回退：删除 `~/Applications/Claude-zh.app`，继续使用官方应用即可；翻译文件用 git 回退。
