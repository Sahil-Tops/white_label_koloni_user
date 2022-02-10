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
    
}

extension UIViewController{
    func loadCreateAccountView(desc: String){
        if let view = Bundle.main.loadNibNamed("CreateNewAccountView", owner: nil, options: [:])?.first as? CreateNewAccountView{
            view.frame = self.view.bounds
            view.vc = self
            view.description_lbl.text = desc
            self.view.addSubview(view)
            view.frame.origin.y += view.frame.height
            UIView.animate(withDuration: 0.5) {
                view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}
