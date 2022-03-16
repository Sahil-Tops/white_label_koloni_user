//
//  APIRequest.swift
//  KoloniKube_Swift
//
//  Created by Sam on 11/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import Foundation
import Alamofire

class APIRequest{
    
    static let sharedInstance: APIRequest = {
        return APIRequest()
    }()    
        
    func startConnectionWithJson(urlStr: String, methodType: HTTP_METHOD,_ params: [String:Any] = [:], showLoader: Bool, successHandler: @escaping(_ response: Any)-> Void, errorHandler: @escaping(_ error: String)-> Void){
        
        if let url = URL(string: BASE_URLS.baseUrl + urlStr){
            var urlRequest = URLRequest(url: url)
            if methodType == .post{
                do{
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: .sortedKeys)
                }catch let err{
                    print("Catch Error: ", err)
                }
            }else if methodType == .get{
                var getUrl = BASE_URLS.baseUrl + urlStr + "?"
                for (key, value) in params{
                    getUrl.append("\(key)=\(value)&")
                }
                getUrl.removeLast()
                if let url = URL(string: getUrl){
                    urlRequest = URLRequest(url: url)
                }
            }
            urlRequest.allHTTPHeaderFields = ["Content-Type": "application/json",
                                              "Authorization": "Bearer \(AuthManager.accessToken)"]
            urlRequest.httpMethod = methodType.rawValue
            
            print("Requested Params: ", params)
            print("URL Request: ", urlRequest)
            
            if showLoader{
                StaticClass.sharedInstance.ShowSpiner("", true)
            }
            AF.request(urlRequest).response { response in
                if showLoader{
                    StaticClass.sharedInstance.HideSpinner()
                }
                if let data = response.data{
                    do{
                        let jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                        print("Reponse: ", jsonObj)
                        successHandler(jsonObj)
                    }catch let err{
                        print("Error: ", err)
                        errorHandler("Error: \(err.localizedDescription)")
                    }
                }
            }
        }
    }
    
}
