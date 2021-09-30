//
//  shareTransation.swift
//  Club_Mobile
//
//  Created by Tops on 12/22/16.
//  Copyright © 2016 Self. All rights reserved.
//

import UIKit

class shareTransation: NSObject {
    var strId:String = ""
    var strDate:String = ""
    var strCardId:String = ""
    var strReference:String = ""
    var strDisc:String = ""
    var fltAmoount:Float = 0.0
    var fltPrebalance:Float = 0.0
    var fltbalance:Float = 0.0
    var fltcommision:Float = 0.0
    var strStatus:String = ""
    var strIsCredit:String = ""
    
    // FOR DATE SORTING 
    var date:Date {
        get {
            if let date = StaticClass.sharedInstance.dateFormatterForYMD_T_HMSsss().date(from:strDate) as NSDate? {
                return date as Date
            }
            else if let date = StaticClass.sharedInstance.dateFormatterForYMD_T_HMS().date(from:strDate) as NSDate? {
                return date as Date
            }
            else{
                return Date()
            }
        }
    }
    // FOR AGENT SIDE NEW
    var strUserId:String = ""
    var strAgentId:String = ""
    var strDateApproved:String = ""
    var strApprovedById:String = ""
    
}
