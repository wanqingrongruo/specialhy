//
//  RNExpressShowViewController.swift
//  HoyoServicer
//
//  Created by roni on 2017/6/23.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNExpressShowViewController: UIViewController{
    
     var URLString:String?
     var tmpTitle:String?
    
    var webView: UIWebView!
    
    var button:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: tmpTitle, target: self, action: #selector(disMissBtn))]
        
        
        //重新加载按钮
        button=UIButton(frame: CGRect(x: 0, y: SCREEN_HEIGHT/2-40, width: SCREEN_WIDTH, height: 40))
        button.addTarget(self, action: #selector(loadAgain), for: .touchUpInside)
        button.setTitleColor(UIColor.gray, for: UIControlState())
        button.setTitle("加载失败,点击继续加载！", for: UIControlState())
        button.isHidden=true
      
        
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64))
        view.addSubview(webView)
        webView.delegate=self
        webView.scalesPageToFit = true
        webView.loadRequest(URLRequest(url: URL(string: URLString!)!))
        
        webView.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func disMissBtn(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //继续加载
    @objc func loadAgain(_ button:UIButton)
    {
        webView.loadRequest(URLRequest(url: URL(string: URLString!)!))
        
    }
}


extension RNExpressShowViewController: UIWebViewDelegate {
    
   
    func webViewDidStartLoad(_ webView: UIWebView) {
        button.isHidden=true
       
        RNHud().showHud(nil)
        self.perform(#selector(hideMbProgressHUD), with: nil, afterDelay: 3);
    }
    @objc func hideMbProgressHUD()
    {
       RNHud().hiddenHub()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
         RNHud().hiddenHub()
        button.isHidden=true
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
         RNHud().hiddenHub()
        button.isHidden=false
    }
    
}
