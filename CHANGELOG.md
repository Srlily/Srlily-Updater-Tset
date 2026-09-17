# Changelog

本文件的版本章节会被 GitHub Release 工作流用作发布说明正文。

推荐结构（直接进入条目；没有内容的小节**整节省略**，不要写「（无）」）：

- `### 新增` — 新功能 / 新产物
- `### 修复` — 缺陷修复
- `### 优化` — 体验、性能、流程改进

格式参考 [Keep a Changelog](https://keepachangelog.com/1.1.0/)。

## [1.0.8] - 2026-02-14

### 修复

- 修复 setup.exe 编译失败：`Unknown language name "chinesesimplified"`
  - 原因：在 `[CustomMessages]` 使用内置语言 id 作前缀，与自定义 `MessagesFile` 冲突
  - 原因：`[Languages]` 误写为 `[[Languages]`
- 语言 Name 改为唯一的 `simplifiedchinese`，中文文案移入语言文件的 `[CustomMessages]`

### 优化

- 无前缀 `[CustomMessages]` 作为英文默认；各语言文件可覆盖

## [1.0.7] - 2026-02-14

### 新增

- Inno Setup 简体中文语言文件补全 `[Messages]` 完整向导文案（欢迎页、目录、进度、完成、错误等）

### 修复

- 修复安装界面显示为英文的问题：`ChineseSimplified.isl` 改为 **UTF-8 with BOM**，`LanguageName=简体中文` 可被正确识别
- 修复语言选择列表出现两个 “English”：无 BOM 时中文名无法解析，条目回退为英文

### 优化

- 中文列为默认第一语言，zh-CN 系统会优先选中简体中文
- 开始菜单「打开安装目录」按当前语言显示

## [1.0.6] - 2026-02-14

### 新增

- Release 正文结构固定为「新增 / 修复 / 优化 + 下载说明」，版本下不再输出概述句

### 修复

- 去掉版本下的一句话概述，避免与「修复 / 优化」条目重复
- git tag 注解改为极简短句，不再复述 Release 正文

### 优化

- 打标签时只保留版本号与一句摘要，详细说明以 GitHub Release 正文为准

## [1.0.5] - 2026-02-14

### 新增

- 下载表体积按 B / KB / MB 自动选择单位（小文件不再显示为 `0 MB`）
- 下载说明补充「如何选择」与「版本信息」完整段落（修复换行被压成一行）
- 明确 `update-manifest.json` 用途：供更新器免解压读取版本与架构资产名

### 修复

- 修复 CHANGELOG 抽取失败：正则未启用多行模式，`^` 只匹配文件开头，导致 Release 回退到空模板并出现「本版本无相关条目」
- 修复「如何选择 / 版本信息」在 Release 正文中变成一整行：PowerShell 运算符优先级导致 `-join` 作用域错误
- 发布说明改为 `List[string]` 逐行写入并以 LF 拼接，避免 YAML/脚本缩进与换行再次被破坏

### 优化

- 移除单独的「软件介绍」章节，改为版本下的一句话概述，结构更接近常见更新日志
- 仅在 CHANGELOG 确实缺少某节时，才补「本版本无相关条目」，不再覆盖真实条目
- 下载表保留，类型说明更清晰（安装向导 / MSI / 便携包 / 校验和 / 更新清单）

## [1.0.4] - 2026-02-14

修复 v1.0.3 未能创建 GitHub Release 的问题，并恢复多架构安装包自动发布。

### 新增

- （无新功能，本版本恢复发布流水线）

### 修复

- 重写 Release 正文生成逻辑，去掉会破坏 YAML 缩进的 PowerShell here-string
- v1.0.3 标签存在但无 Release 的根因：工作流文件解析失败，0 个 Job 启动

### 优化

- 发布说明生成改用字符串数组拼接，避免 YAML 字面块与脚本缩进冲突
- setup.exe 文件名继续使用正确的 `/F` 参数（无前导 `=`）

## [1.0.3] - 2026-02-14

修正安装包文件名，并让 Release 正文默认带完整结构与下载对照表。

### 新增

- Release 说明自动生成下载对照表：文件、类型、体积
- Release 说明自动补齐「新增 / 修复 / 优化」结构
- 增加「如何选择」指引：首次安装用 setup.exe/MSI，就地更新用 portable.zip

### 修复

- 修复 Inno Setup 输出文件名多出前导 `=` 的问题
  - 原因：ISCC 的 `/F` 写成了 `/F=文件名`
  - 现状：改为 `/F文件名`，产物名为 `Srlily.UpdaterTset-v{ver}-{rid}-setup.exe`
- 同步修正 CI（`release.yml`）与本地脚本（`tools/package.ps1`）

### 优化

- 统一安装包 / 便携包命名约定，便于更新器按 `{version}-{rid}` 匹配资产
- 中文安装向导语言文件随仓库分发，降低对 CI 环境的依赖

## [1.0.2] - 2026-02-14

修复 CI 上 Inno Setup 缺少中文语言包导致 setup.exe 编译失败的问题。

### 新增

- （无新功能）

### 修复

- 自带 `installer/Languages/ChineseSimplified.isl`，不再依赖 runner 语言包
- 解决 `Couldn't open include file ChineseSimplified.isl` 导致的 Release 失败

### 优化

- 安装向导仍提供中英双语，CI 构建稳定性提升

## [1.0.1] - 2026-02-14

对齐真实桌面软件分发形态：多架构 setup.exe / MSI / portable.zip。

### 新增

- 多架构发布矩阵：`win-x64`、`win-arm64`、`win-x86`
- Inno Setup 安装包 `*-setup.exe`（开始菜单、可选桌面图标、中英文向导）
- WiX 5 MSI 安装包 `*.msi`（per-machine、MajorUpgrade）
- 便携包统一命名为 `*-portable.zip`
- `update-manifest.json` 增加 `releases.architectures` 与 `defaultRid`
- `tools/package.ps1` 支持多 RID 与 `-IncludeInstallers`

### 修复

- （无）

### 优化

- 更新器就地更新使用 portable.zip；首次安装可选 setup.exe 或 MSI
- 发布资产命名更贴近真实桌面软件分发习惯

## [1.0.0] - 2026-02-14

首个版本：.NET 10 更新目标示例应用。

### 新增

- WinForms 主界面（概览 / 文件清单 / 本地化 / 配置）
- CLI：`--version`、`--info`、`--manifest`、`--files`、`--locale`、`--config`
- `update-manifest.json` 更新协议元数据
- 多语言资源：zh-CN / en-US / ja-JP / ko-KR
- 配置、数据、模板、Schema、插件等多类型内容文件
- GitHub Actions：标签触发构建与 Release
- 本地打包脚本 `tools/package.ps1`

### 修复

- （无）

### 优化

- 定位为更新目标测试应用，配合 Srlily-Updater 的 staging / backup / atomic replace 使用
