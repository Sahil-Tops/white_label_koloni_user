//
//  StaticClass.swift
//  SwiftDemo
//
//  Created by Ilesh_Panchal on 02/03/2015.
//  Copyright (c) 2015 Ilesh_Panchal. All rights reserved.


import UIKit
import ISMessages
import GradientCircularProgress
import CoreBluetooth

class StaticClass {
    
    static let sharedInstance = StaticClass()
    var loadBgView = UIView()
    
    var arrGender : NSMutableArray = NSMutableArray()
    var arrAmenities : NSMutableArray = NSMutableArray()
    var arrRunningBookingId = NSMutableArray()
    var arrRunningObjectId = NSMutableArray()
    var progressBar = GradientCircularProgress()
    var shareDevice = ShareDevice()
    var window = UIApplication.shared.keyWindow
    let logoImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 68, height: 68))
    
    //MARK: - Variable values set
    var latitude :CGFloat  {
        get{
            return CGFloat(truncating: retriveFromUserDefaults(Global.g_UserDefaultKey.latitude) as? NSNumber ?? 38.889248)
        }
    }
    var longitude :CGFloat {
        get{
            return CGFloat(truncating: retriveFromUserDefaults(Global.g_UserDefaultKey.longitude) as? NSNumber ?? -77.050636)
        }
    }
    
    var strUserId : String {
        get {
            return String(describing: retriveFromUserDefaults(Global.g_UserData.UserID) as! String)
        }
    }
    var strUserName : String {
        get {
            return String(describing: retriveFromUserDefaults(Global.g_UserData.UserName) as! String)
        }
    }
    //    var strPartnerId : String {
    //        get {
    //            let str = retriveFromUserDefaultsStrings(key: Global.g_UserData.PartnerID)
    //            return str!
    //        }
    //    }
    
    var strDeviceToken : String {
        get {
            return retriveFromUserDefaults(Global.g_UserDefaultKey.DeviceToken) as? String ?? ""
        }
    }
    
    var strUniqueCode : String {
        get {
            return retriveFromUserDefaults(Global.g_UserDefaultKey.UniqueCode) as? String ?? ""
        }
    }
    
    var is_OverlayStart : Bool {
        get {
            return retriveFromUserDefaults(Global.g_UserDefaultKey.Is_StartOverlay) as? Bool ?? false
        }
    }
    
    var is_bookingStart : Bool {
        get {
            return retriveFromUserDefaults(Global.g_UserDefaultKey.Is_StartBooking) as? Bool ?? false
        }
    }
    
    var strNavigationFlow : String {
        get {
            let str = retriveFromUserDefaultsStrings(key: Global.g_UserData.isNavigationFlow)
            return str!
        }
    }
    var strBookingId : String {
        get {
            let str = retriveFromUserDefaultsStrings(key: Global.g_UserData.BookingID)
            return str!
        }
    }
    var strTempBookingRentalStoreID : String {
        get {
            let str = retriveFromUserDefaultsStrings(key: Global.g_UserData.TempBookingRentalStoreID)
            return str!
        }
    }
    
    var strObjectId : String {
        get {
            let str = retriveFromUserDefaultsStrings(key: Global.g_UserData.ObjectID)
            return str!
        }
    }
    
    var strTempOrderId : String {
        get {
            let str = retriveFromUserDefaultsStrings(key: Global.g_UserData.TempBookingID)
            return str!
        }
    }
    
    var strAssetType: String{
        get{
            let str = retriveFromUserDefaultsStrings(key: Global.asset_type)
            return str ?? ""
        }
    }
    
    func retriveFromUserDefaultsBool(key: String) -> Bool{
        if let response = UserDefaults.standard.value(forKey: key)as? Bool, response{
            return true
        }else{
            return false
        }
    }
    
    func retriveFromUserDefaultsStrings (key: String) -> String? {
        let defaults = UserDefaults.standard
        if let strVal = defaults.string(forKey: key as String) {
            return strVal
        }
        else{
            return "" as String?
        }
    }
    
    func isPasswordValid(_ password : String) -> Bool{
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@","^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[-#$%^&*,+!@?=:/.();\\]\\'<>{\\[\\}_|~`])[A-Za-z0-9-#$%^&*,+!@?=:/.();\\]\\'<>{\\[\\}_|~`]{7,}")
        
        return passwordTest.evaluate(with: password)
    }
    
    //MARK: - NOTIFICATION MESSAGE
    func ShowNotification(_ success:Bool,strmsg:String, vc: UIViewController! = nil) -> Void {
        
        if success {
            if vc != nil{
                vc.showTopPop(message: strmsg, response: true)
            }else{
                AppDelegate.shared.window?.showTopPop(message: strmsg, response: true)
            }
        }else{
            if vc != nil{
                vc.showTopPop(message: strmsg, response: false)
            }else{
                AppDelegate.shared.window?.showTopPop(message: strmsg, response: false)
            }
        }
    }
    
    func PriceFormater(price:Double) -> String {
        return String(format: "$%.2f",price)
    }
    
    //MARK: - SPINNER METHODS
    func ShowSpiner(_ msg: String = "", _ showBackgroundColor: Bool = false) -> Void {
        DispatchQueue.main.async {
            print("Starting loader")
            
            AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "loader_img") { (image) in
                self.window = UIApplication.shared.keyWindow
                self.loadBgView.frame = self.window!.bounds
                self.loadBgView.backgroundColor = CustomColor.transparentDarkGray
                self.progressBar.show(message: msg, style: MyStyle())
                self.logoImg.image = image
                self.logoImg.contentMode = .scaleAspectFit
                self.logoImg.center = (self.window?.center)!
                self.logoImg.circleObject()
                self.window?.backgroundColor = .clear
                self.window?.addSubview(self.loadBgView)
                self.window!.addSubview(self.logoImg)
            }
            
        }
    }
    func HideSpinner() -> Void {
        DispatchQueue.main.async {
            print("Stoping loader")
            self.progressBar.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.loadBgView.removeFromSuperview()
                self.logoImg.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Save to NSUserdefault
    func saveToUserDefaults (_ value: AnyObject?, forKey key: String) {
        let defaults = UserDefaults.standard
        if let object = value{
            do{
                let archive = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
                defaults.set(archive, forKey: key as String)
            }catch{
                
            }
        }
    }
    
    func saveToUserDefaultBool(forkey key: String, value: Bool) {
        let defaults = UserDefaults.standard
        defaults.setValue(value, forKey: key)
    }
    
    func saveToUserDefaultsString (value: String, forKey key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value , forKey: key as String)
        defaults.synchronize()
    }
    
    func retriveFromUserDefaults (_ key: String) -> AnyObject? {
        let defaults = UserDefaults.standard
        if(defaults.value(forKey: key as String) != nil){
            if let data = defaults.value(forKey: key as String)as? Data{
                do{
                    let unarchives = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                    return unarchives as AnyObject?
                }catch{
                    return "" as AnyObject?
                }
            }else{
                return "" as AnyObject?
            }
        }else{
            return "" as AnyObject?
        }
        
    }
    
    // MARK: - Validation
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailText = NSPredicate(format:"SELF MATCHES [c]%@",emailRegex)
        return (emailText.evaluate(with: email))
    }
    func validatePhoneNumber(_ value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func isValidatePhoneNumber(_ candidate: String) -> Bool {
        if candidate.count <= 14 && candidate.count > 6
        {
            let phoneRegex: String = "[0-9]{8}([0-9]{1,3})?"
            let test: NSPredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return test.evaluate(with: candidate)
        }
        else{
            return false
        }
    }
    
    func isUsernameValid_aA9(_ strUser:String,WithAccept Charecter:String) -> Bool{
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789\(Charecter)")
        if strUser.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }else{
            return true
        }
    }
    
    //MARK: LOGS ALL FONTS INSTALLS
    func fontDisplayAllFonts() -> Void {
        for family: String in UIFont.familyNames
        {
            for _: String in UIFont.fontNames(forFamilyName: family)
            {
            }
        }
    }
    
    // MARK: - General Methods
    func removeNull (_ str:String) -> String {
        if (str == "<null>" || str == "(null)" || str == "N/A" || str == "n/a" || str.isEmpty || str == "null" || str == "NSNull") {
            return ""
        } else {
            return str
        }
    }
    
    func getDouble(value:Any) -> Double {
        if let double_V = value as? Double {
            return double_V
        } else if let Int_V = value as? Int {
            return Double(Int_V)
        }else if let String_V = value as? String {
            return String_V.toDouble()
        }
        else{
            return 0.0
        }
    }
    
    func getInterGer(value:Any) -> Int {
        if let double_V = value as? Double {
            return Int(double_V)
        } else if let Int_V = value as? Int {
            return Int_V
        }else if let String_V = value as? String {
            return Int(String_V.toDouble())
        }
        else{
            return 0
        }
    }
    
    func setPrefixHttp (_ str:NSString) -> NSString {
        if (str == "" || str .hasPrefix("http://") || str .hasPrefix("https://")) {
            return str
        } else {
            return "http://".appendingFormat(str as String) as NSString
        }
    }
    
    func isconnectedToNetwork() -> Bool {
        return true
    }
    //MARK: TIME FORMAT
    func TimeFormatter_12H() -> DateFormatter {
        //06:35 PM
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }
    
    func TimeFormatter_24_H() -> DateFormatter {
        //19:29:50
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }
    
    func dateFormatter(formatStr: String) -> DateFormatter {
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatStr
        return dateFormatter
    }
    
    func dateFormatterForDisplay() -> DateFormatter {
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        return dateFormatter
    }
    func dateFormatterForDisplay_DMMMY() -> DateFormatter {
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        return dateFormatter
    }
    func dateFormatterForCall() -> DateFormatter {
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    func dateFormatterForCallBirthDay() -> DateFormatter {
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    func dateFormatterForYearOnly() -> DateFormatter {
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter
    }
    func dateFormatterForMonthINNumberOnly() -> DateFormatter {
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter
    }
    func dateFormatterForDaysMonthsYears() -> DateFormatter {
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, d LLL yyyy"
        return dateFormatter
    }
    func dateFormatterForYMD_T_HMSsss() -> DateFormatter {
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter
    }
    func dateFormatterForYMD_T_HMS() -> DateFormatter {
        var dateFormatter: DateFormatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }
    
    //MARK: COLOR FORMATE
    func getUIColorFromRBG (R rVal: CGFloat, G gVal: CGFloat, B bVal: CGFloat) -> UIColor {
        return UIColor(red: rVal/255.0, green: gVal/255.0, blue: bVal/255.0, alpha: 1.0)
    }
    
    func getUIColorFromRBGAlpha (R rVal: CGFloat, G gVal: CGFloat, B bVal: CGFloat, Alpha alpha: CGFloat) -> UIColor {
        return UIColor(red: rVal/255.0, green: gVal/255.0, blue: bVal/255.0, alpha: alpha)
    }
    
    //MARK: DATE AND TIME
    
    func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    //MARK: CHECK APP INSTALATION NUMBERS    
    func isAppLaunchedFirst()->Bool{
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnceMode"){
            return false
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnceMode")
            return true
        }
    }
    
    func checkAppIsLaunchInDay()-> Bool{
        let strToday = self.dateFormatterForCall().string(from: Date() as Date)
        let strDate = self.retriveFromUserDefaults("ISAPPLAUNCH_TODAYFIRST") as? String
        if (strDate != nil) {
            if strDate == strToday{
                return false
            } else {
                StaticClass.sharedInstance.saveToUserDefaults(strToday as AnyObject? , forKey: "ISAPPLAUNCH_TODAYFIRST")
                return true
            }
        }else{
            StaticClass.sharedInstance.saveToUserDefaults(strToday as AnyObject? , forKey: "ISAPPLAUNCH_TODAYFIRST")
            return true
        }
    }
    
    func setStringAsCardNumberWithSartNumber(_ Number:Int,withString str:String ,withStrLenght len:Int ) -> String{
        //let aString: String = "41111111111111111"
        let arr = str
        var CrediteCard : String = ""
        if arr.count > (Number + len) {
            for (index, element ) in arr.enumerated(){
                if index >= Number && index < (Number + len) {
                    CrediteCard = CrediteCard + String("X")
                }else{
                    CrediteCard = CrediteCard + String(element)
                }
            }
            return CrediteCard
        }else{
        }
        return str
    }
    
    deinit {
        print("Static Denited....")
    }
    
}

