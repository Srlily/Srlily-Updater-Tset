# Plugins

本目录用于放置可被更新器单独替换的插件描述文件。

## 约定

- 每个插件一个 JSON 文件：`{plugin-id}.json`
- 更新包可只包含 `Plugins/` 下的文件以实现热更新
- 主程序启动时扫描本目录（本测试应用仅展示清单，不加载真实 DLL）

## 示例

见 `sample-plugin.json`。
