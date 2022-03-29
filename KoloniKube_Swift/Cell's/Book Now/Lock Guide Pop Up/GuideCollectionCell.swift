//
//  GuideCollectionCell.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 6/15/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class GuideCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var lock_img: UIImageView!
    @IBOutlet weak var description_lbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
