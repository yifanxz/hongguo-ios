# 红果短剧 · iPhone 客户端（A 方案）

WKWebView 壳 + Swift 原生桥，复用 [jackotom/hongguo-drama](https://github.com/jackotom/hongguo-drama) 的纯 JS 业务层（签名 / 目录 / 搜索 / 解密），
移植范式照其安卓版（WebView 壳 + Native 桥）。GPL-3.0。

交付形态：**未签名 IPA**，装入 [LiveContainer](https://github.com/LiveContainer/LiveContainer) 运行，不占免费账号 App 名额、无 7 天过期。

## 当前状态

- v0.1 空壳：WKWebView + JS↔Swift 桥（ping / echo / getInfo）+ 内置诊断页。
  目的只有一个：在 LiveContainer 里验通「壳能启动、WebView 能跑、桥能通」。

## 构建

云端：推到 GitHub 后 Actions（macos-26）自动构建，产物在 Artifacts 里下载 `Hongguo-unsigned.ipa`。

本地（需 Xcode + XcodeGen）：

```sh
brew install xcodegen
xcodegen generate
xcodebuild build -project Hongguo.xcodeproj -scheme Hongguo \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""
```

## 设计约束（LiveContainer）

- 单 App，无 App Extension、无推送、无 App Groups / 后台模式等 entitlements 依赖。
- 最低 iOS 15.0。
