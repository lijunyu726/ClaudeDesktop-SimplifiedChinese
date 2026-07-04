# Contributing

欢迎贡献翻译和改进！

## 如何贡献翻译

### 1. 找到需要翻译的字符串

从 Claude.app 中提取英文源文件：

```bash
# 提取 en-US.json
cp /Applications/Claude.app/Contents/Resources/ion-dist/i18n/en-US.json ./en-US.json
```

### 2. 翻译规则

- 保持所有 JSON key 不变，只翻译 value
- 保持格式参数：`{name}`, `{count}`, `{error}`, `{pct}` 等
- 保持 HTML 标签：`<link>`, `<b>`, `<a>`, `<learnMoreLink>` 等
- 保持 ICU MessageFormat 语法：`{count, plural, one {...} other {...}}`

### 3. 术语表

| 英文 | 中文 | 场景 |
|------|------|------|
| app | 应用 | 通用 |
| settings | 设置 | 通用 |
| extension | 扩展 | Chrome 扩展 |
| connector | 连接器 | 数据源 |
| artifact | 制品 | 交互式页面 |
| Free | 免费版 | 套餐名 |
| Pro | Pro | 套餐名（保留） |
| Team | 团队版 | 套餐名 |
| Enterprise | 企业版 | 套餐名 |

### 4. 提交 PR

1. Fork 本仓库
2. `git checkout -b feature/your-improvement`
3. 修改翻译文件
4. `git commit -m "improve: 改进 xxx 的翻译"`
5. `git push origin feature/your-improvement`
6. 创建 Pull Request

## 报告问题

如果发现翻译错误或界面异常，请在 Issues 中报告，包含：
- Claude 桌面版版本号
- macOS 版本
- 问题截图
- 复现步骤
