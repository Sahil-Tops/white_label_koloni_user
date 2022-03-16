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
    
    
    func getWhoIamI_Web(outputBlock: @escaping(_ response: WhoIamI)-> Void){
        self.queue.async {
            let urlStr = "\(MODULE.instance.debug)/\(API_LISTS.instance.whoami)"
            APIRequest.sharedInstance.startConnectionWithJson(urlStr: urlStr, methodType: .get, showLoader: true) { response in
                if let dict = response as? [String:Any]{
                    let model = WhoIamI().setData(dataDic: dict)
                    outputBlock(model)
                }
            } errorHandler: { error in
                
            }
        }
    }
    
    func getLocationListing_Web(count: String, outputBlock: @escaping(_ response: [LocationsModel])-> Void){
        
        self.queue.async {
            let urlStr = "\(MODULE.instance.locations)/"
            let params: [String:Any] = ["count": count]
            APIRequest.sharedInstance.startConnectionWithJson(urlStr: urlStr, methodType: .get, params, showLoader: true) { response in
                if let array = response as? [[String:Any]]{
                    let model = LocationsModel().setData(dataArray: array)
                    outputBlock(model)
                }
            } errorHandler: { error in
                
            }
        }
    }
    
    func getAllDevices_Web(count: Int, outputBlock: @escaping(_ response: [DevicesModel])-> Void){
        
        self.queue.async {
            let urlStr = "\(MODULE.instance.devices)/\(API_LISTS.instance.all)"
            let params: [String:Any] = ["count": "\(count)"]
            APIRequest.sharedInstance.startConnectionWithJson(urlStr: urlStr, methodType: .get, params, showLoader: true) { response in
                if let array = response as? [[String:Any]]{
                    let model = DevicesModel().setData(dataArray: array)
                    outputBlock(model)
                }
            } errorHandler: { error in
                
            }
        }
    }
    
    func getOrganizations_Web(outputBlock: @escaping(_ response: Any)-> Void){
        
        self.queue.async {
            let urlStr = "\(MODULE.instance.organizations)/\(API_LISTS.instance.all)"
            APIRequest.sharedInstance.startConnectionWithJson(urlStr: urlStr, methodType: .get, [:], showLoader: true) { response in
                outputBlock(response)
            } errorHandler: { error in
                
            }
        }
        
    }
    
    func reserveDevice(deviceId: String, outputBlock: @escaping(_ response: ReserveDeviceModel)-> Void){
        self.queue.async {
            let params: [String:Any] = ["device_id": deviceId, "reservation_type": "storage"]
            let urlStr = "\(MODULE.instance.reservations)/\(API_LISTS.instance.reserve_device)"
            APIRequest.sharedInstance.startConnectionWithJson(urlStr: urlStr, methodType: .post, params, showLoader: true) { response in
                if let dict = response as? [String:Any]{
                    let model = ReserveDeviceModel().setData(dict: dict)
                    outputBlock(model)
                }
            } errorHandler: { error in
                
            }
        }
    }
    
}
