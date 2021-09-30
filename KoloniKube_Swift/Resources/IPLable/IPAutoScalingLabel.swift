//
//  IPAutoScalingLabel.swift
//  RAVAS
//
//  Created by Tops on 12/15/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class IPAutoScalingLabel: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoscalingSizeOflable()
    }
    
    func autoscalingSizeOflable (){
        self.font = self.font.withSize(((UIScreen.main.bounds.size.width) * self.font.pointSize) / 320)
    }
}
