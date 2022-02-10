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
    @IBOutlet weak var lbl_Version: UILabel!
    @IBOutlet weak var viewBgShowAlert: UIView!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var alertView: UIView!
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        Singleton.currentVc = "launch_screen"
        StaticVariables.window = UIApplication.shared.keyWindow
        self.callAPiForVersionCheck()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Singleton.currentVc = ""
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.alertView.layer.cornerRadius = 10
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
    
    func callAPiForVersionCheck() {
        let stringwsName = "apiVersion?ios_version=\(appDelegate.getCurrentAppVersion)"
        APICall.shared.getWeb(stringwsName, bearerToken: false, withLoader: false, successBlock: { (response) in
            
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
                        self.checkForceLogoutStatus_Web()
                    }
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "")
                }
            }else{
               
            }
        }) { (error) in
            
        }
    }
    
    func checkForceLogoutStatus_Web(){
        let params = NSMutableDictionary()
        params.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        params.setValue(appDelegate.getCurrentAppVersion, forKey: "ios_version")
        
        APICall.shared.postWeb("is_force_logout_check", parameters: params, showLoder: true, successBlock: { (response) in
            if let status = response["FLAG"]as? Int, status == 1{
                if let logout_status = response["IS_FORCE_LOGOUT"]as? String, logout_status == "1"{
                    APICall.shared.postWeb("is_force_logout", parameters: params, showLoder: true) { (response) in
                        if let status = response["FLAG"]as? Int, status == 1{
                            let viewControllers: [UIViewController] = (Global.appdel.navigation?.viewControllers)!
                            for(_,element) in viewControllers.enumerated() {
                                if(element is LoginWithGoogleAppleVC){
                                    Global.appdel.navigation?.popToViewController(element, animated: false)
                                    break
                                }
                            }
                        }else{
                            StaticClass.sharedInstance.ShowNotification(false, strmsg: response["MESSAGE"] as? String ?? "")
                        }
                    } failure: { (error) in
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "")
                    }
                }else{
                    Global.appdel.userDetailCall(vc: self)
                }
            }else{
                StaticClass.sharedInstance.ShowNotification(false, strmsg: response["MESSAGE"] as? String ?? "")
            }
        }, failure: { (error) in
            StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "")
        })
    }
    
}
