//
//  EditProfileVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 4/18/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import CountryPickerView

class EditProfileVC: UIViewController,UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    //MARK:- Outlet's
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var viewUserName: UIView!
    @IBOutlet weak var viewBirth: UIView!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtBirthDate: UITextField!
    @IBOutlet weak var txtEmailChange: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var verifyMobile_btn: UIButton!
    @IBOutlet weak var textField_btn: UIButton!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var btnChangeImage: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnBirthDate: UIButton!
    
    @IBOutlet weak var mobileNumber_lbl: UILabel!
    @IBOutlet var isCorrectMobileNumberView: UIView!
    @IBOutlet weak var mobileNumberContainerView: CustomView!
    @IBOutlet weak var maleBtnContainerView: CustomView!
    @IBOutlet weak var femaleBtnContainerView: CustomView!
    @IBOutlet weak var otherBtnContainerView: CustomView!
    @IBOutlet weak var male_lbl: UILabel!
    @IBOutlet weak var female_lbl: UILabel!
    @IBOutlet weak var other_lbl: UILabel!
    @IBOutlet weak var logout_btn: UIButton!
    @IBOutlet weak var emailPrimaryAcc_lbl: UILabel!
    @IBOutlet weak var mobilePrimaryAcc_lbl: UILabel!
    
    
    
    //MARK:- Variabl's
    var isFromFBKit:Bool = false
    var isUserSocial = false
    var enterMobileNumberView: EnterMobileNumberView!
    var countryView: CountryPickerView!
    var backVc = UIViewController()
    var phoneCode = "+1"
    var selectedGender = ""
    var imagePicker:  UIImagePickerController!    
    
    //MARK:- Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadContent()
        self.applyDiffrenceInProfileForSocialUser()
        self.setTextFieldPadding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isMovingToParent {
            self.setLanguageText()
            self.setAllProfileDataFromShareClass()
        }
        
        if StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.isUserMobileNumberVerified)as? String ?? "" == "0" && !txtMobileNumber.isEmptyTextField(){
            self.verifyMobile_btn.isHidden = false
            self.textField_btn.isUserInteractionEnabled = true
        }else{
            self.verifyMobile_btn.isHidden = true
            self.textField_btn.isUserInteractionEnabled = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadUI()
        self.photoView.circleObject()
    }
    
    //MARK:- @IBAction's
    @IBAction func tapLogoutBtn(_ sender: UIButton) {
        Singleton.internetCheckTimer.invalidate()
        Global.appdel.logoutUser()
    }
    
    @IBAction func tapMaleBtn(_ sender: UIButton) {
        self.selectedGender = "1"
        self.changeGenderButtonColor()
    }
    
    @IBAction func tapFemaleBtn(_ sender: UIButton) {
        self.selectedGender = "0"
        self.changeGenderButtonColor()
    }
    
    @IBAction func tapOtherBtn(_ sender: UIButton) {
        self.selectedGender = "2"
        self.changeGenderButtonColor()
    }
    
    @IBAction func tapVerifyPhoneBtn(_ sender: UIButton) {
        self.isCorrectMobileNumberView.frame = self.view.frame
        self.mobileNumber_lbl.text = self.txtMobileNumber.text!
        self.view.addSubview(isCorrectMobileNumberView)
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func tapVerifyEmailBtn(_ sender: UIButton) {
        self.loadVerifyEmailView()
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        self.isCorrectMobileNumberView.removeFromSuperview()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func tapConfirmBtn(_ sender: UIButton) {
        self.sendOtp_Web(mobile_number: self.txtMobileNumber.text!)
        self.isCorrectMobileNumberView.removeFromSuperview()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func tapOnTextFieldBtn(_ sender: UIButton) {
        self.enterMobileNumberView = Bundle.main.loadNibNamed("EnterMobileNumberView", owner: nil, options: [:])?.first as? EnterMobileNumberView
        self.enterMobileNumberView.frame = self.view.frame
        self.enterMobileNumberView.countryCode_btn.addTarget(self, action: #selector(countryCodeBtnTapped(_:)), for: .touchUpInside)
        self.enterMobileNumberView.cancel_btn.addTarget(self, action: #selector(cancelBtnTapped(_:)), for: .touchUpInside)
        self.enterMobileNumberView.sendOtp_btn.addTarget(self, action: #selector(sendOtpBtnTapped(_:)), for: .touchUpInside)
        self.enterMobileNumberView.animHide()
        self.view.addSubview(enterMobileNumberView)
        self.gettingDefaultCountryFlag()
        self.textField_btn.isUserInteractionEnabled = false
        _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false, block: { (_) in
            self.enterMobileNumberView.animShow()
        })
    }
    
    @IBAction func tapBirthDateBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.loadDateTimePickerView(mode: .date, date_format: "yyyy-MM-dd", max_date_year: -18)
    }
    
    @IBAction func btnChangeImagePressed(_ sender: UIButton) {
        self.showImagePicker()
    }
    
    @IBAction func btnSavePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        
        var trimmedString = txtFirstName.text!.trimmingCharacters(in: .whitespaces) as String
        guard trimmedString.count > 0 else {
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey:"KeyVMFirstName"), vc: self)
            return
        }
        trimmedString = txtUserName.text!.trimmingCharacters(in: .whitespaces) as String
        trimmedString = txtEmailChange.text!.trimmingCharacters(in: .whitespaces) as String
        trimmedString = txtUserName.text!.trimmingCharacters(in: .whitespaces) as String
        trimmedString = txtEmailChange.text!.trimmingCharacters(in: .whitespaces) as String
        if trimmedString != "" {
            guard StaticClass.sharedInstance.isValidEmail(trimmedString) else {
                StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey:"KeyVVLEmail"), vc: self)
                return
            }
        }
        self.editApiCall()
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.backVc.isKind(of: BookNowVC.self){
            Global.appdel.setUpSlideMenuController()
        }else{
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Custom Function's
    
    func loadUI(){
        if AppLocalStorage.sharedInstance.application_gradient{
            self.bgImage.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.btnSave.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.bgImage.backgroundColor = CustomColor.primaryColor
            self.btnSave.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        
    }
    
    func loadContent(){
        
        StaticClass.sharedInstance.arrGender = ["Male","Female"]
        self.btnBirthDate.isUserInteractionEnabled = false
        self.txtBirthDate.isUserInteractionEnabled = false
        self.txtFirstName.circleObject()
        self.txtLastName.circleObject()
        self.txtEmailChange.circleObject()
        self.txtUserName.circleObject()
        self.txtMobileNumber.circleObject()
        self.txtBirthDate.circleObject()
        self.btnSave.circleObject()        
        self.photoView.layer.borderWidth = 4
        self.photoView.layer.borderColor = UIColor.white.cgColor
        self.view.layoutIfNeeded()
        
    }
    
    func setTextFieldPadding(){
        
        DispatchQueue.main.async {
            let txtFirstNamePaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
            self.txtFirstName.leftView = txtFirstNamePaddingView
            self.txtFirstName.leftViewMode = .always
            let txtLastNamePaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
            self.txtLastName.leftView = txtLastNamePaddingView
            self.txtLastName.leftViewMode = .always
            let txtEmailPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
            self.txtEmailChange.leftView = txtEmailPaddingView
            self.txtEmailChange.leftViewMode = .always
            let txtUserNamePaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
            self.txtUserName.leftView = txtUserNamePaddingView
            self.txtUserName.leftViewMode = .always
            let txtMobileLeftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
            let txtMobileRightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
            self.txtMobileNumber.leftView = txtMobileLeftPaddingView
            self.txtMobileNumber.rightView = txtMobileRightPaddingView
            self.txtMobileNumber.leftViewMode = .always
            self.txtMobileNumber.rightViewMode = .always
            let txtBirthDatePaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
            self.txtBirthDate.leftView = txtBirthDatePaddingView
            self.txtBirthDate.leftViewMode = .always
        }
    }
    
    
    func applyDiffrenceInProfileForSocialUser(){
        if let stSocial = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USER_IS_social) as? String{
            if stSocial == "1"{
                self.viewUserName.isHidden = true
                self.isUserSocial = true
            }else{
                
            }
        }
    }
    
    func setAllProfileDataFromShareClass(){
        
        if UserDataModel.sharedInstance?.primary_account == "1"{
            self.emailPrimaryAcc_lbl.isHidden = false
            self.mobilePrimaryAcc_lbl.isHidden = true
        }else if UserDataModel.sharedInstance?.primary_account == "2"{
            self.emailPrimaryAcc_lbl.isHidden = true
            self.mobilePrimaryAcc_lbl.isHidden = false
        }
        
        self.txtFirstName.text = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USERFIRSTNAME) as? String ?? ""
        self.txtLastName.text = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USERLASTNAME) as? String ?? ""
        
        if let stUname = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserName) as? String {
            if stUname == "" {
                self.viewUserName.isHidden = true
            }else{
                self.viewUserName.isHidden = false
            }
        }
        self.txtUserName.text = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserName) as? String ?? ""
        self.txtEmailChange.text = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserEMail) as? String ?? ""
        self.txtEmailChange.isUserInteractionEnabled = self.txtEmailChange.text?.trimmingCharacters(in: .whitespaces).count == 0
        self.txtMobileNumber.text = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserMobile)as? String ?? ""
        self.txtMobileNumber.isUserInteractionEnabled = false
        
        if StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.isUserMobileNumberVerified)as? String ?? "" == "0" && !txtMobileNumber.isEmptyTextField(){
            self.verifyMobile_btn.isHidden = false
            self.textField_btn.isUserInteractionEnabled = false
        }else{
            self.verifyMobile_btn.isHidden = true
            self.textField_btn.isUserInteractionEnabled = true
        }
        
        if StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.isUserMobileNumberVerified)as? String ?? "" == "0"{
            self.logout_btn.isHidden = false
        }else{
            self.logout_btn.isHidden = true
        }
        
        if let stGender = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserGender) as? String {
            
            if stGender == "1"{
                self.selectedGender = "1"
                self.changeGenderButtonColor()
            }else if stGender == "0"{
                self.selectedGender = "0"
                self.changeGenderButtonColor()
            }else if stGender == "2"{
                self.selectedGender = "2"
                self.changeGenderButtonColor()
            }
        }else{
            
        }
        self.txtBirthDate.text = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USER_DOB) as? String ?? "1990-01-01";
        self.btnBirthDate.isUserInteractionEnabled = true
        
        if let stbirth = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USER_DOB) as? String {
            if stbirth == "0000-00-00"{
                self.txtBirthDate.text = ""
                self.txtBirthDate.placeholder = "Date Of Birth"
                self.viewBirth.isHidden = false
            }else{
                self.txtBirthDate.text = stbirth
                self.viewBirth.isHidden = false
            }
        }else{
            self.txtBirthDate.text = ""
            self.viewBirth.isHidden = true
        }
        let strProfileImage =  StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USERPROFILEIMAGEURL) as? String ?? ""
        if strProfileImage == "" {
            
        }else {
            self.imgUserProfile.sd_setImage(with: URL(string: strProfileImage), placeholderImage: UIImage(named: "NoProfileImage"))
        }
    }
    
    func clearAllData(){
        self.txtUserName.text = ""
        self.txtFirstName.text = ""
        self.txtLastName.text = ""
        self.txtEmailChange.text = ""
        self.txtBirthDate.text = ""
    }
    
    func setLanguageText(){
        self.clearAllData()
        self.txtFirstName.placeholder = LocalizeHelper().localizedString(forKey: "KeyFirstName")
        self.txtLastName.placeholder = LocalizeHelper().localizedString(forKey: "KeyLastName")
        self.txtUserName.placeholder = LocalizeHelper().localizedString(forKey: "KeyUserName")
        self.txtEmailChange.placeholder = LocalizeHelper().localizedString(forKey: "KeyEmailAddress")
        self.txtBirthDate.placeholder = LocalizeHelper().localizedString(forKey: "KeyDateOfBirth")
    }
    
    func gettingDefaultCountryFlag(){
        self.countryView = CountryPickerView(frame: CGRect.zero)
        let country = countryView.countries.filter({$0.code.uppercased() == "US"})
        if country.count > 0{
            self.enterMobileNumberView.countryFlag_Img.image = country[0].flag
        }
    }
    
    func showImagePicker(){
        
        let actionSheet = UIAlertController(title: "", message: "Select Profile Image", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Take Photo", style: .default) { (_) in
            self.openImagePickerController(source_type: .camera)
        }
        let gallary = UIAlertAction(title: "Select From Library", style: .default) { (_) in
            self.openImagePickerController(source_type: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        
        actionSheet.addAction(camera)
        actionSheet.addAction(gallary)
        actionSheet.addAction(cancel)
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow
            actionSheet.popoverPresentationController?.sourceRect = UIApplication.shared.keyWindow!.bounds
            actionSheet.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        self.present(actionSheet, animated: true)
        
    }
    
    func openImagePickerController(source_type: UIImagePickerController.SourceType){
        self.imagePicker = UIImagePickerController()
        self.imagePicker.sourceType = source_type
        self.imagePicker.mediaTypes = ["public.image"]
        self.imagePicker.allowsEditing = true
        self.imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Custom Action For Enter Mobile Number Xib View Button's
    @objc func countryCodeBtnTapped(_ sender: UIButton){
        let countryPickerVC = CountryPickerVC(nibName: "CountryPickerVC", bundle: nil)
        countryPickerVC.countryPickerDelegate = self
        self.present(countryPickerVC, animated: true, completion: nil)
    }
    
    @objc func cancelBtnTapped(_ sender: UIButton){
        self.enterMobileNumberView.removeFromSuperview()
        self.textField_btn.isUserInteractionEnabled = true
    }
    
    @objc func sendOtpBtnTapped(_ sender: UIButton){
        let number = self.phoneCode + self.enterMobileNumberView.enterMobileNumber_txtField.text!
        if self.isValidPhoneNumber(number){
            self.sendOtp_Web(mobile_number: number)            
            self.enterMobileNumberView.removeFromSuperview()
            self.textField_btn.isUserInteractionEnabled = true
        }else{
            StaticClass.sharedInstance.ShowNotification(false, strmsg: "Please enter a valid phone number", vc: self)
        }
        
    }
    
    func changeGenderButtonColor(){
        if AppLocalStorage.sharedInstance.application_gradient{
            if selectedGender == "1"{
                self.maleBtnContainerView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
                self.male_lbl.textColor = UIColor.white
                self.femaleBtnContainerView.removeLayer()
                self.female_lbl.textColor = UIColor.darkGray
                self.otherBtnContainerView.removeLayer()
                self.other_lbl.textColor = UIColor.darkGray
            }else if selectedGender == "0"{
                self.maleBtnContainerView.removeLayer()
                self.male_lbl.textColor = UIColor.darkGray
                self.femaleBtnContainerView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
                self.female_lbl.textColor = UIColor.white
                self.otherBtnContainerView.removeLayer()
                self.other_lbl.textColor = UIColor.darkGray
            }else if selectedGender == "2"{
                self.maleBtnContainerView.removeLayer()
                self.male_lbl.textColor = UIColor.darkGray
                self.femaleBtnContainerView.removeLayer()
                self.female_lbl.textColor = UIColor.darkGray
                self.otherBtnContainerView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
                self.other_lbl.textColor = UIColor.white
            }
        }else{
            if selectedGender == "1"{
                self.maleBtnContainerView.backgroundColor = AppLocalStorage.sharedInstance.button_color
                self.male_lbl.textColor = UIColor.white
                self.femaleBtnContainerView.backgroundColor = CustomColor.customLightGray
                self.female_lbl.textColor = UIColor.darkGray
                self.otherBtnContainerView.backgroundColor = CustomColor.customLightGray
                self.other_lbl.textColor = UIColor.darkGray
            }else if selectedGender == "0"{
                self.maleBtnContainerView.backgroundColor = CustomColor.customLightGray
                self.male_lbl.textColor = UIColor.darkGray
                self.femaleBtnContainerView.backgroundColor = AppLocalStorage.sharedInstance.button_color
                self.female_lbl.textColor = UIColor.white
                self.otherBtnContainerView.backgroundColor = CustomColor.customLightGray
                self.other_lbl.textColor = UIColor.darkGray
            }else if selectedGender == "2"{
                self.maleBtnContainerView.backgroundColor = CustomColor.customLightGray
                self.male_lbl.textColor = UIColor.darkGray
                self.femaleBtnContainerView.backgroundColor = CustomColor.customLightGray
                self.female_lbl.textColor = UIColor.darkGray
                self.otherBtnContainerView.backgroundColor = AppLocalStorage.sharedInstance.button_color
                self.other_lbl.textColor = UIColor.white
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            imgUserProfile.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
        
    func showPopUpToConfirmEmail(){
        
        let al = UIAlertController(title: "Confirm Email", message: "\(self.txtEmailChange.text!) \nAfter confirming this you won't be able to edit email.", preferredStyle: .alert)
        al.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        al.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (alert) in
            self.editApiCall()
        }))
        self.present(al, animated: true, completion: nil)
    }
    
}

//MARK:- TextField Delegate's
extension EditProfileVC{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.tintColor = UIColor(hexxString: Global.g_ColorString.GreenTxt)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

//MARK: - Web Api's
extension EditProfileVC{
    
    func callResendEmail(){
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.callApiForMultipleImageUpload("resend_verification", withParameter: paramer, withImage: [], withLoader: true, successBlock: { (response) in
            
            let res = response as? [String:Any] ?? [:]
            if let msg = (res["MESSAGE"]as? String){
                if msg != ""{
                    AppDelegate.shared.window?.showBottomAlert(message: msg)
                }
            }
        }) { (error) in
            
        }
        
    }
    
    func sendOtp_Web(mobile_number: String){
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue("0", forKey: "check_secondary_contact")
        paramer.setValue(mobile_number, forKey: "mobile_number")
        paramer.setValue("1", forKey: "send_from_profile")
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        paramer.setValue("1", forKey: "device_type")
        
        print(paramer)
        
        APICall.shared.postWeb("mobile_singup", parameters: paramer, showLoder: true, successBlock: { (response) in
            if let dict = response as? NSDictionary {
                
                if (dict["FLAG"] as! Bool){
                    let otpViewController = OtpVerificationVC(nibName: "OtpVerificationVC", bundle: nil)
                    otpViewController.backVc = self
                    otpViewController.mobile_or_email = mobile_number
                    otpViewController.login_type = "phone"
                    otpViewController.userId = StaticClass.sharedInstance.strUserId
                    self.navigationController?.pushViewController(otpViewController, animated: true)
                }else{
                    let msg = dict["MESSAGE"] as? String ?? ""
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: msg, vc: self)
                }
                
            }
        }) { (error) in
            
        }
    }
    
    func editApiCall() -> Void {
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(self.txtFirstName.text, forKey: "first_name")
        paramer.setValue(self.txtLastName.text, forKey: "last_name")
        paramer.setValue(self.txtBirthDate.text, forKey: "date_of_birth")
        paramer.setValue(self.selectedGender, forKey: "gender")
//        paramer.setValue(txtEmailChange.text, forKey: "email_id")
//        if self.emailNeedToSendInApi {
//            paramer.setValue(txtEmailChange.text, forKey: "email_id")
//        }
        paramer.setValue(self.txtUserName.text, forKey: "username")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        let img : UIImage!
        if self.imgUserProfile.image == nil {
            img = UIImage(named: "NoProfileImage")
            paramer.setValue("1", forKey: "is_delete_photo")
        }else{
            img = self.imgUserProfile.image
            paramer.setValue("0", forKey: "is_delete_photo")
        }
        
        let stringwsName = "edit_profile/id/\(StaticClass.sharedInstance.strUserId)"
        APICall.shared.callApiUsingPOST_Image(stringwsName as NSString, withParameter: paramer, withImage: (img)!, WithImageName: "profile_image", withLoader: true, successBlock: { (response) in
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool){
                    if let arrResult = dict["USER_DETAILS"] as? NSArray{
                        if let dicResult = arrResult[0] as? NSDictionary {
                            
                            StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"id") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.UserID)
                            StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"first_name") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USERFIRSTNAME)
                            StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"last_name") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USERLASTNAME)
                            StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"email_id") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.UserEMail)
                            StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"date_of_birth") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USER_DOB)
                            StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"profile_image") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USERPROFILEIMAGEURL)
                            StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"is_verify") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USER_IsVarify)
                            
                            //Added for single signon
                            StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"is_social_email_verified") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USER_IS_social_email_verified)
                            
                            StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"is_social_email_verified") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USER_IS_social_email_verified)
                            
                            if self.isFromFBKit{
                                StaticClass.sharedInstance.saveToUserDefaults((true) as AnyObject, forKey: Global.g_UserDefaultKey.IS_USERLOGIN)
                                Global.appdel.userRunningRental_Web(loader: false)
                            }else{
                                Global.appdel.userRunningRental_Web(loader: false)
                                Global.appdel.userDetailCall(vc: self)
                            }
                        }
                        
                    }
                    else{
                        
                    }
                }
                else{
                    let msg = dict["MESSAGE"] as? String ?? ""
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: msg, vc: self)
                }
            }
        }) { (isError) in
            
        }
    }
    
}

//MARK: - Date Picker Delegate's
extension EditProfileVC: DateTimePickerDelegate{
    func selectedDateTime(value: String) {
        self.txtBirthDate.text = value
    }
}

//MARK: - Country Picker Delegate's
extension EditProfileVC: CountryPickerDelegate{
    func countryCodePicker(flag: UIImage, countryCode: String, phoneCode: String) {
        self.enterMobileNumberView.countryFlag_Img.image = flag
        self.enterMobileNumberView.countryCode_lbl.text = "(\(countryCode)) \(phoneCode)"
        self.phoneCode = phoneCode
    }
}
