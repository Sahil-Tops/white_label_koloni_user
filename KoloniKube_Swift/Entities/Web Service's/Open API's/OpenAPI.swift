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
    
    func getWhoIamI_Web(outputBlock: @escaping(_ response: Any)-> Void){
        self.queue.async {
            let urlStr = "\(MODULE.instance.debug)/\(API_LISTS.instance.whoami)"
            APIRequest.sharedInstance.startConnectionWithPost(urlStr: urlStr, methodType: .get, showLoader: true) { data in
                do{
                    _ = try JSONDecoder().decode(WhoIamI.self, from: data)
                    outputBlock(data)
                }catch let err{
                    print("Catch block 1", err)
                }
            } errorHandler: { error in
                
            }

        }
    }
    
    func getLocationListing_Web(outputBlock: @escaping(_ response: Any)-> Void){
        
        self.queue.async {
            let urlStr = "\(MODULE.instance.locations)/"
            let params: [String:Any] = ["count": "10"]
            APIRequest.sharedInstance.startConnectionWithPost(urlStr: urlStr, methodType: .get, params, showLoader: true) { response in
                outputBlock(response)
            } errorHandler: { error in
                
            }

        }
        
    }
    
    func getOrganizations_Web(outputBlock: @escaping(_ response: Any)-> Void){
        
        self.queue.async {
            let urlStr = "\(MODULE.instance.organizations)/\(API_LISTS.instance.all)"
            APIRequest.sharedInstance.startConnectionWithPost(urlStr: urlStr, methodType: .get, [:], showLoader: true) { response in
                outputBlock(response)
            } errorHandler: { error in
                
            }

        }
        
    }
    
    func getReservationDevice(outputBlock: @escaping(_ response: Data)-> Void){
        self.queue.async {
            let params: [String:Any] = ["device_id": "24vsZRzpfJY50mDN62EUVgf8wlY", "reservation_type": "storage"]
            let urlStr = "\(MODULE.instance.reservations)/\(API_LISTS.instance.reserve_device)"
            APIRequest.sharedInstance.startConnectionWithPost(urlStr: urlStr, methodType: .post, params, showLoader: true) { response in
                outputBlock(response)
            } errorHandler: { error in
                
            }
        }
    }
    
}
