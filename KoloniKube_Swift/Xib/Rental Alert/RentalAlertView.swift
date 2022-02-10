//
//  RentalAlertView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 5/4/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class RentalAlertView: UIView {

    @IBOutlet weak var checkBox_btn: UIButton!
    @IBOutlet weak var endRental_btn: CustomButton!
    @IBOutlet weak var lock_btn: CustomButton!
    @IBOutlet weak var cancel_btn: UIButton!
    
    
    var bookNowVc: BookNowVC?
    
    //MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case lock_btn:
            self.bookNowVc?.rentalActionPerformed = 0
            self.bookNowVc?.permissionAlertToPause()
            self.removeView()
            break
        case endRental_btn:
            self.bookNowVc?.rentalActionPerformed = 1
            self.bookNowVc?.permissionAlertToEnd()
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
    
}

extension UIViewController{
    
    func loadRentalAlertView(){
        let view = Bundle.main.loadNibNamed("RentalAlertView", owner: nil, options: [:])?.first as! RentalAlertView
        view.frame = self.view.bounds
        view.bookNowVc = self as? BookNowVC
        view.frame.origin.y += view.frame.height
        self.view.addSubview(view)
        
        UIView.animate(withDuration: 0.5) {
            view.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }
    }
}
