//
//  UIButton+Border.swift
//  Booking_system
//
//  Created by Tops on 5/21/16.
//  Copyright © 2016 Tops. All rights reserved.
//

import UIKit

extension UIButton {
    
    func SetCustomBoarder(){
        self.layer.cornerRadius = 1.0
        //self.layer.borderColor = StaticClass.sharedInstance.colorWithHexString("E8E8E8", alpha: 1.0).CGColor
        self.layer.borderWidth = 1.0
    }
    
    func SetCustomBoarderWithHexColor(_ str:String){
        self.layer.cornerRadius = 1.0
        //self.layer.borderColor = StaticClass.sharedInstance.colorWithHexString(str, alpha: 1.0).CGColor
        self.layer.borderWidth = 1.0
    }
    
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2 as Double)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func DrawButtonUnderline(_ lineHeight:CGFloat, lineColor:UIColor, lineWidth: CGFloat) {
        let border = CALayer()
        border.borderColor = lineColor.cgColor
        border.frame = CGRect(x: CGFloat(0), y: CGFloat(self.frame.size.height - lineHeight), width: CGFloat(lineWidth), height: CGFloat(lineHeight))
        border.borderWidth = lineHeight
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func DrawButtonTopline(_ lineHeight:CGFloat, lineColor:UIColor, lineWidth: CGFloat) {
        let border = CALayer()
        border.borderColor = lineColor.cgColor
        border.frame = CGRect(x: CGFloat(0), y:CGFloat(0), width: CGFloat(lineWidth), height: CGFloat(lineHeight))
        border.borderWidth = lineHeight
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
}
