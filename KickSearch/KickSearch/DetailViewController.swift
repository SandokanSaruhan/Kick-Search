//
//  DetailViewController.swift
//  KickSearch
//
//  Created by Saruhan Kole on 27.06.2019.
//  Copyright © 2019 Peartree Developers. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,UIWebViewDelegate {
  
 @IBOutlet var indicator: UIActivityIndicatorView!
    
  //Not in use
  @IBOutlet weak var detailDescriptionLabel: UILabel!
  @IBOutlet weak var detailPercentageLabel: UILabel!
  @IBOutlet weak var detailCountryLabel: UILabel!
  
  var detailConstant: Constant? {
    didSet {
      configureView()
    }
  }
  
  func configureView() {
    if let detailConstant = detailConstant {
      
        title = detailConstant.title
        
        let webView:UIWebView = UIWebView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height-2))
        self.view.addSubview(webView)
        webView.delegate = self
        let url = URL(string:String(format: "%@%@", "http://www.kickstarter.com", detailConstant.url))
        //let url = URL(string:"http://www.kickstarter.com")
        let urlRequest:URLRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest)
        
        print (detailConstant.percentageFunded)
        print (detailConstant.location)
        
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = view.center
        self.view.addSubview(indicator)
        self.view.bringSubviewToFront(indicator)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
    
   // MARK: - WebView Delegates
  func webViewDidStartLoad(_ webView: UIWebView)
  {
      indicator.startAnimating()
  }
    
  func webViewDidFinishLoad(_ webView: UIWebView)
  {
      indicator.stopAnimating()
      indicator .removeFromSuperview()
  }
  
}

