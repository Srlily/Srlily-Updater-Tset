# 更新协议说明

本文描述 Srlily-Updater 与本测试应用之间的约定，便于实现与联调。

## 1. 清单文件

路径：安装根目录 `latest.json`

| 字段 | 说明 |
|------|------|
| `appId` | 应用唯一 ID，更新器用作本地注册键 |
| `channel` | `stable` / `beta` / `nightly` |
| `version` | 当前包版本（SemVer） |
| `releases.api` | GitHub Releases API |
| `releases.downloadPattern` | 便携包名模板，`{version}` `{rid}` 可被替换 |
| `releases.defaultRid` | 默认架构 RID（通常 `win-x64`） |
| `releases.architectures` | 按架构列出 portable / setup / msi 资产名 |
| `entry.executable` | 主程序文件名 |
| `checksum.algorithm` | 包校验算法（SHA256） |
| `checksum.file` | 校验清单文件名（`SHA256SUMS.txt`） |
| `paths.*` | 配置/语言/数据/插件/备份/暂存目录 |
| `updatePolicy.*` | 是否校验、是否原子替换、是否重启等 |

JSON Schema：`src/Srlily.UpdaterTset/Data/schema/latest.schema.json`

## 2. 检查更新

```
GET {releases.api}
→ 解析 tag_name（如 v1.0.1）与 assets
→ 与本地 version 比较
→ 若更新：下载 downloadPattern 匹配的 zip
```

## 3. 安装步骤（建议）

1. **下载** 到 `paths.staging`
2. **校验** `SHA256SUMS.txt` 中对应 zip 的 SHA256
3. **解压** 到 staging 子目录
4. **备份** 当前安装目录关键文件到 `paths.backup`
5. **原子替换** 安装根目录内容（先写临时目录再切换）
6. **校验** 新 `Srlily.UpdaterTset.exe --version` 输出
7. **重启** 主进程（`updatePolicy.restartAfterUpdate`）

## 4. 版本探测

更新器可用任一方式读取本地版本：

```powershell
# 程序集版本
.\Srlily.UpdaterTset.exe --version

# 清单版本
(Get-Content .\latest.json | ConvertFrom-Json).version

# 完整信息
.\Srlily.UpdaterTset.exe --info
```

## 5. 发布资产命名

每个版本、每个架构（`win-x64` / `win-arm64` / `win-x86`）均提供：

| 资产 | 说明 |
|------|------|
| `Srlily.UpdaterTset-v{version}-{rid}-portable.zip` | **便携包，就地更新用** |
| `Srlily.UpdaterTset-v{version}-{rid}-setup.exe` | Inno Setup 安装程序 |
| `Srlily.UpdaterTset-v{version}-{rid}.msi` | WiX MSI 安装包 |
| `SHA256SUMS.txt` | 全部资产哈希清单 |
| `latest.json` | 与包同版本的更新元数据 |

更新器应根据本机架构选择对应 `rid` 的 **portable.zip**；setup.exe / MSI 供用户首次安装。

Release **正文**来自 `CHANGELOG.md` 对应 `## [version]` 章节（即软件介绍）。

## 6. 联调建议场景

| 场景 | 做法 |
|------|------|
| 正常完整更新 | 安装 v1.0.0 → 发布 v1.0.1 → 检查并更新 |
| 增量/目录替换 | 只改 Locales 后发新版本，验证仅语言文件变化 |
| 校验失败 | 故意改坏 zip 哈希，确认更新器拒绝安装 |
| 中断恢复 | 下载中途杀进程，确认 staging 可清理重试 |
| 版本回退 | 本地版本高于远端，确认「已是最新」 |
