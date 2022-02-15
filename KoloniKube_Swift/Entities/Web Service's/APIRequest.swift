//
//  APIRequest.swift
//  KoloniKube_Swift
//
//  Created by Sam on 11/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import Foundation
import AFNetworking

class APIRequest{
    
    static let sharedInstance: APIRequest = {
        return APIRequest()
    }()    
    
    
    func startConnectionWithJSON(urlStr: String, methodType: HTTP_METHOD, params: [String:Any], showLoader: Bool, successHandler: @escaping(_ response: [String:Any])-> Void, errorHandler: @escaping(_ error: String)-> Void){
    
        if showLoader{
            StaticClass.sharedInstance.ShowSpiner("", true)
        }
        
        let url = BASE_URLS.baseUrl + urlStr
        print("Requested Params: ", params)
        print("Url: ", url)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 20
        config.httpMaximumConnectionsPerHost = 10
        
        let manager = AFHTTPSessionManager(sessionConfiguration: config)
        let header = ["\(Global.g_Username)": "\(Global.g_Password)", "Authorization": "Bearer \(AuthManager.accessToken)"]
        
        switch methodType {
        case .post:
            manager.post(url, parameters: params, headers: header, progress: nil) { task, response in
                if showLoader{
                    StaticClass.sharedInstance.HideSpinner()
                }
                if let data = response as? NSArray{
                    successHandler(["data": data])
                }else if let data = response as? NSDictionary{
                    successHandler(["data": data])
                }
            } failure: { task, err in
                print("Error: ", err.localizedDescription)
                errorHandler(err.localizedDescription)
            }
            break
        case .get:
            manager.get(url, parameters: params, headers: header, progress: nil) { dataTask, response in
                if showLoader{
                    StaticClass.sharedInstance.HideSpinner()
                }
                if let data = response as? NSArray{
                    successHandler(["data": data])
                }else if let data = response as? NSDictionary{
                    successHandler(["data": data])
                }
            } failure: { dataTask, err in
                print("Error: ", err)
                errorHandler(err.localizedDescription)
            }
        default:break
        }
    }
    
}
