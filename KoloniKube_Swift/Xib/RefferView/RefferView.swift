//
//  RefferView.swift
//  KoloniKube_Swift
//
//  Created by Tops on 29/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class RefferView: UIView {
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var containerView: CustomView!
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var codeBg_imageView: UIImageView!
    @IBOutlet weak var referralCode_lbl: UILabel!
    @IBOutlet weak var tapToCopy_btn: UIButton!
    @IBOutlet weak var userName_lbl: UILabel!
    @IBOutlet weak var yourReferralGetText_lbl: UILabel!
    @IBOutlet weak var youReceiveText_lbl: UILabel!
    @IBOutlet weak var redemRentalTitle_lbl: UILabel!
    @IBOutlet weak var shareCode_btn: CustomButton!
    @IBOutlet weak var redeem_btn: CustomButton!
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var yourReferalView: UIView!
    @IBOutlet weak var youReceiveView: UIView!
    @IBOutlet weak var redeemStackView: UIStackView!
    @IBOutlet weak var redeemStack_height: NSLayoutConstraint!
    
    var viewConstroller: UIViewController?
    
    @IBAction func clickOnButtons(_ sender: UIButton) {
        switch sender {
        case close_btn:
            UIView.animate(withDuration: 0.5, animations: {
                self.frame.origin.y += (self.frame.height) * 1.5
            }) { (_) in
                self.layoutIfNeeded()
                self.removeFromSuperview()
                UserDefaults.standard.set(true, forKey: "isRippleEffectClosed")
                Singleton.smRippleView?.removeFromSuperview()                
            }
            break
        case tapToCopy_btn:
            UIPasteboard.general.string = self.referralCode_lbl.text!
//            AppDelegate.shared.window?.showBottomAlert(message: "There is an error while fetching acess token")
            break
        case shareCode_btn:
            let shareItems:Array = ["Here’s a referral code for a 1 hour free rental with the Koloni App.", "\n\nReferral code: \(referralCode_lbl.text!)", "\n\nApp Store:", URL(string: "https://itunes.apple.com/us/app/kolonishare/id1265110043?mt=8")!, "\n\nPlay Store:", URL(string: "https://play.google.com/store/apps/details?id=com.kolonishare")!] as [Any]
            print(shareItems)
            let activityShareObj: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityShareObj.excludedActivityTypes = [
                .print,
                .assignToContact,
                .saveToCameraRoll,
                .addToReadingList,
                .airDrop,
            ]
            activityShareObj.setValue("Free hour on a rental for every", forKey: "Subject")
            viewConstroller!.present(activityShareObj, animated: true, completion: nil)
            break
        case redeem_btn:
            UIView.animate(withDuration: 0.5, animations: {
                self.frame.origin.y += (self.frame.height) * 1.5
            }) { (_) in
                self.layoutIfNeeded()
                self.removeFromSuperview()
                UserDefaults.standard.set(true, forKey: "isRippleEffectClosed")
                Singleton.smRippleView?.removeFromSuperview()
                let Referral = Bundle.main.loadNibNamed("Refferal_popup", owner: nil, options: [:])?.first as? Refferal_popup
//                Referral?.delegate = self
                Referral!.DisplayPopup()
            }
            break
        default:
            break
        }
        
    }
    
    func loadContent(){
        
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "flag_logo_img") { (image) in
            self.titleImage.image = image
        }
        
        if AppLocalStorage.sharedInstance.application_gradient{
            self.shareCode_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.redeem_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.shareCode_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
            self.redeem_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        
        if UserDefaults.standard.bool(forKey: "isShowEnterRefBtn") {
            self.redeem_btn.isHidden = false
            self.redeemStackView.isHidden = false
            self.redeemStack_height.constant = 160
        }else{
            self.redeem_btn.isHidden = true
            self.redeemStackView.isHidden = true
            self.redeemStack_height.constant = 20
        }
        
        self.titleImage.circleObject()
        self.title_lbl.textColor = CustomColor.secondaryColor
        self.redemRentalTitle_lbl.textColor = CustomColor.secondaryColor
        self.codeBg_imageView.setBorder(border_width: 2, border_color: CustomColor.primaryColor)
        self.codeBg_imageView.cornerRadius(cornerValue: 10)
        self.layoutIfNeeded()
    }
    
}


extension UIViewController{
    
    func loadShareRefferView(){
        
        let refferView = Bundle.main.loadNibNamed("RefferView", owner: nil, options: [:])?.first as? RefferView
        refferView?.frame = self.view.frame
        
        if let userDataArray = Singleton.userProfileData.value(forKey: "USER_DETAILS")as? NSArray{
            if userDataArray.count > 0{
                if let userData = userDataArray.object(at: 0)as? [String:Any]{
                    let firstname = (userData["first_name"] as? String) ?? ""
                    let lastname = (userData["last_name"] as? String) ?? ""
                    let username = (userData["username"] as? String) ?? ""
                    var name = ""
                    
                    let message = "get your friends on koloni!"
                    if firstname.trimmingCharacters(in: .whitespaces) == ""{
                        refferView?.userName_lbl.text = username + ", "
                        name = username + ", "
                    }else{
                        refferView?.userName_lbl.text = firstname + " " + lastname + ", "
                        name = firstname + " " + lastname + ", "
                    }
                    //Avenir Next Demi Bold 16.0
                    
                    let messageAttributedString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
                    let userAttributedString = NSAttributedString(string: name, attributes: [NSAttributedString.Key.foregroundColor: UIColor.blue.withAlphaComponent(0.8), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)])
                    let string = NSMutableAttributedString()
                    string.append(userAttributedString)
                    string.append(messageAttributedString)
                    refferView?.userName_lbl.text = "For every person you refer, you each receive a free 1 hour rental."
                }
            }
        }        
        refferView?.viewConstroller = self
        refferView?.shareCode_btn.isUserInteractionEnabled = false
        self.view.addSubview(refferView!)
        refferView?.frame.origin.y += (refferView?.frame.height)! * 1.5
        UIView.animate(withDuration: 0.5, animations: {
            refferView?.frame.origin.y -= (refferView?.frame.height)! * 1.5
        }) { (_) in
            refferView?.layoutIfNeeded()
        }
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        refferView?.layoutIfNeeded()
        Singleton.showSkeltonViewOnViews(viewsArray: [refferView!.containerView])
        APICall.shared.postWeb("user_referral_code", parameters: paramer, showLoder: false, successBlock: { (response) in
            Singleton.hideSkeltonViewFromViews(viewsArray: [(refferView!.containerView)!])
            refferView?.shareCode_btn.isUserInteractionEnabled = true
            let res = response as? [String:Any] ?? [:]
            print(res)
            refferView?.referralCode_lbl.text = res["referral_code"]as? String ?? ""
            refferView?.loadContent()
        }) { (error) in
            
        }
    }
   
}
