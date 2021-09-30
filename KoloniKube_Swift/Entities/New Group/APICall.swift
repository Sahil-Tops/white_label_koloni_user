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
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }
    
    func endBackgroundTask() {
//        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(backgroundTask.rawValue))
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func HideSpinnerOnView(_ view:UIView) -> Void {
        view.removeFromSuperview()
    }
    
    //MARK: BASIC FIX URL
    func GetWithFixUrl(_ withUrl:String, withLoader showLoder:Bool, successBlock:@escaping (_ responce:AnyObject) -> Void) {
        if(showLoder){
            StaticClass.sharedInstance.ShowSpiner()
        }
//        Flurry.logEvent(withUrl)
        
        print("Request URL:",withUrl)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 30
        configuration.timeoutIntervalForRequest = 30
        configuration.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        manager.get(withUrl, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if let jsonResponse = responseObject as? NSDictionary {
//                Flurry.endTimedEvent(withUrl, withParameters: jsonResponse as? [AnyHashable: Any])
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                        
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        
                        alert.modalPresentationStyle = .overFullScreen

                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")

                        let viewControllers: [UIViewController] = (Global.appdel.nav?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginVC){
                                Global.appdel.nav?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        
                       // Global.appdel.nav?.popToRootViewController(animated: true)
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if(showLoder){
                    StaticClass.sharedInstance.HideSpinner()
                }
                successBlock(jsonResponse)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
                StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL"))
            }
        }
    }
    
    //MARK: BASIC + GET + LOADER
    func Get(_ withUrl:String, withLoader showLoder:Bool, successBlock:@escaping (_ responce:AnyObject) -> Void, failure:@escaping (_ responce:AnyObject) -> Void) {
        if(showLoder){
            StaticClass.sharedInstance.ShowSpiner()
        }
        let urlPath1 = Global.g_APIBaseURL + (withUrl as String) 
        
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
        
        manager.get(urlPath1, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
            }
            
            print("Json Response is",responseObject as Any)

            if let jsonResponse = responseObject as? NSDictionary {
                
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                       // Global.appdel.forceLogout()
                        
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen

                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        
                       Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")

                        let viewControllers: [UIViewController] = (Global.appdel.nav?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginVC){
                                Global.appdel.nav?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        
                       // Global.appdel.nav?.popToRootViewController(animated: true)
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                successBlock(jsonResponse)
            }
            else {
                StaticClass.sharedInstance.HideSpinner()
                successBlock(responseObject as AnyObject)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
                successBlock(false as AnyObject)
//                StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
            }else{
                failure(LocalizeHelper().localizedString(forKey: "ERROR_CALL") as AnyObject)
            }
            
        }
    }
    
    func GetLogin(_ withUrl:String, withLoader showLoder:Bool, successBlock:@escaping (_ responce:AnyObject) -> Void) {
        if(showLoder){
            StaticClass.sharedInstance.ShowSpiner()
        }
        let urlPath1 = Global.g_APIBaseURL + (withUrl as String)
        
        print("Request URL:",urlPath1)

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20
        configuration.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        
        manager.get(urlPath1, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            
            if let string = String(data: responseObject as! Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                if(showLoder){
                    //StaticClass.sharedInstance.HideSpinner()
                }
                successBlock(string as AnyObject)
            }
            else if let jsonResponse = responseObject as? NSDictionary {
                
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen

                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")

                        let viewControllers: [UIViewController] = (Global.appdel.nav?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginVC){
                                Global.appdel.nav?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        
                       // Global.appdel.nav?.popToRootViewController(animated: true)
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if(showLoder){
                    StaticClass.sharedInstance.HideSpinner()
                }
                successBlock(jsonResponse) //
                if let error =  jsonResponse.object(forKey: "Message") as? String {
                    StaticClass.sharedInstance.ShowNotification(false, strmsg:error)
                }
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            StaticClass.sharedInstance.HideSpinner()
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
        }
    }
    
    func GetEncript(_ withUrl:String, withLoader showLoder:Bool, successBlock:@escaping (_ responce:AnyObject) -> Void) {
        if(showLoder){
            StaticClass.sharedInstance.ShowSpiner()
        }
        let urlPath1 = Global.g_APIBaseURL + (withUrl as String)
        
        print("Request URL:",urlPath1)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20
        configuration.httpMaximumConnectionsPerHost = 10

        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        manager.get(urlPath1, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if let string = String(data: responseObject as! Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                if(showLoder){
                    //StaticClass.sharedInstance.HideSpinner()
                }
                successBlock(string as AnyObject)
            }
            else if let jsonResponse = responseObject as? NSDictionary {
                
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen

                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")

                        let viewControllers: [UIViewController] = (Global.appdel.nav?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginVC){
                                Global.appdel.nav?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        
                        //Global.appdel.nav?.popToRootViewController(animated: true)
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
            
                
                if(showLoder){
                    StaticClass.sharedInstance.HideSpinner()
                }
                successBlock(jsonResponse) //
                if let error =  jsonResponse.object(forKey: "Message") as? String {
                    StaticClass.sharedInstance.ShowNotification(false, strmsg:error)
                }
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            StaticClass.sharedInstance.HideSpinner()
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
        }
    }
    
    func Post(_ withUrl:String, parameters:NSMutableDictionary, showLoder:Bool, successBlock:@escaping (_ responce : AnyObject) -> Void, failure:@escaping (_ responce:AnyObject) -> Void) {
        
        if(showLoder){
            StaticClass.sharedInstance.ShowSpiner()
        }
        let urlPath1 = Global.g_APIBaseURL + (withUrl as String)
        
        print("Request URL:",urlPath1)
        print("Post: Param  is",parameters)
        
        self.registerBackgroundTask()
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20
        configuration.httpMaximumConnectionsPerHost = 10

        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        manager.post(urlPath1, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
           
             self.endBackgroundTask()
            if let jsonResponse = responseObject as? NSDictionary {

                print("Response is",jsonResponse)

                if let bookingArray = jsonResponse.object(forKey: "BOOKING")as? [[String:Any]], bookingArray.count > 0{
                    Singleton.endTime = bookingArray[0]["end_time"]as? String ?? ""
                }
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen

                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")
                        
                        let viewControllers: [UIViewController] = (Global.appdel.nav?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginVC){
                                Global.appdel.nav?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        //Global.appdel.nav?.popToRootViewController(animated: true)
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if(showLoder){
                    StaticClass.sharedInstance.HideSpinner()
                }
                successBlock(jsonResponse)
            }
        }) { (task: URLSessionDataTask?, error: Error) in

            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
            self.endBackgroundTask()
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
                
                let str = LocalizeHelper().localizedString(forKey: "ERROR_CALL")
                
                if urlPath1.contains("object_book")
                {
                    failure(str as AnyObject)
                }
                else
                {
                    StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
                }
            }
            failure(LocalizeHelper().localizedString(forKey: "ERROR_CALL") as AnyObject)
        }
    }
    
    
    func callApiForMultipleImageUpload (_ urlPath: NSString, withParameter dictData: NSMutableDictionary, withImage arrimage: NSMutableArray,withLoader showLoader: Bool, successBlock success:@escaping (_ responceData:AnyObject)->Void, failureBlock Failure:@escaping (_ Error: NSError?)->Void) {
        
        if(showLoader){
            StaticClass.sharedInstance.ShowSpiner()
        }
        
        let urlPath1 = Global.g_APIBaseURL + (urlPath as String)
        
        print("urlPath1 is",urlPath1)
        print("parameter is",dictData)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest = 60
        configuration.httpMaximumConnectionsPerHost = 10

        self.registerBackgroundTask()
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        
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
        _ = manager.post(urlPath1, parameters: dictData, constructingBodyWith: { (Data) in
            
            for imag in arrimage {
                let imageTemp = imag as! UIImage
                if imageTemp != UIImage(named: "imgPlaceHolderIcon"){
                    
                    let dataParse = imageTemp.jpegData(compressionQuality: 0.1)
                    
//                    let image = UIImage(data: dataParse!)
                    if dataParse != nil{
                        if urlPath == "finish_booking" || urlPath == "rental_image"
                        {
                            Data.appendPart(withFileData: dataParse!, name:"image", fileName: "\(randomNumber2).png", mimeType: "image/png")
                        }
                        else
                        {
                            Data.appendPart(withFileData: dataParse!, name:"image[]", fileName: "\(randomNumber2).png", mimeType: "image/png")
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
    
    
    func CallAPi_CSVUpload (_ urlPath: NSString, withParameter dictData: NSMutableDictionary, withCSVData csvFile: Data,withLoader showLoader: Bool, successBlock success:@escaping (_ responceData:AnyObject)->Void, failureBlock Failure:@escaping (_ Error: NSError?)->Void) {
        
        if(showLoader){
            StaticClass.sharedInstance.ShowSpiner()
        }
        
        let urlPath1 = Global.g_APIBaseURL + (urlPath as String)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest = 60
        configuration.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)

        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        
        _ = manager.post(urlPath1, parameters: dictData, constructingBodyWith: { (Data) in
            
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
    
    func callApiUsingPOST_Image (_ urlPath: NSString, withParameter dictData: NSMutableDictionary, withImage image: UIImage, WithImageName imageName: NSString, withLoader showLoader: Bool, successBlock success:@escaping (_ responceData:AnyObject)->Void, failureBlock Failure:@escaping (_ Error: NSError?)->Void) {
        
        if(showLoader){
            StaticClass.sharedInstance.ShowSpiner()
        }
        
        let urlPath1 = Global.g_APIBaseURL + (urlPath as String) 
        
        print("urlPath1 is",urlPath1)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest = 60
        configuration.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
       
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(Global.g_Username, password: Global.g_Password)
        var Timestamp: String {
            return "\(Date().timeIntervalSince1970 * 1000)"
        }
        
        _ = manager.post(urlPath1, parameters: dictData, constructingBodyWith: { (Data) in
            
            let strFlag = dictData.object(forKey: "is_delete_photo") as? String ?? ""
            if strFlag == "0"{
                let image1: UIImage? = image
                if image1 != nil{
                    
                    Data.appendPart(withFileData: image1!.jpegData(compressionQuality: 0.1)!, name: imageName as String, fileName: "\(Timestamp).png", mimeType: "image/png")
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
    
    //MARK: ADD LOADER WITH VIEW
    func GetWithView(_ withUrl:String, withLoader showLoder:Bool, view:UIView, successBlock:@escaping (_ responce:AnyObject) -> Void) {
        
        if showLoder {
            StaticClass.sharedInstance.ShowSpiner()
        }
        let urlPath1 = Global.g_APIBaseURL + (withUrl as String)
        
        print("Request URL:",urlPath1)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 30
        configuration.timeoutIntervalForRequest = 30
        configuration.httpMaximumConnectionsPerHost = 10

        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        
        manager.requestSerializer = AFJSONRequestSerializer()
        //[operation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:404]];
        manager.responseSerializer.acceptableStatusCodes = NSIndexSet(indexSet:[500,404,200]) as IndexSet
        manager.get(urlPath1, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
            }
            if let jsonResponse = responseObject as? NSDictionary {
                
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                        
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen

                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")

                        let viewControllers: [UIViewController] = (Global.appdel.nav?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginVC){
                                Global.appdel.nav?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        
                        //Global.appdel.nav?.popToRootViewController(animated: true)
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                
                successBlock(jsonResponse)
            }
            else {
                successBlock(responseObject as AnyObject)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
            }
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
        }
    }
    func PostWithView(_ withUrl:String,parameters:NSMutableDictionary, withLoader showLoder:Bool, view:UIView, successBlock: @escaping (_ responce:AnyObject) -> Void){
        if showLoder {
            //viewLoad = addShowLoaderInView(viewObj: view, boolShow: showLoder)
            StaticClass.sharedInstance.ShowSpiner()
        }
        let urlPath1 = Global.g_APIBaseURL + (withUrl as String)
        print("Request URL:",urlPath1)

        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 30
        configuration.timeoutIntervalForRequest = 30
        configuration.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
       
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer.acceptableStatusCodes = NSIndexSet(indexSet:[404,200]) as IndexSet
        
        manager.post(urlPath1, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if(showLoder){
                //StaticClass.sharedInstance.HideSpinnerOnView(viewLoad!)
                StaticClass.sharedInstance.HideSpinner()
            }
            
            if let jsonResponse = responseObject as? NSDictionary {
                
                
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen

                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")

                        let viewControllers: [UIViewController] = (Global.appdel.nav?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginVC){
                                Global.appdel.nav?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        
                        //Global.appdel.nav?.popToRootViewController(animated: true)
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                successBlock(jsonResponse)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
                StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
            }
        }
    }
    
    func GetWithViewFail(_ withUrl:String, withLoader showLoder:Bool, view:UIView, successBlock:@escaping (_ responce:AnyObject) -> Void,failureBlock Failure:@escaping (_ Error: Error?)-> Void) {
        
        if showLoder {
            StaticClass.sharedInstance.ShowSpiner()
        }
      
        let urlPath1 = Global.g_APIBaseURL + (withUrl as String)
        print("Request URL:",urlPath1)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 30
        configuration.timeoutIntervalForRequest = 30
        configuration.httpMaximumConnectionsPerHost = 10

        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.get(urlPath1, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
            }
            if let jsonResponse = responseObject as? NSDictionary {
                
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen

                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")

                       // Global.appdel.nav?.popToRootViewController(animated: true)
                        
                        let viewControllers: [UIViewController] = (Global.appdel.nav?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginVC){
                                Global.appdel.nav?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                
                successBlock(jsonResponse)
            }
            else {
                successBlock(responseObject as AnyObject)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
                StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
            }
            Failure(error as Error?)
        }
    }
    
    func GetWithViewFailFixUrl(_ withUrl:String, withLoader showLoder:Bool, view:UIView, successBlock:@escaping (_ responce:AnyObject) -> Void,failureBlock Failure:@escaping (_ Error: Error?)-> Void) {
        
        if showLoder {
            StaticClass.sharedInstance.ShowSpiner()
        }
        let urlPath1 = (withUrl as String)
        print("Request URL:",urlPath1)

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 30
        configuration.timeoutIntervalForRequest = 30
        configuration.httpMaximumConnectionsPerHost = 10
        
      //  let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
       
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.get(urlPath1, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
            }
            if let jsonResponse = responseObject as? NSDictionary {
                
                if jsonResponse["FORCE_TO_UPDATE"] != nil{
                    
                    let isActive = "\(jsonResponse["FORCE_TO_UPDATE"] ?? "0")"
                    
                    print("force update ",isActive)
                    
                    if (isActive  == "1") {
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen

                        alert.message = jsonResponse["MESSAGE"] as? String ?? ""
                        
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                if  let isActive = jsonResponse["IS_ACTIVE"] as? Bool {
                    if (!isActive  == true) {
                        Global.appdel.forceLogout()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: jsonResponse["MESSAGE"] as? String ?? "")
                        
                        let viewControllers: [UIViewController] = (Global.appdel.nav?.viewControllers)!
                        for(_,element) in viewControllers.enumerated() {
                            if(element is LoginVC){
                                Global.appdel.nav?.popToViewController(element, animated: false)
                                break
                            }
                        }
                        
                      // Global.appdel.nav?.popToRootViewController(animated: true)
                        if(showLoder){
                            StaticClass.sharedInstance.HideSpinner()
                        }
                        return
                    }
                }
                
                
                successBlock(jsonResponse)
            }
            else {
                successBlock(responseObject as AnyObject)
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            if(showLoder){
                StaticClass.sharedInstance.HideSpinner()
                StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL") )
            }
            Failure(error as Error?)
        }
    }
    
    deinit {
        
        print("APICall Denited....")
        
    }
}

fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
    return UIBackgroundTaskIdentifier(rawValue: input)
}
