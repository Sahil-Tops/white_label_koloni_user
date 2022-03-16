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
    
    static let sharedInstance: AuthManager = {
        return AuthManager()
    }()
    
    static let clientId = "ZVGCyfDmt9789SaBb1K8kqWWMZJ9X0VO"
    let orgId = "org_8J7OwVOjFH3HNRpB"
    let apiIdentifier = "https://mobile.lockers.koloni.io"
    static var accessToken = ""
    static var refreshToken = ""
    var credentialManager = CredentialsManager.init(authentication: Auth0.authentication())
    
    
    func checkLoginStatus(outputBlock: @escaping(_ response: Bool)-> Void){
        outputBlock(self.credentialManager.hasValid())
    }
    
    func loginWithAuth0(){
        
        Auth0.webAuth().scope("openid email sms profile offline_access read:current_user update:current_user_metadata").audience(self.apiIdentifier).organization(self.orgId).start { result in
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
                if let refreshToken = credentials.refreshToken{
                    AuthManager.refreshToken = refreshToken
                }
                self.storedTokenIntoUserDefault(accessToken: AuthManager.accessToken, refreshToken: AuthManager.refreshToken)
                self.getUserInfo(credentials: credentials)
                print("Acess Token: ", AuthManager.accessToken)
            }
        }
    }
    
    func renewToken(outputBlock: @escaping(_ response: Bool)-> Void){
        if let token = StaticClass.sharedInstance.retriveFromUserDefaultsStrings(key: "auth0_refresh_token"){
            Auth0.authentication().renew(withRefreshToken: token).start { result in
                switch result{
                case .success(let credentials):
                    guard let accessToken = credentials.accessToken, let refreshToken = credentials.refreshToken else {
                        return
                    }
                    AuthManager.accessToken = accessToken
                    AuthManager.refreshToken = refreshToken
                    print("Acess Token: ", AuthManager.accessToken)
                    self.storedTokenIntoUserDefault(accessToken: AuthManager.accessToken, refreshToken: AuthManager.refreshToken)
                    outputBlock(true)
                    return
                case .failure(let err):
                    print("Error: ", err)
                    outputBlock(false)
                    return
                }
            }
        }
    }
    
    func storedTokenIntoUserDefault(accessToken: String, refreshToken: String){
        StaticClass.sharedInstance.saveToUserDefaultsString(value: accessToken, forKey: "auth0_access_token")
        StaticClass.sharedInstance.saveToUserDefaultsString(value: accessToken, forKey: "auth0_refresh_token")
    }
    
    func getUserInfo(credentials: (Credentials)){
        if let a_token = credentials.accessToken{
            StaticClass.sharedInstance.ShowSpiner()
            Auth0.authentication().userInfo(withAccessToken: a_token).start { (userInfo) in
                switch (userInfo){
                case .success(let profile):
                    print("Email: ", profile.email ?? "")
                    print(profile.sub)
                    StaticClass.sharedInstance.HideSpinner()
                    OpenAPI.sharedInstance.getWhoIamI_Web { response in
                        StaticClass.sharedInstance.saveToUserDefaultBool(forkey: "isUserLogin", value: true)
                        AppDelegate.shared.pushToSideMenuVC()
                    }
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
                    StaticClass.sharedInstance.removeValueForKey(forKey: "isUserLogin")
                    outputBlock(error == nil ? true:false)
                }
            }else{
                outputBlock(false)
            }
        }
    }
    
}
