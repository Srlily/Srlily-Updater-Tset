# Srlily Updater Test

用于测试 **Srlily-Updater** 更新功能的示例 Windows 桌面应用。

本仓库不是更新器本身，而是**更新目标应用**：它模拟真实软件的版本号、资源目录、配置、多语言与插件结构，方便验证下载、校验、原子替换、重启等完整更新链路。

## 功能特性

- 基于 **.NET 10** 的 WinForms 桌面程序
- 启动后展示版本、运行时、架构与更新通道信息
- 内置 **文件清单 / 本地化 / 配置** 三个检查页，便于对比更新前后差异
- CLI 模式支持 `--version`、`--info`、`--manifest`、`--files` 等命令，便于脚本化验收
- 根目录 `latest.json` 描述更新元数据（发布 API、包名模板、校验算法、路径约定）
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
├── latest.json                 # 更新器可读的清单
├── CHANGELOG.md                # 版本说明（Release 正文来源）
├── Directory.Build.props       # 统一版本号
├── SHA256SUMS.txt              # 构建后生成（发布资产）
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

另有 `SHA256SUMS.txt` 与 `latest.json`。

> 更新器做增量/就地更新时请下载 **portable.zip**；setup.exe / MSI 面向首次安装。

## 本地打包

```powershell
# 仅 portable.zip
pwsh ./tools/package.ps1 -Version 1.0.1

# 多架构 + 安装包（需本机已装 Inno Setup 6；WiX 会自动安装）
pwsh ./tools/package.ps1 -Version 1.0.1 -Runtimes win-x64,win-arm64,win-x86 -IncludeInstallers
```

产物位于 `artifacts/`，并生成 `SHA256SUMS.txt`。

## 发布流程（自动构建）

1. 更新 `Directory.Build.props` 中的 `Version`
2. 更新 `latest.json` 中的 `version`
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

本仓库已接入 [Srlily-Updater](https://github.com/Srlily/Srlily-Updater)：

| 文件 | 作用 |
|------|------|
| `src/Srlily.UpdaterTset/updater.config.json` | 宿主接入配置（github feed + preserve 等） |
| `latest.json` | 安装包身份（版本 / 入口 / 资产命名） |
| 主界面「检查更新」/「更新界面」 | 应用内调用 Updater.exe |
| CLI `--check-update` / `--apply-update` / `--update-ui` | 脚本化触发 |
| `tools/run-updater.ps1` | 一键调用更新器 |
| `tools/new-channel-feed.ps1` | 生成 `channel.json` 远程 Feed |
| Release 资产 `channel.json` | 更新器读取的远程元数据（CI 自动生成） |

### 使用更新器

```powershell
# 1) 准备 Updater.exe（二选一）
$env:SRLILY_UPDATER = "E:\Github\Srlily-Updater\dist\Updater.exe"
# 或复制到安装目录: <root>\updater\Updater.exe

# 2) 准备一份安装目录（含 updater.config.json + latest.json）
#    可解压 portable.zip，或自行 publish 到测试目录

# 3) 应用内 / CLI
cd C:\Apps\SrlilyUpdaterTest
.\Srlily.UpdaterTset.exe --check-update
.\Srlily.UpdaterTset.exe --update-ui

# 或外部脚本
pwsh ./tools/run-updater.ps1 -InstallRoot C:\Apps\SrlilyUpdaterTest -Mode check
pwsh ./tools/run-updater.ps1 -InstallRoot C:\Apps\SrlilyUpdaterTest -Mode silent
pwsh ./tools/run-updater.ps1 -InstallRoot C:\Apps\SrlilyUpdaterTest -Mode ui
```

退出码：`0` 已最新/成功 · `10` 有更新 · `20` 已更新 · 其他为错误。

更新器可读取：

| 来源 | 用途 |
|------|------|
| `updater.config.json` | feed 类型、入口、preserve、策略 |
| `latest.json` | 本地版本、appId、fallback 资产模板 |
| `channel.json`（Release） | 远端版本 + portable.zip URL + SHA256 + notes |
| GitHub Releases API | 无 channel.json 时的回退源 |
| `SHA256SUMS.txt` | 包完整性校验 |
| `Config/` `Locales/` `Data/` `Plugins/` | 验证多类型文件替换是否完整 |

详细协议见 [docs/update-protocol.md](docs/update-protocol.md) 与更新器仓库 `docs/update-design.md`。

## 许可证

MIT License，见 [LICENSE](LICENSE)。
