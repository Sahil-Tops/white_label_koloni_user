//
//  Refferal_popup.swift
//  
//
//  Created by Tops on 22/07/19.
//

import UIKit
protocol ReferralCodeDelegate {
    func DidClosePopup(str: Bool)
}
class Refferal_popup: UIView,UITextFieldDelegate {
    
    @IBOutlet weak var view_center: NSLayoutConstraint!
    @IBOutlet weak var txtReferralCode: UITextField!
    @IBOutlet weak var submit_btn: UIButton!
    @IBOutlet weak var cancel_btn: UIButton!
    
    var viewTrans: UIView!
    var delegate:ReferralCodeDelegate?
    
    
    override func awakeFromNib() {
        self.submit_btn.circleObject()
        txtReferralCode.delegate = self
        self.frame = CGRect(x: 0, y: Global.screenHeight, width: Global.screenWidth, height: Global.screenHeight)
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        ClosePopup()
        self.delegate?.DidClosePopup(str: StaticClass.sharedInstance.retriveFromUserDefaultsBool(key: Global.g_UserData.is_referral_shown))
    }
    
    @IBAction func btnOk_Click(_ sender: Any) {     
        if self.txtReferralCode.text != ""{
            let paramer: NSMutableDictionary = NSMutableDictionary()
            paramer.setValue(txtReferralCode.text, forKey: "referral_code")
            paramer.setValue(StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserID), forKey: "user_id")
            paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
            
            APICall.shared.postWeb("add_referral_code", parameters:paramer, showLoder: true, successBlock:{(response) in
                if let dict = response as? NSDictionary {
                    if (dict["FLAG"] as! Bool){
                        UserDefaults.standard.set(false, forKey: "isShowEnterRefBtn")   //This is for allowing user to enter referral once.
                        self.delegate?.DidClosePopup(str: StaticClass.sharedInstance.retriveFromUserDefaultsBool(key: Global.g_UserData.is_referral_shown))
                        self.ClosePopup()
                    } else {
                        let msg = dict["MESSAGE"] as? String ?? ""
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: msg)
                    }
                }
                
            }) { (error) in
                
            }
        }else{
            AppDelegate.shared.window?.showBottomAlert(message: "Please enter referral code!")
        }
    }
    func DisplayPopup(){
        viewTrans = UIView.init(frame: (appDelegate.window?.bounds)!)
        viewTrans.backgroundColor = Global.PopUpColor
        viewTrans.addSubview(self)
        
        appDelegate.window?.addSubview(viewTrans)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.frame.origin.y = 0
        }) { (t) in
            
        }
    }
    
    func ClosePopup(){
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.frame.origin.y = Global.screenHeight
        }) { (t) in
            self.viewTrans.removeFromSuperview()
            StaticClass.sharedInstance.saveToUserDefaultBool(forkey: Global.g_UserData.is_referral_shown, value: true)
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !Global.is_Iphone._6p{
            view_center.constant = -40
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        view_center.constant = 0
    }
    
}
