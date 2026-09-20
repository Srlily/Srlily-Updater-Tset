# Srlily Updater Test

用于测试 **Srlily-Updater** 更新功能的示例 Windows 桌面应用。

本仓库不是更新器本身，而是**更新目标应用**：它模拟真实软件的版本号、资源目录、配置、多语言与插件结构，方便验证下载、校验、原子替换、重启等完整更新链路。

## 功能特性

- 基于 **.NET 10** 的 WinForms 桌面程序
- 启动后展示版本、运行时、架构与更新通道信息
- 内置 **文件清单 / 本地化 / 配置** 三个检查页，便于对比更新前后差异
- CLI 模式支持 `--version`、`--info`、`--manifest`、`--files` 等命令，便于脚本化验收
- 根目录 `update-manifest.json` 描述更新协议元数据（发布 API、包名模板、校验算法、路径约定）
- GitHub Actions 自动构建；推送 `v*` 标签即发布带软件说明的 GitHub Release

## 目录结构

```
Srlily-Updater-Tset/
├── .github/workflows/          # CI / Release 自动化
├── src/Srlily.UpdaterTset/     # 主程序
│   ├── Config/                 # 应用与更新配置
│   ├── Locales/                # 多语言字符串
│   ├── Data/                   # 样例数据、模板、Schema
│   ├── Plugins/                # 插件描述
│   └── Assets/                 # 品牌与横幅资源
├── docs/                       # 架构与更新协议说明
├── tools/package.ps1           # 本地打包脚本
├── update-manifest.json        # 更新器可读的清单
├── CHANGELOG.md                # 版本说明（Release 正文来源）
└── Directory.Build.props       # 统一版本号
```

## 环境要求

- Windows 10/11 x64
- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)（本地构建）

## 快速开始

```powershell
# 还原并构建
dotnet build Srlily.UpdaterTset.sln -c Release

# 启动 GUI
dotnet run --project src/Srlily.UpdaterTset -c Release

# CLI：打印版本 / 清单 / 文件列表
.\src\Srlily.UpdaterTset\bin\Release\net10.0-windows\Srlily.UpdaterTset.exe --version
.\src\Srlily.UpdaterTset\bin\Release\net10.0-windows\Srlily.UpdaterTset.exe --manifest
.\src\Srlily.UpdaterTset\bin\Release\net10.0-windows\Srlily.UpdaterTset.exe --files
```

## 分发产物（多架构）

每个版本同时提供三种形态，覆盖常见桌面软件分发方式：

| 产物 | 命名 | 用途 |
|------|------|------|
| **setup.exe** | `Srlily.UpdaterTset-v{ver}-{rid}-setup.exe` | Inno Setup 安装向导，首次安装 |
| **MSI** | `Srlily.UpdaterTset-v{ver}-{rid}.msi` | WiX 5 企业/静默安装 |
| **portable.zip** | `Srlily.UpdaterTset-v{ver}-{rid}-portable.zip` | 便携包，**更新器就地替换用** |

支持架构：

| RID | 架构 |
|-----|------|
| `win-x64` | Windows x64 |
| `win-arm64` | Windows ARM64 |
| `win-x86` | Windows x86 |

另有 `checksums.sha256` 与 `update-manifest.json`。

> 更新器做增量/就地更新时请下载 **portable.zip**；setup.exe / MSI 面向首次安装。

## 本地打包

```powershell
# 仅 portable.zip
pwsh ./tools/package.ps1 -Version 1.0.1

# 多架构 + 安装包（需本机已装 Inno Setup 6；WiX 会自动安装）
pwsh ./tools/package.ps1 -Version 1.0.1 -Runtimes win-x64,win-arm64,win-x86 -IncludeInstallers
```

产物位于 `artifacts/`，并生成 `checksums.sha256`。

## 发布流程（自动构建）

1. 更新 `Directory.Build.props` 中的 `Version`
2. 更新 `update-manifest.json` 中的 `version`
3. 在 `CHANGELOG.md` 写入该版本说明（含「软件介绍」）
4. 提交并打标签推送：

```powershell
git tag -a v1.0.2 -m "Srlily Updater Test v1.0.2"
git push origin main --tags
```

GitHub Actions 会：

1. 对 `win-x64` / `win-arm64` / `win-x86` 分别 `dotnet publish`（自包含）
2. 为每个架构生成 **setup.exe（Inno Setup）**、**MSI（WiX）**、**portable.zip**
3. 汇总校验和，创建 GitHub Release（**正文自动取自 CHANGELOG 对应章节**）

## 作为 Srlily-Updater 测试目标

更新器可读取：

| 来源 | 用途 |
|------|------|
| `update-manifest.json` | 应用 ID、版本、架构资产表、发布 API、路径约定 |
| `Srlily.UpdaterTset.exe --version` | 校验本地当前版本 |
| GitHub Releases API | 获取最新版本与资产下载地址 |
| `checksums.sha256` | 校验包完整性 |
| `Config/` `Locales/` `Data/` `Plugins/` | 验证多类型文件替换是否完整 |

详细协议见 [docs/update-protocol.md](docs/update-protocol.md)。

## 许可证

MIT License，见 [LICENSE](LICENSE)。
