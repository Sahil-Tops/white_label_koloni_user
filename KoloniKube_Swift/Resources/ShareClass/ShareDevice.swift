//
//  ShareDevice.swift
//  KoloniKube_Swift
//
//  Created by Tops on 4/6/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class ShareHomeParam {
    var strUser_id:String = ""
    var doubleLat: Double  = 0.0
    var doubleLong: Double  = 0.0
    var strIsNearest: String = "0"
    var strDistance_Unit: String = "0"
    var intMinVal:Int = 0
    var intMaxVal:Int = 0
    var intRating:Int = 0
    var strSelectedCategory = ""
    var strKeyword: String = ""
    var strtype :String = "0"
    var arrCategories = NSMutableArray()
}

class ShareDevice: NSObject {
    
    var totalCalulationPrice: String = ""
    var totalCalulationMinute: String = ""
    var strPenaltyAmount:String = ""
    var strBookingID:String = ""
    var strObjectID:String = ""
    var strAddress:String = ""
    var strLocationName:String = ""
    var strLocationId = ""
    var strId:String = ""
    var strLocation_Type: String = ""
    var strPartnerID:String = ""
    var strParnerName:String = ""
    var strIsPartnerShowStatus:String = ""

    var strReview:String = ""
    var strRating:Double = 0
    var strAvgRating:Double = 0
    var strKubes:String = ""
    var strBikes:String = ""
    var strKubeAvgPrice:Double = 0
    var strBikeAvgPrice:Double = 0
    var strLat:Double = 0
    var strLong:Double = 0
    var strAvailableBike:Int = 0
    var strAvailableKube:Int = 0
    var isFeedBackStatus: String = ""
    
    
    var arrKubes:NSMutableArray = NSMutableArray()
    var arrBikes:NSMutableArray = NSMutableArray()
    var arrAmenities:NSMutableArray = NSMutableArray()
    var arrImage:NSMutableArray = NSMutableArray()
    var arrGeofence:NSMutableArray = NSMutableArray()
    var isAccessibleUser:Int = 0
    var isAffiliateLocation:Int = 1
    var total_assets = ""

}
class ShareDeviceImage: NSObject {

    var strImage:String = ""
}

class ShareAmenities: NSObject {
    var strId:String = ""
    var strName:String = ""
    var strImage:String = ""
}
class ShareGeofence: NSObject {
    var latitude : Double = 0.0
    var longitude : Double = 0.0
}

class ShareBothBikeKube: NSObject {
    var strId:String = ""
    var strName:String = ""
    var strImg:String = ""
    var strBooked:String = ""
    var doublePrice :Double = 0.0
}
class ShareAd: NSObject
{
    var title = ""
    var descriptionn = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var logo_image = ""
    var banner_image = ""
    
}

class AffliatedProgram{
    
    var fLAG : Bool!
    var iSACTIVE : Bool!
    var affiliateData : [AffiliateData]!
    var expiryDate : String!
    var hourlyBikePrice : String!
    var partnerName : String!
 
    init(fromDictionary dictionary: [String:Any]){
        fLAG = dictionary["FLAG"] as? Bool
        iSACTIVE = dictionary["IS_ACTIVE"] as? Bool
        affiliateData = [AffiliateData]()
        if let affiliateDataArray = dictionary["affiliate_data"] as? [[String:Any]]{
            for dic in affiliateDataArray{
                let value = AffiliateData(fromDictionary: dic)
                affiliateData.append(value)
            }
        }
        expiryDate = dictionary["expiry_date"] as? String ?? ""
        hourlyBikePrice = dictionary["hourly_bike_price"] as? String ?? ""
        partnerName = dictionary["partner_name"] as? String ?? ""
    }
    
}

class AffiliateData{
    
    var geofence : [Geofence]!
    var latitude : String!
    var locationId : String!
    var locationName : String!
    var longitude : String!
   
    init(fromDictionary dictionary: [String:Any]){
        geofence = [Geofence]()
        if let geofenceArray = dictionary["geofence"] as? [[String:Any]]{
            for dic in geofenceArray{
                let value = Geofence(fromDictionary: dic)
                geofence.append(value)
            }
        }
        latitude = dictionary["latitude"] as? String ?? ""
        locationId = dictionary["location_id"] as? String ?? ""
        locationName = dictionary["location_name"] as? String ?? ""
        longitude = dictionary["longitude"] as? String ?? ""
    }
    
}

class Geofence{
    
    var latitude : Double!
    var longitude : Double!
  
    init(fromDictionary dictionary: [String:Any]){
        latitude = dictionary["latitude"] as? Double ?? 0.0
        longitude = dictionary["longitude"] as? Double ?? 0.0
    }
    
}
