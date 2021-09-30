//
//  RoundView.swift
//  KoloniKube_Swift
//
//  Created by Tops on 10/16/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class RoundView: UIView {

    override func layoutSubviews() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2.0
    }
    
}
