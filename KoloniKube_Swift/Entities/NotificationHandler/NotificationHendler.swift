//
//  NotificationHendler.swift
//  Booking_system
//
//  Created by Tops on 9/16/16.
//  Copyright © 2016 Tops. All rights reserved.
//

import UIKit

class NotificationHendler: NSObject,UIAlertViewDelegate {
    
  /*  var DicData:NSDictionary?
    var strBookingId:String = ""
    class var sharedInstance: NotificationHendler {
        struct Static {
            static var instance: NotificationHendler?
            static var navProfileVC: UINavigationController?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = NotificationHendler()
        }
        return Static.instance!
    }
    
    //MARK: GET NOTIFICATION DATA
    func getPushNotificationDataAndProcess(pushdata:NSDictionary){
        DicData = pushdata as NSDictionary
        let strLogin = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserDefaultKey.IS_USERLOGIN) as! String
        if strLogin == "1"{
            if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
                givePushNotifAppActiveAlert()
            }
            else{
                handlePushNotifInactiveApp()
            }
        }
    }
    
    func givePushNotifAppActiveAlert(){
        let aps:NSDictionary = DicData!["aps"] as! NSDictionary
        let data:NSDictionary = aps["data"] as! NSDictionary
        let strType : String = aps["ft"] as! String
        if strType == "1" {
                strBookingId = (data["bid"]?.stringValue)!
                let alert = UIAlertView(title: "", message:aps["alert"] as! String
                    , delegate:self, cancelButtonTitle:nil , otherButtonTitles:"Got it")
                alert.tag = 520
                alert.show()
        }
    }
    
    func handlePushNotifInactiveApp(){
           // let aps:NSDictionary = DicData!["aps"] as! NSDictionary
           // let data:NSDictionary = aps["data"] as! NSDictionary
           // let strType : String = aps["ft"] as! String
    }
    
    //MARK: UIALERTVIEW DELEGATE
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 520 {   // FOR NOTIFICATOIN RECIVED
            Global.appdel.UserGotitCall(strBookingId)
        }
    }*/
}
