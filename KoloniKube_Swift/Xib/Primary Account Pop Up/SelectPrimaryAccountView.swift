//
//  SelectPrimaryAccountView.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 05/07/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class SelectPrimaryAccountView: UIView {

    @IBOutlet weak var description_lbl: UILabel!
    @IBOutlet weak var email_lbl: UILabel!
    @IBOutlet weak var mobileNumber_lbl: UILabel!
    @IBOutlet weak var emailCheck_btn: UIButton!
    @IBOutlet weak var mobileCheck_btn: UIButton!
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var submit_btn: CustomButton!
    
    var selectedAccount = ""
    var bookNowVc: BookNowVC!
    
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case close_btn:
            self.removeView()
            break
        case emailCheck_btn:
            self.emailCheck_btn.setImage(CustomImages.checked_blue, for: .normal)
            self.mobileCheck_btn.setImage(CustomImages.uncheck_gray, for: .normal)
            self.selectedAccount = "1"
            break
        case mobileCheck_btn:
            self.mobileCheck_btn.setImage(CustomImages.checked_blue, for: .normal)
            self.emailCheck_btn.setImage(CustomImages.uncheck_gray, for: .normal)
            self.selectedAccount = "2"
            break
        case submit_btn:
            if self.selectedAccount != ""{
                self.updatePrimaryAccount_Web()
            }else{
                AppDelegate.shared.window?.showBottomAlert(message: "Please check one of account (Email or Mobile)")
            }
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
    
    func loadContent(data: [String:Any]){
        self.email_lbl.text = "Email ID (\(data["popup_email_id"]as? String ?? ""))"
        self.mobileNumber_lbl.text = "Mobile Number (\(data["popup_mobile_number"]as? String ?? ""))"
        self.description_lbl.text = data["popup_msg"]as? String ?? ""
    }
    
    func updatePrimaryAccount_Web(){
        let params: NSMutableDictionary = NSMutableDictionary()
        params.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        params.setValue(self.selectedAccount, forKey: "primary_login")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("update_primary_login", parameters: params, showLoder: true) { (response) in
            if let message = response["MESSAGE"]as? String{
                if let status = response["FLAG"]as? Int, status == 1{
                    self.bookNowVc.reloadVc()
                    AppDelegate.shared.window?.showBottomAlert(message: message)
                    self.removeView()
                }else{
                    AppDelegate.shared.window?.showTopPop(message: message, response: false)
                }
            }
        } failure: { (error) in
            
        }

    }
}

extension BookNowVC{
    
    func loadPrimaryAccountView(data: [String:Any]){
        if let view = Bundle.main.loadNibNamed("SelectPrimaryAccountView", owner: nil, options: [:])?.first as? SelectPrimaryAccountView{
            view.frame = AppDelegate.shared.window?.bounds ?? self.view.bounds
            view.bookNowVc = self
            view.loadContent(data: data)
            AppDelegate.shared.window?.addSubview(view)
            view.frame.origin.y += view.frame.height
            UIView.animate(withDuration: 0.5) {
                view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
