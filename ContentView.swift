//
//  ContentView.swift
//  msyui
//
//  Created by 谢天磊 on 20/1/26.
//

import SwiftUI
import WebKit
import UIKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView,
                    decidePolicyFor navigationAction: WKNavigationAction,
                    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // 检测是否是支付宝或微信相关的域名
            if shouldOpenInExternalBrowser(url) {
                openInExternalBrowser(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }

        private func shouldOpenInExternalBrowser(_ url: URL) -> Bool {
            // 检查URL Scheme
            if let scheme = url.scheme {
                let externalSchemes = ["alipay", "alipays", "weixin", "wechat", "wxpay"]
                if externalSchemes.contains(scheme.lowercased()) {
                    return true
                }
            }

            // 检查域名
            if let host = url.host {
                let lowercasedHost = host.lowercased()

                // 支付宝相关域名
                if lowercasedHost.contains("alipay.com") ||
                   lowercasedHost.contains("alipay.cn") ||
                   lowercasedHost.hasSuffix("alipay.com") ||
                   lowercasedHost.hasSuffix("alipay.cn") {
                    return true
                }

                // 微信相关域名
                if lowercasedHost.contains("weixin.qq.com") ||
                   lowercasedHost.contains("wx.qq.com") ||
                   lowercasedHost.hasSuffix("weixin.qq.com") ||
                   lowercasedHost.hasSuffix("wx.qq.com") ||
                   lowercasedHost.contains("wxpay") {
                    return true
                }
            }

            return false
        }

        private func openInExternalBrowser(_ url: URL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        WebView(url: URL(string: "https://cld-sfdr-rsm.msyui.com/ht/pages/login/index")!)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
