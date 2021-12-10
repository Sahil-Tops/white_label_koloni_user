//
//  AssetsTableViewCell.swift
//  KoloniPartner
//
//  Created by Sahil Mehra on 4/3/20.
//  Copyright © 2020 Sahil Mehra. All rights reserved.
//

import UIKit

class AssetsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var barView: CustomView!
    @IBOutlet weak var assetId_lbl: UILabel!
    @IBOutlet weak var location_lbl: UILabel!
    @IBOutlet weak var assetType_lbl: UILabel!
    @IBOutlet weak var cellBgView: CustomView!
    @IBOutlet weak var reportIssue_btn: UIButton!
    @IBOutlet weak var reportIssueBtn_width: NSLayoutConstraint!
    
    var assetListVc: AssetsListingViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutIfNeeded() {
        DispatchQueue.main.async {
            self.reportIssue_btn.isHidden = true            
            self.reportIssue_btn.circleObject()
            self.barView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.barView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        }
    }
    
}
