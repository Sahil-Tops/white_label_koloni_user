//
//  LinkaAPIManager.swift
//  LockTestAPIiOS
//
//  Created by Leung Yu Wing on 8/10/2016.
//  Copyright © 2016年 Vanport. All rights reserved.
//  Last change for Linka Version 1.3.3

import UIKit
import LinkaAPIKit
import CoreLocation
import CoreBluetooth

class AppLinkaAPIManager: NSObject, LinkaAPIProtocol, CLLocationManagerDelegate {
    static var LinkaMerchantAPIKey = "562e0453-f660-479c-9bd8-69365fd31215"
    static var LinkaMerchantSecretKey = "4c981ecd-845d-473d-89d9-af0cc51a954e"
    
    static var isButtonUsedForLocking = false
    
    var locationManager : CLLocationManager!
    func Linka_locationManager() -> CLLocationManager!
    {
        return locationManager
    }
    func LinkaMerchantAPI_getAPIKey() -> String!
    {
        return AppLinkaAPIManager.LinkaMerchantAPIKey
    }
    func LinkaMerchantAPI_getSecretKey() -> String!
    {
        return AppLinkaAPIManager.LinkaMerchantSecretKey
    }
    
    func LinkaMerchantAPI_getIsButtonUsed() -> Bool
    {
        return AppLinkaAPIManager.isButtonUsedForLocking
    }
    
    func initializeLocationManager()
    {
        locationManager = LinkaMerchantAPIService.makeLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    var curLocation : CLLocation!
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        curLocation = locations[0];
        StaticClass.sharedInstance.saveToUserDefaults(curLocation.coordinate.latitude as AnyObject?, forKey: Global.g_UserDefaultKey.latitude)
        StaticClass.sharedInstance.saveToUserDefaults(curLocation.coordinate.longitude as AnyObject?, forKey: Global.g_UserDefaultKey.longitude)
        locationManager.stopMonitoringSignificantLocationChanges()
        //        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        //This method does real time status monitoring.
        
        switch status {
        case .notDetermined:
            print(".NotDetermined")
            break
            
        case .authorizedAlways:
            print(".AuthorizedAlways")
            //            NotificationCenter.default.post(name: Notification.Name("reloadmap"), object: nil)
            break
            
        case .denied:
            print(".Denied")
            break
            
        case .authorizedWhenInUse:
            //            NotificationCenter.default.post(name: Notification.Name("reloadmap"), object: nil)
            print(".AuthorizedWhenInUse")
            break
            
        case .restricted:
            print(".Restricted")
            break
            
        default:
            print("Unhandled authorization status")
            break            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
    }
}
