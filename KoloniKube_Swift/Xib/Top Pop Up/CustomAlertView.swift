//
//  CustomAlertView.swift
//  Khelo365
//
//  Created by Tops on 06/02/20.
//  Copyright © 2020 Sahil Mehra. All rights reserved.
//

import UIKit

class CustomAlertView: UIView {
    
    @IBOutlet weak var containerView_top: NSLayoutConstraint!
    @IBOutlet weak var containerView: CustomView!
    @IBOutlet weak var message_lbl: UILabel!
    
    
    @IBAction func tapOnView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.frame.origin.y -= self.containerView.frame.height + 10
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
}

extension UIWindow{
    
    func showTopPop(message: String, response: Bool, dissmisTime: CGFloat = 3){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let customAlert = Bundle.main.loadNibNamed("CustomAlertView", owner: nil, options: [:])?.first as? CustomAlertView
            customAlert?.frame = self.bounds
            if response{
                customAlert?.containerView.backgroundColor = UIColor.systemGreen
            }else{
                customAlert?.containerView.backgroundColor = CustomColor.customRed
            }
            customAlert?.message_lbl.text = message
            customAlert?.containerView.frame.origin.y -= (customAlert?.containerView.frame.height)! + 10
            if UIDevice.current.hasNotch{
                customAlert?.containerView_top.constant = 38
            }
            
            self.addSubview(customAlert!)
            UIView.animate(withDuration: 0.4, animations: {
                customAlert?.containerView.frame.origin.y += (customAlert?.containerView.frame.height)! + 10
            }) { (_) in
                _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(dissmisTime), repeats: false, block: { (_) in
                    UIView.animate(withDuration: 0.2, animations: {
                        customAlert?.containerView.frame.origin.y -= (customAlert?.containerView.frame.height)! + 10
                    }) { (_) in
                        customAlert?.removeFromSuperview()
                    }
                })
            }
        }
    }
    
}

extension UIViewController{
    
    func showTopPop(message: String, response: Bool, dissmisTime: CGFloat = 3){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let customAlert = Bundle.main.loadNibNamed("CustomAlertView", owner: nil, options: [:])?.first as? CustomAlertView
            customAlert?.frame = self.view.bounds
            if response{
                customAlert?.containerView.backgroundColor = UIColor.systemGreen
            }else{
                customAlert?.containerView.backgroundColor = CustomColor.customRed
            }
            customAlert?.message_lbl.text = message
            customAlert?.containerView.frame.origin.y -= (customAlert?.containerView.frame.height)! + 10
            if UIDevice.current.hasNotch{
                customAlert?.containerView_top.constant = 38
            }
            
            self.view.addSubview(customAlert!)
            UIView.animate(withDuration: 0.4, animations: {
                customAlert?.containerView.frame.origin.y += (customAlert?.containerView.frame.height)! + 10
            }) { (_) in
                _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(dissmisTime), repeats: false, block: { (_) in
                    UIView.animate(withDuration: 0.2, animations: {
                        customAlert?.containerView.frame.origin.y -= (customAlert?.containerView.frame.height)! + 10
                    }) { (_) in
                        customAlert?.removeFromSuperview()
                    }
                })
            }
        }
    }
    
}

