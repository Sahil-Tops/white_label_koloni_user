//
//  ChangePasswordViewController.swift
//  KoloniKube_Swift
//
//  Created by Tops on 17/10/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

// This Controller is not in Use Now.

class ChangePasswordViewController: UIViewController {
    
    //Outlet's
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var enterOldPwd_textField: UITextField!
    @IBOutlet weak var enterNewPwd_textField: UITextField!
    @IBOutlet weak var enterConfirmPwd_textField: UITextField!
    @IBOutlet weak var saveChanges_btn: CustomButton!
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadHeaderView()
        self.loadContent()
    }
    
    //MARK: - Custom Function's
    
    func loadContent(){
                
        self.saveChanges_btn.circleObject()
        
    }
    
    func loadHeaderView(){
        self.loadSignUpHeaderView(view: self.headerView, headerTitle: "Change Password", isBackBtnHidden: false)
    }
    
    func validation(){
        let newPwdStr = self.enterNewPwd_textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPwdStr = self.enterConfirmPwd_textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if self.enterOldPwd_textField.isEmptyTextField(){
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey:"KeyVMPasswordOld"), vc: self)
        }else if self.enterNewPwd_textField.isEmptyTextField(){
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey:"KeyVMPasswordNew"), vc: self)
        }else if !StaticClass.sharedInstance.isPasswordValid(newPwdStr){
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "KeyVPasswordValid"), vc: self)
        }else if self.enterConfirmPwd_textField.isEmptyTextField(){
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey:"KeyVMPasswordConfirm"), vc: self)
        }else if !StaticClass.sharedInstance.isPasswordValid(confirmPwdStr){
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "KeyVPasswordValid"), vc: self)
        }else if newPwdStr != confirmPwdStr{
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey:"keyVConfirmPassword"), vc: self)
        }else{
            self.view.endEditing(true)
            self.changePwd_Web()
        }
        
    }
    
    //MARK: - @IBAction's
    @IBAction func tapSaveChangesBtn(_ sender: UIButton) {
        self.validation()
    }
    
    //MARK: - Web Api's
    
    func changePwd_Web() -> Void {
        let paramer: NSMutableDictionary = NSMutableDictionary()
        
        paramer.setValue(self.enterOldPwd_textField.text!, forKey: "old_password")
        paramer.setValue(self.enterNewPwd_textField.text!, forKey: "new_password")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        let stringwsName = "change_password/id/\(StaticClass.sharedInstance.strUserId)"
        APICall.shared.postWeb(stringwsName, parameters: paramer, showLoder: true, successBlock: { (response) in
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool){                    
                    let msg = dict["MESSAGE"] as? String ?? ""
                    self.navigationController?.popViewController(animated: true)
                    StaticClass.sharedInstance.ShowNotification(true, strmsg: msg, vc: self)
                }
                else{
                    let msg = dict["MESSAGE"] as? String ?? ""
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: msg, vc: self)
                }
            }
        }) { (error) in
            
        }
    }

}
