//
//  SignUpHeader.swift
//  KoloniKube_Swift
//
//  Created by Tops on 17/10/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class SignUpHeader: UIView {

    @IBOutlet weak var flagContainerView: CustomView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var backBtn_width: NSLayoutConstraint!
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var flagIcon_img: CustomView!
    
    
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
        if AppLocalStorage.sharedInstance.application_gradient{
            headerView?.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            headerView?.backgroundColor = CustomColor.primaryColor
        }
        headerView?.shadow(color: AppLocalStorage.sharedInstance.primary_color, radius: 4, opacity: 0.5)
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "flag_logo_img") { (image) in
            headerView?.flagIcon_img.image = image
        }
        headerView?.title_lbl.text = headerTitle
        if isBackBtnHidden{
            headerView?.back_btn.isHidden = true
            headerView?.backBtn_width.constant = 0
        }
        view.addSubview(headerView!)
        
    }
    
}
