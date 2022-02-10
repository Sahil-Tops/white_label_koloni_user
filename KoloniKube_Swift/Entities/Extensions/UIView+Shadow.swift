//
//  UIView+Shadow.swift
//  Booking_system
//
//  Created by Tops on 5/14/16.
//  Copyright © 2016 Tops. All rights reserved.
//

import UIKit
extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

extension UIView {
    
    func shadowWithCorner(corner: CGFloat){
        self.layer.masksToBounds = false
        self.layer.cornerRadius = corner
        self.layer.shadowOffset = CGSize(width: 0,height: 0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.5
    }
    
    func viewTrnsformAnimation(){
        self.transform = CGAffineTransform.identity.scaledBy(x: 0.3, y: 0.3)
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform.identity;
        }) 
    }
    
    func useUnderline(_ lineHeight:CGFloat, lineColor:UIColor, lineWidth: CGFloat) {
        let border = CALayer()
        border.borderColor = lineColor.cgColor
        border.frame = CGRect(x: CGFloat(0), y: CGFloat(self.frame.size.height - lineHeight), width: CGFloat(lineWidth), height: CGFloat(lineHeight))
        border.borderWidth = lineHeight
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    func useTopline(_ lineHeight:CGFloat, lineColor:UIColor, lineWidth: CGFloat) {
        let border = CALayer()
        border.borderColor = lineColor.cgColor
        border.frame = CGRect(x: CGFloat(0), y:CGFloat(0), width: CGFloat(lineWidth), height: CGFloat(lineHeight))
        border.borderWidth = lineHeight
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }

    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -3.0, 3.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
