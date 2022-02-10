//
//  PinCodePopUp.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 21/10/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class PinCodePopUp: UIView {

    @IBOutlet weak var containerView: CustomView!
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var code_textField: UITextField!
    @IBOutlet weak var cancel_btn: UIButton!
    @IBOutlet weak var submit_btn: UIButton!
    
    var vc: UIViewController?
    var type = ""
    
    
    //MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case cancel_btn:
            self.closeView()
            break
        case submit_btn:
            if self.code_textField.text!.count == 4{
                if self.type == "start_booking"{
                    if let bookNowVc = self.vc as? BookNowVC{
                        bookNowVc.startBookingSwift?.generateExtenedLicense(code: self.code_textField.text!)
                    }
                }else if self.type == "qr_code_scan"{
                    if let qrCodeVc = self.vc as? QRCodeScaneVC{
                        qrCodeVc.generateExtenedLicense(code: self.code_textField.text!)
                    }
                }
                self.closeView()
            }else{
                self.vc?.alert(title: "Alert", msg: "Please enter 4 digit code to lock and open the lock")
            }
            break
        default:
            break
        }
    }
    
    func closeView(){
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.size.height
            self.layoutIfNeeded()
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
}

extension UIViewController{
    func loadPinCodePopUp(type: String){
        if let view = Bundle.main.loadNibNamed("PinCodePopUp", owner: nil, options: [:])?.first as? PinCodePopUp{
            view.frame = self.view.bounds
            view.vc = self
            view.type = type
            view.code_textField.becomeFirstResponder()
            view.frame.origin.y += view.frame.size.height
            self.view.addSubview(view)
            
            UIView.animate(withDuration: 0.5) {
                view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}
