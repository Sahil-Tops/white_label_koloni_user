//
//  BackgroundTaskManager.swift
//  LocationSwing
//
//  Created by Mazhar Biliciler on 14/07/14.
//  Copyright (c) 2014 Mazhar Biliciler. All rights reserved.
//

import Foundation
import UIKit


class BackgroundTaskManager : NSObject {
    
    var bgTaskIdList : NSMutableArray?
    var masterTaskId : UIBackgroundTaskIdentifier?
    
    override init() {
        super.init()
//        if self != nil {
//            self.bgTaskIdList = NSMutableArray()
//            self.masterTaskId = UIBackgroundTaskIdentifier.invalid
//        }
        self.bgTaskIdList = NSMutableArray()
        self.masterTaskId = UIBackgroundTaskIdentifier.invalid
    }
    
    class func sharedBackgroundTaskManager() -> BackgroundTaskManager? {
        struct Static {
            static var sharedBGTaskManager : BackgroundTaskManager?
            static var onceToken : dispatch_time_t = 0
        }
        
        Static.sharedBGTaskManager = BackgroundTaskManager()

        return Static.sharedBGTaskManager
    }
    
    func beginNewBackgroundTask() -> UIBackgroundTaskIdentifier? {
        let application : UIApplication = UIApplication.shared
        
        var bgTaskId : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid

        if application.responds(to: #selector(UIApplication.beginBackgroundTask(withName:expirationHandler:))){
            bgTaskId = application.beginBackgroundTask(expirationHandler: {
            })
        }
        
        if self.masterTaskId == UIBackgroundTaskIdentifier.invalid {
            self.masterTaskId = bgTaskId
        } else {
            // add this ID to our list
            self.bgTaskIdList!.add(bgTaskId)
            //self.endBackgr
        }
        return bgTaskId
    }
    
  @objc  func endBackgroundTask(){
        self.drainBGTaskList(all: false)
    }
    
  @objc  func endAllBackgroundTasks() {
        self.drainBGTaskList(all: true)
    }
    
    func drainBGTaskList(all:Bool) {
        //mark end of each of our background task
        let application: UIApplication = UIApplication.shared
        
        let _ : Selector = #selector(BackgroundTaskManager.endBackgroundTask)
        
        if application.responds(to: #selector(BackgroundTaskManager.endBackgroundTask)) {
            let count: Int = self.bgTaskIdList!.count
            for _ in (all == true ? 0 : 1)..<count {
                let bgTaskId : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: self.bgTaskIdList!.object(at: 0) as! Int)
                application.endBackgroundTask(bgTaskId)
                self.bgTaskIdList!.removeObject(at: 0)
            }
            if self.bgTaskIdList!.count > 0 {
            }
            if all == true {
                application.endBackgroundTask(self.masterTaskId!)
                self.masterTaskId = UIBackgroundTaskIdentifier.invalid
            } else {
            }
        }
    }

}


