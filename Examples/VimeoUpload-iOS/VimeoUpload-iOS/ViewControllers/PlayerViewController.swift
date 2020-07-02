//
//  PlayerView.swift
//  VimeoUpload-iOS
//
//  Created by Diego on 7/2/20.
//  Copyright © 2020 Alfie Hanssen. All rights reserved.
//


import UIKit
import WebKit

class PlayerViewController: UIViewController {
    
    static let NibName = "PlayerViewController"
    private var webView: WKWebView!
    public let baseUrl = "https://player.vimeo.com/video/"
    public var video: VIMVideo?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.view.backgroundColor = .black
        self.navigationItem.title = title
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: makeBackButton())
        
        
        // Web view
        let webViewPrefs = WKPreferences()
        webViewPrefs.javaScriptEnabled = true
        webViewPrefs.javaScriptCanOpenWindowsAutomatically = true
        let webViewConf = WKWebViewConfiguration()
        webViewConf.preferences = webViewPrefs
        webViewConf.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: view.frame, configuration: webViewConf)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.keyboardDismissMode = .onDrag
        view.addSubview(webView)
        webView.navigationDelegate = self
        
        let text:String = self.video!.link!
        
        let start = text.lastIndex(of: "/") ?? text.startIndex
        var videoId = text[start...]
        videoId.remove(at: videoId.startIndex)
        
        // Load url
        load(url: baseUrl + videoId + "?byline=false")
    }
    
    
    private func load(url: String) {
        print(url)
        webView.load(URLRequest(url: URL(string: url)!))
    }
    
    
     func makeBackButton() -> UIButton {
            let backButtonImage = UIImage(named: "backbutton")?.withRenderingMode(.alwaysTemplate)
            let backButton = UIButton(type: .custom)
            backButton.setImage(backButtonImage, for: .normal)
            backButton.tintColor = .blue
            backButton.setTitle("  Back", for: .normal)
            backButton.setTitleColor(.blue, for: .normal)
            backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
            return backButton
        }

        @objc func backButtonPressed() {
            dismiss(animated: true, completion: nil)
    //        navigationController?.popViewController(animated: true)
        }
    
}


// MARK: - WKNavigationDelegate
extension PlayerViewController: WKNavigationDelegate {
    
    // Finish
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
     
    }
    
    // Start
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
     
    }
    
    // Error
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        
    }
}
