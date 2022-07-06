//
//  termsCondViewController.swift
//  TIK TIK
//
//  Created by Mac on 29/10/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import WebKit

class termsCondViewController:UIViewController,WKUIDelegate,WKNavigationDelegate {
    
    
    //MARK:- Outlets
    @IBOutlet weak var webViewDisplay: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var vcTitle: UILabel!
    
    var privacyDoc = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.WeblinkView()
    }
    
    //MARK:- DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK:- Switch Action
    func WeblinkView(){
         if AppUtility!.connected() == false{
            return
        }
        
        var url = URL(string: "https://www.freeprivacypolicy.com/live/63ea2c65-c86a-408a-b12a-35afeec613dd")!
        
        if privacyDoc == false{
         url = URL(string: "https://www.freeprivacypolicy.com/live/63ea2c65-c86a-408a-b12a-35afeec613dd")!
            
            vcTitle.text = "Terms & Conditions"
        }

        self.webViewDisplay.load(URLRequest(url: url))
        self.webViewDisplay.navigationDelegate = self
    }
    //MARK: WebView
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
//        self.activityIndicator.stopAnimating()
        
        AppUtility?.stopLoader(view: self.view)
        
        let alert  = UIAlertController(title: nil, message: "Please reload the page", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert:UIAlertAction) in
            self.webViewDisplay.reload()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
//        self.activityIndicator.startAnimating()
        
        AppUtility?.startLoader(view: self.view)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
//        self.activityIndicator.stopAnimating()
        AppUtility?.stopLoader(view: self.view)
    }

    
    //MARK:- View Life Cycle End here...
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
