//
//  DropDownViewCell.swift
//  KoloniPartner
//
//  Created by Sahil Mehra on 2/2/21.
//  Copyright © 2021 Sahil Mehra. All rights reserved.
//

import UIKit

class DropDownViewCell: UITableViewCell {
    
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var underLine_lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
