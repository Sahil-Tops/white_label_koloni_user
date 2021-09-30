//
//  CardsListCell.swift
//  KoloniKube_Swift
//
//  Created by Tops on 25/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class CardsListCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cardImg: UIImageView!
    @IBOutlet weak var cardNumber_lbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
