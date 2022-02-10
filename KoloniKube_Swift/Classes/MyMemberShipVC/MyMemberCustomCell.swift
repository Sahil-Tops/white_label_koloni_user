//
//  MyMemberCustomCell.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/22/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit

class MyMemberCustomCell: UITableViewCell {

    //MARK: - Outlet's
    @IBOutlet weak var containerView: CustomView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var planName_lbl: UILabel!
    @IBOutlet weak var planExpiresDate_lbl: UILabel!
    @IBOutlet weak var price_lbl: UILabel!
    @IBOutlet weak var duration_lbl: UILabel!
    @IBOutlet weak var perRide_lbl: UILabel!
    @IBOutlet weak var descriptionText_lbl: UILabel!
    @IBOutlet weak var dropDown_btn: UIButton!
    
    //MARK: - Default Function's
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.titleView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        }
   }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
