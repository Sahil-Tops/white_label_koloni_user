//
//  AssetsListTableCell.swift
//  KoloniKube_Swift
//
//  Created by Sam on 17/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import UIKit

class AssetsListTableCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewTitle: CustomView!
    @IBOutlet weak var lblAssetId: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
    }
    
    override func layoutIfNeeded() {
        DispatchQueue.main.async {
            self.viewTitle.roundCorners(corners: [.topLeft, .topRight], radius: 15)
            self.viewContainer.cornerRadius(cornerValue: 15)
            self.viewContainer.shadow(color: UIColor.gray, radius: 4, opacity: 0.4)
        }
    }

}
