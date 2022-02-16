//
//  AuthManager.swift
//  KoloniKube_Swift
//
//  Created by Sam on 10/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import Foundation
import Auth0

class AuthManager: NSObject{
    
    static let clientId = "ZVGCyfDmt9789SaBb1K8kqWWMZJ9X0VO"
    let apiIdentifier = "https://api.koloni.io"
    static var sharedInstance: AuthManager!
    static var accessToken = ""
    var credentialManager = CredentialsManager.init(authentication: Auth0.authentication())
    var vc: UIViewController!
    
    init(vc: UIViewController) {
        super.init()
        self.vc = vc
        type(of: self).sharedInstance = self
    }
    
    func checkLoginStatus(outputBlock: @escaping(_ response: Bool)-> Void){
        outputBlock(self.credentialManager.hasValid())
    }
    
    func loginWithAuth0(){
        
        Auth0.webAuth().scope("openid email sms profile offline_access read:current_user update:current_user_metadata").audience(self.apiIdentifier).start { result in
            switch result {
            case .failure(let error):
                // Handle the error
                print("Auth0 Error: \(error)")
            case .success(let credentials):
                // Do something with credentials e.g.: save them.
                // Auth0 will automatically dismiss the login page
                print("Login Credentials: \(credentials)")
                _ = self.credentialManager.store(credentials: credentials)
                if let accessToken = credentials.accessToken{
                    AuthManager.accessToken = accessToken
                }
                self.storedTokenIntoUserDefault(accessToken: AuthManager.accessToken)
                self.getUserInfo(credentials: credentials)
                print("Acess Token: ", AuthManager.accessToken)
            }
        }
    }
    
    func renewToken(){
        
        if let token = StaticClass.sharedInstance.retriveFromUserDefaultsStrings(key: "auth0_access_token"){
            Auth0.authentication().renew(withRefreshToken: token).start { result in
                switch result{
                case .success(let credentials):
                    guard let accessToken = credentials.accessToken else {
                        return
                    }
                    AuthManager.accessToken = accessToken
                    print("Acess Token: ", AuthManager.accessToken)
                    self.storedTokenIntoUserDefault(accessToken: AuthManager.accessToken)
                    return
                case .failure(let err):
                    print("Error: ", err)
                    return
                }
            }
        }
        
    }
    
    func storedTokenIntoUserDefault(accessToken: String){
        
        StaticClass.sharedInstance.saveToUserDefaultsString(value: accessToken, forKey: "auth0_access_token")
        
    }
    
    func getUserInfo(credentials: (Credentials)){
        if let a_token = credentials.accessToken{
            StaticClass.sharedInstance.ShowSpiner()
            Auth0.authentication().userInfo(withAccessToken: a_token).start { (userInfo) in
                switch (userInfo){
                case .success(let profile):
                    print("Email: ", profile.email ?? "")
                    print(profile.sub)
                    var type = ""
                    if profile.sub.contains("google"){
                        type = "social_google"
                    }else if profile.sub.contains("apple"){
                        type = "social_apple"
                    }else if profile.sub.contains("sms"){
                        type = "mobile"
                    }else if profile.sub.contains("email"){
                        type = "email"
                    }
                    StaticClass.sharedInstance.HideSpinner()
                    OpenAPI.sharedInstance.getWhoIamI_Web { response in
                        print(WhoIamI().id ?? "")
                        OpenAPI.sharedInstance.getLocationListing_Web { data in
                            
                        }
                    }
//                    self.checkAccessToken_Web(token: credentials.accessToken ?? "", type: type)
                    break
                case .failure(let err):
                    print("Error: ", err)
                    break
                }
            }
        }
    }
    
    func logoutAuth0(outputBlock: @escaping(_ response: Bool)-> Void){
        Auth0.webAuth().clearSession(federated: false) { (response) in
            if response{
                self.credentialManager.revoke { (error) in
                    outputBlock(error == nil ? true:false)
                }
            }else{
                outputBlock(false)
            }
        }
    }
    
    func checkAccessToken_Web(token: String, type: String){
        
        //        let params: NSMutableDictionary = NSMutableDictionary()
        //        params.setValue(token, forKey: "access_token")
        //        params.setValue(type, forKey: "access_type")
        //        params.setValue("1", forKey: "device_type")
        //        params.setValue(StaticClass.sharedInstance.strDeviceToken, forKey: "device_token")
        //        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "os_version")
        //        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        //        params.setValue(appDelegate.getCurrentDeviceName, forKey: "device_name")
        //        params.setValue(String(describing: StaticClass.sharedInstance.latitude), forKey: "latitude")
        //        params.setValue(String(describing: StaticClass.sharedInstance.longitude), forKey: "longitude")
        //
        //        APICall.shared.postWeb("check_access_token", parameters: params, showLoder: true) { (response) in
        //            if let data = response as? [String:Any]{
        //                print("Data: ", data)
        //                if let status = data["FLAG"]as? Int, status == 1{
        //                    if let arrResult = data["LOGIN_DETAILS"] as? NSArray, arrResult.count > 0{
        //                        if let dicResult = arrResult[0] as? NSDictionary {
        //                            StaticClass.sharedInstance.saveToUserDefaults((dicResult.object(forKey:"id") as? String  ?? "") as AnyObject, forKey: Global.g_UserData.UserID)
        //                            StaticClass.sharedInstance.saveToUserDefaults((true) as AnyObject, forKey: Global.g_UserDefaultKey.IS_USERLOGIN)
        //                            Global.storeLoginData(dicResult: dicResult)
        //                            Global.getUserProfile_Web(vc: self.vc) { (response, data) in
        //                                if response{
        //                                    if let is_new_user = data["is_new_user"]as? String, is_new_user == "1"{
        //                                        let vc = AddCardsViewController(nibName: "AddCardsViewController", bundle: nil)
        //                                        self.vc.navigationController?.pushViewController(vc, animated: true)
        //                                    }else{
        //                                        Global.appdel.userRunningRental_Web(loader: true)
        //                                    }
        //                                }
        //                            }
        //                        }else{
        //                            //                            self.socialSignUp_Web(params: params)
        //                        }
        //                    }
        //                }else{
        //                    StaticClass.sharedInstance.ShowNotification(false, strmsg: data["MESSAGE"]as? String ?? "")
        //                }
        //            }
        //        } failure: { (error) in
        //            StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "")
        //        }
        //
    }
    
}
