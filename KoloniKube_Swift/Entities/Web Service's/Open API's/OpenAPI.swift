//
//  OpenAPI.swift
//  KoloniKube_Swift
//
//  Created by Sam on 15/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import Foundation

class OpenAPI{
    
    static var sharedInstance: OpenAPI{
        return OpenAPI()
    }
    var queue = DispatchQueue.init(label: "api_response")
    
    func getLocationListing_Web(outputBlock: @escaping(_ response: [String:Any])-> Void){
        
        self.queue.async {
            let urlStr = "\(MODULE.instance.locations)/"
            let params: [String:Any] = ["count": "10"]
            APIRequest.sharedInstance.startConnectionWithJSON(urlStr: urlStr, methodType: .get, params: params, showLoader: true) { response in
                print(response)
                outputBlock(response)
            } errorHandler: { error in
                
            }

        }
        
    }
    
    func getOrganizations_Web(outputBlock: @escaping(_ response: [String:Any])-> Void){
        
        self.queue.async {
            let urlStr = "\(MODULE.instance.organizations)/\(API_LISTS.instance.all)"
            APIRequest.sharedInstance.startConnectionWithJSON(urlStr: urlStr, methodType: .get, params: [:], showLoader: true) { response in
                print(response)
                outputBlock(response)
            } errorHandler: { error in
                
            }

        }
        
    }
    
}
