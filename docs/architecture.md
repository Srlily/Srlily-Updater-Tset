# 架构说明

## 定位

`Srlily-Updater-Tset` 是 **更新目标应用（update target）**，不是更新器本体。它的职责是：

1. 以真实桌面应用形态提供可安装、可替换的文件树
2. 暴露稳定的版本与清单接口，供 Srlily-Updater 读取
3. 让测试者在更新前后对比「哪些文件被替换、是否完整」

## 模块

```
Program.cs          入口：无参启动 GUI，有参走 CLI
MainForm.cs         主界面：概览 / 文件清单 / 本地化 / 配置
Models/AppInfo.cs   版本与 latest.json 反序列化模型
Services/           Config、Locale、FileInventory 辅助
Config/             appsettings 与更新规则
Locales/            多语言 JSON
Data/               样例数据、XML 模板、CSV、JSON Schema
Plugins/            插件描述（可单独热替换）
Assets/             品牌元数据与横幅文本
```

## 版本来源

| 字段 | 来源 |
|------|------|
| `Version` / `FileVersion` | `Directory.Build.props` → 程序集 |
| 清单 `version` | `latest.json` |
| Release 标签 | Git tag `vX.Y.Z`（CI 同步回写上述两者） |

应用内展示的版本以**程序集**为准；更新器检查远端版本时以 **Release 标签 / manifest** 为准。

## 内容文件为何要「各种各样」

更新器最容易在下列场景出问题，因此测试包刻意覆盖：

- 可执行文件（`Srlily.UpdaterTset.exe` 及依赖）
- JSON 配置（Config）
- 多语言 JSON（Locales）
- 结构化数据（Data/*.json）
- XML（Data/templates.xml）
- CSV（Data/sample-dictionary.csv）
- JSON Schema（Data/schema）
- Markdown（README / Plugins/README）
- 纯文本（Assets/banner.txt）
- 元数据 JSON（latest.json）

替换后应用应仍能 `--version` 成功，且文件清单数量与内容符合新版本预期。

## GUI 与 CLI

- GUI：人工目视对比
- CLI：自动化脚本在更新器退出后执行 `--version` / `--files` 做断言
