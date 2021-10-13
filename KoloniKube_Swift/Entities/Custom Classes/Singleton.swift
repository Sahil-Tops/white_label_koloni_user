//
//  Singleton.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/19/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import SkeletonView

typealias IOCTRL = (UInt8)

class StaticVariables{
    
    static var window: UIWindow?
    
}

class Singleton: NSObject {
    
    var is_LocationVisible = false
    var is_BookingVisible = false
    static var userData: [String:Any] = [:]
    static var userProfileData = NSDictionary()
    static var currentVc = ""
    static var numberOfReferralRides = "0"
    static var smRippleView: SMRippleView!
    static var totalRidesTaken = 0
    static var lastViewController = ""
    static var lastRideSummaryData: [String:Any] = [:]
    static var noInternetConnectionView: NoInternetConnection?
    static var noInternetViewLoaded: Bool = false
    static var internetCheckTimer = Timer()
    static var runningRentalArray: [[String:Any]] = []
    static var trackLocationRentalArray: [[String:Any]] = []
    static var order_id = ""
    static var timerArray: [Timer] = []    
    static var numberOfCards: [[String:Any]] = []
    static var endTime = ""
    static var track_location_timer = Timer()
    static var covid19Visibuilty = true
    static var covid19_url = ""
    static var emailConfirmationToken = ""
    static var lockInstructionArray: [[String:Any]] = []
    static var editProfileVc: EditProfileVC?
    static var axa_ekey = ""
    static var axa_passkey = ""
    static var axa_ekey_dictionary: [String:Any] = [:]
    static var currentIndex = 0
    static var bottomPopUpView: BottomPopUp?
    static var appFont: UIFont? = UIFont(name: "AvenirNext-Medium", size: 17)
    static var systemFont = UIFont.systemFont(ofSize: 17.0)
    static var isOpeningAppFromNotification = false
    static var notificationRunningRentalDetail: [String:Any] = [:]
    static var isCalledDidFinishLaunch = true
    static var partnerIdWhiteLabel = "58"
    var socialMediaUserData: ShareUser = ShareUser()
    var cardListsArray: [shareCraditCard] = []
    var referalCount = ""
    
    private override init() {
        
    }
    static let shared: Singleton = {
        let instance = Singleton()
        return instance
    }()
    
    var bikeData = ShareBikeData()
    
    func parseDeviceJson(arr:NSArray,arrOut:NSMutableArray) -> Void{
        
        if let array = arr as? [NSDictionary]{
            for dict in array
            {
                let device = ShareDevice()
                device.strId = dict.object(forKey: "id") as? String ?? ""
                device.strLocation_Type = dict.object(forKey: "location_type") as? String ?? "0"                
                device.strAddress = dict.object(forKey: "address") as? String ?? ""
                device.strAvailableBike = StaticClass.sharedInstance.getInterGer(value: dict.object(forKey: "available_bikes")  ?? "0")
                device.strAvailableKube = StaticClass.sharedInstance.getInterGer(value: dict.object(forKey: "available_kubes")  ?? "0")
                
                if let lati = dict.object(forKey: "latitude") as? String{
                    if lati == ""{
                        device.strLat = 0.0
                    }else{
                        device.strLat = Double(lati)!
                    }
                }
                if let longi = dict.object(forKey: "longitude") as? String{
                    if longi == ""{
                        device.strLong = 0.0
                    }else{
                        device.strLong = Double(longi)!
                    }
                }
                device.strLocationName = dict.object(forKey: "location_name") as? String ?? ""
                device.strLocationId = dict.object(forKey: "id")as? String ?? ""
                device.strReview = dict.object(forKey: "total_review") as? String ?? ""
                device.strRating = StaticClass.sharedInstance.getDouble(value: dict.object(forKey: "average_ratings") ?? "0")
                device.strAvgRating = StaticClass.sharedInstance.getDouble(value: dict.object(forKey: "average_ratings") ?? "0")
                device.strKubeAvgPrice = StaticClass.sharedInstance.getDouble(value: dict.object(forKey: "kube_average_price") ?? "0")
                device.strBikeAvgPrice = StaticClass.sharedInstance.getDouble(value: dict.object(forKey: "bike_average_price") ?? "0")
                device.strPartnerID = dict.object(forKey: "plan_partner_id") as? String ?? ""
                device.strParnerName = dict.object(forKey: "partner_name") as? String ?? ""
                device.strIsPartnerShowStatus = dict.object(forKey: "is_plan_purchase") as? String ?? ""
                device.isAccessibleUser = StaticClass.sharedInstance.getInterGer(value: dict.object(forKey: "is_accessible_user")  ?? "0")                
                device.isAffiliateLocation = StaticClass.sharedInstance.getInterGer(value: dict.object(forKey: "is_affiliate_location")  ?? "0")
                device.total_assets = dict.object(forKey: "total_assets")as? String ?? "0"
                if let arrKube = dict["kube_list"] as? NSArray{
                    for dictKube in arrKube as! [NSDictionary]{
                        let kube = ShareBikeData()
                        kube.strId = dictKube.object(forKey: "id") as? String ?? ""
                        kube.strImg = dictKube.object(forKey: "image") as? String ?? ""
                        kube.strName = dictKube.object(forKey: "name") as? String ?? ""
                        kube.strObjName = dictKube.object(forKey: "object_name") as? String ?? ""
                        kube.strDeviceID = dictKube.object(forKey: "device_id") as? String ?? ""
                        kube.doublePrice = StaticClass.sharedInstance.getDouble(value: dictKube.object(forKey: "price") ?? "0")
                        kube.strDistance = dictKube.object(forKey: "distance") as? String ?? "" //
                        kube.strBooked = dictKube.object(forKey: "is_booked") as? String ?? ""
                        kube.intType = 1 //Kubes
                        device.arrKubes.add(kube)
                    }
                }
                if let arrBike = dict["bike_list"] as? NSArray{
                    for dictBike in arrBike as! [NSDictionary]{
                        let Bike = ShareBikeData()
                        Bike.strId = dictBike.object(forKey: "id") as? String ?? ""
                        Bike.strImg = dictBike.object(forKey: "image") as? String ?? ""
                        Bike.strName = dictBike.object(forKey: "name") as? String ?? ""
                        Bike.strObjName = dictBike.object(forKey: "object_name") as? String ?? ""
                        Bike.doublePrice = StaticClass.sharedInstance.getDouble(value: dictBike.object(forKey: "price") ?? "0")
                        Bike.strDistance = dictBike.object(forKey: "distance") as? String ?? ""
                        Bike.strDeviceID = dictBike.object(forKey: "device_id") as? String ?? ""
                        Bike.intType = 2 //Bikes
                        device.arrBikes.add(Bike)
                    }
                }
                if let arrAmenities = dict["amenities"] as? NSArray{
                    for dictKube in arrAmenities as! [NSDictionary]{
                        let kube = ShareAmenities()
                        kube.strId = dictKube.object(forKey: "id") as? String ?? ""
                        kube.strImage = dictKube.object(forKey: "image") as? String ?? ""
                        kube.strName = dictKube.object(forKey: "name") as? String ?? ""
                        device.arrAmenities.add(kube)
                    }
                }
                if let arrGeofence = dict["geofence"] as? NSArray{
                    for dictGeofence in arrGeofence as! [NSDictionary]{
                        let geofence = ShareGeofence()
                        geofence.latitude = Double(dictGeofence.object(forKey: "latitude") as? Double ?? 0.0)
                        geofence.longitude = Double(dictGeofence.object(forKey: "longitude") as? Double ?? 0.0)
                        device.arrGeofence.add(geofence)
                    }
                }
                
                if let arrImage = dict["location_image"] as? NSArray{
                    for dictKube in arrImage as! [NSDictionary]{
                        let kube = ShareDeviceImage()
                        kube.strImage = dictKube.object(forKey: "image") as? String ?? ""
                        device.arrImage.add(kube)
                    }
                }
                arrOut.add(device)
            }
        }
        
    }
    func parseAdJson(arr:NSArray,arrOut:NSMutableArray) -> Void
    {
        for dict in arr as! [NSDictionary]
        {
            let device = ShareAd()
            device.title = dict.object(forKey: "title") as? String ?? "0"
            device.descriptionn = dict.object(forKey: "description") as? String ?? ""
            device.logo_image = dict.object(forKey: "logo_image") as? String ?? ""
            device.banner_image = dict.object(forKey: "banner_image")  as? String ?? ""
            device.latitude = Double(dict.object(forKey: "latitude") as? String ?? "0")!
            device.longitude = Double(dict.object(forKey: "longitude") as? String ?? "0")!
            arrOut.add(device)
            
        }
    }
    
    func parseBikeJson(arr:NSArray,arrOut:NSMutableArray) -> Void
    {
        if let array = arr as? [NSDictionary]{
            for dictBike in array {
                DispatchQueue.main.async {
                    let Bike = AvailabelBike()
                    Bike.strId = dictBike.object(forKey: "id") as? String ?? ""
                    Bike.strObjUniqueId = dictBike.object(forKey: "unique_id") as? String ?? ""
                    //obj_unique_id
                    Bike.strLocationId = dictBike.object(forKey: "location_id")as? String ?? ""
                    Bike.doubleBikeAveragePrice = StaticClass.sharedInstance.getDouble(value: dictBike.object(forKey: "assets_average_price") ?? "0")
                    Bike.doubleKubeAveragePrice = StaticClass.sharedInstance.getDouble(value: dictBike.object(forKey: "kube_average_price") ?? "0")
                    Bike.bikeInitialPrice = StaticClass.sharedInstance.getDouble(value: dictBike.object(forKey: "assets_initial_price") ?? "0")
                    Bike.bikeInitialMintues = StaticClass.sharedInstance.getDouble(value: dictBike.object(forKey: "assets_initial_mintues") ?? "0")
                    if let lati = dictBike.object(forKey: "latitude") as? String{
                        if lati == ""{
                            Bike.strLatitude = 0.0
                        }else{
                            Bike.strLatitude = Double(lati)!
                        }
                    }
                    if let longi = dictBike.object(forKey: "longitude") as? String{
                        if longi == ""{
                            Bike.strLongitude = 0.0
                        }else{
                            Bike.strLongitude = Double(longi)!
                        }
                    }
                    Bike.isAccessibleUser = dictBike.object(forKey: "is_accessible_user") as? Int ?? 0
                    Bike.strAddress = dictBike.object(forKey: "address") as? String ?? ""
                    Bike.partner_name = dictBike.object(forKey: "partner_name") as? String ?? ""
                    Bike.plan_partner_id = dictBike.object(forKey: "plan_partner_id") as? String ?? "0"
                    Bike.is_plan_purchase = dictBike.object(forKey: "is_plan_purchase") as? String ?? "0"
                    Bike.is_outof_dropzone = Int(String(describing: dictBike["is_outof_dropzone"]!)) ?? -1
                    Bike.outOfDropzoneMsg = dictBike.object(forKey: "outof_dropzone_message")as? String ?? ""
                    Bike.is_bike_active = dictBike.object(forKey: "is_assets_active")as? Int ?? -1
                    Bike.is_bike_active_msg = dictBike.object(forKey: "is_assets_active_msg")as? String ?? ""
                    Bike.type = dictBike.object(forKey: "type")as? String ?? ""
                    Bike.type_name = dictBike.object(forKey: "type_name")as? String ?? ""
                    Bike.assets_color_code = dictBike.object(forKey: "assets_color_code")as? String ?? "#FB4671"
                    Bike.asset_img_url = dictBike.object(forKey: "assets_img_url")as? String ?? ""
                    arrOut.add(Bike)
                }
            }
        }
    }
    
    deinit {
        print("Singleton Denited....")
    }
    
    static func showSkeltonViewOnViews(viewsArray: [UIView]){
        for i in 0..<viewsArray.count{
            viewsArray[i].showAnimatedGradientSkeleton()
        }
    }
    
    static func hideSkeltonViewFromViews(viewsArray: [UIView]){
        for i in 0..<viewsArray.count{
            viewsArray[i].hideSkeleton()
        }
    }
    
    func getCardsList_Web(){
        let dictParam : NSMutableDictionary = NSMutableDictionary()
        let strCustID = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID)as? String ?? ""
        dictParam.setValue(strCustID, forKey: "bt_customer")
        dictParam.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        Singleton.shared.cardListsArray.removeAll()
        APICall.shared.postWeb("creditCardList", parameters: dictParam, showLoder: false, successBlock: { (responseOBJ) in
            
            if let dict =  responseOBJ as? NSDictionary {
                if let flag = dict.value(forKey: "FLAG")as? Int, flag == 1{
                    
                    if let referalCount = dict["referral_count"]as? String{
                        Singleton.shared.referalCount = referalCount
                    }
                    
                    if let bookingUserType = dict.value(forKey: "booking_user_type")as? String, bookingUserType == "1"{
                        
                    }else{
                        let arrCard = (dict["bt_card_details"] as? NSArray)
                        DispatchQueue.main.async(execute: {
                            for element in arrCard! {
                                if let dict = element as? NSDictionary {
                                    let cardDetail = shareCraditCard()
                                    cardDetail.cardType = dict.object(forKey: "cardType") as? String ?? ""
                                    cardDetail.card_number = dict.object(forKey: "card_number") as? String ?? ""
                                    cardDetail.exipry = dict.object(forKey: "exipry") as? String ?? ""
                                    cardDetail.exipry_month = dict.object(forKey: "exipry_month") as? String ?? ""
                                    cardDetail.exipry_year = dict.object(forKey: "exipry_year") as? String ?? ""
                                    cardDetail.name = dict.object(forKey: "name") as? String ?? ""
                                    cardDetail.token_id = dict.object(forKey: "token_id") as? String ?? ""
                                    Singleton.shared.cardListsArray.append(cardDetail)
                                }
                            }
                            
                        })
                    }
                }else{
                }
            }
        }) { (error) in
            
        }
    }
    
}

struct ERLOCK_ATTRIBUTES {
    static var UUID_SERVICE = "00001523-E513-11E5-9260-0002A5D5C51B"    //Used to discover services.
    static var UUID_STATE_CHAR = "00001524-E513-11E5-9260-0002A5D5C51B" //Used to get the state of lock.
    static var UUID_LOCK_CHAR = "00001525-E513-11E5-9260-0002A5D5C51B"  //Used to lock and unlock operations.
}

enum LockType {
    case linka,axa
}
