//
//  Colors.swift
//  Koloni
//
//  Created by Sahil Mehra on 5/1/19.
//  Copyright © 2019 Sahil Mehra. All rights reserved.
//

import Foundation
import UIKit

class CustomColor{
    
    static var primaryColor = AppLocalStorage.sharedInstance.primary_color
    static var countsColor = UIColor(hex: "#06d2dd")!
    static var secondaryColor = AppLocalStorage.sharedInstance.secondary_color
    static var blueColor = UIColor(hex: "#082588")!
    static var customAppGreen =  UIColor(red: 6/255, green: 210/255, blue: 210/255, alpha: 1.0)
    static var customAppBlueWithAlpha = UIColor(red: 84/255, green: 76/255, blue: 244/255, alpha: 1.0).withAlphaComponent(0.7)
    static var customYellow = UIColor(red: 250/255, green: 226/255, blue: 119/255, alpha: 1.0)
    static var customLightGray = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    static var customAppRed =  UIColor(red: 251/255, green: 70/255, blue: 113/255, alpha: 1.0)
    static var customRed = UIColor(red: 255/255, green: 3/255, blue: 3/255, alpha: 1.0)
    static var selectedMenu = AppLocalStorage.sharedInstance.secondary_color
    static var transparentDarkGray = UIColor(red: 33/255, green: 33/255, blue: 3/255, alpha: 0.9)
    
}
