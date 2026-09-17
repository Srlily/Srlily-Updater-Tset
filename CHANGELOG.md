# Changelog

本文件的版本章节会被 GitHub Release 工作流用作**软件介绍 / 发布说明**正文。

每个版本请尽量包含以下小节（工作流会补齐缺失小节）：

- `### 软件介绍` — 这个版本是什么、解决什么问题
- `### 新增` — 新功能 / 新产物 / 新接口
- `### 修复` — 缺陷修复
- `### 优化` — 体验、性能、流程改进

格式参考 [Keep a Changelog](https://keepachangelog.com/1.1.0/)。

## [1.0.3] - 2026-02-14

### 软件介绍

Srlily Updater Test v1.0.3 修正安装包文件名，并让 GitHub Release 正文默认带上完整的「新增 / 修复 / 优化」结构与下载对照表，便于测试者直接按架构选用 setup.exe、MSI 或 portable.zip。

### 新增

- Release 说明自动生成下载对照表：按文件列出类型（安装向导 / MSI / 便携包 / 校验和 / 清单）与体积
- Release 说明自动补齐「软件介绍 / 新增 / 修复 / 优化」四段结构，避免条目缺失时正文空白
- 增加「如何选择」指引：首次安装用 setup.exe/MSI，更新器就地更新用 portable.zip

### 修复

- 修复 Inno Setup 输出文件名多出前导 `=` 的问题  
  原因：ISCC 的 `/F` 参数写成了 `/F=文件名`，Inno 会把 `=` 一并写入 OutputBaseFilename  
  现状：改为 `/F文件名`，产物名恢复为 `Srlily.UpdaterTset-v{ver}-{rid}-setup.exe`
- 同步修正 CI（`release.yml`）与本地脚本（`tools/package.ps1`）中的同类调用

### 优化

- 统一安装包 / 便携包命名约定，便于更新器按 `{version}-{rid}` 模板匹配资产
- 中文安装向导语言文件随仓库分发，降低对 CI 运行环境的依赖

## [1.0.2] - 2026-02-14

### 软件介绍

Srlily Updater Test v1.0.2 修复 CI 上 Inno Setup 缺少中文语言包导致 setup.exe 编译失败的问题。现已将 `ChineseSimplified.isl` 随仓库分发，三架构安装包可稳定构建。

### 新增

- （无新功能）

### 修复

- 自带 `installer/Languages/ChineseSimplified.isl`，不再依赖 GitHub Actions runner 上的 Inno 语言包
- 解决 `Couldn't open include file ChineseSimplified.isl` 导致的 Release 失败

### 优化

- 安装向导仍提供中英双语，CI 构建稳定性提升

## [1.0.1] - 2026-02-14

### 软件介绍

Srlily Updater Test v1.0.1 对齐真实桌面软件分发形态：提供 **setup.exe（Inno Setup）**、**MSI（WiX 5）** 与 **portable.zip** 三类产物，并同时支持 **win-x64 / win-arm64 / win-x86** 三种架构。portable.zip 供更新器就地替换；setup.exe / MSI 用于首次安装。

### 新增

- 多架构发布矩阵：`win-x64`、`win-arm64`、`win-x86`
- Inno Setup 安装包 `Srlily.UpdaterTset-v{ver}-{rid}-setup.exe`（开始菜单、可选桌面图标、中英文向导）
- WiX 5 MSI 安装包 `Srlily.UpdaterTset-v{ver}-{rid}.msi`（per-machine、MajorUpgrade）
- 便携包统一命名为 `*-portable.zip`，与安装包区分
- `update-manifest.json` 增加 `releases.architectures` 与 `defaultRid`
- `tools/package.ps1` 支持多 RID 与 `-IncludeInstallers`

### 修复

- （无）

### 优化

- 更新器就地更新请使用 **portable.zip**；首次安装可选 setup.exe 或 MSI
- 发布资产命名更贴近真实桌面软件分发习惯

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

### 修复

- （无）

### 优化

- 本仓库为**更新目标测试应用**，不包含更新器实现
- 推荐配合 Srlily-Updater 的 staging / backup / atomic replace 流程使用
