//
//  LoginWithGoogleAppleVC.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 10/28/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit
import GoogleSignIn
import AuthenticationServices

class LoginWithGoogleAppleVC: UIViewController {
    
//    @IBOutlet's
    @IBOutlet weak var description_textView: UITextView!
    @IBOutlet weak var signInWithAuthView: CustomView!
    @IBOutlet weak var signInWithAuth_btn: UIButton!
    @IBOutlet weak var signInWithAppleView: CustomView!
    @IBOutlet weak var signInWithApple_btn: UIButton!
    @IBOutlet weak var signInWithGoogleView: CustomView!
    @IBOutlet weak var signInWithGoogle_btn: UIButton!
    @IBOutlet weak var otherOption_btn: CustomButton!
    @IBOutlet weak var checkBox_btn: UIButton!
    @IBOutlet weak var flagLogoView: CustomView!
    @IBOutlet weak var flagImg: UIImageView!
    
    var social_login_type = ""
    var loginBy = ""
    var check_secondary_contact = "1"
    var shareUser = ShareUser()
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if UserDefaults.standard.value(forKey: "is_app_loaded") == nil{
//            let vc = InstructionSlidesVC(nibName: "InstructionSlidesVC", bundle: nil)
//            vc.modalPresentationStyle = .overFullScreen
//            self.present(vc, animated: true, completion: nil)
//        }
        
        AuthManager(vc: self).checkLoginStatus { (status) in
            if status{
                //User Already Login
            }
        }
        self.loadContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 13.0, *) {
            self.signInWithAppleView.isHidden = false
        }else{
            self.signInWithAppleView.isHidden = true
        }
    }
    
    //MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case signInWithAuth_btn:
            if self.checkBox_btn.tag == 0{
                self.showWarningMessage()
            }else{
                AuthManager(vc: self).loginWithAuth0()                
            }
            break
        case signInWithApple_btn:
            self.signInWithAppleView.animateView()
            if self.checkBox_btn.tag == 0{
                self.showWarningMessage()
            }else{
                self.loginWithApple()
            }
            break
        case signInWithGoogle_btn:
            self.signInWithGoogleView.animateView()
            if self.checkBox_btn.tag == 0{
                self.showWarningMessage()
            }else{
                self.loginWithGoogle()
            }
            break
        case otherOption_btn:
            if self.checkBox_btn.tag == 0{
                self.showWarningMessage()
            }else{
                let vc = LoginWithPhoneOrEmailVC(nibName: "LoginWithPhoneOrEmailVC", bundle: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case checkBox_btn:
            if self.checkBox_btn.tag == 0{
                self.checkBox_btn.tag = 1
                self.checkBox_btn.setImage(UIImage(named: "checked_blue"), for: .normal)
            }else{
                self.checkBox_btn.setImage(UIImage(named: "unchecked_gray"), for: .normal)
                self.checkBox_btn.tag = 0
            }
            break
        default:
            break
        }
        
    }
    
    //MARK: - Custom Function's
    func showWarningMessage(){
        self.showTopPop(message: "Please accept the Terms and Conditions and User Agreement.", response: false)
    }
    
    func loadContent(){
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        let string = "I have read and agree to the Terms and Conditions, User Agreement."
        let termConStr = "Terms and Conditions"
        let userAgreeStr = "User Agreement."
        let rangeOfterms = (string as NSString).range(of: termConStr)
        let rangeOfuserAgree = (string as NSString).range(of: userAgreeStr)
        let attributedString = NSMutableAttributedString.init(string: string)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.customBlue, NSAttributedString.Key.link: URL(string: "http://www.terms.com")!, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: rangeOfterms)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.customBlue, NSAttributedString.Key.link: URL(string: "http://www.useragreement.com")!, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: rangeOfuserAgree)
        
        self.description_textView.attributedText = attributedString
        self.description_textView.font = UIFont(name: "Avenir Next", size: 15.0)
        self.description_textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: CustomColor.customBlue]
        self.description_textView.delegate = self
        self.description_textView.isEditable = false
        
    }
    
    func loginWithApple(){
        if #available(iOS 13.0, *) {
            self.social_login_type = "apple"
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func loginWithGoogle(){
        self.social_login_type = "google"
        GIDSignIn.sharedInstance().signIn()
    }
    
}

//MARK: - Text View Delegate's
extension LoginWithGoogleAppleVC: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        print(URL.absoluteString)
        
        switch URL.absoluteString{
        case "http://www.terms.com":
            let vc = TermsConditionsViewController(nibName: "TermsConditionsViewController", bundle: nil)
            vc.urlString = "http://kolonishare.com/app/term_and_condition"
            vc.titleStr = "Terms and Conditions"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case "http://www.useragreement.com":
            let vc = TermsConditionsViewController(nibName: "TermsConditionsViewController", bundle: nil)
            vc.urlString = "http://kolonishare.com/app/software_license"
            vc.titleStr = "User Agreement"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
        
        return false
    }
    
}

//MARK: - Apple Login Delegate's
extension LoginWithGoogleAppleVC: ASAuthorizationControllerDelegate{
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
            
            self.shareUser.strAppleId = userIdentifier
            self.shareUser.strFname = fullName?.givenName ?? ""
            self.shareUser.strLname = fullName?.familyName ?? ""
            self.shareUser.strUserName = (fullName?.givenName ?? "").lowercased()
            
            self.shareUser.strEmailId = email ?? ""
            self.loginBy = "social"
            self.socialLogin(user: self.shareUser)
        }
        
    }
    
}

//MARK: - Google Login Delegate's
extension LoginWithGoogleAppleVC: GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            if (signIn.currentUser != nil) {
                var username = ""
                
                self.shareUser.strGoogleId = signIn.currentUser.userID
                if let given_name = signIn.currentUser.profile.givenName{
                    self.shareUser.strFname = given_name
                    username = given_name
                }
                if let family_name = signIn.currentUser.profile.familyName{
                    self.shareUser.strLname = family_name
                }
                self.shareUser.strUserName = username
                self.shareUser.strEmailId = signIn.currentUser.profile.email
                if signIn.currentUser.profile.hasImage {
                    self.shareUser.strProfileImg = "\(String(describing: signIn.currentUser.profile.imageURL(withDimension: 500)))"
                }
                self.loginBy = "social"
                self.socialLogin(user: self.shareUser)
                GIDSignIn.sharedInstance()?.signOut()
            }
            
        }
    }
}

//MARK: - Web Api's
extension LoginWithGoogleAppleVC {
    
    func socialLogin(user:ShareUser) -> Void {
        Singleton.shared.socialMediaUserData = user
        let params: NSMutableDictionary = NSMutableDictionary()
        params.setValue(self.check_secondary_contact, forKey: "check_secondary_contact")
        params.setValue(user.strFname, forKey: "first_name")
        params.setValue(user.strLname, forKey: "last_name")
        params.setValue(user.strEmailId, forKey: "email_id")
        params.setValue(user.strFBId, forKey: "facebook_id")
        params.setValue(user.strTweeterId, forKey: "twitter_id")
        params.setValue(user.strGoogleId, forKey: "google_id")
        params.setValue(user.strAppleId, forKey: "apple_id")
        params.setValue("1", forKey: "device_type")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "os_version")
        params.setValue(appDelegate.getCurrentDeviceName, forKey: "device_name")
        params.setValue(StaticClass.sharedInstance.strDeviceToken, forKey: "device_token")
        params.setValue(String(describing: StaticClass.sharedInstance.latitude), forKey: "latitude")
        params.setValue(String(describing: StaticClass.sharedInstance.longitude), forKey: "longitude")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
                        
        APICall.shared.postWeb("social_login", parameters: params, showLoder: true, successBlock: { (response) in
            
            if let dict = response as? NSDictionary {
                
                if (dict["FLAG"] as! Bool){
                    if let show_secondary_popup = (dict as? [String:Any] ?? [:])["show_secondary_popup"]as? Int, show_secondary_popup == 1{
                        self.loadCreateAccountView(desc: response["MESSAGE"]as? String ?? "")
                    }else{
                        if let arrResult = dict["LOGIN_DETAILS"] as? NSArray, arrResult.count > 0{
                            if let dicResult = arrResult[0] as? NSDictionary {
                                StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"id") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.UserID)
                                StaticClass.sharedInstance.saveToUserDefaults((true) as AnyObject, forKey: Global.g_UserDefaultKey.IS_USERLOGIN)
                                Global.storeLoginData(dicResult: dicResult)
                                Global.getUserProfile_Web(vc: self) { (response, data) in
                                    if response{
                                        if let is_new_user = dict["is_new_user"]as? String, is_new_user == "1"{
                                            let vc = AddCardsViewController(nibName: "AddCardsViewController", bundle: nil)
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }else{
                                            Global.appdel.userRunningRental_Web(loader: true)
                                        }
                                    }
                                }
                            }else{
                                //                            self.socialSignUp_Web(params: params)
                            }
                        }else{
                            //                        self.socialSignUp_Web(params: params)
                        }
                    }
                }else {
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
                }
            }
        }) { (error) in
            
        }
        
    }
    
}
