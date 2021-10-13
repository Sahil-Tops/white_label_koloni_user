//
//  RentalAlertView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 5/4/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class RentalAlertView: UIView {

    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var checkBox_btn: UIButton!
    @IBOutlet weak var endRental_btn: CustomButton!
    @IBOutlet weak var lock_btn: CustomButton!
    @IBOutlet weak var cancel_btn: UIButton!
    
    
    var bookNowVc: BookNowVC?
    var locationVc: LocationListingViewController?
    var vc: UIViewController?
    
    //MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case lock_btn:
            if self.vc is BookNowVC{
                self.bookNowVc?.rentalActionPerformed = 0
                self.bookNowVc?.permissionAlertToPause()
            }else{
                self.locationVc?.runningRentalView?.rentalActionPerformed = 0
                self.locationVc?.runningRentalView?.pauseResumeEndAlert(action: "pause")
            }
            self.removeView()
            break
        case endRental_btn:
            if self.vc is BookNowVC{
                self.bookNowVc?.rentalActionPerformed = 1
                self.bookNowVc?.permissionAlertToEnd()
            }else{
                self.locationVc?.runningRentalView?.rentalActionPerformed = 1
                self.locationVc?.runningRentalView?.pauseResumeEndAlert(action: "end")
            }
            self.removeView()
            break
        case checkBox_btn:
            if self.checkBox_btn.tag == 0{
                self.checkBox_btn.setImage(UIImage(named: "checked_blue"), for: .normal)
                self.checkBox_btn.tag = 1
                UserDefaults.standard.set(true, forKey: "hide_axa_lock_alert_popup")
            }else{
                self.checkBox_btn.setImage(UIImage(named: "unchecked_gray"), for: .normal)
                self.checkBox_btn.tag = 0
                UserDefaults.standard.set(false, forKey: "hide_axa_lock_alert_popup")
            }
            break
        case cancel_btn:
            self.removeView()
            break
        default:
            break
        }
        
    }
    
    func removeView(){
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.height
            self.layoutIfNeeded()
        } completion: { (_) in
            self.removeFromSuperview()
        }

    }
    
    func loadContent(){
        if let viewController = self.vc as? BookNowVC{
            self.bookNowVc = viewController
        }else if let viewController = self.vc as? LocationListingViewController{
            self.locationVc = viewController
        }
        self.title_lbl.textColor = CustomColor.primaryColor
        if AppLocalStorage.sharedInstance.application_gradient{
            self.lock_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.lock_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
    }
    
}

extension UIViewController{
    
    func loadRentalAlertView(){
        let view = Bundle.main.loadNibNamed("RentalAlertView", owner: nil, options: [:])?.first as! RentalAlertView
        view.frame = self.view.bounds
        view.vc = self
        view.frame.origin.y += view.frame.height
        view.loadContent()
        self.view.addSubview(view)
        UIView.animate(withDuration: 0.5) {
            view.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }
    }
}
