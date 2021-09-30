//
//  ResendEmailVerifyVC.swift
//  KoloniKube_Swift
//
//  Created by tops on 18/09/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class ResendEmailVerifyVC: UIViewController, UITextFieldDelegate {
    
    //IBOutlet's
    @IBOutlet weak var signIn_btn: UIButton!
    @IBOutlet weak var email_textField: UITextField!
    @IBOutlet weak var imgEmail: UIImageView!
    @IBOutlet weak var emailLine_label: UILabel!
    @IBOutlet weak var resendEmail_btn: UIButton!
    @IBOutlet weak var alreadyUser_btn: UIButton!
    
    //Local variabl's
    let hexGreenColor = Global.g_ColorString.GreenTxt;
    let hexGrayColor = Global.g_ColorString.GreyLightTxt;

    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadScreenContents()
    }
    
    
    //MARK: IBAction's Buttons
    @IBAction func clickOnBtn(_ sender: UIButton) {
        switch sender {
        case signIn_btn:
            self.navigationController?.popViewController(animated: true)
            break
        case resendEmail_btn:
            if StaticClass.sharedInstance.isValidEmail(self.email_textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)){
                self.resendEmail_Web()
            }else{
                StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "KeyVVLEmail"))
            }
            break
        case alreadyUser_btn:
            self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
    
    //MARK:- Custom Function's
    
    func loadScreenContents(){
        emailLine_label.backgroundColor = UIColor(hexxString: hexGrayColor as String)
        email_textField.placeHolderColor = UIColor.lightGray
        email_textField.autocorrectionType = .no
        email_textField.delegate = self;
        resendEmail_btn.layer.cornerRadius = resendEmail_btn.frame.size.height/2;
    }
    
    func EmailText(strEmail:String) -> Void {
        if (email_textField.text!.count) > 0 {
            email_textField.textColor = UIColor(hexxString: Global.g_ColorString.GreenTxt)
            emailLine_label.backgroundColor = UIColor(hexxString: Global.g_ColorString.GreenTxt)
            imgEmail.image = UIImage(named: "email_green")
        }else{
            email_textField.textColor = UIColor(hexxString:Global.g_ColorString.GreyLightTxt)
            emailLine_label.backgroundColor = UIColor(hexxString:Global.g_ColorString.GreyLightTxt)
            imgEmail.image = UIImage(named: "email")
        }
    }

    //MARK:- Text Field Delegets Methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.tintColor = UIColor(hexxString: Global.g_ColorString.GreenTxt)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == email_textField){
            let trimmedString = email_textField.text!.trimmingCharacters(in: .whitespacesAndNewlines) as String
            self.EmailText(strEmail: trimmedString);
        }
    }
    
    //MARK: - Web Api's
    
    func resendEmail_Web(){
        
        self.view.endEditing(true)
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(self.email_textField.text!, forKey: "email_id")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.Post("login_resend_verification", parameters: paramer, showLoder: true, successBlock: { (response) in
            if let Dict = response as? NSDictionary {
                if Dict.object(forKey: "FLAG") as! Bool {
                    StaticClass.sharedInstance.ShowNotification(true, strmsg: Dict.object(forKey: "MESSAGE") as! String)
                    _ = self.navigationController?.popViewController(animated: true)
                }
                else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: Dict.object(forKey: "MESSAGE") as! String)
                }
            }
        }) { (error) in
            print("Error: ", error)
        }
        
    }
    
}
