//
//  LoginWithPhoneOrEmailVC.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 10/28/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit
import CountryPickerView

class LoginWithPhoneOrEmailVC: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var phoneNumber_btn: UIButton!
    @IBOutlet weak var email_btn: UIButton!
    @IBOutlet weak var next_btn: CustomButton!
    @IBOutlet weak var underLinePhone_lbl: UILabel!
    @IBOutlet weak var underLineEmail_lbl: UILabel!
    @IBOutlet weak var phoneNumberView: CustomView!
    @IBOutlet weak var emailView: CustomView!
    @IBOutlet weak var enterEmail_textField: UITextField!
    @IBOutlet weak var enterPhoneNumber_textField: UITextField!
    @IBOutlet weak var countryCode_btn: UIButton!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var phoneCode_lbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var description_lbl: UILabel!
    
    var login_type = "phone"
    var phoneCode = "+1"
    var check_secondary_contact = "1"
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.gettingDefaultCountryFlag()
        self.loadSignUpHeaderView(view: self.headerView, headerTitle: "Sign In", isBackBtnHidden: false)
    
    }
    
    override func viewDidLayoutSubviews() {
        self.loadUI()
    }
    
    //MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case phoneNumber_btn:
            self.login_type = "phone"
            self.description_lbl.text = "Enter phone number to sign in"
            self.phoneNumberView.isHidden = false
            self.emailView.isHidden = true
            self.phoneNumber_btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
            self.email_btn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
            self.phoneNumber_btn.setTitleColor(CustomColor.primaryColor, for: .normal)
            self.email_btn.setTitleColor(.darkGray, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.underLinePhone_lbl.isHidden = false
                    self.underLineEmail_lbl.isHidden = true
                    self.view.layoutIfNeeded()
                }) { (_) in
                }
            }
            break
        case email_btn:
            self.login_type = "email"
            self.description_lbl.text = "Enter email to sign in"
            self.phoneNumberView.isHidden = true
            self.emailView.isHidden = false
            self.phoneNumber_btn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
            self.email_btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
            self.email_btn.setTitleColor(CustomColor.primaryColor, for: .normal)
            self.phoneNumber_btn.setTitleColor(.darkGray, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.underLinePhone_lbl.isHidden = true
                    self.underLineEmail_lbl.isHidden = false
                    self.view.layoutIfNeeded()
                }) { (_) in
                }
            }
        case countryCode_btn:
            let countryPickerVC = CountryPickerVC(nibName: "CountryPickerVC", bundle: nil)
            countryPickerVC.countryPickerDelegate = self
            self.present(countryPickerVC, animated: true, completion: nil)
            break
        case next_btn:
            
            if self.login_type == "email"{
                if self.enterEmail_textField.isEmptyTextField(){
                    self.showTopPop(message: "Please enter an email", response: false)
                }else{
                    self.loginWithEmailOrPhone()
                }
            }else if self.login_type == "phone"{
                if self.enterPhoneNumber_textField.isEmptyTextField(){
                    self.showTopPop(message: "Please enter an phone number", response: false)
                }else{
                    self.loginWithEmailOrPhone()
                }
            }
        default:
            break
        }
        
    }
    
    //MARK: - Custom Function's
    func gettingDefaultCountryFlag(){
        let countryView = CountryPickerView(frame: CGRect.zero)
        let country = countryView.countries.filter({$0.code.uppercased() == "US"})
        if country.count > 0{
            self.countryFlag.image = country[0].flag
        }
    }
    
    func loadUI(){
        self.next_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        self.underLinePhone_lbl.backgroundColor = CustomColor.primaryColor
        self.underLineEmail_lbl.backgroundColor = CustomColor.primaryColor
        self.phoneNumber_btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        self.phoneNumber_btn.setTitleColor(CustomColor.primaryColor, for: .normal)        
    }
    
}

//MARK: - Web Api's
extension LoginWithPhoneOrEmailVC{
    
    func loginWithEmailOrPhone(){
        var params: [String:Any] = ["check_secondary_contact": self.check_secondary_contact, "device_type": "1", "device_token": StaticClass.sharedInstance.strDeviceToken, "ios_version": "\(appDelegate.getCurrentAppVersion)", "device_name": appDelegate.getCurrentDeviceName, "latitude": String(describing: StaticClass.sharedInstance.latitude), "longitude": String(describing: StaticClass.sharedInstance.longitude)]
        var urlStr = ""
        if self.login_type == "email"{
            params["email_id"] = self.enterEmail_textField.text!
            urlStr = "email_signup"
        }else{
            params["mobile_number"] = "\(self.phoneCode)\(self.enterPhoneNumber_textField.text!)"
            urlStr = "mobile_singup"
        }
        APICall.shared.postWeb(urlStr, parameters: NSMutableDictionary(dictionary: params), showLoder: true, successBlock: { (response) in
            print(response as! NSDictionary)
            if let status = response["FLAG"]as? Int, status == 1{
                if let show_secondary_popup = (response as? [String:Any] ?? [:])["show_secondary_popup"]as? Int, show_secondary_popup == 1{
                    self.loadCreateAccountView(desc: response["MESSAGE"]as? String ?? "")
                }else{
                    if self.login_type == "email"{
                        let vc = EmailSentVC(nibName: "EmailSentVC", bundle: nil)
                        vc.email = self.enterEmail_textField.text!
                        vc.login_type = self.login_type
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        if let data = response as? [String:Any]{
                            if let userId = data["USER_ID"]as? String{
                                let vc = OtpVerificationVC(nibName: "OtpVerificationVC", bundle: nil)
                                vc.login_type = self.login_type
                                vc.userId = userId
                                vc.mobile_or_email = "\(self.phoneCode)\(self.enterPhoneNumber_textField.text!)"
                                self.navigationController?.pushViewController(vc, animated: true)
                            }else{
                                self.showTopPop(message: "User id not found, please try again", response: false)
                            }
                        }
                    }
                }
            }else{
                self.showTopPop(message: response["MESSAGE"] as? String ?? "", response: false)
            }
        }) { (error) in
            //            self.showTopPop(message: error as? String ?? "", response: false)
        }
    }
    
}

//MARK: - Country Picker Delegate Method
extension LoginWithPhoneOrEmailVC: CountryPickerDelegate{
    
    func countryCodePicker(flag: UIImage, countryCode: String, phoneCode: String) {
        self.phoneCode_lbl.text = "(\(countryCode)) \(phoneCode)"
        self.countryFlag.image = flag
        self.phoneCode = phoneCode
    }
    
}
