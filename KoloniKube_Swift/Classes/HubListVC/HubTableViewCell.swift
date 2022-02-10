//
//  HubTableViewCell.swift
//  KoloniKube_Swift
//
//  Created by Tops on 27/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class HubTableViewCell: UITableViewCell {
    
    //Outlet's
    @IBOutlet weak var containerView: CustomView!
    @IBOutlet weak var plansName_lbl: UILabel!
    @IBOutlet weak var price_lbl: UILabel!
    @IBOutlet weak var duration_lbl: UILabel!
    @IBOutlet weak var perRide_lbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
