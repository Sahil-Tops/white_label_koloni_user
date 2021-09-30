//
//  FaqTableCell.swift
//  KoloniKube_Swift
//
//  Created by Tops on 09/12/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class FaqTableCell: UITableViewCell {
    
    @IBOutlet weak var question_lbl: UILabel!
    @IBOutlet weak var answer_lbl: UILabel!
//    @IBOutlet weak var answerLabel_height: NSLayoutConstraint!
    @IBOutlet weak var arrow_btn: UIButton!
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
