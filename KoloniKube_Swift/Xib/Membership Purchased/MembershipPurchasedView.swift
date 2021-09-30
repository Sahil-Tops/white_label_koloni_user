//
//  MembershipPurchasedView.swift
//  KoloniKube_Swift
//
//  Created by Tops on 19/03/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class MembershipPurchasedView: UIView {

    @IBOutlet weak var membershipName_lbl: UILabel!
    @IBOutlet weak var seeMembershipDetail_lbl: UILabel!
    @IBOutlet weak var gotit_btn: CustomButton!
    
    var membershipName = ""
    var vc = UIViewController()
    
    @IBAction func tapGotItBtn(_ sender: UIButton) {
        
        self.dismissView()

    }
    
    func dismissView(){
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.height
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
    func loadContent(){
        self.membershipName_lbl.text = self.membershipName
        let str = "See the membership details here"
        let range = (str as NSString).range(of: "here")
        let attributedStr = NSMutableAttributedString(string: str)
        attributedStr.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.primaryColor, NSAttributedString.Key.font: Singleton.appFont ?? Singleton.systemFont, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
        self.seeMembershipDetail_lbl.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapHere(_:))))
        self.seeMembershipDetail_lbl.isUserInteractionEnabled = true
        self.seeMembershipDetail_lbl.attributedText = attributedStr
    }
    
    @objc func tapHere(_ gesture: UITapGestureRecognizer){
        let range = (self.seeMembershipDetail_lbl.text! as NSString).range(of: "here")
        if gesture.didTapAttributedTextInLabel(label: self.seeMembershipDetail_lbl, inRange: range){
            self.dismissView()
            let myMembershipVc = MyMemberShipVC(nibName: "MyMemberShipVC", bundle: nil)
            myMembershipVc.backVc = self.vc
            self.vc.navigationController?.pushViewController(myMembershipVc, animated: true)
        }
    }
    
}

extension UIViewController{
    
    func loadMembershipPurchased(memberhip_name: String){
        let view = Bundle.main.loadNibNamed("MembershipPurchasedView", owner: nil, options: [:])?.first as! MembershipPurchasedView
        view.frame = self.view.bounds
        view.vc = self
        view.frame.origin.y += view.frame.height
        view.membershipName = memberhip_name
        view.loadContent()
        self.view.addSubview(view)
        UIView.animate(withDuration: 0.5) {
            view.frame.origin.y = 0
        }
    }
    
}
