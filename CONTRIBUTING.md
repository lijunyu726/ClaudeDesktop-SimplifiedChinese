# 贡献指南

欢迎改进翻译、补译新版本文案，或为其他平台补充安装脚本。

## 改进已有翻译

1. 在 `patches/` 对应的 JSON 文件里找到要改的条目（可以用中文原句搜索），**只改 value，不改 key**。
2. 运行校验（英文文件取自你安装的 Claude Desktop）：

   ```bash
   R=/Applications/Claude.app/Contents/Resources
   python3 tools/icu_check.py $R/ion-dist/i18n/en-US.json patches/zh-CN-layer-c.json
   ```

3. 错误为 0 后提交 PR，提交信息形如 `i18n(zh-CN): 改进 xxx 的译法`。

报告问题时，请附上 Claude Desktop 版本号、在哪个界面看到、英文原文（如有）和建议译法。

## 适配新版本

```bash
python3 tools/build_patches.py extract   # 生成 scratch/chunks/<批次>.en.json
```

把每个批次翻译成同名的 `<批次>.zh.json`（key 不变），逐个校验，最后合并：

```bash
python3 tools/icu_check.py scratch/chunks/c-00.en.json scratch/chunks/c-00.zh.json
python3 tools/build_patches.py merge
```

`merge` 会按当前版本英文重排条目，并丢弃新版已不再使用的 key。改写过的英文原文 key 会变化，对应旧译文也会被视为待译。

## 翻译规范

读者是看不太懂英文的简体中文用户。译文要自然、简洁，像国内正规软件的界面文案。

### 结构（`icu_check.py` 会检查）

- 占位符 `{name}` 名称不能改、不能增删。
- `{count, plural, one {...} other {...}}`、`select`：关键字和分支名保留，只翻译花括号里的文字；`#` 保留。
- 标签 `<link>…</link>`、`<b>…</b>`、`<span1>…</span1>` 等：标签名和出现次数与原文一致，位置可按中文语序调整。
- **不要用英文单引号 `'`**，它是 ICU 转义符，`'{name}'` 会让占位符失效；也不要用未转义的英文双引号。需要引号时用 “ ” ‘ ’。
- 原文的 `\n` 保留；JSON 保持 UTF-8 原字符，不要写成 `\uXXXX`。

### 用语与排版

- 中国大陆简体用语：文件、设置、默认、视频、信息、网络、登录、账号（不用檔案、設定、預設、影片、訊息、網路）。
- 称呼用户统一用“你”。
- 中文与英文、数字、占位符之间加半角空格；标点用中文全角。

### 术语表

| 英文 | 译法 |
|---|---|
| Artifact | 工件 |
| Project / Workspace | 项目 / 工作区 |
| Skill / Connector / Plugin / Extension | 技能 / 连接器 / 插件 / 扩展 |
| Session / Memory | 会话 / 记忆 |
| Routine / Scheduled task | 定时任务 / 计划任务（两者不混用） |
| Agent / Subagent | 智能体 / 子智能体 |
| Prompt | 提示词 |
| Token | 模型计量为 token；身份凭据为 令牌 |
| Context window | 上下文窗口 |
| Worktree / Repository / Branch / Commit / Diff | 工作树 / 代码仓库 / 分支 / 提交 / 差异 |
| Pull request | 拉取请求（可写 PR） |
| Effort | 推理强度 |
| Plan mode / Auto mode / Bypass permissions | 计划模式 / 自动模式 / 绕过权限 |
| Computer use / Remote Control | 计算机操控 / 远程控制 |
| Rewind / Fork | 回退 / 分叉 |
| Marketplace | 插件市场 |
| Usage / Extra usage / Usage credits / Spend limit | 用量 / 额外用量 / 用量额度 / 支出限额 |
| Auto-reload（计费） | 自动充值 |
| Allowlist | 白名单 |
| Composer | 输入框 |
| Sign in / Sign out | 登录 / 退出登录 |

**保留英文**：Claude、Claude Code、Anthropic、Cowork、Dispatch、MCP、API、SDK、SSH、WSL、Git、GitHub、macOS、Windows、Linux、Chrome、Opus、Sonnet、Haiku、Fable、JSON、URL、CLI、IDE、PR、快捷键名（Cmd、Esc 等）和命令。

**套餐名保留英文**：Pro、Max（含 Max 5x、Max 20x）、Team、Enterprise，例如“Team 套餐”“升级到 Enterprise”。Free 译作“免费版”。普通用法照常翻译，如“团队成员”“企业搜索”“最长 720 小时”。
