//
//  ShareBike.swift
//  KoloniKube_Swift
//
//  Created by Tops on 4/11/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class ShareBikeData: NSObject {
    var strId:String = ""
    var strObjUniqueId = ""
    var strName:String = ""
    var strObjName:String = ""
    var strBikeName:String = ""
    var strImg:String = ""
    var strReview:String = ""
    var strRating:String = ""
    var doublePrice:Double = 0.0
    var strDistance:String = ""
    var strDeviceID:String = ""
    var strPartnerID:String = ""
    var strBooked:String = ""
    var intType = 0     //type = 2 for bike 1 = kube
    var intUserType = 0
    var strAddress = ""
    var bike_number = ""
    var booking_object_type = ""
    var booking_object_sub_type = ""
    var strLatitude :Double = 0.0
    var strLongitude :Double = 0.0
    var strLocationName = ""
    var strLocationID = ""
    var strStatus = ""
    var is_outof_dropzone = -1
    var outOfDropzoneMsg = ""
    var price_per_hour = ""
    var rental_fee = ""
    var duration_for_rental_fee = ""
    var promotional = ""
    var promotional_hours = ""
    var promotional_header = ""
    var show_member_button = ""
    var partner_name = ""
    var lock_id = ""
//    var axa_identifier = ""
    var device_name = ""
}

class AvailabelBike : NSObject {
    var strId:String = ""
    var strObjUniqueId = ""
    var strLocationId = ""
    var strLatitude :Double = 0.0
    var strLongitude :Double = 0.0
    var doubleBikeAveragePrice:Double = 0.0
    var doubleKubeAveragePrice:Double = 0.0
    var bikeInitialPrice: Double = 0.0
    var bikeInitialMintues: Double = 0.0
    var isAccessibleUser:Int = 0
    var strAddress = ""
    var partner_name = ""
    var plan_partner_id = ""
    var is_plan_purchase = ""
    var is_outof_dropzone = -1
    var outOfDropzoneMsg = ""
    var is_bike_active = -1
    var is_bike_active_msg = ""
    var type = ""
    var type_name = ""
    var bikeHourlyRate = ""
    var asset_img: UIImage?
    var asset_img_url = ""
    var assets_color_code = ""
}


