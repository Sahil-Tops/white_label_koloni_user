//
//  ReferralView.swift
//  KoloniKube_Swift
//
//  Created by Tops on 26/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class ReferralView: UIView {

    @IBOutlet weak var checkBox_btn: UIButton!
    @IBOutlet weak var numberOfReferral_lbl: UILabel!

    var bookingPaymentVc: BookingPaymentVC?
    
    @IBAction func tapCheckBoxBtn(_ sender: UIButton) {
        if sender.tag == 0{
            sender.tag = 1
            self.bookingPaymentVc?.referralSelected = 1
            self.checkBox_btn.setImage(UIImage(named: "checked_blue"), for: .normal)
        }else{
            sender.tag = 0
            self.bookingPaymentVc?.referralSelected = 0
            self.checkBox_btn.setImage(UIImage(named: "unchecked_gray"), for: .normal)
        }
    }
    
}

//extension BookingPaymentVC{
//    func loadReferralView(view: UIView, numberOfReferral: String){
//        
//    }
//}
