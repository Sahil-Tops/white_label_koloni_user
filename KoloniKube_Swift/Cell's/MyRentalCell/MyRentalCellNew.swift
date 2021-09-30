//
//  MyRentalCellNew.swift
//  KoloniKube_Swift
//
//  Created by Tops on 19/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class MyRentalCellNew: UITableViewCell {
    
    @IBOutlet weak var containerView: CustomView!
    @IBOutlet weak var vehicleNameContainerView: UIView!
    @IBOutlet weak var vehicalNameBgImageView: UIImageView!
        
    @IBOutlet weak var startTimeTitle_lbl: UILabel!
    @IBOutlet weak var totalAmountPaidTitle_lbl: UILabel!
    @IBOutlet weak var totalTimeTitle_lbl: UILabel!
    
    @IBOutlet weak var orderNumber_lbl: UILabel!
    @IBOutlet weak var date_lbl: UILabel!
    @IBOutlet weak var startTime_lbl: UILabel!
    @IBOutlet weak var totalAmountPaid_lbl: UILabel!
    @IBOutlet weak var totalTime_lbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
