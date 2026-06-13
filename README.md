# 28周身材皮肤计划 PWA

这是手机网页/PWA 发布目录。发布后，iPhone 用 Safari 打开在线网址，可以通过“分享 → 添加到主屏幕”保存成类似 App 的入口。

## 文件说明

- `index.html`：最新版入口，手机日常只打开这个。
- `manifest.webmanifest`：PWA 元信息。
- `service-worker.js`：缓存最新版页面，便于弱网时打开最近版本。
- `versions/2026-06-13/index.html`：本次历史版本。
- `CHANGELOG.md`：版本更新记录。

## 免费发布建议

优先用 Cloudflare Pages 或 GitHub Pages，把整个 `fitness-skin-plan-pwa` 目录作为静态网站发布。发布完成后，手机端只保存平台给出的在线网址。

本机当前没有可用的 `git` 命令，因此未自动创建 GitHub Pages 仓库或推送代码。
