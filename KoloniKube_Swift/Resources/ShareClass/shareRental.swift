//
//  shareRental.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/18/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class shareRental: NSObject {
    
    var strPayment_Id:String = ""
    var strUserID:String = ""
    var strUser_Type:String = ""
    var strTransectionID:String = ""
    var strObjectID:String = ""
    var strOrderID: String = ""
    var strCardToken:String = ""
    var strAmount:String = ""
    var strTotalAmount:String = ""    
    var strIsPaymentDone:String = ""
    var strTransectionDate:String = ""
    var strDropOffLocationID:String = ""
    var strCreatedAt:String = ""
    var strUserName:String = ""
    var strObjectType:String = ""
    var strKubeName:String = ""
    var strObjectName:String = ""
    var strObjectUniqueId = ""
    var strLocationType:String = ""
    var strPricePerHour:String = ""
    var strPenaltyCharges:String = ""
    var strLocationName:String = ""
    var strLatitude:String = ""
    var strLongitude:String = ""
    var strAddress:String = ""
    var strLocationImage:String = ""
    var strStartDate:String = ""
    var strStartTime:String = ""
    var strPrintRecipt:String = ""
    var strEndDate:String = ""
    var strEndTime:String = ""
    var strTotalTime:String = ""
    var strCardNumber:String = ""
    var strCardType:String = ""
    var strDeviceId:String = ""
    var strFeedbackStatus:String = ""
    var strMapImage:String = ""
    var strCalories:String = "0.00"
    var strDistance:String = ""
    var strFare:String = ""
    var strTime:String = ""
    var isRefferalUsed: Bool = false
    var strReferralId: String = ""
    var isMembershipUsed: Bool = false
    var strMembershipName: String = ""
    var asset_name = ""
    var assets_sub_name = ""
    var promo_code_percenatge = ""
    var isAffiliateUsed = 0
    var isOutOfDropZoneUsed = 0
}

class shareCompleteInfo: NSObject {
    var strValue:String = ""
    var strTitle:String = ""
    var is_Pentalty:Bool = false
    
    init(Title:String,Value:String,is_Pent:Bool) {
        super.init()
        self.strTitle = Title
        self.strValue = Value
        self.is_Pentalty = is_Pent
    }
}

class sharePopUpInfo: NSObject {
    var strIndex:String = ""
    var strValue:String = ""
    var strTitle:String = ""
    var strImage:String = ""

    init(Index:String,Title:String,Value:String,Img:String) {
        super.init()
        self.strTitle = Title
        self.strValue = Value
        self.strIndex = Index
        self.strImage = Img
    }
}

