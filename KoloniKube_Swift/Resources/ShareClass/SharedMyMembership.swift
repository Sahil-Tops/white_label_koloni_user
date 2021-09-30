//
//  SharedMyMembership.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/18/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit

class SharedMyMembership: NSObject {
    var strMembershipId:String = ""
    var strMembershipImage:String = ""
    var strPartnerID:String = ""
    var strMemberName:String = ""
    var strMemberAddress:String = ""
    var strMemberRating:String = ""
    var strMemberReview:String = ""
    var is_purchased:String = ""
    var message:String = ""
}

class SharedBuyMembership: NSObject {
    var strPlanID:String = ""
    var strPlanName:String = ""
    var strID : String = ""
    var strImage : String = ""
    var strUser_ID : String = ""
    var strUserName : String = ""
    var strAmount:String = ""
    var strTotalPlanDay:String = ""
    var strExpireDate:String = ""
    var strPurchaseDate:String = ""
    var strFreeRentalHours = ""
    var strAvailableFreeRentalHours = ""
}

class SharedHubList: NSObject {
    var strPlanID:String = ""
    var strPartner_name : String = ""
    var strPlan_name : String = ""
    var strPrice:String = ""
    var strPer_ride_cap : String = ""
    var strduration:String = ""
    var strdescription:String = ""
}

