//
//  SignUpHeader.swift
//  KoloniKube_Swift
//
//  Created by Tops on 17/10/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class SignUpHeader: UIView {

    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var backBtn_width: NSLayoutConstraint!
    @IBOutlet weak var title_lbl: UILabel!
//    @IBOutlet weak var flagContainerView: CustomView!
    
    var viewController =  UIViewController()
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.viewController.navigationController?.popViewController(animated: true)
    }
    
}

extension UIViewController{
    
    func loadSignUpHeaderView(view: UIView, headerTitle: String, isBackBtnHidden: Bool){
        
        let headerView = Bundle.main.loadNibNamed("SignUpHeader", owner: nil, options: [:])?.first as? SignUpHeader
        headerView?.frame = view.bounds
        headerView?.viewController = self
        headerView?.title_lbl.text = headerTitle
        if isBackBtnHidden{
            headerView?.back_btn.isHidden = true
            headerView?.backBtn_width.constant = 0
        }
        view.addSubview(headerView!)
        
    }
    
}
