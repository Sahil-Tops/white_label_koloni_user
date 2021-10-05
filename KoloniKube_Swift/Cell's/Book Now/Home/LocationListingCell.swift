//
//  LocationListingCell.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 01/10/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class LocationListingCell: UITableViewCell {
    
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var description_lbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.titleContainerView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.titleContainerView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
            self.layoutIfNeeded()
        }
        self.title_lbl.textColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
