//
//  CustomButton.swift
//  CougarX
//
//  Created by Sourabh Mittal on 10/6/18.
//  Copyright © 2018 Promatics. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CustomButton: UIButton{
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUp), for: .primaryActionTriggered)
        self.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
    }
    
    @IBAction func touchDown(sender: AnyObject) {
        print("Touch Down")       
    }
    
    @IBAction func touchUp(sender: AnyObject) {
        print("Touch Up")
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    @IBAction func touchUpOutside(sender: AnyObject) {
        print("Touch Up Outside")
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0{
        
        didSet{
            self.setCorner()
        }
    }
    
    @IBInspectable var isCirculer: Bool = false{
        
        didSet{
            self.setCorner()
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.0{
        
        didSet{
            self.setBorder()
        }
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.black{
        
        didSet{
            self.setBorder()
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
                border.frame = CGRect(x: 0, y: (self.frame.origin.y + self.frame.size.height) - 1, width: self.frame.size.width, height: 1)
                self.layer.addSublayer(border)
            }
        }
    }
    
    @IBInspectable
    open var underLineColor: UIColor = UIColor.black{
        
        didSet{
            self.setColor()
        }
        
    }
    
    func setColor(){
        
        layer.backgroundColor = underLineColor.cgColor
        
    }
    
    func setBorder(){
        
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        
    }
    
    func setCorner(){
        
        if isCirculer{
            self.layer.cornerRadius = self.frame.height/2
        }else{
            self.layer.cornerRadius = cornerRadius
        }        
    }
    
    
}

