//
//  SharePlaces.swift
//  Booking_system
//
//  Created by Tops on 10/10/16.
//  Copyright © 2016 Tops. All rights reserved.
//

import UIKit

class SharePlaces: NSObject {
    var strId:String = ""
    var strType:String = ""
    var strPlaceId:String = ""
    var strName:String = ""
    var strAddress:String = ""
    var strPostcode:String = ""
    var strPhone:String = ""
    var strPrice:String = ""
    var strLat:Double = 0.0
    var strLong:Double = 0.0
    var strDistance:String = ""
    var arrayGeofence: [ShareGeofence] = []
    var mapLink = ""
}
