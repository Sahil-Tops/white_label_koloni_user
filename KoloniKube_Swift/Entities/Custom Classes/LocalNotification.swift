//
//  LocalNotification.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 22/06/21.
//  Copyright © 2021 Self. All rights reserved.
//

import Foundation
import UIKit

class LocalNotification{
    
    let content = UNMutableNotificationContent()
    
    init(title: String, subtitle: String, body: String) {
        self.content.title = title
        self.content.subtitle = subtitle
        self.content.body = body
        let request = UNNotificationRequest(identifier: "timerDone", content: self.content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { (error) in
            if error == nil{
                print("Notification Delivered")
            }
        }
    }
    
}
