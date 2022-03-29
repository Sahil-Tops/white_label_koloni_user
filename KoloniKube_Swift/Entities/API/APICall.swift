//
//  APICall.swift
//  Club Mobile Application
//
//  Created by Tops on 12/7/16.
//  Copyright © 2016 Self. All rights reserved.
//

import Foundation
import AFNetworking
import ISMessages


class APICall {
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    var manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
    var spinnerView: UIView?
    
    static let shared: APICall = {
        let instance = APICall()
        return instance
    }()
    //MARK :- Background
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundTask()
        })
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(backgroundTask.rawValue))
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func HideSpinnerOnView(_ view:UIView) -> Void {
        view.removeFromSuperview()
    }
    
    func appInMaintanance(message: String){
        Global.appdel.forceLogout()
        StaticClass.sharedInstance.ShowNotification(false, strmsg: message)
    }
    
    //MARK: Get Api
    
    func getAppData(withUrl: String, successBlock: @escaping(_ response: AnyObject)-> Void, failure: @escaping (_ response: String)-> Void){
        StaticClass.sharedInstance.ShowSpiner()
        let url = withUrl
        print("Request URL: ", url)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20
        configuration.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        let header = ["\(Global.g_Username)":"\(Global.g_Password)"]        
        manager.get(url, parameters: nil, headers: header, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            StaticClass.sharedInstance.HideSpinner()
            print("Json Response is",responseObject as Any)
            if let jsonResponse = responseObject as? NSDictionary {
                
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen
                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        alert.isMaintainance = false
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        return
                    }else{
                        self.appInMaintanance(message: jsonResponse["MESSAGE"] as? String ?? "")
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")
                        
                        let viewControllers: [UIViewController] = (Global.appdel.navigation?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginWithGoogleAppleVC){
                                Global.appdel.navigation?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        return
                    }
                }
                successBlock(jsonResponse)
            }else{
                successBlock(responseObject as AnyObject)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
            StaticClass.sharedInstance.HideSpinner()
            failure(error.localizedDescription)
        }

    }
    
    func getWeb(_ withUrl:String, withLoader showLoder:Bool, successBlock:@escaping (_ responce:AnyObject) -> Void, failure:@escaping (_ responce:AnyObject) -> Void) {
        if(showLoder){
            StaticClass.sharedInstance.ShowSpiner()
        }
        let urlPath1 = Global.g_APIBaseURL + (withUrl as String) + "?ios_version=\(appDelegate.getCurrentAppVersion)&partner_id_white_label=\(Singleton.partnerIdWhiteLabel)"
        
        print("Request URL:",urlPath1)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20
        configuration.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        manager.responseSerializer.acceptableStatusCodes = NSIndexSet(indexSet:[500,200]) as IndexSet
        let header = ["\(Global.g_Username)":"\(Global.g_Password)"]
        manager.get(urlPath1, parameters: nil, headers: header, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
            }
            print("Json Response is",responseObject as Any)
            if let jsonResponse = responseObject as? NSDictionary {
                
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen
                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        alert.isMaintainance = false
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        return
                    }else{
                        self.appInMaintanance(message: jsonResponse["MESSAGE"] as? String ?? "")
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")
                        
                        let viewControllers: [UIViewController] = (Global.appdel.navigation?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginWithGoogleAppleVC){
                                Global.appdel.navigation?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        return
                    }
                }
                successBlock(jsonResponse)
            }else{
                successBlock(responseObject as AnyObject)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
                successBlock(false as AnyObject)
            }else{
                failure(LocalizeHelper().localizedString(forKey: "ERROR_CALL") as AnyObject)
            }
            
        }
    }
    
    //MARK: Post Api
    func postWeb(_ withUrl:String, parameters:NSMutableDictionary, showLoder:Bool,_ showLoaderBgColor: Bool = false , successBlock:@escaping (_ responce : AnyObject) -> Void, failure:@escaping (_ responce:AnyObject) -> Void) {
        
        if(showLoder){
            StaticClass.sharedInstance.ShowSpiner("", true)
        }
        let urlPath1 = Global.g_APIBaseURL + (withUrl as String)
        parameters.setValue(Singleton.partnerIdWhiteLabel, forKey: "partner_id_white_label")
        if withUrl != "track_location"{
            print("Request URL:",urlPath1)
            print("Post: Param  is",parameters)
        }
        
        self.registerBackgroundTask()
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20
        configuration.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        let header = ["\(Global.g_Username)":"\(Global.g_Password)"]
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        manager.post(urlPath1, parameters: parameters, headers: header, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
            }
            self.endBackgroundTask()
            if let jsonResponse = responseObject as? NSDictionary {
                print("Response is",jsonResponse)
                if let bookingArray = jsonResponse.object(forKey: "BOOKING")as? [[String:Any]], bookingArray.count > 0{
                    Singleton.endTime = bookingArray[0]["end_time"]as? String ?? ""
                }
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    if (isActive  == "1") {
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen
                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        alert.isMaintainance = false
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        return
                    }else{
                        self.appInMaintanance(message: jsonResponse["MESSAGE"] as? String ?? "")
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")
                        
                        let viewControllers: [UIViewController] = (Global.appdel.navigation?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginWithGoogleAppleVC){
                                Global.appdel.navigation?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        return
                    }
                }
                successBlock(jsonResponse)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL"))
            self.endBackgroundTask()
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
            }
            failure(LocalizeHelper().localizedString(forKey: "ERROR_CALL") as AnyObject)
            print(LocalizeHelper().localizedString(forKey: "ERROR_CALL") ?? "")
        }
    }
    
    func callApiForMultipleImageUpload (_ urlPath: NSString, withParameter parameters: NSMutableDictionary, _ showLoaderBgColor: Bool = false, withImage arrimage: NSMutableArray,withLoader showLoader: Bool, successBlock success:@escaping (_ responceData:AnyObject)->Void, failureBlock Failure:@escaping (_ Error: NSError?)->Void) {
        
        if(showLoader){
            StaticClass.sharedInstance.ShowSpiner("", true)
        }
        
        let urlPath1 = Global.g_APIBaseURL + (urlPath as String)
        parameters.setValue(Singleton.partnerIdWhiteLabel, forKey: "partner_id_white_label")
        print("Request URL:",urlPath1)
        print("Post: Param  is",parameters)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest = 60
        configuration.httpMaximumConnectionsPerHost = 10
        
        self.registerBackgroundTask()
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        let header = ["\(Global.g_Username)":"\(Global.g_Password)"]
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        
        var randomNumber :String {
            var number = ""
            for i in 0..<4 {
                var randomNumber = arc4random_uniform(10)
                while randomNumber == 0 && i == 0 {
                    randomNumber = arc4random_uniform(10)
                }
                number += "\(randomNumber)"
            }
            return String(number)
        }
        var randomNumber2 :String {
            var number = ""
            for i in 0..<8 {
                var randomNumber = arc4random_uniform(10)
                while randomNumber == 0 && i == 0 {
                    randomNumber = arc4random_uniform(10)
                }
                number += "\(randomNumber)"
            }
            return String(number)
        }
        _ = manager.post(urlPath1, parameters: parameters, headers: header, constructingBodyWith: { (Data) in
            
            for imag in arrimage {
                let imageTemp = imag as! UIImage
                if imageTemp != UIImage(named: "imgPlaceHolderIcon"){
                    let dataParse = imageTemp.sd_imageData()
                    if dataParse != nil{
                        if urlPath == "finish_booking" || urlPath == "rental_image"
                        {
                            Data.appendPart(withFileData: dataParse!, name:"image", fileName: "\(randomNumber2).jpeg", mimeType: "image/jpeg")
                        }
                        else
                        {
                            Data.appendPart(withFileData: dataParse!, name:"image[]", fileName: "\(randomNumber2).jpeg", mimeType: "image/jpeg")
                        }
                    }
                }
            }
            
        }, progress: { (Finished) in
            
            print("Upload Progress: \(Finished.fractionCompleted)")
            
        }, success: { (task:URLSessionDataTask, response:Any?) in
            
            self.endBackgroundTask()
            if(showLoader){
                StaticClass.sharedInstance.HideSpinner()
            }
            success(response as AnyObject)
            
        }) { (task:URLSessionDataTask?, error:Error) in
            self.endBackgroundTask()
            if(showLoader) {
                StaticClass.sharedInstance.HideSpinner()
                StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL"))
            }
            Failure(error as NSError?)
        }
    }
    
    
    func callAPi_CSVUpload (_ urlPath: NSString, withParameter dictData: NSMutableDictionary, withCSVData csvFile: Data,withLoader showLoader: Bool, successBlock success:@escaping (_ responceData:AnyObject)->Void, failureBlock Failure:@escaping (_ Error: NSError?)->Void) {
        
        if(showLoader){
            StaticClass.sharedInstance.ShowSpiner()
        }
        
        let urlPath1 = Global.g_APIBaseURL + (urlPath as String)
        dictData.setValue(Singleton.partnerIdWhiteLabel, forKey: "partner_id_white_label")
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest = 60
        configuration.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        let header = ["\(Global.g_Username)":"\(Global.g_Password)"]
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        
        _ = manager.post(urlPath1, parameters: dictData, headers: header, constructingBodyWith: { (Data) in
            
            Data.appendPart(withFileData: csvFile, name:"csv_file", fileName: "general.csv", mimeType: "text/csv")
            
        }, progress: { (Finished) in
            
        }, success: { (task:URLSessionDataTask, response:Any?) in
            if(showLoader){
                StaticClass.sharedInstance.HideSpinner()
            }
            success(response as AnyObject)
            
        }) { (task:URLSessionDataTask?, error:Error) in
            
            if(showLoader) {
                StaticClass.sharedInstance.HideSpinner()
                StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
            }
            Failure(error as NSError?)
        }
    }
    
    func callApiUsingPOST_Image (_ urlPath: NSString, withParameter parameters: NSMutableDictionary, withImage image: UIImage, WithImageName imageName: NSString, withLoader showLoader: Bool, successBlock success:@escaping (_ responceData:AnyObject)->Void, failureBlock Failure:@escaping (_ Error: NSError?)->Void) {
        
        if(showLoader){
            StaticClass.sharedInstance.ShowSpiner()
        }
        
        let urlPath1 = Global.g_APIBaseURL + (urlPath as String) 
        parameters.setValue(Singleton.partnerIdWhiteLabel, forKey: "partner_id_white_label")
        print("Request URL:",urlPath1)
        print("Post: Param  is",parameters)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest = 60
        configuration.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        let header = ["\(Global.g_Username)":"\(Global.g_Password)"]
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        var Timestamp: String {
            return "\(Date().timeIntervalSince1970 * 1000)"
        }
        
        _ = manager.post(urlPath1, parameters: parameters, headers: header, constructingBodyWith: { (Data) in
            
            let strFlag = parameters.object(forKey: "is_delete_photo") as? String ?? ""
            if strFlag == "0"{
                let image1: UIImage? = image
                if image1 != nil{
                    
                    Data.appendPart(withFileData: image1!.jpegData(compressionQuality: 1.0)!, name: imageName as String, fileName: "\(Timestamp).png", mimeType: "image/png")
                }
            }
            
        }, progress: { (Finished) in
            
        }, success: { (task:URLSessionDataTask, response:Any?) in
            if(showLoader){
                StaticClass.sharedInstance.HideSpinner()
            }
            success(response as AnyObject)
            
        }) { (task:URLSessionDataTask?, error:Error) in
            
            print("error for post call is",error.localizedDescription)
            
            if(showLoader) {
                StaticClass.sharedInstance.HideSpinner()
                StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
            }
            Failure(error as NSError?)
        }
    }
}

fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
    return UIBackgroundTaskIdentifier(rawValue: input)
}
