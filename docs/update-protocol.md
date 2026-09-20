# 更新协议说明

本文描述 **Srlily-Updater** 与本测试应用之间的约定。

完整设计见更新器仓库：`Srlily-Updater/docs/update-design.md`。

## 0. 接入文件

| 文件 | 位置 | 作用 |
|------|------|------|
| `updater.config.json` | 安装根目录（随 portable.zip 分发） | 告诉更新器：feed、入口、版本来源、preserve |
| `latest.json` | 安装根目录 | 安装包身份（appId/version/entry/paths） |
| `channel.json` | **Release 资产 / Feed** | 远程更新源：version + 各 RID 资产 url/size/sha256 + notes |

更新器 CLI：

```powershell
Updater.exe --check --root <安装目录>   # exit 10 = 有更新，0 = 已最新
Updater.exe --apply --root <安装目录>   # exit 20 = 已更新
Updater.exe --silent --root <安装目录>  # 无 UI 静默更新
```

## 1. 清单文件 `latest.json`（安装身份）

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

更新器优先级：

```
CLI --feed  >  updater.config.json feed  >  latest.json.releases.api 推导
```

### 2a. 标准 HTTP Feed（推荐）

```
GET {feed.url}                    # 通常是 .../releases/latest/download/channel.json
→ 解析 ChannelFeed.assets[rid]
→ 与本地 version 比较
→ 下载 assets[rid].url（portable.zip）
→ 校验 sha256
```

`channel.json` 由 CI 生成并上传到 Release（`tools/new-channel-feed.ps1`）。

### 2b. GitHub Provider（兼容现有资产）

```
GET https://github.com/{repo}/releases/latest/download/channel.json
# 若不存在：
GET https://api.github.com/repos/{repo}/releases/latest
→ 用 assetPattern + RID 匹配 portable.zip
→ 下载 SHA256SUMS.txt 校验
```

## 3. 安装步骤（实现于 Updater 引擎）

1. **下载** 到 `paths.staging/download`
2. **校验** Feed 内联 sha256，或 `SHA256SUMS.txt`
3. **备份** preserve 规则 + 将被覆盖文件到 `paths.backup/{from}-{timestamp}`
4. **解压** 到 `paths.staging/extract`（防 Zip Slip）
5. **替换** 安装根目录（保留 preserve；可选删除孤儿文件）
6. **写入** `.srlily-updater/state.json`
7. **重启** 主进程（`policy.restartAfterUpdate`）
8. 失败时 **回滚** backup

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
