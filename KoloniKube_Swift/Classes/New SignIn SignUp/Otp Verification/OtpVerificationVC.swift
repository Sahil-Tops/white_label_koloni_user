//
//  OtpVerificationVC.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 10/28/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class OtpVerificationVC: UIViewController {
    
    @IBOutlet weak var navigationBgImage: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var otpStackView: UIStackView!
    @IBOutlet weak var one_textField: UITextField!
    @IBOutlet weak var two_textField: UITextField!
    @IBOutlet weak var three_textField: UITextField!
    @IBOutlet weak var four_textField: UITextField!
    @IBOutlet weak var enterCodeTextView: CustomView!
    @IBOutlet weak var enterCode_textField: UITextField!
    @IBOutlet weak var submit_btn: CustomButton!
    @IBOutlet weak var resendOtp_btn: UIButton!
    
    var login_type = ""
    var otp = ""
    var userId = ""
    var mobile_or_email = ""
    var backVc = UIViewController()
    
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.login_type == "phone"{
            self.loadNavigationView(title: "Verify Phone Number")
            self.enterCodeTextView.isHidden = true
            self.one_textField.delegate = self
            self.two_textField.delegate = self
            self.three_textField.delegate = self
            self.four_textField.delegate = self
        }else{
            if Singleton.emailConfirmationToken != ""{
                self.enterCode_textField.text = Singleton.emailConfirmationToken
                self.verifyOtpOrToken()
            }
            self.loadNavigationView(title: "Verify Email")
            self.otpStackView.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.loadUI()
    }
    
    //MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case submit_btn:
            self.verifyOtpOrToken()
        case resendOtp_btn:
            self.loginWithEmailOrPhone()
        default:
            break
        }
        
    }
    
    
    //MARK: - Custom Function's
    
    func loadUI(){
        self.submit_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        self.navigationBgImage.backgroundColor = CustomColor.primaryColor
        self.resendOtp_btn.titleLabel?.textColor = CustomColor.primaryColor
        let range = ("Resend" as NSString).range(of: "Resend")
        let attributtedStr = NSMutableAttributedString.init(string: "Resend")
        attributtedStr.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.secondaryColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
        self.resendOtp_btn.setAttributedTitle(attributtedStr, for: .normal)
    }
    func loadNavigationView(title: String){
        
        let navigationView = Bundle.main.loadNibNamed("NavigationView", owner: nil, options: nil)?.first as? NavigationView
        navigationView?.frame = self.headerView.bounds
        navigationView?.backBtnAction = "back"
        navigationView?.title_lbl.text = title
        navigationView?.navigation = self.navigationController!
        self.headerView.addSubview(navigationView!)
        
    }
    
    func clearTextFields(){
        self.one_textField.text = ""
        self.two_textField.text = ""
        self.three_textField.text = ""
        self.four_textField.text = ""
    }
    
}

//MARK: - Text Field Delegate's
extension OtpVerificationVC: UITextFieldDelegate{
    
    @IBAction func textFieldOne(_ sender: UITextField) {
        if sender.isEmptyTextField(){
        }else{
            self.two_textField.becomeFirstResponder()
        }
    }
    
    @IBAction func textFieldTwo(_ sender: UITextField) {
        if sender.isEmptyTextField(){
            self.one_textField.becomeFirstResponder()
        }else{
            self.three_textField.becomeFirstResponder()
        }
    }
    
    @IBAction func textFieldThree(_ sender: UITextField) {
        if sender.isEmptyTextField(){
            self.two_textField.becomeFirstResponder()
        }else{
            self.four_textField.becomeFirstResponder()
        }
    }
    
    @IBAction func textFieldFour(_ sender: UITextField) {
        if sender.isEmptyTextField(){
            self.three_textField.becomeFirstResponder()
        }else{
            self.four_textField.resignFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        if string.count == 4 && string.isContainOnlyNumber(){
            self.one_textField.text = string[0]
            self.two_textField.text = string[1]
            self.three_textField.text = string[2]
            self.four_textField.text = string[3]
            self.view.endEditing(true)
            return false
        }else{
            if textField.text?.count ?? -1 > 0 && string == ""{
                return true
            }else if textField.text?.count == 0 && string != ""{
                return true
            }else{
                return false
            }
        }
        
    }
    
}

//MARK: - Web Api's
extension OtpVerificationVC{
    
    func verifyOtpOrToken(){
        var urlStr = ""
        var params: [String:Any] = ["device_type": "1", "device_token": StaticClass.sharedInstance.strDeviceToken, "ios_version": "\(appDelegate.getCurrentAppVersion)", "device_name": appDelegate.getCurrentDeviceName]
        if self.login_type == "email"{
            urlStr = "check_token"
            params["token"] = self.enterCode_textField.text!
            if self.backVc.isKind(of: EditProfileVC.self){
                params["send_from_profile"] = "1"
                params["email_id"] = StaticClass.sharedInstance.retriveFromUserDefaultsStrings(key: "email_to_update")
            }
        }else{
            urlStr = "mobile_verify_otp"
            params["user_id"] = self.userId
            params["otp"] = "\(self.one_textField.text!)\(self.two_textField.text!)\(self.three_textField.text!)\(self.four_textField.text!)"
            params["mobile_number"] = self.mobile_or_email
        }
        APICall.shared.postWeb(urlStr, parameters: NSMutableDictionary(dictionary: params), showLoder: true, successBlock: { (response) in
            if let status = response.object(forKey: "FLAG")as? Bool, status{
                if let arrResult = response["LOGIN_DETAILS"] as? NSArray{
                    if let dicResult = arrResult[0] as? NSDictionary {
                        Singleton.emailConfirmationToken = ""
                        StaticClass.sharedInstance.saveToUserDefaults((true) as AnyObject, forKey: Global.g_UserDefaultKey.IS_USERLOGIN)
                        StaticClass.sharedInstance.saveToUserDefaults((dicResult["id"]as? String  ?? "") as AnyObject, forKey: Global.g_UserData.UserID)
                        Global.getUserProfile_Web(vc: self) { (response, data) in
                            if response{
                                if self.backVc.isKind(of: EditProfileVC.self){
                                    print("Number Updated")
                                    if self.login_type == "email"{
                                        Global.appdel.userRunningRental_Web(loader: true)
                                    }else{
                                        if let editProfileVc = self.backVc as? EditProfileVC{
                                            editProfileVc.txtMobileNumber.text = self.mobile_or_email
                                        }
                                        self.navigationController?.popToViewController(self.backVc, animated: true)
                                    }
                                }else{
                                    if let is_new_user = dicResult["is_new_user"]as? String, is_new_user == "1"{
                                        let vc = AddCardsViewController(nibName: "AddCardsViewController", bundle: nil)
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }else{
                                        Global.appdel.userRunningRental_Web(loader: true)
                                    }
                                }
                            }
                        }
                    }
                }
                if let arrResult = response["BOOKING"] as? NSArray {
                    for element in arrResult {
                        if let dict = element as? NSDictionary {
                            if let bookingId = dict.object(forKey: "booking_id") as? Int {
                                StaticClass.sharedInstance.saveToUserDefaults( String(bookingId) as AnyObject , forKey: Global.g_UserData.BookingID)
                                let strBookingID = String(bookingId)
                                if !StaticClass.sharedInstance.arrRunningBookingId.contains(strBookingID) {
                                    StaticClass.sharedInstance.arrRunningBookingId.add(strBookingID)
                                }
                            }
                            else if let bookingId = dict.object(forKey: "booking_id") as? String{
                                StaticClass.sharedInstance.saveToUserDefaults(bookingId as AnyObject , forKey: Global.g_UserData.BookingID)
                                if !StaticClass.sharedInstance.arrRunningBookingId.contains(bookingId) {
                                    StaticClass.sharedInstance.arrRunningBookingId.add(bookingId)
                                }
                            }
                            
                            if let ObjectId = dict.object(forKey: "object_id") as? Int {
                                StaticClass.sharedInstance.saveToUserDefaults(String(ObjectId) as AnyObject , forKey: Global.g_UserDefaultKey.ObjectiIdList)
                                let strObjectID = String(ObjectId)
                                if !StaticClass.sharedInstance.arrRunningObjectId.contains(strObjectID) {
                                    StaticClass.sharedInstance.arrRunningObjectId.add(strObjectID)
                                }
                            }
                            else if let ObjectId = dict.object(forKey: "object_id") as? String {
                                StaticClass.sharedInstance.saveToUserDefaults(ObjectId as AnyObject , forKey: Global.g_UserDefaultKey.ObjectiIdList)
                                if !StaticClass.sharedInstance.arrRunningObjectId.contains(ObjectId) {
                                    StaticClass.sharedInstance.arrRunningObjectId.add(ObjectId)
                                }
                            }
                            StaticClass.sharedInstance.saveToUserDefaults(StaticClass.sharedInstance.arrRunningBookingId as AnyObject , forKey: Global.g_UserData.BookingIDsArr)
                            StaticClass.sharedInstance.saveToUserDefaults(StaticClass.sharedInstance.arrRunningObjectId  as AnyObject , forKey: Global.g_UserData.ObjectIDsArr)
                            
                        }
                    }
                }
            }else{
                StaticClass.sharedInstance.ShowNotification(false, strmsg: response["MESSAGE"] as? String ?? "", vc: self)
                if Singleton.emailConfirmationToken != ""{
                    Singleton.emailConfirmationToken = ""
                    let loginVc = LoginWithGoogleAppleVC(nibName: "LoginWithGoogleAppleVC", bundle: nil)
                    Global.changeRootVc(vc: loginVc)
                }
            }
            
        }) { (error) in
        }
    }
    
    private func loginWithEmailOrPhone(){
        var params: [String:Any] = ["check_secondary_contact": "0", "device_type": "1", "device_token": StaticClass.sharedInstance.strDeviceToken, "os_version": "\(appDelegate.getCurrentAppVersion)", "ios_version": "\(appDelegate.getCurrentAppVersion)", "device_name": appDelegate.getCurrentDeviceName, "latitude": String(describing: StaticClass.sharedInstance.latitude), "longitude": String(describing: StaticClass.sharedInstance.longitude)]
        var urlStr = ""
        if self.login_type == "email"{
            params["email_id"] = self.mobile_or_email
            urlStr = "email_signup"
        }else{
            params["mobile_number"] = self.mobile_or_email
            if self.backVc.isKind(of: EditProfileVC.self){
                params["send_from_profile"] = "1"
                params["user_id"] = self.userId
            }
            urlStr = "mobile_singup"
        }
        APICall.shared.postWeb(urlStr, parameters: NSMutableDictionary(dictionary: params), showLoder: true, successBlock: { (response) in
            if let status = response["FLAG"]as? Int, status == 1{
                if let user_id = response["USER_ID"]as? String{
                    self.userId = user_id
                }
                self.alertBox("Success", response["MESSAGE"]as? String ?? "") {
                    self.clearTextFields()
                }                
            }else{
                self.showTopPop(message: response["MESSAGE"] as? String ?? "", response: false)
            }
        }) { (error) in
            
        }
    }
    
}
