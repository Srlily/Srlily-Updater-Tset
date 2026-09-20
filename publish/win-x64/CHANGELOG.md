# Changelog

本文件的版本章节会被 GitHub Release 工作流用作**软件介绍 / 发布说明**正文。

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [1.0.1] - 2026-02-14

### 软件介绍

Srlily Updater Test v1.0.1 对齐真实桌面软件分发形态：提供 **setup.exe（Inno Setup）**、**MSI（WiX 5）** 与 **portable.zip** 三类产物，并同时支持 **win-x64 / win-arm64 / win-x86** 三种架构。portable.zip 供更新器就地替换；setup.exe / MSI 用于首次安装。

### 新增

- 多架构发布矩阵：`win-x64`、`win-arm64`、`win-x86`
- Inno Setup 安装包 `Srlily.UpdaterTset-v{ver}-{rid}-setup.exe`（含开始菜单、可选桌面图标、中英文向导）
- WiX 5 MSI 安装包 `Srlily.UpdaterTset-v{ver}-{rid}.msi`（per-machine、MajorUpgrade）
- 便携包统一命名为 `*-portable.zip`，便于与安装包区分
- `update-manifest.json` 增加 `releases.architectures` 与 `defaultRid`
- `tools/package.ps1` 支持多 RID 与 `-IncludeInstallers`

### 说明

- 更新器就地更新请使用 **portable.zip**
- 首次安装用户可选用 setup.exe 或 MSI

## [1.0.0] - 2026-02-14

### 软件介绍

Srlily Updater Test 是用于验证 [Srlily-Updater](https://github.com/Srlily/Srlily-Updater) 完整更新链路的示例桌面应用。它模拟真实软件的版本管理、资源目录与多类型文件结构，覆盖下载、SHA256 校验、原子替换与重启等场景。

### 新增

- 基于 .NET 10 的 WinForms 主界面（概览 / 文件清单 / 本地化 / 配置）
- CLI 模式：`--version`、`--info`、`--manifest`、`--files`、`--locale`、`--config`
- `update-manifest.json` 更新协议元数据
- 多语言资源：zh-CN / en-US / ja-JP / ko-KR
- 配置、数据、模板、Schema、插件描述等多类型内容文件
- GitHub Actions：标签触发自动构建与带说明的 Release
- 本地打包脚本 `tools/package.ps1`

### 说明

- 本仓库为**更新目标测试应用**，不包含更新器实现
- 推荐配合 Srlily-Updater 的 staging / backup / atomic replace 流程使用
