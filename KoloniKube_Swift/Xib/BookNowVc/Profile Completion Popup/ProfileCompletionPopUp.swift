//
//  ProfileCompletionPopUp.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 01/07/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class ProfileCompletionPopUp: UIView {

    @IBOutlet weak var description_lbl: UILabel!
    @IBOutlet weak var ok_btn: CustomButton!
    
    var vc: UIViewController?
    
    @IBAction func tapOkBtn(_ sender: UIButton) {
        let editProfileVc = EditProfileVC(nibName: "EditProfileVC", bundle: nil)
        if let bookNowVc = self.vc as? BookNowVC{
            editProfileVc.backVc = bookNowVc
            self.vc?.navigationController?.pushViewController(editProfileVc, animated: true)
        }
    }
    
    func loadContent(){
        if AppLocalStorage.sharedInstance.application_gradient{
            self.ok_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.ok_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
    }
}

extension UIViewController{
    func loadProfileCompletionPopUp(desc: String){
        if let view = Bundle.main.loadNibNamed("ProfileCompletionPopUp", owner: nil, options: [:])?.first as? ProfileCompletionPopUp{
            view.frame = self.view.bounds
            view.vc = self
            view.description_lbl.text = desc
            view.loadContent()
            self.view.addSubview(view)
            view.frame.origin.y += view.frame.height
            UIView.animate(withDuration: 0.5) {
                view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}
