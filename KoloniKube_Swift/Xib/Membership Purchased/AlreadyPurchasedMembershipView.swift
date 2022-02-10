//
//  AlreadyPurchasedMembershipView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 3/25/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class AlreadyPurchasedMembershipView: UIView {

    @IBOutlet weak var seeDetail_lbl: UILabel!
    @IBOutlet weak var gotIt_btn: CustomButton!
    
    var membershipData: SharedMyMembership?
    var vc = UIViewController()
    
    @IBAction func tapGotItBtn(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.height
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
    func loadContent(){
        
        let str = "See My Memberships for the details, or start a rental to use."
        let range = (str as NSString).range(of: "My Memberships")
        let attributtedString = NSMutableAttributedString(string: str)
        attributtedString.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.customBlue, NSAttributedString.Key.font: Singleton.appFont ?? Singleton.systemFont, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
        self.seeDetail_lbl.isUserInteractionEnabled = true
        self.seeDetail_lbl.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapHere(_:))))
        self.seeDetail_lbl.attributedText = attributtedString
    }
    
    @objc func tapHere(_ gesture: UITapGestureRecognizer){
        let range = (self.seeDetail_lbl.text! as NSString).range(of: "My Memberships")
        if gesture.didTapAttributedTextInLabel(label: self.seeDetail_lbl, inRange: range){
            let myMembershipVc = MyMemberShipVC(nibName: "MyMemberShipVC", bundle: nil)
            myMembershipVc.backVc = self.vc
            self.removeFromSuperview()
            self.vc.navigationController?.pushViewController(myMembershipVc, animated: true)
        }
    }
    
}

extension UIViewController{
    
    func loadAlreadyPurchasedMembershio(membershipData: SharedMyMembership){
            
        let view = Bundle.main.loadNibNamed("AlreadyPurchasedMembershipView", owner: nil, options: [:])?.first as! AlreadyPurchasedMembershipView
        view.frame = self.view.bounds
        view.frame.origin.y += view.frame.height
        view.membershipData = membershipData
        view.vc = self
        view.loadContent()
        self.view.addSubview(view)
        UIView.animate(withDuration: 0.5) {
            view.frame.origin.y -= view.frame.height
            self.view.layoutIfNeeded()
        }
    }
    
}


