//
//  WebViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 5/5/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    @IBOutlet var webview: UIWebView!
    var pagetitle:String! = ""
    var url:String! = ""
    override func viewDidLoad() {
        super.viewDidLoad()





    }

    override func viewWillAppear(animated: Bool){
        self.title = pagetitle
        let url = NSURL (string:self.url);
        let requestObj = NSURLRequest(URL: url!);
        self.webview.loadRequest(requestObj);
        
    }
}
