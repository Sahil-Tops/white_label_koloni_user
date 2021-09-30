//
//  Membership1TblCell.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/22/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit

class BuyMembershipTblCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var seperator: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
