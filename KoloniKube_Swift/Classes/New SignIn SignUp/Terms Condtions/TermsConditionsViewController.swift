//
//  TermsConditionsViewController.swift
//  KoloniKube_Swift
//
//  Created by Tops on 18/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit
import WebKit

class TermsConditionsViewController: UIViewController {
    
    //MARK: - Outlet's
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var webView: WKWebView!
    
    //Variables
    var urlString = ""
    var titleStr = ""
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadSignUpHeaderView(view: self.headerView, headerTitle: self.titleStr, isBackBtnHidden: false)
        self.loadWebView()
    }
    
    //MARK: - Custom Function's
    
    func loadWebView(){
        let urlRequest = URLRequest(url: URL(string: self.urlString)!)
        self.webView.load(urlRequest)
    }
    
}

