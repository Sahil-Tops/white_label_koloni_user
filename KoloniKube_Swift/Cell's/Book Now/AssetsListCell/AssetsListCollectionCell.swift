//
//  AssetsListCollectionCell.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 5/5/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class AssetsListCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var assetTitle_lbl: UILabel!
    @IBOutlet weak var imageContainerView: CustomView!
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var assetType_lbl: UILabel!
    @IBOutlet weak var initialPrice_lbl: UILabel!
    @IBOutlet weak var hourlyRate_lbl: UILabel!
    @IBOutlet weak var seePlans_btn: CustomButton!
    @IBOutlet weak var book_btn: CustomButton!
    
    var assetsListView: AssetsListView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setAvailableBikeDataOnCell(data: AvailabelBike){
    
        self.assetType_lbl.text = data.type_name
        DispatchQueue.main.async {
            if AppLocalStorage.sharedInstance.application_gradient{
                self.book_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            }else{
                self.book_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
            }
            if data.asset_img_url != ""{
                if data.type == "2"{
                    if let url = URL(string: data.asset_img_url){
                        self.assetImage.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")) { (image, error, cache, url) in
                            self.imageContainerView.backgroundColor = UIColor.init(hex: data.assets_color_code)
                            self.imageContainerView.circleObject()
                        }
                    }
                }else{
                    self.assetImage.image = UIImage(named: "locker_white")
                    self.imageContainerView.backgroundColor = CustomColor.secondaryColor
                }
            }
        }
        self.initialPrice_lbl.text = "$\(Int(data.bikeInitialPrice))"
        self.hourlyRate_lbl.text = "$\(Int(data.doubleBikeAveragePrice))"
        self.assetTitle_lbl.text = "ID - \(data.strObjUniqueId)"
        
        if data.is_bike_active == 0{
            self.book_btn.isHidden = true
            self.seePlans_btn.setTitle("Show nearly koloni", for: .normal)
        }else{
            self.book_btn.isHidden = false
            if data.isAccessibleUser == 0{
                self.seePlans_btn.setTitle("Show nearly koloni", for: .normal)
                self.book_btn.setTitle("Private", for: .normal)
                if data.is_outof_dropzone == 1{
                    self.seePlans_btn.isHidden = true
                }else{
                    self.seePlans_btn.isHidden = false
                }
            }else{
                self.seePlans_btn.setTitle("See plans", for: .normal)
                self.book_btn.setTitle("Book", for: .normal)
                if data.is_plan_purchase == "1"{
                    self.seePlans_btn.isHidden = true
                }else{
                    if data.is_outof_dropzone == 1{
                        self.seePlans_btn.isHidden = true
                    }else{
                        self.seePlans_btn.isHidden = false
                    }
                }
            }
        }
        self.seePlans_btn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.book_btn.titleLabel?.adjustsFontSizeToFitWidth = true
    }    
    //MARK: - @IBAction
    @IBAction func clickOnBtn(_ sender: UIButton) {
        let data = self.assetsListView.availabelBikeArray[self.tag]
        if sender == book_btn{
            UIView.animate(withDuration: 0.2, animations: {
                self.assetsListView.containerView.alpha = 0
            }) { (_) in
                self.assetsListView.removeFromSuperview()
                self.assetsListView.bookNowVc.selectedObjectId = data.strObjUniqueId
                if self.book_btn.currentTitle == "Book"{
                    self.assetsListView.delegate?.selectedAsset(buttonPressed: "book", assetId: data.strObjUniqueId)
                }else{
                    self.assetsListView.delegate?.selectedAsset(buttonPressed: "private", assetId: data.strObjUniqueId)
                }
            }
        }else if sender == seePlans_btn{
            UIView.animate(withDuration: 0.2, animations: {
                self.assetsListView.containerView.alpha = 0
            }) { (_) in
                self.assetsListView.removeFromSuperview()
                if self.seePlans_btn.currentTitle == "See plans"{
                    let HubListVCController = HubListVC(nibName: "HubListVC", bundle: nil)
                    HubListVCController.strPartnerName = data.partner_name
                    HubListVCController.strPartnerID = data.plan_partner_id
                    self.assetsListView.bookNowVc.navigationController?.pushViewController(HubListVCController, animated: true)
                }else{
                    self.assetsListView.delegate?.selectedAsset(buttonPressed: "nearly_koloni", assetId: data.strObjUniqueId)
                }
                
            }
        }
    }
    
    
}
