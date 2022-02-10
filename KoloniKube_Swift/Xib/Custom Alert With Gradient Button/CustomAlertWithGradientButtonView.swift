//
//  CustomAlertWithGradientButtonView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 3/25/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class CustomAlertWithGradientButtonView: UIView {

    @IBOutlet weak var titleMsg_lbl: UILabel!
    @IBOutlet weak var message_lbl: UILabel!
    @IBOutlet weak var gotIt_btn: CustomButton!
    
    var callBack: (()->()) = {}
    
    @IBAction func tapGotIt_btn(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.height
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
}

extension UIViewController{
    
    func loadCustomAlertWithGradientButtonView(title: String, messageStr: String, buttonTitle: String){
            
        let view = Bundle.main.loadNibNamed("CustomAlertWithGradientButtonView", owner: nil, options: [:])?.first as! CustomAlertWithGradientButtonView
        view.frame = self.view.bounds
        view.frame.origin.y += view.frame.height
        view.message_lbl.text = messageStr
        view.titleMsg_lbl.text = title
        view.gotIt_btn.setTitle(buttonTitle, for: .normal)
        self.view.addSubview(view)
        UIView.animate(withDuration: 0.5) {
            view.frame.origin.y -= view.frame.height
            self.view.layoutIfNeeded()
        }
    }
    
}
