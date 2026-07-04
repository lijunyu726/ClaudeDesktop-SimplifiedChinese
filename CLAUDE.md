# Claude Desktop 中文汉化

为 Claude 桌面版 (macOS) 提供完整简体中文汉化的开源项目。

## 技术栈

- Shell (Bash) - 安装/卸载脚本
- Python 3 - JSON 处理
- sed - JS 文件修补

## 项目结构

- `patches/` - 翻译补丁文件（核心）
- `install.sh` - 一键安装脚本
- `uninstall.sh` - 卸载脚本
- `docs/` - 文档目录

## 翻译文件说明

- `patches/zh-CN-layer-b.json` - Electron 主进程层（菜单、对话框等）
- `patches/zh-CN-layer-c.json` - Web 渲染器层（主聊天界面）
- `patches/zh-CN-layer-c-dynamic.json` - 动态内容（模型描述等）
- `patches/zh_CN.lproj.strings` - macOS 原生层

## 开发指南

### 修改翻译

1. 编辑 `patches/` 下的 JSON 文件
2. 保持 key 不变，只修改 value
3. 保持格式参数 `{name}` 和 HTML 标签 `<link>` 不变
4. 运行 `bash install.sh` 测试

### 测试

```bash
# 安装
bash install.sh

# 验证：在 Claude 设置中应能看到中文选项

# 卸载
bash uninstall.sh
```

## 关键决策

- 使用 JSON 哈希键格式（与 Claude 原始 i18n 格式一致）
- 修补前端 JS bundle 而非修改 app.asar（更简单、更安全）
- 翻译文件存储在 `~/.claude-locale/`（更新后可恢复）
