//
//  AddCardTableViewCell.swift
//  KoloniKube_Swift
//
//  Created by Tops on 21/10/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class AddCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardImage: CustomView!
    @IBOutlet weak var cardNumber_lbl: UILabel!
    @IBOutlet weak var cardHolderName_lbl: UILabel!
    @IBOutlet weak var expireDate_lbl: UILabel!
    @IBOutlet weak var cardType_Img: UIImageView!
    @IBOutlet weak var radioImg: UIImageView!
    @IBOutlet weak var radioImg_width: NSLayoutConstraint!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.addRightViewInCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    @objc func deleteBtnTapped(){
        //Reset the cell state and close the swipe action
        print("Delete Tapped")
    }
}
