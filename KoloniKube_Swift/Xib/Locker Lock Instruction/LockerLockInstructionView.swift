//
//  LockerLockInstructionView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 11/20/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class LockerLockInstructionView: UIView {

    @IBOutlet weak var description_lbl: UILabel!
    @IBOutlet weak var locker_imgView: UIImageView!
//    @IBOutlet weak var cancel_btn: UIButton!
    @IBOutlet weak var ok_btn: UIButton!
    @IBOutlet weak var close_btn: UIButton!
    
    var bookNowVc: BookNowVC?
    
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case close_btn:
            UIView.animate(withDuration: 0.5, animations: {
                self.frame.origin.y = (self.frame.origin.y + self.frame.height)
                self.layoutIfNeeded()
            }) { (_) in                
                self.removeFromSuperview()
            }
        case ok_btn:
            UIView.animate(withDuration: 0.5, animations: {
                self.frame.origin.y = (self.frame.origin.y + self.frame.height)
                self.layoutIfNeeded()
            }) { (_) in
                if self.bookNowVc != nil{
                    CoreBluetoothClass.sharedInstance.isBluetoothOn(vc: self.bookNowVc!)
                }
                self.removeFromSuperview()
            }
        default:
            break
        }
        
    }
    
    func loadContent(){
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "locker_alert_img", outputBlock: { (image) in
            self.locker_imgView.image = image
        })
        if AppLocalStorage.sharedInstance.application_gradient{
            self.ok_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.ok_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
    }
    
}

extension UIViewController{
    
    func loadLockerInstructionView(){
        
        let view = Bundle.main.loadNibNamed("LockerLockInstructionView", owner: nil, options: [:])?.first as! LockerLockInstructionView
        view.frame = self.view.bounds
        view.bookNowVc = self as? BookNowVC
        view.description_lbl.text = "Please remove items and close the door to end your rental."
        view.loadContent()
        view.frame.origin.y = (view.frame.origin.y + view.frame.height)
        self.view.addSubview(view)
        
        UIView.animate(withDuration: 0.3, animations: {
            view.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }) { (_) in
            
        }
        
    }
    
}
