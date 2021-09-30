//
//  EmailSentViewController.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 10/29/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class EmailSentVC: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var one_lbl: UILabel!
    @IBOutlet weak var two_lbl: UILabel!
    @IBOutlet weak var emailSent_lbl: UILabel!
    @IBOutlet weak var openEmail_btn: CustomButton!
    @IBOutlet weak var enterCode_btn: UIButton!
    @IBOutlet weak var resendEmail_btn: UIButton!
    
    var email = ""
    var login_type = ""
    var backVc = UIViewController()
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUI()
        self.loadContent()
        self.loadSignUpHeaderView(view: self.headerView, headerTitle: "Check Your Email", isBackBtnHidden: false)
    }
    
    override func viewDidLayoutSubviews() {
        self.one_lbl.circleObject()
        self.two_lbl.circleObject()
    }
    
    //MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case enterCode_btn:
            let vc = OtpVerificationVC(nibName: "OtpVerificationVC", bundle: nil)
            vc.login_type = self.login_type
            vc.mobile_or_email = self.email
            vc.backVc = self.backVc
            self.navigationController?.pushViewController(vc, animated: true)
        case openEmail_btn:            
            let gmailUrl = URL(string: "googlegmail://")!
            if UIApplication.shared.canOpenURL(gmailUrl){
                UIApplication.shared.open(gmailUrl, options: [:], completionHandler: nil)
            }else{
                let mailURL = URL(string: "message://")!
                if UIApplication.shared.canOpenURL(mailURL) {
                    UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
                }
            }
            break
        case resendEmail_btn:
            self.loginWithEmail()
            break
        default:
            break
        }
        
    }
    
    //MARK: - Custom Function's
    func loadContent(){
        if email.contains("@"){
            let array = email.components(separatedBy: "@")
            if array.count > 0{
                let string = "An email was sent to \(String(array[0].prefix(1)))xxxx@\(array[1]) with a link to sign in."
                let range = (string as NSString).range(of: "\(String(array[0].prefix(1)))xxxx@\(array[1])")
                let attributtedStr = NSMutableAttributedString.init(string: string)
                attributtedStr.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.secondaryColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
                self.emailSent_lbl.attributedText = attributtedStr
            }
        }
    }
    
    func loadUI(){
        self.openEmail_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        let range = ("Enter Code" as NSString).range(of: "Enter Code")
        let attributtedStr = NSMutableAttributedString.init(string: "Enter Code")
        attributtedStr.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.secondaryColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
        self.enterCode_btn.setAttributedTitle(attributtedStr, for: .normal)
        let range1 = ("Resend" as NSString).range(of: "Resend")
        let attributtedStr1 = NSMutableAttributedString.init(string: "Resend")
        attributtedStr1.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.secondaryColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range1)
        self.resendEmail_btn.setAttributedTitle(attributtedStr1, for: .normal)
        self.one_lbl.backgroundColor = CustomColor.primaryColor
        self.two_lbl.backgroundColor = CustomColor.primaryColor
    }
}

//MARK: - Web Api's
extension EmailSentVC {
    
    func loginWithEmail(){
        var params: [String:Any] = ["check_secondary_contact": "0", "email_id": self.email, "device_type": "1", "device_token": StaticClass.sharedInstance.strDeviceToken, "os_version": "\(appDelegate.getCurrentAppVersion)", "ios_version": "\(appDelegate.getCurrentAppVersion)", "device_name": appDelegate.getCurrentDeviceName, "latitude": String(describing: StaticClass.sharedInstance.latitude), "longitude": String(describing: StaticClass.sharedInstance.longitude)]
        if self.backVc.isKind(of: EditProfileVC.self){
            params["send_from_profile"] = "1"
        }
        
        APICall.shared.postWeb("email_signup", parameters: NSMutableDictionary(dictionary: params), showLoder: true, successBlock: { (response) in
            if let status = response["FLAG"]as? Int, status == 1{
                self.alertBox("Success", response["MESSAGE"]as? String ?? "") {
                }
            }else{
                self.showTopPop(message: response["MESSAGE"] as? String ?? "", response: false)
            }
        }) { (error) in
            //            self.showTopPop(message: error as? String ?? "", response: false)
        }
    }
    
}
