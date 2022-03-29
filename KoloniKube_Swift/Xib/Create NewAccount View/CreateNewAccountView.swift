//
//  CreateNewAccountView.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 05/07/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class CreateNewAccountView: UIView {

    @IBOutlet weak var description_lbl: UILabel!
    @IBOutlet weak var no_btn: CustomButton!
    @IBOutlet weak var yes_btn: CustomButton!
    
    var vc: UIViewController?
    
    //MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case no_btn:
            Global.appdel.setNavigationFlow()
            self.removeView()
            break
        case yes_btn:
            if let viewController = self.vc as? LoginWithPhoneOrEmailVC{
                viewController.check_secondary_contact = "0"
                viewController.loginWithEmailOrPhone()
            }else if let viewController = self.vc as? LoginWithGoogleAppleVC{
                viewController.check_secondary_contact = "0"
                viewController.socialLogin(user: viewController.shareUser)
            }
            self.removeView()
            break
        default:
            break
        }
        
    }
    
    func removeView(){
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.height
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
    func loadContent(){
        if AppLocalStorage.sharedInstance.application_gradient{
            self.yes_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.no_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.yes_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
            self.no_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
    }
    
}

extension UIViewController{
    func loadCreateAccountView(desc: String){
        if let view = Bundle.main.loadNibNamed("CreateNewAccountView", owner: nil, options: [:])?.first as? CreateNewAccountView{
            view.frame = self.view.bounds
            view.vc = self
            view.description_lbl.text = desc
            view.loadContent()
            self.view.addSubview(view)
            view.frame.origin.y += view.frame.height
            UIView.animate(withDuration: 0.5) {
                view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}
