//
//  PromoCodeView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 2/23/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit
protocol PromoCodeDelegate {
    func didGetPromoCode(code: String, msg: String, response: Bool, promo_id: String)
}

class PromoCodeView: UIView {

    @IBOutlet weak var containerView: CustomView!
    @IBOutlet weak var enterCode_textField: UITextField!
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var submit_btn: UIButton!
    
    var delegate: PromoCodeDelegate?
    var vc: UIViewController?
    var partnerId = ""
    
    //MARK: @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case close_btn:
            self.removeView()            
        case submit_btn:
            if !self.enterCode_textField.isEmptyTextField(){
                self.verifyPromoode_Web()
                self.removeView()
            }else{
                vc?.alert(title: "Alert", msg: "Please enter valid promocode")
            }
        default:
            break
        }
        
    }
    
    func loadContent(){
        self.submit_btn.circleObject()
    }
    
    func removeView(){
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.height
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
    //MARK: - Web Api's
    
    func verifyPromoode_Web(){
        
        let dictionary = NSMutableDictionary()
        dictionary.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        dictionary.setValue(self.enterCode_textField.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "promo_code")
        dictionary.setValue(self.partnerId, forKey: "partner_id")
        dictionary.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("promo_code_check", parameters: dictionary, showLoder: true) { (response) in
            print("promo_code_check: ", response)
            if let status = response["FLAG"]as? Int, status == 1{
                self.delegate?.didGetPromoCode(code: self.enterCode_textField.text!, msg: response["MESSAGE"]as? String ?? "", response: true, promo_id: response["PROMO_ID"]as? String ?? "")
            }else{
                self.delegate?.didGetPromoCode(code: self.enterCode_textField.text!, msg: response["MESSAGE"]as? String ?? "", response: false, promo_id: response["PROMO_ID"]as? String ?? "")
            }
        } failure: { (error) in
            
        }

    }
    
}

extension UIViewController{
    
    func loadPromoCodeView(partner_id: String){
        let view = Bundle.main.loadNibNamed("PromoCodeView", owner: nil, options: [:])?.first as! PromoCodeView
        view.frame = self.view.bounds
        view.frame.origin.y += view.frame.height
        view.delegate = self as? PromoCodeDelegate
        view.loadContent()
        view.vc = self
        view.partnerId = partner_id
        self.view.addSubview(view)
        UIView.animate(withDuration: 0.5) {
            view.frame.origin.y = 0
            self.view.layoutIfNeeded()
        } completion: { (_) in
            
        }
    }
    
}

extension UIView{
    func loadPromoCodeView(vc: UIViewController?, partner_id: String){
        let view = Bundle.main.loadNibNamed("PromoCodeView", owner: nil, options: [:])?.first as! PromoCodeView
        view.frame = self.bounds
        view.frame.origin.y += view.frame.height
        view.delegate = self as? PromoCodeDelegate
        view.vc = vc
        view.partnerId = partner_id
        view.loadContent()
        self.addSubview(view)
        UIView.animate(withDuration: 0.5) {
            view.frame.origin.y = 0
            self.layoutIfNeeded()
        } completion: { (_) in
            
        }
    }
}
