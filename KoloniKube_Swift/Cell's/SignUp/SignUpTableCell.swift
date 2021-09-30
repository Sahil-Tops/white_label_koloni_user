//
//  SignUpTableCell.swift
//  KoloniKube_Swift
//
//  Created by Tops on 21/10/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class SignUpTableCell: UITableViewCell {
    
    @IBOutlet weak var textFieldTItle_lbl: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldBtn: UIButton!

    @IBOutlet weak var enterMobile_textField: UITextField!
    @IBOutlet weak var countryCode_btn: UIButton!
    @IBOutlet weak var countryFlag_Img: UIImageView!
    @IBOutlet weak var countryCode_lbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
