//
//  LocationTracker.swift
//  LocationSwing
//
//  Created by Mazhar Biliciler on 19/07/14.
//  Copyright (c) 2014 Mazhar Biliciler. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

let LATITUDE = "latitude"
let LONGITUDE = "longitude"
let ACCURACY = "theAccuracy"

class LocationTracker : NSObject, CLLocationManagerDelegate, UIAlertViewDelegate {
    
    var myLastLocation : CLLocationCoordinate2D?
    var myLastLocationAccuracy : CLLocationAccuracy?
    
    var accountStatus : NSString?
    var authKey : NSString?
    var device : NSString?
    var name : NSString?
    var profilePicURL : NSString?
    var userid : Int?
    
    var shareModel : LocationShareModel?
    
    var myLocation : CLLocationCoordinate2D?
    var myLocationAcuracy : CLLocationAccuracy?
    var myLocationAltitude : CLLocationDistance?
    
    override init()  {
        super.init()
        self.shareModel = LocationShareModel()
        self.shareModel!.myLocationArray = NSMutableArray()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LocationTracker.applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    class func sharedLocationManager()->CLLocationManager? {
        
        struct Static {
            static var _locationManager : CLLocationManager?
        }
        
        objc_sync_enter(self)
        if Static._locationManager == nil {
            Static._locationManager = CLLocationManager()
            Static._locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        
        objc_sync_exit(self)
        return Static._locationManager!
    }
    
    // MARK: Application in background
    @objc func applicationEnterBackground() {
        if StaticClass.sharedInstance.is_bookingStart{
            let locationManager : CLLocationManager = LocationTracker.sharedLocationManager()!
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startUpdatingLocation()
            if #available(iOS 9.0, *) {
//                locationManager.allowsBackgroundLocationUpdates = true
//                print("Start background location 1")
            } else {
                // Fallback on earlier versions
            }
            locationManager.startMonitoringSignificantLocationChanges()
            
            self.shareModel!.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager()
            _ = self.shareModel?.bgTask?.beginNewBackgroundTask()
        }
    }
    
    @objc func restartLocationUpdates() {
        if self.shareModel?.timer != nil {
            self.shareModel?.timer?.invalidate()
            self.shareModel!.timer = nil
        }
        
        let locationManager : CLLocationManager = LocationTracker.sharedLocationManager()!
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        if #available(iOS 9.0, *) {
//            locationManager.allowsBackgroundLocationUpdates = true
            print("Start background location 2")
        } else {
            // Fallback on earlier versions
        }
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func startLocationTracking() {
        
        if CLLocationManager.locationServicesEnabled() == false {
            AppDelegate.shared.window?.showAlert(title: "Location Services Disabled", message: "You currently have all location services for this device disabled")
//            let servicesDisabledAlert : UIAlertView = UIAlertView(title: "Location Services Disabled", message: "You currently have all location services for this device disabled", delegate: nil, cancelButtonTitle: "OK")
//            servicesDisabledAlert.show()
        } else {
            let authorizationStatus : CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if (authorizationStatus == CLAuthorizationStatus.denied) || (authorizationStatus == CLAuthorizationStatus.restricted) {
            } else {
                let locationManager : CLLocationManager = LocationTracker.sharedLocationManager()!
                locationManager.delegate = self
                locationManager.requestAlwaysAuthorization()
                
                if CLLocationManager.locationServicesEnabled() {
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                    locationManager.distanceFilter = kCLDistanceFilterNone
                    if StaticClass.sharedInstance.is_bookingStart{
                        locationManager.startUpdatingLocation()
                        if #available(iOS 9.0, *) {
                            locationManager.allowsBackgroundLocationUpdates = true
                            print("Start background location 3")
                        } else {
                            // Fallback on earlier versions
                        }
                        locationManager.startMonitoringSignificantLocationChanges()
                    }else{
                        locationManager.stopUpdatingLocation()
                        locationManager.allowsBackgroundLocationUpdates = false
                        locationManager.stopMonitoringSignificantLocationChanges()
                    }
                }
            }
        }
    }
    
    func stopLocationTracking () {
        
        if self.shareModel!.timer != nil {
            self.shareModel!.timer!.invalidate()
            self.shareModel!.timer = nil
        }
        let locationManager : CLLocationManager = LocationTracker.sharedLocationManager()!
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = false
        print("Stop background location 3")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        for loc in locations  {
        let newLocation : CLLocation = locations[0]
        let theLocation : CLLocationCoordinate2D = newLocation.coordinate
        let theAltitude : CLLocationDistance = newLocation.altitude
        let theAccuracy : CLLocationAccuracy = newLocation.horizontalAccuracy
        
        //            let locationAge : TimeInterval = newLocation.timestamp.timeIntervalSinceNow
        //            if locationAge > 15.0 {
        //                continue
        //            }
        //            // Select only valid location and also location with good accuracy
        //            if (newLocation != nil) && (theAccuracy > 0) && (theAccuracy < 2000) && !((theLocation.latitude == 0.0) && (theLocation.longitude == 0.0)) {
        self.myLastLocation = theLocation
        self.myLastLocationAccuracy = theAccuracy
        
        StaticClass.sharedInstance.saveToUserDefaults(theLocation.latitude as AnyObject?, forKey: Global.g_UserDefaultKey.latitude)
        StaticClass.sharedInstance.saveToUserDefaults(theLocation.longitude as AnyObject?, forKey: Global.g_UserDefaultKey.longitude)
        
        let dict : NSMutableDictionary = NSMutableDictionary()
        dict.setObject(NSNumber(floatLiteral:theLocation.latitude ),  forKey: "latitude" as NSCopying)
        
        dict.setObject(NSNumber(floatLiteral:theLocation.longitude ),  forKey: "longitude" as NSCopying)
        
        dict.setObject(NSNumber(floatLiteral:theAccuracy ),  forKey: "theAccuracy" as NSCopying)
        
        dict.setObject(NSNumber(floatLiteral:theAltitude ),  forKey: "theAltitude" as NSCopying)
        
        // Add the vallid location with good accuracy into an array
        // Every 1 minute, I will select the best location based on accuracy and send to server
        self.shareModel!.myLocationArray!.add(dict)
        //            }
        //        }
        // If the timer still valid, return it (Will not run the code below)
        if self.shareModel!.timer != nil {
            return
        }
        
        self.shareModel!.bgTask = BackgroundTaskManager.sharedBackgroundTaskManager()
        _ = self.shareModel!.bgTask!.beginNewBackgroundTask()
        
        // Restart the locationMaanger after 1 minute
        //        let restartLocationUpdates : Selector = #selector(LocationTracker.restartLocationUpdates)
        //        self.shareModel!.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: restartLocationUpdates, userInfo: nil, repeats: false)
        
        // Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
        // The location manager will only operate for 10 seconds to save battery
//        let stopLocationDelayBy10Seconds : Selector = #selector(LocationTracker.stopLocationDelayBy10Seconds)
//        var_s : Timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: stopLocationDelayBy10Seconds, userInfo: nil, repeats: false)
    }
    
    
    //MARK: Stop the locationManager
    @objc func stopLocationDelayBy10Seconds() {
        //        let locationManager : CLLocationManager = LocationTracker.sharedLocationManager()!
        //        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        switch (error) {
        case CLError.network:
//            let alert : UIAlertView = UIAlertView(title: "Network Error", message: "Please check your network connection.", delegate: self, cancelButtonTitle: "OK")
            AppDelegate.shared.window?.showAlert(title: "Network Error", message: "Please check your network connection.")
//            alert.show()
            break
        default:
            break
        }
        
    }
    
    // MARK: Update location to server
    func updateLocationToServer() {
        
        // Find the best location from the array based on accuracy
        var myBestLocation : NSMutableDictionary = NSMutableDictionary()
        
        for (index,object) in (self.shareModel?.myLocationArray?.enumerated())! {
            let currentLocation : NSMutableDictionary = object as! NSMutableDictionary
            if index == 0 {
                myBestLocation = currentLocation
            } else {
                if (currentLocation.object(forKey: ACCURACY) as! Float) <= (myBestLocation.object(forKey: ACCURACY) as! Float) {
                    myBestLocation = currentLocation
                }
            }
        }
        
        // If the array is 0, get the last location
        // Sometimes due to network issue or unknown reason, 
        // you could not get the location during that period, the best you can do is
        // sending the last known location to the server
        
        if self.shareModel!.myLocationArray!.count == 0 {
            self.myLocation = self.myLastLocation
            self.myLocationAcuracy = self.myLastLocationAccuracy
        } else {
            let lat : CLLocationDegrees = myBestLocation.object(forKey: LATITUDE) as! CLLocationDegrees
            let lon : CLLocationDegrees = myBestLocation.object(forKey: LONGITUDE) as! CLLocationDegrees
            let theBestLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            self.myLocation = theBestLocation
            self.myLocationAcuracy = myBestLocation.object(forKey: ACCURACY) as! CLLocationAccuracy?
        }
        
        
        // After sending the location to the server successful,
        // remember to clear the current array with the following code. It is to make sure that you clear up old location in the array 
        // and add the new locations from locationManager
        
        self.shareModel!.myLocationArray!.removeAllObjects()
        self.shareModel!.myLocationArray = nil
        self.shareModel!.myLocationArray = NSMutableArray()
    }
    
    func getBestLocationForServer()->NSDictionary? {
        
        // Find the best location from the array based on accuracy
        var myBestLocation : NSMutableDictionary = NSMutableDictionary()
        
        
        for (index,object) in (self.shareModel?.myLocationArray?.enumerated())! {
            let currentLocation : NSMutableDictionary = object as! NSMutableDictionary
            if index == 0 {
                myBestLocation = currentLocation
            } else {
                if (currentLocation.object(forKey: ACCURACY) as! Float) <= (myBestLocation.object(forKey: ACCURACY) as! Float) {
                    myBestLocation = currentLocation
                }
            }
        }
        
        // If the array is 0, get the last location
        // Sometimes due to network issue or unknown reason,
        // you could not get the location during that period, the best you can do is
        // sending the last known location to the server
        
        if self.shareModel!.myLocationArray!.count == 0 {
            self.myLocation = self.myLastLocation
            self.myLocationAcuracy = self.myLastLocationAccuracy
        } else {
            let lat : CLLocationDegrees = myBestLocation.object(forKey: LATITUDE) as! CLLocationDegrees
            let lon : CLLocationDegrees = myBestLocation.object(forKey: LONGITUDE) as! CLLocationDegrees
            let theBestLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            self.myLocation = theBestLocation
            
            self.myLocationAcuracy = myBestLocation.object(forKey: ACCURACY) as! CLLocationAccuracy?
        }
        
        let returnType : NSMutableDictionary = NSMutableDictionary()
        returnType.setValue(self.myLocation?.latitude, forKey: "lat")
        returnType.setValue(self.myLocation?.longitude, forKey: "lon")
        returnType.setValue(self.myLocationAcuracy!, forKey: "acc")
        
        
        // After sending the location to the server successful,
        // remember to clear the current array with the following code. It is to make sure that you clear up old location in the array
        // and add the new locations from locationManager
        
        self.shareModel!.myLocationArray!.removeAllObjects()
        self.shareModel!.myLocationArray = nil
        self.shareModel!.myLocationArray = NSMutableArray()
        return returnType
    }
    
}
