//
//  VerifyEmailView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 11/12/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class VerifyEmailView: UIView {

    @IBOutlet weak var updateEmail_lbl: UILabel!
    @IBOutlet weak var enterEmail_textField: EZTextField!
    @IBOutlet weak var cancel_btn: UIButton!
    @IBOutlet weak var verify_btn: UIButton!
    
    var vc = UIViewController()
    
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case cancel_btn:
            UIView.animate(withDuration: 0.5, animations: {
                self.frame.origin.y = (self.frame.origin.y + self.frame.height)
                self.layoutIfNeeded()
            }) { (_) in
                self.removeFromSuperview()
            }
        case verify_btn:
            if self.enterEmail_textField.isEmptyTextField(){
                self.vc.showTopPop(message: "Please enter an email", response: false)
            }else{
                self.loginWithEmail()
            }
        default:
            break
        }
    }

}

//MARK: - Web Api
extension VerifyEmailView{
    func loginWithEmail(){
        let params: [String:Any] = ["user_id": StaticClass.sharedInstance.strUserId, "check_secondary_contact": "0", "email_id": self.enterEmail_textField.text!, "send_from_profile": "1", "device_type": "1", "device_token": StaticClass.sharedInstance.strDeviceToken, "os_version": "\(appDelegate.getCurrentAppVersion)", "ios_version": "\(appDelegate.getCurrentAppVersion)", "device_name": appDelegate.getCurrentDeviceName, "latitude": String(describing: StaticClass.sharedInstance.latitude), "longitude": String(describing: StaticClass.sharedInstance.longitude)]
        
        APICall.shared.postWeb("email_signup", parameters: NSMutableDictionary(dictionary: params), showLoder: true, successBlock: { (response) in
            if let status = response["FLAG"]as? Int, status == 1{
                UIView.animate(withDuration: 0.5, animations: {
                    self.frame.origin.y = (self.frame.origin.y + self.frame.height)
                    self.layoutIfNeeded()
                }) { (_) in
                    StaticClass.sharedInstance.saveToUserDefaultsString(value: self.enterEmail_textField.text!, forKey: "email_to_update")
                    let vc = EmailSentVC(nibName: "EmailSentVC", bundle: nil)
                    vc.email = self.enterEmail_textField.text!
                    vc.login_type = "email"
                    vc.backVc = self.vc
                    if let editVc = self.vc as? EditProfileVC{
                        Singleton.editProfileVc = editVc
                    }
                    self.vc.navigationController?.pushViewController(vc, animated: true)
                    self.removeFromSuperview()
                }
            }else{
                self.vc.showTopPop(message: response["MESSAGE"] as? String ?? "", response: false)
//                if UserDataModel.sharedInstance?.apple_id != ""{
//                    StaticClass.sharedInstance.saveToUserDefaultBool(forkey: "is_email_or_mobile_updation_failed", value: true)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {                        
//                        Global.appdel.setUpSlideMenuController()
//                    }
//                }
            }
        }) { (error) in
            //            self.showTopPop(message: error as? String ?? "", response: false)
        }
    }
}

extension UIViewController{
    
    func loadVerifyEmailView(){
        
        let view = Bundle.main.loadNibNamed("VerifyEmailView", owner: nil, options: [:])?.first as! VerifyEmailView
        view.frame = self.view.bounds
        view.vc = self
        view.frame.origin.y = (view.frame.origin.y + view.frame.height)
        self.view.addSubview(view)
        
        UIView.animate(withDuration: 0.3, animations: {
            view.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }) { (_) in
            
        }
        
    }
    
}
