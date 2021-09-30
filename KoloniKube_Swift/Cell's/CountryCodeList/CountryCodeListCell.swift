//
//  CountryCodeListCell.swift
//  KoloniKube_Swift
//
//  Created by Tops on 04/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class CountryCodeListCell: UITableViewCell {
    
    @IBOutlet weak var flag_Img: UIImageView!
    @IBOutlet weak var countryNameAndCode_lbl: UILabel!
    @IBOutlet weak var phoneCode_lbl: UILabel!
    @IBOutlet weak var cell_btn: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
