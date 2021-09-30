//
//  UIViewShadow.swift
//  Patient
//
//  Created by promatics on 13/09/18.
//  Copyright © 2018 Promatics Technologies. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomView: UIImageView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable
    open var isUnderLine: Bool = false{
        
        didSet {
            if isUnderLine {
                
                let border = CALayer()
                border.backgroundColor = underLineColor.cgColor
                border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
                self.layer.addSublayer(border)
            }
        }
    }
    
    func setColor(){
        
        layer.backgroundColor = underLineColor.cgColor
        
    }
    
    @IBInspectable
    open var underLineColor: UIColor = UIColor.darkGray{
        
        didSet{
            self.setColor()
        }
        
    }
    
    @IBInspectable
    var isCircular: Bool = false{
        
        didSet{
            
            if isCircular{
                self.layer.cornerRadius = self.layer.frame.height/2
                self.layer.masksToBounds = true
            }
        }
    }
    
}
//
//@IBDesignable
//class CustomAnimateView: UIView{
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
//        self.addGestureRecognizer(tap)
//    }
//    
//    @objc func tapGestureAction(_ sender: UITapGestureRecognizer){
//        
//        UIView.animate(withDuration: 0.5) {
//            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//        } completion: { (_) in
//            UIView.animate(withDuration: 0.5) {
//                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//            }
//        }
//        
//    }
//    
//    @IBInspectable
//    var cornerRadius: CGFloat {
//        get {
//            return layer.cornerRadius
//        }
//        set {
//            layer.cornerRadius = newValue
//        }
//    }
//    
//    @IBInspectable
//    var borderWidth: CGFloat {
//        get {
//            return layer.borderWidth
//        }
//        set {
//            layer.borderWidth = newValue
//        }
//    }
//    
//    @IBInspectable
//    var borderColor: UIColor? {
//        get {
//            if let color = layer.borderColor {
//                return UIColor(cgColor: color)
//            }
//            return nil
//        }
//        set {
//            if let color = newValue {
//                layer.borderColor = color.cgColor
//            } else {
//                layer.borderColor = nil
//            }
//        }
//    }
//    
//    @IBInspectable
//    var shadowRadius: CGFloat {
//        get {
//            return layer.shadowRadius
//        }
//        set {
//            layer.shadowRadius = newValue
//        }
//    }
//    
//    @IBInspectable
//    var shadowOpacity: Float {
//        get {
//            return layer.shadowOpacity
//        }
//        set {
//            layer.shadowOpacity = newValue
//        }
//    }
//    
//    @IBInspectable
//    var shadowOffset: CGSize {
//        get {
//            return layer.shadowOffset
//        }
//        set {
//            layer.shadowOffset = newValue
//        }
//    }
//    
//    @IBInspectable
//    var shadowColor: UIColor? {
//        get {
//            if let color = layer.shadowColor {
//                return UIColor(cgColor: color)
//            }
//            return nil
//        }
//        set {
//            if let color = newValue {
//                layer.shadowColor = color.cgColor
//            } else {
//                layer.shadowColor = nil
//            }
//        }
//    }
//    
//    @IBInspectable
//    open var isUnderLine: Bool = false{
//        
//        didSet {
//            if isUnderLine {
//                
//                let border = CALayer()
//                border.backgroundColor = underLineColor.cgColor
//                border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
//                self.layer.addSublayer(border)
//            }
//        }
//    }
//    
//    func setColor(){
//        
//        layer.backgroundColor = underLineColor.cgColor
//        
//    }
//    
//    @IBInspectable
//    open var underLineColor: UIColor = UIColor.darkGray{
//        
//        didSet{
//            self.setColor()
//        }
//        
//    }
//    
//    @IBInspectable
//    var isCircular: Bool = false{
//        
//        didSet{
//            
//            if isCircular{
//                self.layer.cornerRadius = self.layer.frame.height/2
//                self.layer.masksToBounds = true
//            }
//        }
//    }
//    
//}
