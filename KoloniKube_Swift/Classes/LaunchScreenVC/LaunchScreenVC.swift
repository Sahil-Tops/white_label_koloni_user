//
//  LaunchScreenVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/24/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit

class LaunchScreenVC: UIViewController {
    
    //MARK: - Outlet's
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var lbl_Version: UILabel!
    @IBOutlet weak var viewBgShowAlert: UIView!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var alertView: UIView!
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        Singleton.currentVc = "launch_screen"
        StaticVariables.window = UIApplication.shared.keyWindow
        self.loadAppData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Singleton.currentVc = ""
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "splash_img") { (image) in
//            self.bgImage.image = image
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction's
    @IBAction func btnUpdateClick(_ sender: UIButton) {
        guard let url = URL(string: "https://itunes.apple.com/us/app/kolonishare/id1265110043?mt=8") else { return }
        UIApplication.shared.open(url, options: [:]) { (_) in
            
        }
    }

}

//MARK: - Web Api's
extension LaunchScreenVC {
    
    //Loading White label Data
    func loadAppData(){
        
        let url = "https://kolonishare.com/super_partner_beta/ws/v1/apiVersion?ios_version=\(appDelegate.getCurrentAppVersion)&partner_id_white_label=\(Singleton.partnerIdWhiteLabel)"
        APICall.shared.getAppData(withUrl: url) { (response) in
            if let data = response as? [String:Any]{
                if let status = data["FLAG"]as? Int, status == 1{
                    if let app_setting = data["application_setting"]as? [String:Any]{
                        var newImg = false
                        StaticClass.sharedInstance.saveToUserDefaults(app_setting as AnyObject, forKey: "application_setting")
                        for (key, value) in app_setting{
                            if key.contains("_img"){
                                let storedImg = StaticClass.sharedInstance.retriveFromUserDefaultsStrings(key: key)
                                print(storedImg ?? "")
                                print(value as? String ?? "")
                                if (value as? String ?? "" != storedImg ?? ""){
                                    print("New image found")
                                    newImg = true
                                    break
                                }else if value as? String ?? "" == ""{
                                    print("No image found")
                                }else{
                                    print("Image exist")
                                }
                            }
                        }
                        if newImg{
                            _ = AppLocalStorage.init()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if UserDefaults.standard.value(forKey: Global.g_UserDefaultKey.IS_USERLOGIN) != nil {
                                if StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserDefaultKey.IS_USERLOGIN) as? Bool ?? false{
                                    self.callAPiForVersionCheck()
                                }else {
                                    AppDelegate.shared.setNavigationFlow()
                                }
                            }else{
                                AppDelegate.shared.setNavigationFlow()
                            }
                        }
//                        if !StaticClass.sharedInstance.retriveFromUserDefaultsBool(key: "is_images_loaded"){
//                            StaticClass.sharedInstance.saveToUserDefaultBool(forkey: "is_images_loaded", value: true)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                if UserDefaults.standard.value(forKey: Global.g_UserDefaultKey.IS_USERLOGIN) != nil {
//                                    if StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserDefaultKey.IS_USERLOGIN) as? Bool ?? false{
//                                        self.callAPiForVersionCheck()
//                                    }else {
//                                        AppDelegate.shared.setNavigationFlow()
//                                    }
//                                }else{
//                                    AppDelegate.shared.setNavigationFlow()
//                                }
//                            }
//                        }else{
//                            if UserDefaults.standard.value(forKey: Global.g_UserDefaultKey.IS_USERLOGIN) != nil {
//                                if StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserDefaultKey.IS_USERLOGIN) as? Bool ?? false{
//                                    self.callAPiForVersionCheck()
//                                }else {
//                                    AppDelegate.shared.setNavigationFlow()
//                                }
//                            }else{
//                                AppDelegate.shared.setNavigationFlow()
//                            }
//                        }
                    }
                }
            }
        } failure: { (error) in
            print("Error: ", error)
        }
        
    }
    
    func callAPiForVersionCheck() {
        let stringwsName = "apiVersion"
        APICall.shared.getWeb(stringwsName, withLoader: true, successBlock: { (response) in
            
            print("apiVersion is",response)
            
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool) {
                    let getVersion = dict["current_ios_version"] as? String ?? ""
                    self.lbl_Version.text = "V.\(Global.appdel.getCurrentAppVersion)"
                    
                    let currentVersion: Float = Float(Global.appdel.getCurrentAppVersion) ?? 0
                    let version : Float = Float(getVersion) ?? 0
                    print(currentVersion)
                    if currentVersion < version {
                        self.alertView.isHidden = false
                        self.viewBgShowAlert.isHidden = false
                    } else {
                        self.alertView.isHidden = true
                        self.viewBgShowAlert.isHidden = true
                        Global.appdel.userDetailCall(vc: self)
                    }
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "")
                }
            }else{
               
            }
        }) { (error) in
            
        }
    }
    
}
