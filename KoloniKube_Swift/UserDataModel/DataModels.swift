//
//  DataModels.swift
//  KoloniKube_Swift
//
//  Created by Sam on 16/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import Foundation

class WhoIamI: NSObject{
    var id: String?
    
    func setData(dataDic: [String:Any])-> WhoIamI{
        let model = WhoIamI()
        model.id = dataDic["id"]as? String ?? ""
        return model
    }
}

class LocationsModel: NSObject{
    
    var location_id: String?
    var name: String?
    var org_id: String?
    var point: Points?
    
    func setData(dataArray: [[String:Any]])-> [LocationsModel] {
        var array: [LocationsModel] = []
        for item in dataArray{
            let model = LocationsModel()
            model.location_id = item["location_id"]as? String ?? ""
            model.name = item["name"]as? String ?? ""
            model.org_id = item["org_id"]as? String ?? ""
            if let points = item["point"]as? [String:Any]{
                model.point = Points().setData(dict: points)
            }
            array.append(model)
        }
        return array
    }
}
class Points: NSObject{
    var latitude: Double?
    var longitude: Double?
    
    func setData(dict: [String:Any])-> Points{
        let model = Points()
        model.latitude = dict["latitude"]as? Double ?? 0.0
        model.longitude = dict["longitude"]as? Double ?? 0.0
        return model
    }
}

class DevicesModel: NSObject{
    var assignment: String?
    var availability: String?
    var device_id: String?
    var device_type: String?
    var image: String?
    var item: String?
    var location_id: String?
    var lock_data: LockData?
    var locked: Int?
    var management_id: String?
    var org_id: String?
    var price_id: String?
    
    func setData(dataArray: [[String:Any]])-> [DevicesModel]{
        var array: [DevicesModel] = []
        for item in dataArray{
            let model = DevicesModel()
            model.location_id = item["location_id"]as? String ?? ""
            model.assignment = item["assignment"]as? String ?? ""
            model.availability = item["availability"]as? String ?? ""
            model.device_id = item["device_id"]as? String ?? ""
            model.device_type = item["device_type"]as? String ?? ""
            model.image = item["image"]as? String ?? ""
            model.item = item["item"]as? String ?? ""
            model.locked = item["locked"]as? Int ?? 0
            model.management_id = item["management_id"]as? String ?? ""
            model.org_id = item["org_id"]as? String ?? ""
            model.price_id = item["price_id"]as? String ?? ""
            
            if let lock_data = item["lock_data"]as? [String:Any]{
                model.lock_data = LockData().setData(dict: lock_data)
            }
            array.append(model)
        }
        return array
    }
}
class LockData: NSObject{
    var mac_id: String?
    
    func setData(dict: [String:Any])-> LockData{
        let model = LockData()
        model.mac_id = dict["mac_id"]as? String ?? ""
        return model
    }
}


class ReserveDeviceModel: NSObject{
    var org_id: String?
    var user_id: String?
    var reservation_type: String?
    var device_id: String?
    var reservation_id: String?
    
    func setData(dict: [String:Any]) -> ReserveDeviceModel{
        let model = ReserveDeviceModel()
        model.org_id = dict["org_id"]as? String ?? ""
        model.user_id = dict["user_id"]as? String ?? ""
        model.reservation_type = dict["reservation_type"]as? String ?? ""
        model.device_id = dict["device_id"]as? String ?? ""
        model.reservation_id = dict["reservation_id"]as? String ?? ""
        return model
    }
}
