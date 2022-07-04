//
//  EnterPartnerIdView.swift
//  KoloniKube_Swift
//
//  Created by Sam on 04/07/22.
//  Copyright © 2022 Self. All rights reserved.
//

import UIKit
protocol EnterPartnerIdDelegate {
    func responseFromDelegate()
}
class EnterPartnerIdView: UIView {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var textFieldPartnerId: UITextField!
    @IBOutlet weak var btnOk: UIButton!
    var delegate: EnterPartnerIdDelegate?
    @IBAction func tapOkBtn(_ sender: UIButton) {
        if self.textFieldPartnerId.isEmptyTextField() {
            AppDelegate.shared.window?.showTopPop(message: "Please enter partner id", response: false)
        } else {
            Singleton.partnerIdWhiteLabel = self.textFieldPartnerId.text ?? ""
            StaticClass.sharedInstance.saveToUserDefaultsString(value: Singleton.partnerIdWhiteLabel, forKey: "partnerIdWhiteLabel")
            self.delegate?.responseFromDelegate()
            self.removeFromSuperview()
        }
    }
}
extension UIViewController {
    func loadEnterPartnerIdView() {
        if let view = Bundle.main.loadNibNamed("EnterPartnerIdView", owner: nil, options: [:])?.first as? EnterPartnerIdView {
            view.frame = self.view.bounds
            view.delegate = self as? EnterPartnerIdDelegate
            view.btnOk.createGradientLayer(color1: CustomColor.customAppGreen, color2: CustomColor.customAppBlueWithAlpha, startPosition: 0.0, endPosition: 0.9)
            view.btnOk.circleObject()
            view.layoutIfNeeded()
            self.view.addSubview(view)
        }
    }
}
