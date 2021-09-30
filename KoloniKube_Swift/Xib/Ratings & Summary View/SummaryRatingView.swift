//
//  RatingsView.swift
//  KoloniKube_Swift
//
//  Created by Tops on 18/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class SummaryRatingView: UIView {
    @IBOutlet weak var title_lbl: UILabel!
    //Summary View Outlet's
    @IBOutlet weak var summaryContainerView: CustomView!
    @IBOutlet weak var bikeSummaryView: CustomView!
    @IBOutlet weak var lockerSummaryView: CustomView!
    @IBOutlet weak var time_lbl: UILabel!
    @IBOutlet weak var time_2_lbl: UILabel!
    @IBOutlet weak var distance_lbl: UILabel!
    @IBOutlet weak var calories_lbl: UILabel!
    @IBOutlet weak var amount_lbl: UILabel!
    @IBOutlet weak var amount_2_lbl: UILabel!
    @IBOutlet weak var gotIt_btn: UIButton!
    @IBOutlet weak var gotIt_2_btn: CustomButton!
    @IBOutlet weak var logo_btn: UIButton!
    @IBOutlet weak var seeMore_lbl: UILabel!
    @IBOutlet weak var seeMore_2_lbl: UILabel!
    @IBOutlet weak var timeIcon_lbl: UILabel!
    @IBOutlet weak var amountIcon_lbl: UILabel!
//    @IBOutlet weak var time2Icon_lbl: UILabel!
    @IBOutlet weak var distanceIcon_lbl: UILabel!
    @IBOutlet weak var engryIcon_lbl: UILabel!
    
    //Rating View Outlet's
    @IBOutlet weak var ratingContainerView: CustomView!
    @IBOutlet weak var logo_lbl: UILabel!
    @IBOutlet weak var rating1_btn: UIButton!
    @IBOutlet weak var rating2_btn: UIButton!
    @IBOutlet weak var rating3_btn: UIButton!
    @IBOutlet weak var rating4_btn: UIButton!
    @IBOutlet weak var rating5_btn: UIButton!
    @IBOutlet weak var comment_textView: UITextView!
    @IBOutlet weak var commentTextView_height: NSLayoutConstraint!
    @IBOutlet weak var submit_btn: UIButton!
    
    var numberOfRating = 0
    var bookNowVc: BookNowVC?
    var orderId = ""
    
    //Default Function's
    override func awakeFromNib() {
        self.gotIt_btn.circleObject()
        self.submit_btn.circleObject()
        self.logo_lbl.circleObject()
        self.comment_textView.delegate = self
    }
    
    //MARK: - @IBAction's
    @IBAction func tapGotItBtn(_ sender: UIButton) {
        UIView.transition(with: self.ratingContainerView, duration: 0.5, options: .curveEaseOut, animations: {
            self.summaryContainerView.frame.origin.y += (self.frame.origin.y + self.frame.height)
        }) { (_) in
            self.removeFromSuperview()
            if !UserDefaults.standard.bool(forKey: "dont_show_app_store_rating"){
                if !(self.bookNowVc?.iamAtHub ?? false){
                    self.bookNowVc?.loadAppStoreRatingView()
                    Singleton.lastRideSummaryData = [:]
                }else{
                    Global.appdel.setUpSlideMenuController()
                }
            }
        }
    }
    
    @IBAction func ratingBtnsAction(_ sender: UIButton) {
        
        switch sender {
        case rating1_btn:
            self.numberOfRating = 1
            self.showHideCommentTextView(isHide: false)
            self.rating1_btn.setImage(UIImage(named: "smily_selected_1"), for: .normal)
            self.rating2_btn.setImage(UIImage(named: "smily_unselected_2"), for: .normal)
            self.rating3_btn.setImage(UIImage(named: "smily_unselected_3"), for: .normal)
            self.rating4_btn.setImage(UIImage(named: "smily_unselected_4"), for: .normal)
            self.rating5_btn.setImage(UIImage(named: "smily_unselected_5"), for: .normal)
            break
        case rating2_btn:
            self.numberOfRating = 2
            self.showHideCommentTextView(isHide: false)
            self.rating1_btn.setImage(UIImage(named: "smily_selected_1"), for: .normal)
            self.rating2_btn.setImage(UIImage(named: "smily_selected_2"), for: .normal)
            self.rating3_btn.setImage(UIImage(named: "smily_unselected_3"), for: .normal)
            self.rating4_btn.setImage(UIImage(named: "smily_unselected_4"), for: .normal)
            self.rating5_btn.setImage(UIImage(named: "smily_unselected_5"), for: .normal)
            break
        case rating3_btn:
            self.numberOfRating = 3
            self.showHideCommentTextView(isHide: false)
            self.rating1_btn.setImage(UIImage(named: "smily_selected_1"), for: .normal)
            self.rating2_btn.setImage(UIImage(named: "smily_selected_2"), for: .normal)
            self.rating3_btn.setImage(UIImage(named: "smily_selected_3"), for: .normal)
            self.rating4_btn.setImage(UIImage(named: "smily_unselected_4"), for: .normal)
            self.rating5_btn.setImage(UIImage(named: "smily_unselected_5"), for: .normal)
            break
        case rating4_btn:
            self.numberOfRating = 4
            self.showHideCommentTextView(isHide: false)
            self.rating1_btn.setImage(UIImage(named: "smily_selected_1"), for: .normal)
            self.rating2_btn.setImage(UIImage(named: "smily_selected_2"), for: .normal)
            self.rating3_btn.setImage(UIImage(named: "smily_selected_3"), for: .normal)
            self.rating4_btn.setImage(UIImage(named: "smily_selected_4"), for: .normal)
            self.rating5_btn.setImage(UIImage(named: "smily_unselected_5"), for: .normal)
            break
        case rating5_btn:
            self.numberOfRating = 5
            self.showHideCommentTextView(isHide: true)
            self.rating1_btn.setImage(UIImage(named: "smily_selected_1"), for: .normal)
            self.rating2_btn.setImage(UIImage(named: "smily_selected_2"), for: .normal)
            self.rating3_btn.setImage(UIImage(named: "smily_selected_3"), for: .normal)
            self.rating4_btn.setImage(UIImage(named: "smily_selected_4"), for: .normal)
            self.rating5_btn.setImage(UIImage(named: "smily_selected_5"), for: .normal)
            break
        default: break
        }
        
    }
    
    @IBAction func tapCrossBtn(_ sender: UIButton) {
        UIView.transition(with: self.ratingContainerView, duration: 0.5, options: .curveEaseOut, animations: {
            self.ratingContainerView.frame.origin.y += (self.frame.origin.y + self.frame.height)
        }) { (_) in
            self.removeFromSuperview()
            Global.appdel.setUpSlideMenuController()
        }
    }
    
    @IBAction func tapSubmitBtn(_ sender: UIButton) {
        UIView.transition(with: self.ratingContainerView, duration: 0.5, options: .curveEaseOut, animations: {
            self.ratingContainerView.frame.origin.y += (self.frame.origin.y + self.frame.height)
        }) { (_) in
            self.removeFromSuperview()
            if self.numberOfRating > 3{
                if !UserDefaults.standard.bool(forKey: "dont_show_app_store_rating"){
                    if !(self.bookNowVc?.iamAtHub ?? false){
                        self.bookNowVc?.loadAppStoreRatingView()
                        Singleton.lastRideSummaryData = [:]
                    }else{
                        Global.appdel.setUpSlideMenuController()
                    }
                }
            }
            self.CallFeedBackAPI()
        }
    }
    
    //MARK: - Custom Function's
    
    func loadContent(){
        
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "flag_logo_img") { (image) in
            self.logo_btn.setImage(image, for: .normal)
            self.logo_btn.setBorder(border_width: 2, border_color: .white)
            self.logo_btn.circleObject()
        }
        if AppLocalStorage.sharedInstance.application_gradient{
            self.gotIt_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.gotIt_2_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.gotIt_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
            self.gotIt_2_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        self.title_lbl.textColor = CustomColor.secondaryColor
        self.timeIcon_lbl.textColor = CustomColor.secondaryColor
        self.distanceIcon_lbl.textColor = CustomColor.secondaryColor
        self.engryIcon_lbl.textColor = CustomColor.secondaryColor
        self.amountIcon_lbl.textColor = CustomColor.secondaryColor
    }
    
    func showHideCommentTextView(isHide: Bool){
        if isHide{
            self.comment_textView.isHidden = true
            self.commentTextView_height.constant = 0
        }else{
            self.comment_textView.isHidden = false
            self.commentTextView_height.constant = 50
        }
    }
    
    func showDefaultRating(){
        self.numberOfRating = 5
        self.showHideCommentTextView(isHide: true)
        self.rating1_btn.setImage(UIImage(named: "smily_selected_1"), for: .normal)
        self.rating2_btn.setImage(UIImage(named: "smily_selected_2"), for: .normal)
        self.rating3_btn.setImage(UIImage(named: "smily_selected_3"), for: .normal)
        self.rating4_btn.setImage(UIImage(named: "smily_selected_4"), for: .normal)
        self.rating5_btn.setImage(UIImage(named: "smily_selected_5"), for: .normal)
    }
    
    func createAtrributedLabel(){
        
        let str = "See more detail here"
        let range = (str as NSString).range(of: "here")
        let attributedStr = NSMutableAttributedString(string: str)
        attributedStr.addAttributes([NSAttributedString.Key.foregroundColor: CustomColor.primaryColor, NSAttributedString.Key.font: Singleton.appFont ?? Singleton.systemFont, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
        self.seeMore_lbl.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapHere(_:))))
        self.seeMore_2_lbl.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapHere(_:))))
        self.seeMore_lbl.isUserInteractionEnabled = true
        self.seeMore_2_lbl.isUserInteractionEnabled = true
        self.seeMore_lbl.attributedText = attributedStr
        self.seeMore_2_lbl.attributedText = attributedStr
        
    }
    
    //MARK: Custom Action's
    @objc func tapHere(_ gesture: UITapGestureRecognizer){
        let range = ("See more detail here" as NSString).range(of: "here")
        if gesture.didTapAttributedTextInLabel(label: self.seeMore_lbl, inRange: range){
            let rentalReciptVc = MyRentalReceiptVC(nibName: "MyRentalReceiptVC", bundle: nil)
            rentalReciptVc.backVc = "book_now"
            rentalReciptVc.paymentId = Singleton.lastRideSummaryData["payment_id"]as? String ?? ""
            self.bookNowVc?.present(rentalReciptVc, animated: true, completion: nil)
        }
    }
    
    //MARK: Send Feedback Web Api.
    func CallFeedBackAPI() -> Void {
        
        var trimmedString = comment_textView.text!.trimmingCharacters(in: .whitespacesAndNewlines) as String
        if trimmedString == "Enter comment"{
            trimmedString = ""
        }
        let paramer: NSMutableDictionary = NSMutableDictionary()                
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue(Singleton.order_id, forKey: "order_id")
        paramer.setValue(String(self.numberOfRating), forKey: "rating")
        paramer.setValue(trimmedString, forKey: "comment")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("order_rating", parameters: paramer, showLoder: true, successBlock: { (response) in
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool) {
                    _ = dict["MESSAGE"] as? String ?? ""                    
                    if self.numberOfRating < 4{
                        Global.appdel.setUpSlideMenuController()
                    }
                } else {
                    let msg = dict["MESSAGE"] as? String ?? ""
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: msg)
                }
            }
        }) { (error) in
            
        }
    }
    
}

extension SummaryRatingView: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter comment"{
            self.comment_textView.text = ""
            self.comment_textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "Enter comment" || textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            self.comment_textView.text = ""
            self.comment_textView.textColor = UIColor.darkGray
        }
    }
    
}

extension UIViewController{
    /* Function for load ride summary view */
    func loadSummaryView(summaryType: String){
        let summaryView = Bundle.main.loadNibNamed("Summary&RatingView", owner: nil, options: [:])?.first as? SummaryRatingView
        summaryView?.frame = self.view.frame
        summaryView?.loadContent()
        summaryView?.summaryContainerView.frame.origin.y += (summaryView?.summaryContainerView.frame.origin.y)! * 1.5
        if let vc = self as? BookNowVC{
            summaryView?.bookNowVc = vc
        }
        summaryView?.createAtrributedLabel()
        summaryView?.ratingContainerView.isHidden = true
        if !Singleton.lastRideSummaryData.isEmpty{
            summaryView?.time_lbl.text = Singleton.lastRideSummaryData["total_time"]as? String ?? ""
            summaryView?.time_2_lbl.text = Singleton.lastRideSummaryData["total_time"]as? String ?? ""
            summaryView?.distance_lbl.text = Singleton.lastRideSummaryData["total_distance"]as? String ?? ""
            summaryView?.calories_lbl.text = Singleton.lastRideSummaryData["total_calories"]as? String ?? ""
            summaryView?.amount_lbl.text = "$" + String(describing: Singleton.lastRideSummaryData["total_amount"]as? String ?? "")
            summaryView?.amount_2_lbl.text = "$" + String(describing: Singleton.lastRideSummaryData["total_amount"]as? String ?? "")
        }
        if summaryType == "2"{
            summaryView?.lockerSummaryView.isHidden = true
            summaryView?.gotIt_2_btn.isHidden = true
        }else{
            summaryView?.bikeSummaryView.isHidden = true
            summaryView?.gotIt_btn.isHidden = true
            summaryView?.logo_btn.isHidden = true
        }
        self.view.addSubview(summaryView!)
        
        UIView.animate(withDuration: 0.5) {
            summaryView?.summaryContainerView.frame.origin.y -= (summaryView?.summaryContainerView.frame.origin.y)! * 1.5
        }
        self.view.layoutIfNeeded()
    }
    
    /* Function for load rating ride view */
    func loadRatingView(){
        let ratingView = Bundle.main.loadNibNamed("Summary&RatingView", owner: nil, options: [:])?.first as? SummaryRatingView
        ratingView?.frame = self.view.frame
        ratingView?.loadContent()
        if let vc = self as? BookNowVC{
            ratingView?.bookNowVc = vc
        }
        ratingView?.summaryContainerView.isHidden = true
        ratingView?.comment_textView.setBorder(border_width: 1.0, border_color: UIColor.black)
        ratingView?.comment_textView.cornerRadius(cornerValue: 3)
        ratingView?.showDefaultRating()
        ratingView?.ratingContainerView.frame.origin.y += (ratingView?.ratingContainerView.frame.origin.y)! * 1.5
        self.view.addSubview(ratingView!)
        
        UIView.animate(withDuration: 0.5) {
            ratingView?.ratingContainerView.frame.origin.y -= (ratingView?.ratingContainerView.frame.origin.y)! * 1.5
        }
        self.view.layoutIfNeeded()
    }
}


