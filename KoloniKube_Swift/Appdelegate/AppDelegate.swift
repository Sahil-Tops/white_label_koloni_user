
//
//  AppDelegate.swift
//  Club Mobile Application
//
//  Created by Tops on 12/7/16.
//  Copyright © 2016 Self. All rights reserved.

import UIKit
import IQKeyboardManagerSwift
import DropDown
import CoreLocation
import UserNotifications
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import LinkaAPIKit
import SystemConfiguration
import CoreData
import AKSideMenu
import Firebase
import FirebaseAnalytics
import SDWebImage
import Braintree

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate,UITabBarDelegate,CLLocationManagerDelegate{
    
    //MARK:- Global Variables -
    var window: UIWindow?
    static var shared: AppDelegate!    
    var navigation : UINavigationController?
    var loginWithGoogleAppleVc : LoginWithGoogleAppleVC?
    var lunchVC : LaunchScreenVC?
    var locationManager = CLLocationManager()
    var appLinkaAPIManager : AppLinkaAPIManager!
    var intReqestMinite = 0
    var locationTracker: LocationTracker?
    var strIsUserType = String()
    var is_rentalRunning = false
    var isFadBGClear = Bool()
    var getCurrentAppVersion = String()
    var getCurrentDeviceName = String()
    var total_distance = ""
    
    //MARK:- Application Life Cycle -
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Firebase configuration
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = "168688252397-278f4bgtd2hqfei7rqtj8dchs0jo5n71.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self
        BTAppSwitch.setReturnURLScheme("com.app.kolonishare.payments")
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk {
            
        }
        
        // Get Current Application version
        self.getCurrentApplicationVersion()
        self.getDeviceName()
        
        // set the minimimum background Fetch interval
//        UIApplication.shared.setMinimumBackgroundFetchInterval(2)
        
        self.createFolder()
        
        // For Push Notifications
        if #available(iOS 9.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(lowPowerModeStateChange), name: NSNotification.Name.NSProcessInfoPowerStateDidChange, object: nil)
        } else {
            //kalpesh
            self.intReqestMinite = 5
        }
        
        // Check Low Power State
        self.lowPowerModeStateChange()
        self.setupLocationManager()
        // Set up Linka
        self.setupLinkaLock()
        // IQkeyboard initiallization
        IQKeyboardManager.shared.enable = true
        
        // TODO: CHANGE THE BUNDLE IN URL SCHEMA GOOGLE MAP SERVICE
        GMSServices.provideAPIKey(GoogleAPIKey)
        GMSPlacesClient.provideAPIKey(GoogleAPIKey)
        
        self.registrationForNotification()
        
        // Check whether application launched first time
        if StaticClass.sharedInstance.isAppLaunchedFirst() {
            StaticClass.sharedInstance.saveToUserDefaults((false) as AnyObject, forKey: Global.g_UserDefaultKey.IS_USERLOGIN)
        }
        if let notification = launchOptions?[.remoteNotification] as? NSDictionary {
            self.notificationReceived(notification: notification as [NSObject : AnyObject])
        }
        _ = AppLocalStorage.init()
        type(of: self).shared = self
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if Singleton.lastViewController == "BookNowVC"{
            Global.appdel.setUpSlideMenuController()
            Singleton.lastViewController = ""
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0;
    }
    
    func applicationWillTerminate(_ application: UIApplication) { }
    
    func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) { }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let scheme = url.scheme{
            if #available(iOS 9.0, *) {
                if (scheme.isEqual("com.app.kolonishare.payments")){
                    print("In Payment block url")
                    if scheme.localizedCaseInsensitiveCompare("com.app.kolonishare.payments") == .orderedSame {
                        print("URL: - ", url)
                        return BTAppSwitch.handleOpen(url, options: options)
                    }
                    return false
                }else if scheme.localizedCaseInsensitiveCompare("com.kolonishare") == .orderedSame, let host = url.host {
                    print("Host - ", host)
                    var parameters: [String: String] = [:]
                    URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                        parameters[$0.name] = $0.value
                    }
                    if host == "email_verify"{
                        Singleton.emailConfirmationToken = parameters["user_id"] ?? ""
                        let otpVc = OtpVerificationVC(nibName: "OtpVerificationVC", bundle: nil)
                        otpVc.login_type = "email"
                        if Singleton.editProfileVc != nil{
                            otpVc.backVc = Singleton.editProfileVc!
                        }
                        Global.changeRootVc(vc: otpVc)
                    }
                    return true
                }else{
                    return ((GIDSignIn.sharedInstance()?.handle(url)) != nil)
                }
            } else {
                return true
            }
        }else{
            return true
        }
        
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // execute code here
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //MARK:- Get current application version -
    func getCurrentApplicationVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            getCurrentAppVersion = "\(version)"
            print("Current Version is",version)
        }
    }
    
    func getDeviceName(){
        self.getCurrentDeviceName = UIDevice.current.modelName
    }
    
    
    //MARK:- Get running Booking Details -
    func userRunningRental_Web(loader: Bool) {
        
        let stringwsName = "user_running_rental/user_id/\(StaticClass.sharedInstance.strUserId)"
        
        APICall.shared.getWeb(stringwsName, withLoader: loader, successBlock: { (response) in
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool){
                    if let arrResult = dict["CURRENT_RENTAL"] as? NSArray , arrResult.count > 0  {
                        var arrRentalStoreID = [String]()
                        
                        for i in 0...arrResult.count - 1 {
                            if let dicResult = arrResult[i] as? NSDictionary {
                                arrRentalStoreID.append(dicResult.object(forKey: "payment_id")as? String ?? "")
                            }
                        }
                        if StaticClass.sharedInstance.strTempBookingRentalStoreID != "" {
                            if arrRentalStoreID.contains(StaticClass.sharedInstance.strTempBookingRentalStoreID){
                                StaticClass.sharedInstance.saveToUserDefaultsString(value:StaticClass.sharedInstance.strTempBookingRentalStoreID, forKey: Global.g_UserData.BookingID)
                                self.pushToSideMenuVC()
                                
                            } else {
                                if arrResult.count > 0{
                                    if let dicResult = arrResult[0] as? NSDictionary {
                                        _ = dicResult.object(forKey: "payment_id") as? String ?? ""
                                        self.pushToSideMenuVC()
                                    }
                                }
                            }
                            
                        } else {
                            if let dicResult = arrResult[0] as? NSDictionary {
                                let strOrderId = dicResult.object(forKey: "payment_id") as? String ?? ""
                                StaticClass.sharedInstance.saveToUserDefaultsString(value:strOrderId, forKey: Global.g_UserData.BookingID)
                                self.pushToSideMenuVC()
                            }
                        }
                    } else {
                        StaticClass.sharedInstance.saveToUserDefaultsString(value:"", forKey: Global.g_UserData.BookingID)
                        self.pushToSideMenuVC()
                    }
                } else {
                    if(StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserDefaultKey.IS_USERLOGIN) as? Bool ?? false) {
                        DispatchQueue.main.async {
                            StaticClass.sharedInstance.saveToUserDefaultsString(value:"", forKey: Global.g_UserData.BookingID)
                            self.pushToSideMenuVC()
                        }
                    } else {
                        Global.appdel.setNavigationFlow()
                    }
                }
            }
        }) { (error) in
            
        }
    }
    
    //MARK:- Set Navigation for Launch Screen -
//    func setNavigationLaunchFlow() {
//        self.lunchVC = LaunchScreenVC(nibName: "LaunchScreenVC", bundle:nil)
//        self.navigation = UINavigationController(rootViewController: lunchVC!)
//        self.navigation?.isNavigationBarHidden = true
//        self.window?.rootViewController = navigation
//        self.window?.makeKeyAndVisible()
//    }
    //MARK:- Set Navigation for Login Screen -
    func setNavigationFlow() {
        self.loginWithGoogleAppleVc = LoginWithGoogleAppleVC(nibName: "LoginWithGoogleAppleVC", bundle: nil)
        self.navigation = UINavigationController(rootViewController: loginWithGoogleAppleVc!)
        self.navigation?.isNavigationBarHidden = true
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
    }
    
    //MARK:- Get User Details -
    func userDetailCall(navigationVc: UINavigationController = UINavigationController(), vc: UIViewController = UIViewController()) -> Void {
        let stringwsName = "profile_details/id/\(StaticClass.sharedInstance.strUserId)"
        
        APICall.shared.getWeb(stringwsName, withLoader: false, successBlock: { (response) in
            
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool){                    
                    if let arrResult = dict["USER_DETAILS"] as? NSArray, arrResult.count > 0{
                        if arrResult[0] is NSDictionary {                            
                            Singleton.userData = arrResult[0] as! [String:Any]
                            Singleton.userProfileData = dict
                            _ = UserDataModel.init(dict: Singleton.userData)
                            NotificationCenter.default.post(name:Notification.Name(rawValue:Global.notification.Push_ProfileDataCall), object: nil, userInfo: nil)
                            StaticClass.sharedInstance.saveToUserDefaults(((arrResult[0] as! NSDictionary).value(forKey: "is_mobile_verified")as? String ?? "") as AnyObject, forKey: Global.g_UserData.isUserMobileNumberVerified)
                            StaticClass.sharedInstance.saveToUserDefaults(((arrResult[0] as! NSDictionary).value(forKey: "mobile_number")as? String ?? "")as AnyObject, forKey: Global.g_UserData.UserMobile)
                            if vc.isKind(of: LaunchScreenVC.self){
                                Global.appdel.userRunningRental_Web(loader: false)
                            }
                        }
                    }
                } else {
                    Global.appdel.setNavigationFlow()
                }
            }else{
                
            }
        }) { (error) in
            StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "")
        }
    }
    //MARK:- Set Up Linka Lock -
    func setupLinkaLock()  {
        self.appLinkaAPIManager = AppLinkaAPIManager()
        self.appLinkaAPIManager.initializeLocationManager()
        LinkaAPIService.setAPIProtocol(_protocol: appLinkaAPIManager)
        LocksController.initialize()
        _ = LinkaBLECentralManager.sharedInstance()        
    }
    
    //MARK:- Check Location Manager Permissions -
    func checkLocationMangereMethod() {
        self.locationTracker = LocationTracker()
        self.updateLocationMethod()
    }
    
    //MARK:- Track Location in Some interval -
    @objc func updateLocationMethod() {
        if StaticClass.sharedInstance.is_bookingStart {
            print("Booking started")
            self.locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.showsBackgroundLocationIndicator = true
            self.locationTracker?.startLocationTracking()
            print("Start background location 5")
        }else{
            print("Booking stopped")
            self.locationManager.stopUpdatingLocation()
            self.locationManager.stopMonitoringSignificantLocationChanges()
            self.locationManager.allowsBackgroundLocationUpdates = false
            self.locationManager.showsBackgroundLocationIndicator = false
            self.locationTracker?.stopLocationTracking()
            print("Stop background location 5")
        }
    }
    
    //MARK:- Generate unique Code -
    func uniqueCodeGenerator()-> String{
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var randomString = ""
        
        for _ in 0 ..< 8 {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString += String(letters.character(at: Int(rand)))
        }
        return randomString
    }
    
    //MARK: LOGOUT -
    func logoutUser() -> Void {
        self.userLogoutCall()
    }
    
    //MARK:- LOCATION UPDATE -
    func setupLocationManager(){
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.startUpdatingLocation()
        if #available(iOS 9.0, *) {
        } else {
            // Fallback on earlier versions
        }
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
        StaticClass.sharedInstance.saveToUserDefaults(locationValue.latitude as AnyObject?, forKey: Global.g_UserDefaultKey.latitude)
        StaticClass.sharedInstance.saveToUserDefaults(locationValue.longitude as AnyObject?, forKey: Global.g_UserDefaultKey.longitude)
    }
    
    //MARK:-  Create Document Folder for storing Koloni Receipt -
    func createFolder() {
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent("KOLONI_RIDE_RECEIPT")
            
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                }
            }
        }
    }
    
    //MARK:-  LOGOUT CALL -
    private func userLogoutCall() -> Void {
        let strUrl = "logout/id/\(StaticClass.sharedInstance.strUserId)"
        APICall.shared.getWeb(strUrl, withLoader: true, successBlock: { (response) in
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool){
                    
                    UserDefaults.standard.set(false, forKey: "hasBeenLaunchedBeforeFlag")
                    UserDefaults.standard.removeObject(forKey: "dont_show_on_linka_view")
                    UserDefaults.standard.synchronize()
                    
                    StaticClass.sharedInstance.saveToUserDefaultsString(value:"" , forKey: Global.g_UserData.BookingID)
                    StaticClass.sharedInstance.saveToUserDefaultsString(value:"" , forKey: Global.g_UserData.ObjectID)
                    StaticClass.sharedInstance.saveToUserDefaultsString(value:"", forKey: Global.g_UserData.TempBookingRentalStoreID)
                    StaticClass.sharedInstance.saveToUserDefaults((false) as AnyObject, forKey: Global.g_UserDefaultKey.IS_USERLOGIN)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.UserID)
                    
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERFIRSTNAME)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERLASTNAME)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.UserEMail)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USER_DOB)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERPROFILEIMAGEURL)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USER_IsVarify)
                    
                    // ADDITONAL
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.UserGender)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.UserMobile)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERID_FB)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERID_GG)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERID_TW)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USER_IsVarify)
                    StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.Customer_ID)
                    StaticClass.sharedInstance.saveToUserDefaultsString(value:"" , forKey: Global.g_UserData.BookingID)
                    StaticClass.sharedInstance.saveToUserDefaultsString(value:"" , forKey: Global.g_UserData.ObjectID)
                    StaticClass.sharedInstance.saveToUserDefaults(false as AnyObject , forKey: Global.g_UserDefaultKey.Is_StartBooking)
//                    StaticClass.sharedInstance.saveToUserDefaultBool(forkey: "is_email_or_mobile_updation_failed", value: false)
                    GIDSignIn.sharedInstance().signOut()
                    Global.appdel.is_rentalRunning = false
                    UserDefaults.standard.set(false, forKey: "isRippleEffectClosed")
                    UserDefaults.standard.set(false, forKey: "dont_show_app_store_rating")
                    Global.appdel.setNavigationFlow()
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "")
                }
            }
        }) { (error) in
            
        }
    }
    
    func forceLogout(){
        UserDefaults.standard.set(false, forKey: "hasBeenLaunchedBeforeFlag")
        UserDefaults.standard.synchronize()
        
        StaticClass.sharedInstance.saveToUserDefaultsString(value:"", forKey: Global.g_UserData.TempBookingRentalStoreID)
        StaticClass.sharedInstance.saveToUserDefaults((false) as AnyObject, forKey: Global.g_UserDefaultKey.IS_USERLOGIN)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.UserID)
        
        StaticClass.sharedInstance.saveToUserDefaultsString(value:"" , forKey: Global.g_UserData.BookingID)
        StaticClass.sharedInstance.saveToUserDefaultsString(value:"" , forKey: Global.g_UserData.ObjectID)
        
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERFIRSTNAME)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERLASTNAME)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.UserEMail)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USER_DOB)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERPROFILEIMAGEURL)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USER_IsVarify)
        
        // ADDITONAL
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.UserGender)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.UserMobile)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERID_FB)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERID_GG)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USERID_TW)
        StaticClass.sharedInstance.saveToUserDefaults("" as AnyObject, forKey: Global.g_UserData.USER_IsVarify)
        Global.appdel.setNavigationFlow()
    }
    
    func locationUpdatesCall(vc: UIViewController) -> Void {
        
        let infoPacket = LockConnectionService.lockInfoPacket
        let rssi = infoPacket?.m_RSSI
        let crrUserId = StaticClass.sharedInstance.strUserId
        var bookingIdString = ""
        var objectIdString = ""
        for i in 0..<Singleton.runningRentalArray.count{
            bookingIdString.append("\(Singleton.runningRentalArray[i]["id"]as? String ?? ""),")
            objectIdString.append("\(Singleton.runningRentalArray[i]["object_id"]as? String ?? ""),")
        }
        if bookingIdString != ""{
            bookingIdString.removeLast()
        }
        if objectIdString != ""{
            objectIdString.removeLast()
        }
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(crrUserId, forKey: "user_id")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        paramer.setValue(objectIdString, forKey: "object_id")
        paramer.setValue(bookingIdString, forKey: "booking_id")
        paramer.setValue(String(describing: StaticClass.sharedInstance.latitude), forKey: "latitude")
        paramer.setValue(String(describing: StaticClass.sharedInstance.longitude), forKey: "longitude")
        paramer.setValue("\(rssi ?? 0)", forKey: "rssi_value")
        
        if StaticClass.sharedInstance.strBookingId.count == 0 || StaticClass.sharedInstance.strObjectId.count == 0 {
            return;
        }        
        APICall.shared.postWeb("track_location", parameters: paramer, showLoder: false, successBlock: { (response) in
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool) {
                    
                    if let arrResult = dict["BOOKING"] as? NSArray{
                        Singleton.trackLocationRentalArray = arrResult as? [[String:Any]] ?? []
                        if let bookNowVc = vc as? BookNowVC{
                            if bookNowVc.selectedRentalIndex < Singleton.trackLocationRentalArray.count && bookNowVc.selectedRentalIndex != -1{
                                bookNowVc.currentRentalAmount_lbl.text = "$\(Singleton.trackLocationRentalArray[bookNowVc.selectedRentalIndex]["total_price"]as? String ?? "0.0")"
                            }
                        }
                        if arrResult.count == 0 {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadVc"), object: nil)
                            StaticClass.sharedInstance.arrRunningBookingId.removeAllObjects()
                            StaticClass.sharedInstance.arrRunningObjectId.removeAllObjects()
                        }
                        for element in arrResult {
                            if let dict = element as? NSDictionary {
                                
                                if dict["total_distance"] != nil {
                                    self.total_distance = "\(dict["total_distance"] ?? "0.00")"
                                }
                                let strBookingID = dict.object(forKey: "booking_id")as? String ?? "0"
                                StaticClass.sharedInstance.saveToUserDefaultsString(value:strBookingID , forKey: Global.g_UserData.BookingID)
                                
                                if !StaticClass.sharedInstance.arrRunningBookingId.contains(strBookingID) {
                                    StaticClass.sharedInstance.arrRunningBookingId.add(strBookingID)
                                }
                                
                                let strObjectID = dict.object(forKey: "object_id")as? String ?? "0"
                                StaticClass.sharedInstance.saveToUserDefaultsString(value:strObjectID , forKey: Global.g_UserData.ObjectID)
                                
                                if !StaticClass.sharedInstance.arrRunningObjectId.contains(strObjectID) {
                                    StaticClass.sharedInstance.arrRunningObjectId.add(strObjectID)
                                }
                            }
                        }
                    }
                    
                } else {
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "")
                }
            }
        }) { (error) in
            
        }
    }
    
    //MARK:-  LOW POWER MODE -
    @objc func lowPowerModeStateChange() -> Void {
        if #available(iOS 9.0, *) {
            if ProcessInfo.processInfo.isLowPowerModeEnabled {
                self.intReqestMinite = 5
            } else {
                self.intReqestMinite = 5
            }
        }
    }
    
    //MARK:- PUSH NOTIFICATION REGISTER -
    func registrationForNotification() -> Void {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    
                }
            }
        }else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
        }
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        DispatchQueue.main.async(execute: {
            UIApplication.shared.registerForRemoteNotifications()
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func setUpSlideMenuController() {
        StaticClass.sharedInstance.saveToUserDefaultsString(value:"", forKey: Global.g_UserData.isNavigationFlow)
        self.pushToSideMenuVC()
    }
    
    func getTopSafeAreaHeight() -> CGFloat{
        self.window = UIApplication.shared.keyWindow
        if #available(iOS 11.0, *) {
            return (self.window?.safeAreaInsets.top)!
        } else {
            // Fallback on earlier versions
            return 0.0
        }
    }
    
    func getBottomSafeAreaHeight() -> CGFloat{
        self.window = UIApplication.shared.keyWindow
        if #available(iOS 11.0, *) {
            return (self.window?.safeAreaInsets.bottom)!
        } else {
            // Fallback on earlier versions
            return 0.0
        }
    }
    
    // MARK: - Core Data stack -
    
    @available(iOS 10.0, *)
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "KoloniKube_Swift")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support -
    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK: - Side bar setup
    func pushToSideMenuVC(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let bookNowVController = BookNowVC(nibName: "BookNowVC", bundle: nil)
            let leftMenu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftMenuViewController") as! LeftMenuViewController
            let sideMenuViewController: AKSideMenu = AKSideMenu(contentViewController: bookNowVController, leftMenuViewController: leftMenu, rightMenuViewController: nil)
            sideMenuViewController.bouncesHorizontally = false
            sideMenuViewController.contentViewScaleValue = 0.65
            sideMenuViewController.scaleContentView = true
            self.navigation = UINavigationController(rootViewController: sideMenuViewController)
            self.navigation?.isNavigationBarHidden = true
            self.window?.rootViewController = self.navigation
            self.window?.makeKeyAndVisible()
        }
    }
    
}

//MARK:- NOTIFICATION RECEVED METHODS -
extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate{
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Device Token: ", fcmToken ?? "")
        StaticClass.sharedInstance.saveToUserDefaults(fcmToken as AnyObject?, forKey: Global.g_UserDefaultKey.DeviceToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //        if let userInfo = notification.request.content.userInfo as? [String : AnyObject] {
        //            IPNotificationManager.shared.GetPushProcessDataWhenActive(dictNoti: userInfo as NSDictionary)
        //        }
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification received 3: ", response.notification.request.content.userInfo as NSDictionary)
        if let dictionary = response.notification.request.content.userInfo as? [String:Any]{
            Singleton.notificationRunningRentalDetail = dictionary
            print(Singleton.notificationRunningRentalDetail)
        }
        Singleton.isOpeningAppFromNotification = true
        if !Singleton.isCalledDidFinishLaunch{
            self.setUpSlideMenuController()
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Notification received 4: ", userInfo)
        notificationReceived(notification: userInfo as [NSObject : AnyObject])
        switch application.applicationState {
        case .inactive:
            print("Inactive")
            //Show the view with the content of the push
            completionHandler(.newData)
            
        case .background:
            print("Background")
            //Refresh the local model
            completionHandler(.newData)
            
        case .active:
            print("Active")
            //Show an in-app banner
            completionHandler(.newData)
        @unknown default:
            break
        }
    }
    //
    func notificationReceived(notification: [NSObject:AnyObject]) {
        print("Push Notification received 1: ", notification)
    }
    
}

extension AppDelegate: GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

func trackUserInFirebase(userId: String){
    Analytics.setUserID(userId)
}

public extension UIApplication {

    func clearLaunchScreenCache() {
        do {
            try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Library/SplashBoard")
        } catch {
            print("Failed to delete launch screen cache: \(error)")
        }
    }

}
