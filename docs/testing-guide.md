# 测试指南

## 准备

1. 安装目标机器：Windows 10/11 x64
2. 安装 Srlily-Updater（或你的更新器实现）
3. 从 [Releases](https://github.com/Srlily/Srlily-Updater-Tset/releases) 下载某一版本 zip 并解压到测试目录，例如：

```
C:\Apps\SrlilyUpdaterTest\
  Srlily.UpdaterTset.exe
  latest.json
  Config\ ...
  Locales\ ...
```

4. 记录基线：

```powershell
cd C:\Apps\SrlilyUpdaterTest
.\Srlily.UpdaterTset.exe --version
.\Srlily.UpdaterTset.exe --files > files-before.txt
```

## 场景 A：标准更新

1. 确认本地版本 < 最新 Release
2. 启动更新器，指向本应用安装目录（目录内含 `updater.config.json` + `latest.json`）：

```powershell
# 检查
Updater.exe --check --root C:\Apps\SrlilyUpdaterTest
# 有更新时 exit=10

# 更新（静默，适合脚本）
Updater.exe --silent --root C:\Apps\SrlilyUpdaterTest
# 成功 exit=20

# 或打开 UI
Updater.exe --root C:\Apps\SrlilyUpdaterTest
```

3. 验收：

```powershell
.\Srlily.UpdaterTset.exe --version   # 应等于新版本
.\Srlily.UpdaterTset.exe --files > files-after.txt
# 对比 files-before / files-after
```

5. GUI 应能启动，「概览」页版本号为新版本

## 场景 B：多类型文件完整性

更新后检查下列路径均存在且内容为新版本：

- `Config/appsettings.json`
- `Locales/zh-CN.json`（及 en-US / ja-JP / ko-KR）
- `Data/samples.json`
- `Data/templates.xml`
- `Data/sample-dictionary.csv`
- `Data/schema/latest.schema.json`
- `Plugins/sample-plugin.json`
- `Assets/banner.txt`
- `latest.json`（version 已更新）

## 场景 C：CLI 自动化

```powershell
# 更新器进程退出码为 0 后
$v = & .\Srlily.UpdaterTset.exe --version
if ($v.Trim() -ne "1.0.1") { throw "version mismatch: $v" }

& .\Srlily.UpdaterTset.exe --manifest | ConvertFrom-Json | Select-Object -ExpandProperty version
```

## 场景 D：异常

- 将 `SHA256SUMS.txt` 中哈希改错 → 应拒绝安装
- 下载中途断网 → 应可重试且不破坏现有安装
- 磁盘只读目录 → 应报错且可回滚

## 场景 E：发一个新测试版本

```powershell
# 1. 改版本
#    Directory.Build.props + latest.json + CHANGELOG.md
# 2. 提交
git add -A
git commit -m "chore: bump to 1.0.1"
# 3. 打标签并推送
git tag -a v1.0.1 -m "Srlily Updater Test v1.0.1"
git push origin main --tags
```

等待 Actions 的 Release 任务完成后即可作为更新源。
