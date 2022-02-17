//
//  DataModels.swift
//  KoloniKube_Swift
//
//  Created by Sam on 16/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import Foundation

class WhoIamI: Codable{
    var id: String?
}

class LocationsModel: Codable{
    
    var location_id: String?
    var name: String?
    var org_id: String?
    var point: Points?
    
}
class Points: Codable{
    var latitude: Double?
    var longitude: Double?
}
