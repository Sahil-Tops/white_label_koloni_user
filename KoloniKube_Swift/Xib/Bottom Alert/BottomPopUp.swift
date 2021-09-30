//
//  BottomPopUp.swift
//  KoloniPartner
//
//  Created by Sahil Mehra on 4/16/20.
//  Copyright © 2020 Sahil Mehra. All rights reserved.
//

import UIKit

class BottomPopUp: UIView {

    @IBOutlet weak var containerView: CustomView!
    @IBOutlet weak var message_lbl: UILabel!
    @IBOutlet weak var containerView_bottom: NSLayoutConstraint!
    
    @IBAction func tapOnView(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, animations: {
            self.containerView.alpha -= 0
            self.layoutIfNeeded()
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
}

extension UIWindow{
    
    func showBottomAlert(message: String){
        Singleton.bottomPopUpView?.removeFromSuperview()
        if let view = Bundle.main.loadNibNamed("BottomPopUp", owner: nil, options: [:])?.first as? BottomPopUp{
            Singleton.bottomPopUpView = view
            Singleton.bottomPopUpView!.frame = self.bounds
            Singleton.bottomPopUpView!.message_lbl.text = message
//            view.containerView.backgroundColor = CustomColor.customCyan
            Singleton.bottomPopUpView!.containerView.frame.origin.y += (Singleton.bottomPopUpView!.containerView.frame.origin.y + Singleton.bottomPopUpView!.containerView.frame.height)
            self.addSubview(Singleton.bottomPopUpView!)
            
            UIView.animate(withDuration: 0.2) {
                Singleton.bottomPopUpView!.containerView.frame.origin.y -= (Singleton.bottomPopUpView!.containerView.frame.origin.y + Singleton.bottomPopUpView!.containerView.frame.height)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                UIView.animate(withDuration: 1.0, animations: {
                    Singleton.bottomPopUpView!.containerView.frame.origin.y += (Singleton.bottomPopUpView!.containerView.frame.origin.y + Singleton.bottomPopUpView!.containerView.frame.height)
                    Singleton.bottomPopUpView!.layoutIfNeeded()
                }) { (_) in
                    Singleton.bottomPopUpView!.removeFromSuperview()
                }
            }
        }
    }
    
}
