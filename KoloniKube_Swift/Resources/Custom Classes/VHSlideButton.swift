//
//  VHSlideView.swift
//  SlideButtonFramework
//
//  Created by Tops on 23/11/19.
//  Copyright © 2019 Tops. All rights reserved.
//

import Foundation
import UIKit

enum Postion{
    case top
    case bottom
}

protocol VHSlideButtonDelegate {
    func selectedPosition(position: Postion)
}

@IBDesignable
open class VHSlideButton: UIView{
    
    var sliding_btn = UIButton()
    var buttonImg = UIImageView()
    var bottomLabel = UILabel()
    var topLabel = UILabel()
    var delegate: VHSlideButtonDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame : frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    @IBInspectable
    var isHorizental: Bool = false{
        didSet{
            
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable
    var isCircular: Bool = false{
        didSet{
            if isCircular{
                self.layer.cornerRadius = self.frame.width/2
                self.layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable
    var bgColor: UIColor? {
        get{
            if let color = layer.backgroundColor{
                return UIColor(cgColor: color)
            }else{
                return UIColor.white
            }
        }
        set{
            if let color = newValue {
                layer.backgroundColor = color.cgColor
            }
        }
    }
    
    @IBInspectable
    var slideBtnBgColor: UIColor?{
        
        get{
            if let color = layer.backgroundColor{
                return UIColor(cgColor: color)
            }else{
                return UIColor.lightGray
            }
        }
        set{
            if let color = newValue{
                self.sliding_btn.backgroundColor = color
            }
        }
    }
    
    @IBInspectable
    var topTitle: String = ""{
        didSet{
            self.topLabel.text = topTitle
        }
    }
    
    @IBInspectable
    var bottomTitle: String = ""{
        didSet{
            self.bottomLabel.text = bottomTitle
        }
    }
    
    @IBInspectable
    var topTitleTextColor: UIColor = .black{
        didSet{
            self.topLabel.textColor = topTitleTextColor
        }
    }
    @IBInspectable
    var bottomTitleTextColor: UIColor = .black{
        didSet{
            self.bottomLabel.textColor = bottomTitleTextColor
        }
    }
    
    @IBInspectable
    var imageName: UIImage = UIImage(){
        didSet{
            self.setupButton()
        }
    }
    
    func setUpView(){
        if self.isHorizental{
            self.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
        }
    }
    
    func setupButton(){
        
        self.sliding_btn.frame = CGRect(x: 6, y: 6, width: self.frame.width-12, height: self.frame.width-12)
        self.sliding_btn.setBackgroundImage(UIImage(named: "side_menu"), for: .normal)
//        self.sliding_btn.createGradientLayer(color1: CustomColor.customBlue, color2: CustomColor.customAppGreen, startPosition: 0.2, endPosition: 1.0)
        self.sliding_btn.layer.cornerRadius = self.sliding_btn.frame.width/2
        self.sliding_btn.layer.masksToBounds = true
        self.setupButtonImage()
        self.setupTopBottomLabel()
        self.addSubview(sliding_btn)
        self.addPangesture()
        
    }
    
    func setupButtonImage(){
        self.buttonImg.frame.size.width = self.sliding_btn.frame.width/2
        self.buttonImg.frame.size.height = self.sliding_btn.frame.height/2
        self.buttonImg.frame.origin.x = self.sliding_btn.frame.width/2 - self.buttonImg.frame.width/2
        self.buttonImg.frame.origin.y = self.sliding_btn.frame.height/2 - self.buttonImg.frame.height/2
        self.buttonImg.backgroundColor = UIColor.clear
        self.buttonImg.contentMode = .scaleAspectFit
        self.buttonImg.image = self.imageName
        self.buttonImg.tintColor = .white
        self.sliding_btn.addSubview(buttonImg)
    }
    
    func setupTopBottomLabel(){
        
        self.topLabel.frame = CGRect(x: 4, y: 20, width: self.frame.width - 4, height: 20)
        self.bottomLabel.frame = CGRect(x: 4, y: self.frame.height - 20, width: self.frame.width - 4, height: 20)
        self.topLabel.font = UIFont.systemFont(ofSize: 15.0)
        self.bottomLabel.font = UIFont.systemFont(ofSize: 15.0)
        self.topLabel.textAlignment = .center
        self.bottomLabel.textAlignment = .center
        self.addSubview(topLabel)
        self.addSubview(bottomLabel)
    }
    
    func addPangesture(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(panGesture:)))
        panGesture.minimumNumberOfTouches = 1
        self.sliding_btn.addGestureRecognizer(panGesture)
    }
    
    @objc func panGestureHandler(panGesture recognizer: UIPanGestureRecognizer) {
        
        DispatchQueue.main.async {
            
            if recognizer.state == .changed{
                self.sliding_btn.center.y = recognizer.location(in: self).y
                if self.sliding_btn.center.y > (self.frame.height) - ((self.sliding_btn.frame.height)/2 + 6) {
                    self.sliding_btn.center.y = (self.frame.height) - ((self.sliding_btn.frame.height)/2 + 6)
                }else if self.sliding_btn.frame.origin.y < 6{
                    self.sliding_btn.center.y = 6 + (self.sliding_btn.frame.height)/2
                }
            }else if recognizer.state != .began{
                
                if (recognizer.view?.center.y)! < self.frame.height/2{
                    self.sliding_btn.center.y = 6 + (self.sliding_btn.frame.height)/2
                    self.delegate?.selectedPosition(position: Postion.top)
                }else{
                    if round(self.sliding_btn.center.y) == round((self.frame.height) - ((self.sliding_btn.frame.height)/2 + 6)) {
                        self.sliding_btn.center.y = (self.frame.height) - ((self.sliding_btn.frame.height)/2 + 6)
                        self.delegate?.selectedPosition(position: Postion.bottom)
                    }else{
                        self.sliding_btn.center.y = 6 + (self.sliding_btn.frame.height)/2
                        self.delegate?.selectedPosition(position: Postion.top)
                    }
                }
            }
            self.layoutIfNeeded()
        }
        
    }
    
    func resetSlideButton(){
        self.sliding_btn.frame.origin.y = 6
    }
    
}
