//
//  AppStoreRatingView.swift
//  KoloniKube_Swift
//
//  Created by Tops on 03/12/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class AppStoreRatingView: UIView {

    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var description_lbl: UILabel!
    @IBOutlet weak var checkBox_btn: UIButton!
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var rateUs_btn: UIButton!
    @IBOutlet weak var didNotLike_textView: UITextView!

    var viewController: UIViewController?
    
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        if sender == rateUs_btn{
            let url = URL(string: "https://itunes.apple.com/us/app/kolonishare/id1265110043?mt=8")!
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:]) { (response) in
                    if response{
                        print("Opening Url")
                    }
                }
            }
            Singleton.lastViewController = "BookNowVC"
        }else if sender == checkBox_btn{
            if self.checkBox_btn.tag == 0{
                self.checkBox_btn.tag = 1
                self.checkBox_btn.setImage(UIImage(named: "checked_blue"), for: .normal)
                UserDefaults.standard.set(true, forKey: "dont_show_app_store_rating")
            }else{
                self.checkBox_btn.tag = 1
                self.checkBox_btn.setImage(UIImage(named: "unchecked_gray"), for: .normal)
                UserDefaults.standard.set(false, forKey: "dont_show_app_store_rating")
            }
        }
        
        if sender != checkBox_btn{
            UIView.animate(withDuration: 0.5, animations: {
                self.frame.origin.y += self.frame.height
            }) { (_) in
                self.layoutIfNeeded()
                self.removeFromSuperview()
                Global.appdel.setUpSlideMenuController()
            }
        }
    }
    
    func loadContent(){
        
        if AppLocalStorage.sharedInstance.application_gradient{
            self.rateUs_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.rateUs_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        if AppLocalStorage.sharedInstance.use_tertiary_text_color == "1"{
            self.title_lbl.textColor = AppLocalStorage.sharedInstance.tertiary_color
        }else{
            self.title_lbl.textColor = CustomColor.secondaryColor
        }
        self.title_lbl.text = "Enjoy the \(AppLocalStorage.sharedInstance.sitename) app?"
        
        let string = "Didn't like your experience? Report Issue how we can improve!"
        let report_issue = "Report Issue"
        let range = (string as NSString).range(of: report_issue)
        let attributtedString = NSMutableAttributedString.init(string: string)
        attributtedString.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.secondaryColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.link: URL(string: "http://www.tellus.com")!], range: range)
        self.didNotLike_textView.attributedText = attributtedString
        self.didNotLike_textView.textAlignment = .center
        self.didNotLike_textView.font = UIFont(name: "AvenirNext-Medium", size: 14.0)
        self.didNotLike_textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: CustomColor.secondaryColor]
        self.didNotLike_textView.delegate = self
        self.didNotLike_textView.isEditable = false
        
    }
    
}

extension AppStoreRatingView: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "http://www.tellus.com"{
            print("Report Issue Clicked")
            let vc = ReportVC(nibName: "ReportVC", bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            vc.showForRunningRental = true
            self.viewController?.navigationController?.present(vc, animated: true, completion: nil)
        }
        return false
    }
    
}

extension UIViewController{
    
    /** Function to load App Store Rating View */
    func loadAppStoreRatingView(){
        
        let appStoreRatingView = Bundle.main.loadNibNamed("AppStoreRatingView", owner: nil, options: [:])?.first as? AppStoreRatingView
        appStoreRatingView?.frame = self.view.frame
        appStoreRatingView?.viewController = self
        appStoreRatingView?.loadContent()
        appStoreRatingView?.rateUs_btn.circleObject()
        appStoreRatingView!.frame.origin.y += appStoreRatingView!.frame.height
        self.view.addSubview(appStoreRatingView!)
        UIView.animate(withDuration: 0.5, animations: {
            appStoreRatingView!.frame.origin.y -= appStoreRatingView!.frame.height
        }) { (_) in
            self.view.layoutIfNeeded()
        }
    }
}
