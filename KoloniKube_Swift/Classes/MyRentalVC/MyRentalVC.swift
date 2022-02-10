//
//  MyRentalVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 4/4/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import ICSPullToRefresh
import SkeletonView

class MyRentalVC: UIViewController {

    //MARK: - Outlet's
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lblNoHistoryFound: UILabel!
    @IBOutlet weak var tblRental: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var referralCount_lbl: UILabel!
    @IBOutlet weak var skeltonView: UIView!
    @IBOutlet weak var rippleView: UIView!
    @IBOutlet weak var btnGift: IPAutoScalingButton!
    
    //Variable's
    var intPageCount = Int()
    var arrRentalList :NSMutableArray = NSMutableArray()
    

    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnGift.clipsToBounds = true
        self.btnGift.layer.cornerRadius = 12.5
        self.referralCount_lbl.circleObject()
        self.intPageCount = 1
        self.tblRental.register(UINib(nibName: "MyRentalCellNew", bundle: nil), forCellReuseIdentifier: "MyRentalCellNew")
        self.tblRental.tableFooterView = UIView()

        self.tblRental.addInfiniteScrollingWithHandler {
            self.tblRental.infiniteScrollingView?.stopAnimating()
            self.rentalListApiCall(isLoader: false)
        }

        self.tblRental.addPullToRefreshHandler {
            self.tblRental.pullToRefreshView?.stopAnimating()
            self.intPageCount = 1
            self.rentalListApiCall(isLoader: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.arrRentalList.removeAllObjects()
        self.lblNoHistoryFound.isHidden = true
        self.referralCount_lbl.text = Singleton.numberOfReferralRides
        self.tblRental.reloadData()
        self.intPageCount = 1
        self.ApiCall()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if Global.appdel.is_rentalRunning {
            self.view.layoutIfNeeded()
        }
        super.viewWillDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.addUnderLine(color: .lightGray)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: - @IBAction's
    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.sideMenuViewController?.presentLeftMenuViewController()
    }
    
    @IBAction func btnGiftClicked(_ sender: UIButton) {
        self.loadShareRefferView()
    }
    
    //MARK: - Custom Function's
    func ApiCall()  {
        Global().delay(delay: 0.1) {
            self.rentalListApiCall(isLoader: true)
        }
    }
    
    @objc func checkStatusBookingFromNotification(notification:Notification) -> Void {

        self.arrRentalList.removeAllObjects()
        self.tblRental.reloadData()
        self.ApiCall()

    }

    func loadRippleView(){

        if Singleton.totalRidesTaken == 0{
            if !UserDefaults.standard.bool(forKey: "isRippleEffectClosed"){
                if !Global.appdel.is_rentalRunning{
                    let fillColor: UIColor? = CustomColor.customAppGreen
                    Singleton.smRippleView = SMRippleView(frame: self.rippleView.bounds, rippleColor: UIColor.black, rippleThickness: 0.2, rippleTimer: 2, fillColor: fillColor, animationDuration: 3, parentFrame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    self.rippleView.addSubview(Singleton.smRippleView!)
                }
            }
        }

    }
    
    func showSkeltonView(){
        self.skeltonView.isHidden = false
        Singleton.showSkeltonViewOnViews(viewsArray: [self.skeltonView])
    }
    
    func hideSkeltonView(){
        self.skeltonView.isHidden = true
        Singleton.hideSkeltonViewFromViews(viewsArray: [self.skeltonView])
    }
}

//MARK: - Web Api's
extension MyRentalVC{
    
    func rentalListApiCall(isLoader:Bool) {
        let dictParam = NSMutableDictionary()
        dictParam.setValue(StaticClass.sharedInstance.strUserId ,forKey:"user_id")
        dictParam.setValue(intPageCount, forKey: "page_no")
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")

        APICall.shared.postWeb("booking_history", parameters: dictParam, showLoder: false, successBlock: { (response) in

            let dict = response as! NSDictionary
            if (dict["IS_ACTIVE"] as! Bool) {
                if (dict["FLAG"] as! Bool){
                    self.tblRental.infiniteScrollingView?.stopAnimating()
                    self.tblRental.pullToRefreshView?.stopAnimating()
                    if self.intPageCount == 1 {
                        self.arrRentalList.removeAllObjects()
                    }
                    if let arrList = dict["Details"] as? NSArray{

                        if arrList.count > 0 {
                            self.intPageCount = self.intPageCount + 1
                        }

                        for elemnet in arrList as! [NSDictionary] {
                            let dataRental = shareRental()
                            dataRental.strOrderID = elemnet.object(forKey: "order_id")as? String ?? ""
                            dataRental.strAddress = elemnet.object(forKey: "address") as? String ?? ""
                            dataRental.strAmount = elemnet.object(forKey: "amount") as? String ?? ""
                            dataRental.strTotalAmount = elemnet.object(forKey: "total_amount")as? String ?? ""
                            dataRental.strCardType = elemnet.object(forKey: "cardType") as? String ?? ""
                            dataRental.strCardNumber = elemnet.object(forKey: "card_number") as? String ?? ""
                            dataRental.strCardToken = elemnet.object(forKey: "card_token") as? String ?? ""
                            dataRental.strCardToken = "c5wv3j"
                            dataRental.strCreatedAt = elemnet.object(forKey: "created_at") as? String ?? ""
                            dataRental.strDropOffLocationID = elemnet.object(forKey: "dropoff_location_id") as? String ?? ""
                            dataRental.strEndDate = elemnet.object(forKey: "end_date") as? String ?? ""
                            dataRental.strEndTime = elemnet.object(forKey: "end_time") as? String ?? "0.00"
                            dataRental.strStartTime = elemnet.object(forKey: "start_time") as? String ?? "0.00"
                            dataRental.strPrintRecipt = elemnet.object(forKey: "booking_receipt") as? String ?? ""
                            dataRental.isRefferalUsed = elemnet.object(forKey: "referral_used")as? Int ?? 0 == 1 ? true:false
                            dataRental.strReferralId = elemnet.object(forKey: "referral_id")as? String ?? ""
                            dataRental.isMembershipUsed = elemnet.object(forKey: "membership_used")as? Int ?? 0 == 1 ? true:false
                            dataRental.strMembershipName = elemnet.object(forKey: "membership_name")as? String ?? ""
                            dataRental.promo_code_percenatge = elemnet.object(forKey: "promo_code_percenatge")as? String ?? ""
                            dataRental.strUser_Type = elemnet.object(forKey: "user_type") as? String ?? ""
                            dataRental.strMapImage = elemnet.object(forKey: "booking_map_image") as? String ?? ""
                            dataRental.strIsPaymentDone = elemnet.object(forKey: "is_payment_done") as? String ?? ""
                            dataRental.strKubeName = elemnet.object(forKey: "kube_name") as? String ?? ""
                            dataRental.strLatitude = elemnet.object(forKey: "latitude") as? String ?? ""
                            dataRental.strLongitude = elemnet.object(forKey: "longitude") as? String ?? ""
                            dataRental.strLocationImage = elemnet.object(forKey: "location_image") as? String ?? ""
                            dataRental.strLocationName = elemnet.object(forKey: "location_name") as? String ?? ""
                            dataRental.strLocationType = elemnet.object(forKey: "location_type") as? String ?? ""
                            dataRental.strPenaltyCharges = elemnet.object(forKey: "penalty_charges") as? String ?? ""
                            dataRental.strDeviceId = elemnet.object(forKey: "device_id") as? String ?? ""
                            dataRental.strFeedbackStatus = String( elemnet.object(forKey: "is_feedback") as? Int ?? 0)//is_feedback
                            dataRental.isOutOfDropZoneUsed = elemnet.object(forKey: "outof_dropzone_used")as? Int ?? 0
                            dataRental.isAffiliateUsed = elemnet.object(forKey: "affiliate_used")as? Int ?? 0
                            dataRental.strObjectID = elemnet.object(forKey: "object_id") as? String ?? ""
                            dataRental.strObjectName = elemnet.object(forKey: "object_number") as? String ?? ""
                            dataRental.strObjectUniqueId = elemnet.object(forKey: "obj_unique_id")as? String ?? ""
                            dataRental.strObjectType = elemnet.object(forKey: "object_type") as? String ?? ""
                            dataRental.asset_name = elemnet.object(forKey: "object_name") as? String ?? ""
                            dataRental.assets_sub_name = elemnet.object(forKey: "object_sub_name")as? String ?? ""
                            dataRental.strPayment_Id = elemnet.object(forKey: "payment_id") as? String ?? ""
                            dataRental.strPricePerHour = elemnet.object(forKey: "price_per_hour") as? String ?? ""
                            dataRental.strStartDate = elemnet.object(forKey: "start_date") as? String ?? ""
                            dataRental.strTotalTime = elemnet.object(forKey: "total_time") as? String ?? ""
                            dataRental.strTransectionDate = elemnet.object(forKey: "transaction_date") as? String ?? ""
                            dataRental.strTransectionID = elemnet.object(forKey: "transaction_id") as? String ?? ""
                            dataRental.strUserID = elemnet.object(forKey: "user_id") as? String ?? ""
                            dataRental.strUserName = elemnet.object(forKey: "user_name") as? String ?? ""
                            dataRental.strFare = elemnet.object(forKey: "total_amount") as? String ?? ""
                            dataRental.strTime = elemnet.object(forKey: "total_time") as? String ?? ""
                            let dubleMileValue = Double(elemnet.object(forKey: "total_distance") as? String ?? "0.00")
                            dataRental.strDistance = String(format:"%.2f",dubleMileValue!)

                            if let strCalories = elemnet.object(forKey: "total_calories") as? String {
                                dataRental.strCalories = strCalories
                            }
                            if let intCalories = elemnet.object(forKey: "total_calories") as? Int {
                                dataRental.strCalories = "\(intCalories)"
                            }
                            
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
                            self.arrRentalList .add(dataRental)
                        }
                    }
                    self.tblRental.reloadData()
                    Global.appdel.userDetailCall(vc: self)
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
                }
            } else {
                Global.appdel.userDetailCall(vc: self)
                StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
            }
            if self.arrRentalList.count > 0 {
                self.lblNoHistoryFound.isHidden = true
                self.tblRental.isHidden = false
                self.lblNoHistoryFound.text =  ""
                self.tblRental.reloadData()
            } else {
                self.lblNoHistoryFound.isHidden = false
                self.lblNoHistoryFound.text =  "Rental history is empty."
                self.tblRental.isHidden = true
            }
        }) { (error) in
            self.tblRental.reloadData()
        }
    }
    
}

//MARK:- TableView Delegate's
extension MyRentalVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrRentalList.count == 0 ? 10:self.arrRentalList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblRental.dequeueReusableCell(withIdentifier: "MyRentalCellNew")as! MyRentalCellNew
            DispatchQueue.main.async {
                if self.arrRentalList.count == 0{
                    Singleton.showSkeltonViewOnViews(viewsArray: [cell.containerView])
                }else{
                    Singleton.hideSkeltonViewFromViews(viewsArray: [cell.containerView])
                    cell.vehicleNameContainerView.createGradientLayer(color1: CustomColor.customBlue, color2: CustomColor.customCyan, startPosition: 0.2, endPosition: 1.0)
                    if self.arrRentalList.count > 0{
                        cell.vehicleNameContainerView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
                        let rentalOBJ = self.arrRentalList[indexPath.row] as! shareRental
                        cell.orderNumber_lbl.text = rentalOBJ.strOrderID
                        cell.date_lbl.text = rentalOBJ.strEndDate
                        cell.startTime_lbl.text = rentalOBJ.strStartTime
                        cell.totalAmountPaid_lbl.text = "$\(rentalOBJ.strTotalAmount)"
                        cell.totalTime_lbl.text = rentalOBJ.strTime
                    }
                }
            }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.arrRentalList.count > 0{
            let rideReceiptVc = MyRentalReceiptVC(nibName: "MyRentalReceiptVC", bundle: nil)
            rideReceiptVc.rideData = self.arrRentalList.object(at: indexPath.row)as! shareRental
            rideReceiptVc.backVc = "my_rentals"
            self.navigationController?.pushViewController(rideReceiptVc, animated: true)
        }
    }

}
