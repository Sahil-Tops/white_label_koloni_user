//
//  Global.swift
//  Club_Mobile
//
//  Created by Tops on 12/7/16.
//  Copyright © 2016 Self. All rights reserved.
//

import UIKit
import SystemConfiguration
import CoreLocation

class Global {
    
    static let g_Username = "admin"
    static let g_Password = "1234"
    static var Obj_Type = ""
    static var objectAddress = ""
    static var Booking_ID = ""
    static var asset_type = ""
    static var sharedBikeData = ShareBikeKube()
    
    static var PauseColor = UIColor(red: 240.0/255, green: 195.0/255, blue: 50.0/255, alpha: 1.0)
    static var PlayColor = UIColor(red: 0.0/255, green: 163.0/255, blue: 90.0/255, alpha: 1.0)
    static var endRentalColor = UIColor(red: 211.0/255, green: 2.0/255, blue: 13.0/255, alpha: 1.0)
    static var PopUpColor = UIColor(red: 40.0/255, green: 40.0/255, blue: 40.0/255, alpha: 0.0)
    
    // LIVE
//        static let g_APIBaseURL = "http://13.59.246.255/app/ws/v11/"
    
    // BETA    
    static let g_APIBaseURL = "https://kolonishare.com/super_partner_beta/ws/v1/"
    //"https://kolonishare.com/design/ws/v12/"
    
    static let licensingAgreementURL = "http://kolonishare.com/app/software_license"
    static let TearmsURL = "http://kolonishare.com/app/term_and_condition"
    
    // PAYPAL PAYMENT MODE // 0 = sandbox, 1 = Live
    static let g_paypal_live = "0"
    static let g_Club_mobileAppID = ""
    
    static let appdel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    static let arrayMember:NSArray = ["Agents","Call Center","Statement","Home"]
    static let arrayAgent:NSArray = ["Agents Statement","Sell","Card Statement","Home"]
    
    struct Messages {
        static let serverError = "Oops, we can’t reach server.Please Check your connection and try again."
    }
    
    //Custom Font name
    struct CFName {
        static let Muli_Semibold = "Muli-SemiBold"
        static let Muli_Bold = "Muli-Bold"
        static let Muli_Regular = "Muli-Regular"
    }
    
    struct g_ColorString {
        
        static let pause_round_color = "#A68133"
        static let pause_round_inner = "#F9C019"
        
        static let play_round_color = "#006E3d"
        static let play_round_inner = "#00A658"
        
        static let end_round_color = "#B70014"
        static let end_round_inner = "#FF001E"
        
        static let GreenTxt = "#3BBEAE"
        static let GreyLightTxt = "#A8ABB2"
        static let RedLight = "#DB4437"
        static let Red = "#FF0303"
        static let Blue = "#4267B2"
        static let SkyBlue = "#1DA1F2"
        static let Black = "#333333"
        static let Unselected = "#E0E0E0"
        // NEW COLOR CR: CONNECT AND DISCONNECT
        static let GreenBG = "#32B574"
        static let BlueBG = "#337ED1"
    }
    
    struct BT_Card_Details {
        static var CardNo           = "KCCardNumber"
        static var Expiry           = "CMExpiry"
        static var Exipry_month     = "CMExpiry_Month"
        static var Exipry_year      = "CMUserGender"
        static var ID               = "CMID"
        static var Name             = "CMName"
        static var CardType         = "CMCardType"
        
    }
    
    struct g_UserData {
        static let TempBookingRentalStoreID      = "KCTempBookingRentalStoreID"
        
        static let ObjectPrice    = "KCObjectPrice"
        static let ObjectName     = "KCObjectName"
        static let BookingID      = "KCOBookingID"
        static let TempBookingID      = "KCOTempBookingID"
        
        static let BookingIDsArr  = "KCOBookingIDCurrent"
        static let ObjectID       = "KCObjectID"
        static let ObjectIDsArr   = "KCObjectIDCurrent"
        static let UserID         = "KCUID"
        static let PartnerID         = "KCPARTNERID"
        static let isNavigationFlow   = "KCISNAVIGATIONFLOW"
        
        static let UserEMail      = "CMEmailAddress"
        static let UserName       = "CMUsername"
        static let UserGender     = "CMUserGender"
        static let UserMobile     = "CMUserMobile"
        static let USERID_FB      = "CMFBid"
        static let USERID_TW      = "CMTWid"
        static let USERID_GG      = "CMGGid"
        static let USERFIRSTNAME  = "CMFirstName"
        static let USERLASTNAME   = "CMSurname"
        static let USER_DOB       = "CMDOB"
        static let USERPROFILEIMAGEURL = "CMProfileImageUrl"
        static let USER_IsVarify  = "CMVerify"
        static let USER_IS_social_email_verified = "CMSocialEmailVerify"
        static let AFFILIATE_STATUS = "CMAffiliateStatus"
        static let AFFILIATEID = "CMAffiliateId"
        static let isUserMobileNumberVerified = "is_mobile_verified"
        static let isAffiliatedUser = "is_affiliated_user"
        static let USER_IS_social = "CMIsSocial"
        static let is_referral_shown = "CMIsPopup"
        
        
        static let Customer_ID    = "CMCustomerID"
        static let CreateToken = "CMToken"
        
        static let USER_CARDNO = "CMuser_card_number"
        static let USER_CARDMONTH = "CMuser_card_month"
        static let USER_CARDYEAR = "CMuser_card_year"
        static let USER_CARDCVV = "CMuser_card_cvv"
        static let USER_CARDNAME = "CMuser_card_name"
        static let USER_CARDBANK = "CMuser_card_bank"
        static let USER_CARD_ID = "CMuser_card_id"
        static let USER_CARDTYPE = "CMuser_card_type"
    }
    
    struct g_UserDefaultKey {
        static let Token_login      = "CMToken_login"
        static let latitude         = "CMlatitude"
        static let longitude        = "CMlongitude"
        static let DeviceToken      = "CMDeviceToken"
        static let UniqueCode       = "CMUniqueCode"
        static let address          = "CMaddress"
        static let IS_USERLOGIN     = "CMUSER_LOGIN"
        static let IS_Agent         = "IS_AGENT"
        static let city             = "CMCity"
        static let BookingArrList   = "CMBookingArray"
        static let Is_StartBooking  = "isstartbooking"
        static let Is_StartOverlay  = "isstartOverlay"
        static let Is_StartOverlay_Map  = "isstartOverlayMap"
        static let ObjectiIdList    = "ObjectIdList"
        static let ObjectiBookingID    = "ObjectIdListBookingID"
        
    }
    
    struct kFont {
        static let SourceRegular = "SourceSansPro-Regular"
        static let SourceSemiBold = "SourceSansPro-SemiBold"
        static let SourceBold = "SourceSansPro-Bold"
        static let koloniFont2 = "icomoon"
    }
    
    static let screenWidth : CGFloat = (Global.appdel.window!.bounds.size.width)
    static let screenHeight : CGFloat = (Global.appdel.window!.bounds.size.height)
    
    struct directoryPath {
        static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
    }
    
    static func getDeviceSpecificFontSize(_ fontsize: CGFloat) -> CGFloat {
        return ((Global.screenWidth) * fontsize) / 320
    }
    
    // MARK: -  Dispatch Delay
    func delay(delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    //MARK: DEVICE IDENTIFICATON CODE
    struct is_Device {
        static let _iPhone = (UIDevice.current.model as NSString).isEqual(to: "iPhone") ? true : false
        static let _iPad = (UIDevice.current.model as NSString).isEqual(to: "iPad") ? true : false
        static let _iPod = (UIDevice.current.model as NSString).isEqual(to: "iPod touch") ? true : false
    }
    
    //MARK: IOS IDENTIFICATION CODE
    struct is_Ios {
        static let _11 = ((UIDevice.current.systemVersion as NSString).floatValue >= 11.0) ? true : false
        static let _10 = ((UIDevice.current.systemVersion as NSString).floatValue >= 10.0) ? true : false
        static let _9 = ((UIDevice.current.systemVersion as NSString).floatValue >= 9.0) ? true : false
        static let _8 = ((UIDevice.current.systemVersion as NSString).floatValue >= 8.0 && (UIDevice.current.systemVersion as NSString).floatValue < 9.0) ? true : false
        static let _7 = ((UIDevice.current.systemVersion as NSString).floatValue >= 7.0 && (UIDevice.current.systemVersion as NSString).floatValue < 8.0) ? true : false
        static let _6 = ((UIDevice.current.systemVersion as NSString).floatValue <= 6.0 ) ? true : false
    }
    
    //MARK: IPHONE MODEL IDENTIFICATION CODE[
    struct is_Iphone {
        static let _6p = (UIScreen.main.bounds.size.height >= 736.0 ) ? true : false
        static let _6 = (UIScreen.main.bounds.size.height <= 667.0 && UIScreen.main.bounds.size.height > 568.0) ? true : false
        static let _5 = (UIScreen.main.bounds.size.height <= 568.0 && UIScreen.main.bounds.size.height > 480.0) ? true : false
        static let _4 = (UIScreen.main.bounds.size.height <= 480.0) ? true : false
    }
    
    func RGB(r: Float, g: Float, b: Float, a: Float) -> UIColor {
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: CGFloat(a))
    }
    
    static func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
    }
    
    static func checkInternet() -> Bool
    {
        let status = GSReach().connectionStatus()
        switch status {
        case .unknown, .offline:
            return false
        case .online(.wwan), .online(.wiFi):
            return true
        }
    }
    
    static  func DiC_Json(dictionary:NSDictionary) -> String {
        
        var json_String = ""
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: []) {
            
            json_String = String(data: theJSONData,
                                 encoding: .ascii)!
        }
        
        return json_String
        
    }
    
    struct inApp {
        static let inapp2  = "com.lystiosapp.swipes7"
    }
    
    struct notification {
        static let DeviceBLE_StateChange            = "deviceBLEOffEvent"
        static let Push_forLocation                 = "pushnotificationUpdateValuesinLocation"
        static let Push_forBookingTrip              = "pushnotificationUpdateValuesinBookingTrip"
        static let Push_ProfileDataCall              = "pushnotificationUpdateValuesinUserProfileSlideMenu"
        static let is_BookingStartStrip              = "pushnotificationForUpdateValueinBookingStartStripHeader"
        static let is_KeyboardNumbericOpen              = "pushnotificationForUpdateValueKeyboardNumbericOpen"
        static let is_PushNotification_Booking              = "pushnotificationForUpdateValueNotificationBooking"
        static let is_PushNotification_Report              = "pushnotificationForUpdateValueNotificationReport "
        static let is_PushNotification_BuyMembership             = "pushnotificationForUpdateValueNotificationMyMembershiop"
        static let is_PushNotification_MyMembershiop             = "pushnotificationForUpdateValueNotificationMyMembershiop"
        static let is_PushNotification_RentalHub              = "pushnotificationForUpdateValueNotificationRentalHub"
        static let is_PushNotification_Help              = "pushnotificationForUpdateValueNotificationHelp"
        static let is_PushNotification_Settings              = "pushnotificationForUpdateValueNotificationSettings"
        static let LocationUpdateNotification                = "pushnotificationUpdateLocatoinManagerMethod"
        static let is_QRScanOption              = "pushnotificationForUpdateValueinQRScanOption"
        
    }
    
    struct local {
        static let LocalDocument = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    //MARK: TIME FORMAT
    func TimeFormatter_12H() -> DateFormatter {
        //06:35 PM
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }
    
    func showPopUpMsgOnWindow(msg: String, response: Bool){
        AppDelegate.shared.window?.showTopPop(message: msg, response: response)
    }
    
    func startInternetCheckTimer(){
        
        if !Singleton.internetCheckTimer.isValid{
            Singleton.internetCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { (_) in
                
                if !InternetCheck.isConnectedToNetwork(){
                    if !Singleton.noInternetViewLoaded{
                        DispatchQueue.main.async {
                            Singleton.noInternetViewLoaded = true
                            AppDelegate.shared.window?.loadNoInternetConnectionView()
                        }
                    }
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        Singleton.noInternetViewLoaded = false
                        Singleton.noInternetConnectionView?.gifImageView.isHidden = true
                        Singleton.noInternetConnectionView?.removeFromSuperview()
                        AppDelegate.shared.window?.layoutIfNeeded()
                    }
                }
                
            })
        }
        
    }
    
    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        if (unit == "K") {
            dist = dist * 1.609344
        }
        else if (unit == "N") {
            dist = dist * 0.8684
        }
        return dist
    }
    
    func deg2rad(deg:Double) -> Double {
        return deg * .pi / 180
    }
    
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / .pi
    }
    
    static func changeRootVc(vc: UIViewController){
        let navigation = UINavigationController(rootViewController: vc)
        navigation.isNavigationBarHidden = true
        AppDelegate.shared.window?.rootViewController = navigation
        AppDelegate.shared.window?.makeKeyAndVisible()
    }
    
}

extension Global{
    ///To check that user mobile number verified or not.
    //    func checkIsMobileVerified()-> Bool{
    //
    //        return StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.isUserMobileNumberVerified)as? String ?? "" == "0" ? false:true
    //
    //    }
    
    static func storeLoginData(dicResult: NSDictionary){
        
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"first_name") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USERFIRSTNAME)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"last_name") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USERLASTNAME)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"email_id") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.UserEMail)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"date_of_birth") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USER_DOB)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"profile_image") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USERPROFILEIMAGEURL)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"is_verify") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USER_IsVarify)
        
        //Added for single signon
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"is_social_email_verified") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USER_IS_social_email_verified)
        
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"is_social") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USER_IS_social)
        
        // ADDITONAL
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"gender") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.UserGender)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"mobile_number") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.UserMobile)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"facebook_id") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USERID_FB)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"google_id") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USERID_GG)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"twitter_id") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.USERID_TW)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"bt_customer_id") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.Customer_ID)
        
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.value(forKey: "is_mobile_verified")as? String ?? "") as AnyObject, forKey: Global.g_UserData.isUserMobileNumberVerified)
        StaticClass.sharedInstance.saveToUserDefaults((dicResult.value(forKey: "mobile_number")as? String ?? "")as AnyObject, forKey: Global.g_UserData.UserMobile)
    }
    
    static func getUserProfile_Web(vc: UIViewController, outputBlock: @escaping(_ response: Bool, _ data: NSDictionary)-> Void){
        
        let stringwsName = "profile_details/id/\(StaticClass.sharedInstance.strUserId)"
        
        APICall.shared.getWeb(stringwsName, withLoader: false, successBlock: { (response) in
            
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool){
                    Singleton.userProfileData = dict
                    if let userDataArray = dict["USER_DETAILS"]as? [[String:Any]], userDataArray.count > 0{
                        _ = UserDataModel.init(dict: userDataArray[0])                        
                        Global.storeLoginData(dicResult: userDataArray[0] as NSDictionary)
                        outputBlock(true, response as? NSDictionary ?? [:])
                    }
                } else {
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict.object(forKey: "MESSAGE")as? String ?? "", vc: vc)
                    Global.appdel.setNavigationFlow()
                }
            }else{
                
            }
        }) { (error) in
            StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "", vc: vc)
        }
        
    }
    
}

extension UIViewController{
    
    func checkAccountValidForRental()-> Bool{
        if UserDataModel.sharedInstance?.totalNumberOfRides ?? 0 > 0{
            if UserDataModel.sharedInstance?.mobile_number ?? "" != "" && UserDataModel.sharedInstance?.email_id ?? "" != ""{
                return true
            }else{
                if UserDataModel.sharedInstance?.email_id ?? "" == ""{
                    self.loadProfileCompletionPopUp(desc: "Please verify your Email ID before taking another rental.")
                }else if UserDataModel.sharedInstance?.mobile_number ?? "" == ""{
                    self.loadProfileCompletionPopUp(desc: "Please verify your mobile number before taking another rental.")
                }
                return false
            }
        }else{
            return true
        }
    }
    
    func lockLog_Web(params: [String:Any]){
        let reqParams = NSMutableDictionary(dictionary: params)
        reqParams.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        APICall.shared.postWeb("lock_log", parameters: reqParams, showLoder: false, successBlock: { (response) in
            print("Response from lock_log: ", response)
            if let status = response["FLAG"]as? Int, status == 1{
                
            }
        }) { (error) in
            print("Response from lock_log")
            self.showTopPop(message: error as? String ?? "Error", response: false)
        }
    }
    
    func cancelRental_Web(paymentId: String, outputBlock: @escaping(_ response: Bool)-> Void){
        
        let params = NSMutableDictionary()
        params.setValue(paymentId, forKey: "payment_id")
        params.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        APICall.shared.postWeb("cancel_booking", parameters: params, showLoder: true) { (response) in
            if let status = response["FLAG"]as? Int, status == 1{
                outputBlock(true)
            }else{
                outputBlock(false)
            }
        } failure: { (error) in
            self.showTopPop(message: error as? String ?? "Error", response: false)
            outputBlock(false)
        }
        
    }
    
    func lockUnlock_Web(assetId: String, outputBlock: @escaping(_ response: Bool)-> Void){
        let strUserId = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserID) as? String ?? ""
        
        let params = NSMutableDictionary()
        params.setValue(strUserId, forKey:"user_id")
        params.setValue(StaticClass.sharedInstance.retriveFromUserDefaultsStrings(key: Global.g_UserData.BookingID), forKey: "booking_id")
        params.setValue("\(StaticClass.sharedInstance.latitude)", forKey:"latitude")
        params.setValue("\(StaticClass.sharedInstance.longitude)", forKey:"longitude")
        params.setValue("1", forKey: "event") // (0:lock, 1:unlock)
        params.setValue("1", forKey:"lock_status") //(1:Booking Started, 2:Booking Finished, 3:Intermediate Lock , 4:Intermediate Unlock)
        params.setValue(assetId, forKey: "object_id")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("lock_unlock", parameters: params, showLoder: true) { (response) in
            if let status = response["FLAG"]as? Int, status == 1{
                outputBlock(true)
            }
        } failure: { (error) in
            self.showTopPop(message: error as? String ?? "", response: false)
        }
    }
    
    func stringToBytes(_ string: String) -> [UInt8]? {
        let length = string.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
}
