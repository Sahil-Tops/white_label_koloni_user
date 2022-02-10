//
//  RentalEndedView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 5/11/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class RentalEndedView: UIView {

    @IBOutlet weak var descriptionMsg_lbl: UILabel!
    @IBOutlet weak var faqText_lbl: UILabel!
    @IBOutlet weak var gotIt_btn: CustomButton!
    
    var message = ""
    var bookNowVc: BookNowVC?
    
    //MARK: - @IBActions
    @IBAction func tapGotItBtn(_ sender: UIButton) {
        if Singleton.runningRentalArray.count == 0{
            // Pass static "2" to show locker rental summary for bike also. //Previous param passed self.endingRentalData["object_type"] as? String ?? "0"
            self.bookNowVc?.loadSummaryView(summaryType: self.bookNowVc?.endingRentalData["object_type"] as? String ?? "0")
        }else{
            let msg = Singleton.runningRentalArray.count == 1 ? "You have \(Singleton.runningRentalArray.count) ongoing rental":"You have \(Singleton.runningRentalArray.count) ongoing rentals"
            self.bookNowVc?.loadCustomAlertWithGradientButtonView(title: "One rental ended!", messageStr: msg, buttonTitle: "Got It")
            self.bookNowVc?.searchHome_Web(lat: String(describing: self.bookNowVc?.shareParameters.doubleLat), long: String(describing: self.bookNowVc?.shareParameters.doubleLong))
        }
        
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.height
            self.layoutIfNeeded()
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
    func loadContent(){
        
        let str = "Have questions? Click here"
        let range = (str as NSString).range(of: "here")
        let attributedStr = NSMutableAttributedString(string: str)
        attributedStr.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.customBlue, NSAttributedString.Key.font: Singleton.appFont ?? Singleton.systemFont, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
        self.faqText_lbl.attributedText = attributedStr
        self.faqText_lbl.isUserInteractionEnabled = true
        self.faqText_lbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnFaq(_:))))
        
    }
    
    @objc func tapOnFaq(_ gesture: UITapGestureRecognizer){
        print("FAQ Tapped")
        let range = (self.faqText_lbl.text! as NSString).range(of: "here")
        if gesture.didTapAttributedTextInLabel(label: self.faqText_lbl, inRange: range){
            let vc = FAQViewController(nibName: "FAQViewController", bundle: nil)
            vc.type = "1"
            self.bookNowVc?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension UIViewController{
    
    func loadRentalEndedView(message: String){
        if let view = Bundle.main.loadNibNamed("RentalEndedView", owner: nil, options: [:])?.first as? RentalEndedView{
            view.frame = self.view.bounds
            view.message = message
            view.bookNowVc = self as? BookNowVC
            view.loadContent()
            view.frame.origin.y += view.frame.height
            self.view.addSubview(view)
            
            UIView.animate(withDuration: 0.5) {
                view.frame.origin.y -= view.frame.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
