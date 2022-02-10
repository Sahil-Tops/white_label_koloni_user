//
//  MyRentalReceiptVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 19/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class MyRentalReceiptVC: UIViewController {
    
    //MARK: - Outlet's
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var downloadReceipt_btn: CustomButton!
    @IBOutlet weak var orderNumber_lbl: UILabel!
    @IBOutlet weak var assetId_lbl: EZLabel!
    @IBOutlet weak var date_lbl: EZLabel!
    @IBOutlet weak var startTime_lbl: EZLabel!
    @IBOutlet weak var endTime_lbl: EZLabel!
    @IBOutlet weak var penalityAmount_lbl: EZLabel!
    @IBOutlet weak var totalAmountPaid_lbl: EZLabel!
    @IBOutlet weak var totalTime_lbl: EZLabel!
    @IBOutlet weak var affiliateApplied_lnl: EZLabel!
    @IBOutlet weak var outOfDropzone_lbl: EZLabel!
    @IBOutlet weak var promoCode_lbl: EZLabel!
    @IBOutlet weak var referralCode_lbl: EZLabel!
    @IBOutlet weak var partnerName_lbl: EZLabel!
    
    //Stack View's
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var referralStackView: UIStackView!
    @IBOutlet weak var memberShipStackView: UIStackView!
    @IBOutlet weak var penaltyStackView: UIStackView!
    @IBOutlet weak var promoCodeStackView: UIStackView!
    @IBOutlet weak var affiliateStackView: UIStackView!
    @IBOutlet weak var outOFDropzoneStackView: UIStackView!
    
    //Variables
    var rideData: shareRental = shareRental()
    var paymentId = ""
    var backVc = ""  //my_rentals For MyRentalVC, book_now For BookNowVC
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadNavigation()
        if self.backVc == "book_now"{
            self.rentalReceiptDetail_Web()
        }else{
            self.setData()
        }
    }
    
    //MARK: - @IBAction's
    @IBAction func tapDownloadReceiptBtn(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: self.rideData.strPrintRecipt)!, options: [:], completionHandler: nil)
    }
    
    //MARK: - Custom Function's
    func loadNavigation(){
        
        let navBar = Bundle.main.loadNibNamed("NavigationView", owner: nil, options: [:])?.first as? NavigationView
        navBar?.frame = self.headerView.bounds
        navBar?.viewController = self
        navBar?.navigation = self.navigationController
        navBar?.skip_btn.isHidden = true
        navBar?.back_btn.isHidden = false        
        navBar?.title_lbl.text = "Rental Receipt"
        navBar?.backBtnAction = self.backVc == "my_rentals" ? "back":"dismiss"
        self.headerView.addSubview(navBar!)
    }
    
    func setData(){
        
        self.mapImage.showAnimatedSkeleton()
        if let imgUrl = URL(string: rideData.strMapImage){
            self.mapImage.sd_setImage(with: imgUrl) { (image, error, cache, url) in
                self.mapImage.hideSkeleton()
            }
        }
        self.orderNumber_lbl.text = rideData.strOrderID
        self.assetId_lbl.text = rideData.strObjectUniqueId
        self.date_lbl.text = rideData.strEndDate
        self.startTime_lbl.text = rideData.strStartTime
        self.endTime_lbl.text = rideData.strEndTime
        self.totalAmountPaid_lbl.text = "$\(rideData.strTotalAmount)"
        self.totalTime_lbl.text = rideData.strTotalTime
        
        if self.rideData.isAffiliateUsed == 1{
            self.affiliateApplied_lnl.text = "Applied"
        }else{
            self.affiliateStackView.isHidden = true
        }
        
        if self.rideData.isOutOfDropZoneUsed == 1{
            self.outOfDropzone_lbl.text = "Yes"
        }else{
            self.outOFDropzoneStackView.isHidden = true
        }
        
        if self.rideData.isRefferalUsed{
            self.referralCode_lbl.text = "Yes"
        }else{
            self.referralCode_lbl.text = "No"
            self.referralStackView.isHidden = true
        }
        if self.rideData.isMembershipUsed{
            self.partnerName_lbl.text = rideData.strMembershipName
        }else{
            self.partnerName_lbl.text = "No"
            self.memberShipStackView.isHidden = true
        }
        if rideData.strPenaltyCharges == "" || rideData.strPenaltyCharges == "0.00"{
            self.penaltyStackView.isHidden = true
        }else{
            self.penaltyStackView.isHidden = false
            self.penalityAmount_lbl.text = "$\(rideData.strPenaltyCharges)"
        }
        
        if rideData.promo_code_percenatge != "0"{
            self.promoCodeStackView.isHidden = false
            self.promoCode_lbl.text = rideData.promo_code_percenatge
        }else{
            self.promoCodeStackView.isHidden = true
        }
        self.view.layoutIfNeeded()
    }
    
    func showSkeltonView(){
        Singleton.showSkeltonViewOnViews(viewsArray: [self.mainStackView])
    }
    
    func hideSkeltonView(){
        Singleton.hideSkeltonViewFromViews(viewsArray: [self.mainStackView])
    }
    
}

//MARK: - Web Api's
extension MyRentalReceiptVC{
    
    func rentalReceiptDetail_Web(){
        
        let dictParam = NSMutableDictionary()
        
        dictParam.setValue(self.paymentId, forKey: "payment_id")
        dictParam.setValue(StaticClass.sharedInstance.strUserId ,forKey:"user_id")
        dictParam.setValue("0", forKey: "page_no")
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        self.showSkeltonView()
        APICall.shared.postWeb("booking_history", parameters: dictParam, showLoder: false) { (response) in
            self.hideSkeltonView()
            let dict = response as! NSDictionary
            if (dict["IS_ACTIVE"] as! Bool) {
                if (dict["FLAG"] as! Bool){
                    if let arrList = dict["Details"] as? NSArray{
                        
                        if arrList.count > 0 {
                            if let element = arrList.object(at: 0) as? NSDictionary{
                                let dataRental = shareRental()
                                dataRental.strOrderID = element.object(forKey: "order_id")as? String ?? ""
                                dataRental.strAddress = element.object(forKey: "address") as? String ?? ""
                                dataRental.strAmount = element.object(forKey: "amount") as? String ?? ""
                                dataRental.strTotalAmount = element.object(forKey: "total_amount")as? String ?? ""
                                dataRental.strCardType = element.object(forKey: "cardType") as? String ?? ""
                                dataRental.strCardNumber = element.object(forKey: "card_number") as? String ?? ""
                                dataRental.strCardToken = element.object(forKey: "card_token") as? String ?? ""
                                dataRental.strCardToken = "c5wv3j"
                                dataRental.strCreatedAt = element.object(forKey: "created_at") as? String ?? ""
                                dataRental.strDropOffLocationID = element.object(forKey: "dropoff_location_id") as? String ?? ""
                                dataRental.strEndDate = element.object(forKey: "end_date") as? String ?? ""
                                dataRental.strEndTime = element.object(forKey: "end_time") as? String ?? "0.00"
                                dataRental.strStartTime = element.object(forKey: "start_time") as? String ?? "0.00"
                                dataRental.strPrintRecipt = element.object(forKey: "booking_receipt") as? String ?? ""
                                dataRental.isRefferalUsed = element.object(forKey: "referral_used")as? Int ?? 0 == 1 ? true:false
                                dataRental.strReferralId = element.object(forKey: "referral_id")as? String ?? ""
                                dataRental.isMembershipUsed = element.object(forKey: "membership_used")as? Int ?? 0 == 1 ? true:false
                                dataRental.strMembershipName = element.object(forKey: "membership_name")as? String ?? ""
                                dataRental.strUser_Type = element.object(forKey: "user_type") as? String ?? ""
                                dataRental.strMapImage = element.object(forKey: "booking_map_image") as? String ?? ""
                                dataRental.strIsPaymentDone = element.object(forKey: "is_payment_done") as? String ?? ""
                                dataRental.strKubeName = element.object(forKey: "kube_name") as? String ?? ""
                                dataRental.strLatitude = element.object(forKey: "latitude") as? String ?? ""
                                dataRental.strLongitude = element.object(forKey: "longitude") as? String ?? ""
                                dataRental.strLocationImage = element.object(forKey: "location_image") as? String ?? ""
                                dataRental.strLocationName = element.object(forKey: "location_name") as? String ?? ""
                                dataRental.strLocationType = element.object(forKey: "location_type") as? String ?? ""
                                dataRental.strPenaltyCharges = element.object(forKey: "penalty_charges") as? String ?? ""
                                dataRental.strDeviceId = element.object(forKey: "device_id") as? String ?? ""
                                dataRental.strFeedbackStatus = String( element.object(forKey: "is_feedback") as? Int ?? 0)//is_feedback
                                
                                dataRental.strObjectID = element.object(forKey: "object_id") as? String ?? ""
                                dataRental.strObjectName = element.object(forKey: "object_number") as? String ?? ""
                                dataRental.strObjectUniqueId = element.object(forKey: "obj_unique_id")as? String ?? ""
                                dataRental.strObjectType = element.object(forKey: "object_type") as? String ?? ""
                                dataRental.asset_name = element.object(forKey: "object_name") as? String ?? ""
                                dataRental.assets_sub_name = element.object(forKey: "object_sub_name")as? String ?? ""
                                
                                dataRental.strPayment_Id = element.object(forKey: "payment_id") as? String ?? ""
                                
                                dataRental.strPricePerHour = element.object(forKey: "price_per_hour") as? String ?? ""
                                dataRental.strStartDate = element.object(forKey: "start_date") as? String ?? ""
                                
                                dataRental.strTotalTime = element.object(forKey: "total_time") as? String ?? ""
                                dataRental.strTransectionDate = element.object(forKey: "transaction_date") as? String ?? ""
                                
                                dataRental.strTransectionID = element.object(forKey: "transaction_id") as? String ?? ""
                                dataRental.strUserID = element.object(forKey: "user_id") as? String ?? ""
                                dataRental.strUserName = element.object(forKey: "user_name") as? String ?? ""
                                
                                dataRental.strFare = element.object(forKey: "total_amount") as? String ?? ""
                                dataRental.strTime = element.object(forKey: "total_time") as? String ?? ""
                                dataRental.promo_code_percenatge = element.object(forKey: "promo_code_percenatge")as? String ?? ""
                                
                                if dataRental.strStartTime != "" {
                                    let dateAsString = dataRental.strStartTime
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "HH:mm:ss"
                                    
                                    let date = dateFormatter.date(from: dateAsString)
                                    dateFormatter.dateFormat = "HH:mm:ss"
                                    if date != nil{
                                        let Date12 = dateFormatter.string(from: date!)
                                        dataRental.strStartTime = Date12
                                    }
                                }
                                
                                if dataRental.strEndTime != "" {
                                    let dateAsString = dataRental.strEndTime
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "HH:mm:ss"
                                    
                                    let date = dateFormatter.date(from: dateAsString)
                                    dateFormatter.dateFormat = "HH:mm:ss"
                                    if date != nil{
                                        let Date12 = dateFormatter.string(from: date!)
                                        dataRental.strEndTime = Date12
                                    }
                                }
                                
                                if let strCalories = element.object(forKey: "total_calories") as? String {
                                    dataRental.strCalories = strCalories
                                }
                                if let intCalories = element.object(forKey: "total_calories") as? Int {
                                    dataRental.strCalories = "\(intCalories)"
                                }
                                
                                let dubleMileValue = Double(element.object(forKey: "total_distance") as? String ?? "0.00")
                                dataRental.strDistance = String(format:"%.2f",dubleMileValue!)
                                self.rideData = dataRental
                                self.setData()
                            }
                        }
                    }
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
                }
            } else {
                Global.appdel.userDetailCall(vc: self)
                StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
            }
            
        } failure: { (error) in
            self.hideSkeltonView()
        }
    }
}
