//
//  RNWebUrlViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNWebUrlViewController: UIViewController {
    
    
    var url: String
    var myTitle: String
    
    init(url u: String, title t: String) {
        self.url = u
        self.myTitle = t
    
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var webView: UIWebView!
    var button: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: myTitle, target: self, action: #selector(dismissFromVC))]
        
        setUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RNWebUrlViewController{
    
    func setUI() {
        
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        webView.scalesPageToFit = true
        webView.delegate = self
        view.addSubview(webView)
        
        button = UIButton(type: .custom)
        button?.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button?.center = view.center
        button?.setTitle("加载失败,点击重新加载", for: .normal)
        button?.isHidden = true
        button?.setTitleColor(UIColor.gray, for: .normal)
        button?.addTarget(self, action: #selector(loadAgain), for: .touchUpInside)
        webView.addSubview(button!)
        
        
        if let u = URL(string: url){
            let r = URLRequest(url: u)
            webView.loadRequest(r)
        }else{
            button?.isHidden = false
            RNNoticeAlert.showError("提示", body: "链接格式不正确,无法打开")
        }
        
    }
    
    @objc func loadAgain() -> Void {
        
        if let u = URL(string: url){
            let r = URLRequest(url: u)
            webView.loadRequest(r)
        }else{
            button?.isHidden = false
            RNNoticeAlert.showError("提示", body: "链接格式不正确,无法打开")
        }
    }
    
    @objc func dismissFromVC() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RNWebUrlViewController: UIWebViewDelegate{
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        button?.isHidden = true
        RNHud().showHud(nil)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        button?.isHidden = true
        RNHud().hiddenHub()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        RNHud().hiddenHub()
        button?.isHidden = false
    }
}
