//
//  ContentView.swift
//  msyui
//
//  Created by 谢天磊 on 20/1/26.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.bounces = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct ContentView: View {
    var body: some View {
        WebView(url: URL(string: "https://sys-cloud-nt.msyui.com/ht/pages/login/index")!)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
