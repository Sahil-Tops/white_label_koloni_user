//
//  API.swift
//  koloniKube_RideTrack
//
//  Created by Tops on 05/08/19.
//  Copyright © 2019 Self. All rights reserved.
//


import Foundation

//HTTP Methods
enum HttpMethod : String {
    case  GET
    case  POST
    case  DELETE
    case  PUT
}


class HttpClientApi: NSObject{
    
    //TODO: remove app transport security arbitary constant from info.plist file once we get API's
    var request : URLRequest?
    var session : URLSession?
    
    static func instance() ->  HttpClientApi{
        return HttpClientApi()
    }
    
    func makeAPICall(url: String,params: [String:String]?, method: HttpMethod, success:@escaping ( Data? ,HTTPURLResponse?  , NSError? ) -> Void, failure: @escaping ( Data? ,HTTPURLResponse?  , NSError? )-> Void) {
        
        request = URLRequest(url: URL(string: url)!)
        
        if let params = params {
            
            request?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request?.httpMethod = "POST"
            request?.httpBody = encodeParameters(params)
            
//            request?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//            request?.setValue("application/json", forHTTPHeaderField: "Accept")
            request?.setValue("Basic YWRtaW46MTIzNA==", forHTTPHeaderField: "Authorization")
//            request?.httpBody = jsonData//?.base64EncodedData()
            
            //paramString.data(using: String.Encoding.utf8)
        }
        request?.httpMethod = method.rawValue
        
        
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        
        session = URLSession(configuration: configuration)
        //session?.configuration.timeoutIntervalForResource = 5
        //session?.configuration.timeoutIntervalForRequest = 5
    
        session?.dataTask(with: request! as URLRequest) { (data, response, error) -> Void in
            
            if let data = data {
                
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    success(data , response , error as NSError?)
                } else {
                    failure(data , response as? HTTPURLResponse, error as NSError?)
                }
            }else {
                
                failure(data , response as? HTTPURLResponse, error as NSError?)
                
            }
            }.resume()
        
    }
    
}

func encodeParameters(_ parameters: [String:String]?) -> Data? {
    
    var list = [String]()
    
    for key in (parameters?.keys)! {
        let obj = parameters?[key]
        var path: String? = nil
        if let obj = obj {
            path = "\(key)=\(obj)"
        }
        list.append(path ?? "")
    }
    
    return list.joined(separator: "&").data(using: .utf8)
}
