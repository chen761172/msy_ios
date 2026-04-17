# 陌速云手机 (msyui)

iOS原生应用，使用SwiftUI构建，支持WebView集成和第三方支付应用拉起功能。

## 功能特性

- 🌐 WebView集成，支持H5页面显示
- 💰 智能域名检测，自动拉起支付宝/微信支付应用
- 📱 支持iOS 15.0+
- 🔒 支持第三方代码签名

## 技术栈

- **语言**: Swift 5.0
- **框架**: SwiftUI, UIKit, WebKit
- **最低版本**: iOS 15.0
- **架构**: MVVM

## WebView支付功能

应用会自动检测以下域名和URL Scheme，并使用系统浏览器打开以拉起对应支付应用：

### 支付宝
- 域名: `alipay.com`, `alipay.cn` 及子域名
- URL Scheme: `alipay://`, `alipays://`

### 微信
- 域名: `weixin.qq.com`, `wx.qq.com` 及子域名
- URL Scheme: `weixin://`, `wechat://`, `wxpay://`

## GitHub Actions CI/CD

项目配置了自动化的CI/CD流程：

### 自动触发
- Push到`main`或`develop`分支
- Pull Request到`main`或`develop`分支

### 手动触发
在GitHub Actions页面选择"iOS CI"工作流，点击"Run workflow"

### CI/CD流程
1. **测试阶段**: 运行单元测试和UI测试
2. **编译阶段**: 构建iOS archive
3. **导出阶段**: 生成可给第三方签名的IPA包

### 下载IPA包
工作流运行成功后，在GitHub Actions页面可以下载：
- `msyui-ipa`: IPA文件（可用于第三方签名）
- `msyui-dsym`: 符号文件（用于崩溃分析）

## 配置第三方签名

如需在CI/CD中使用自己的签名证书，配置以下GitHub Secrets：

### 必需的Secrets
```
CERTIFICATE_BASE64:          p12格式的证书文件(base64编码)
CERTIFICATE_PASSWORD:        证书密码
PROVISIONING_PROFILE_BASE64: 配置文件.mobileprovision(base64编码)
```

### 生成Secret的步骤

#### 1. 导出证书为p12文件
```bash
# 在Keychain Access中导出证书为p12文件
# 记住设置的密码
```

#### 2. 转换为base64
```bash
# 证书
base64 -i certificate.p12 | pbcopy

# 配置文件
base64 -i profile.mobileprovision | pbcopy
```

#### 3. 在GitHub仓库中添加Secrets
1. 进入仓库Settings → Secrets and variables → Actions
2. 点击"New repository secret"
3. 添加上述三个secrets

## 本地开发

### 环境要求
- Xcode 16.0+
- iOS 15.0+ SDK
- CocoaPods (如果使用依赖管理)

### 编译运行
1. 克隆项目
```bash
git clone https://github.com/chen761172/msy_ios.git
cd msy_ios
```

2. 打开项目
```bash
open msyui.xcodeproj
```

3. 选择目标设备并运行

### 手动编译IPA
```bash
# 编译archive
xcodebuild archive \
  -project msyui.xcodeproj \
  -scheme msyui \
  -archivePath build/msyui.xcarchive \
  -destination 'generic/platform=iOS'

# 导出IPA
xcodebuild -exportArchive \
  -archivePath build/msyui.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist
```

## 第三方签名流程

### 使用第三方企业签名

#### 方法1: 使用第三方签名平台
1. 从GitHub Actions下载IPA文件
2. 上传到第三方签名平台（如：蒲公英、Fir.im等）
3. 签名完成后下载安装

#### 方法2: 本地重新签名
```bash
# 1. 解压IPA
unzip msyui.ipa -d temp

# 2. 替换配置文件
cp your_profile.mobileprovision temp/Payload/msyui.app/embedded.mobileprovision

# 3. 重新签名
codesign -f -s "Your Certificate Name" \
  --entitlements your_entitlements.plist \
  --generate-entitlement-der \
  temp/Payload/msyui.app

# 4. 重新打包
cd temp
zip -r ../msyui_resigned.ipa Payload/
cd ..
```

## 项目结构

```
msyui/
├── msyui.xcodeproj/          # Xcode项目文件
├── msyui/                     # 主应用源代码
│   ├── msyuiApp.swift        # 应用入口
│   ├── ContentView.swift     # 主视图和WebView实现
│   └── Assets.xcassets/      # 资源文件
├── msyuiTests/               # 单元测试
├── msyuiUITests/             # UI测试
├── Info.plist                # 应用配置
├── ExportOptions.plist       # 导出配置（开发用）
└── ExportOptionsThirdParty.plist # 导出配置（第三方签名用）
```

## 配置说明

### Info.plist配置
- `LSApplicationQueriesSchemes`: 允许查询支付宝和微信URL scheme
- `NSAppTransportSecurity`: 允许HTTP请求（开发环境）

### 签名配置
- 开发环境：使用自动签名（Automatic）
- 生产环境：配置相应的证书和配置文件

## 常见问题

### Q: 如何修改默认加载的URL？
A: 在`ContentView.swift`中修改`WebView`的URL参数

### Q: 如何添加其他域名的拦截？
A: 在`WebView.Coordinator.shouldOpenInExternalBrowser()`方法中添加域名检测逻辑

### Q: CI/CD编译失败怎么办？
A: 检查：
1. Xcode版本是否兼容
2. Bundle ID是否正确
3. 证书和配置文件是否有效

## 许可证

[请添加许可证信息]

## 联系方式

如有问题，请提交Issue或联系项目维护者。