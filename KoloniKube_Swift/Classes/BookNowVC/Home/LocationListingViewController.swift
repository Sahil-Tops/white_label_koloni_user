//
//  LocationListingViewController.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 01/10/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class LocationListingViewController: UIViewController {
    
    @IBOutlet weak var navigationImage: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var locationTitle_lbl: UILabel!
    @IBOutlet weak var description_lbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startRental_btn: UIButton!
    @IBOutlet weak var runningRental_btn: UIButton!
    
    //Slide to finish rental
    @IBOutlet weak var btnSlideToFinish: VHSlideButton!
    @IBOutlet weak var finishRentalsView: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    
    
    
    var locationModelArray: [LOCATION_DATA] = []
    var assetsModelArray: [ASSETS_LIST] = []
    var axaLockConnection: AXALOCK_CONNECTION?
    var runningRentalView: RunningRentalView?
    var selectedCardDetail: shareCraditCard!
    var shareDeviceObj = ShareDevice()
    var bikeSharedData = ShareBikeData()
    var bikeSharedDataArray: [ShareBikeData] = []
    var endingRentalData: [String:Any] = [:]
    var appGroupDefaults = UserDefaults.standard
    var selectedRentalIndex = 0
    
    var locationId = ""
    var bikeId = ""
    var paymentId = ""
    var isEndingRentalManual = ""
    var batteryPercentage = ""
    
    var imagePickerVcPresent = false
    
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.registerTableCell()
        self.axaLockConnection = AXALOCK_CONNECTION.init(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchHome_Web(lat: "\(StaticClass.sharedInstance.latitude)", long: "\(StaticClass.sharedInstance.longitude)")
        Singleton.shared.getCardsList_Web()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.axaLockConnection?.dissconnectDevice()
        if !self.imagePickerVcPresent{
            for i in 0..<Singleton.timerArray.count{
                (Singleton.timerArray[i]).invalidate()
            }
            Singleton.timerArray.removeAll()
        }else{
            self.imagePickerVcPresent = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadUI()
    }
    
    //MARK: - @IBAction
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case menu_btn:
            self.sideMenuViewController?.presentLeftMenuViewController()
            break
        case startRental_btn:
            if Singleton.shared.cardListsArray.count > 0{
                self.loadSelectPaymentView()
            }else{
                let bookingPayment = BookingPaymentVC(nibName: "BookingPaymentVC", bundle: nil)
                let strCustID = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID)as? String ?? ""
                bookingPayment.strCustomerID = strCustID
                bookingPayment.referralSelected = 0//self.referralSelected
                bookingPayment.numberOfReferral = 0//self.numberOfReferralRentals
                bookingPayment.selectedObjectId = ""
                self.navigationController?.pushViewController(bookingPayment, completion: {
                })
            }
            break
        case runningRental_btn:
            self.runningRentalView = self.loadRunningRentalView()
            break
        default:
            break
        }
        
    }
    
    //MARK: - Custom Function's
    func registerTableCell(){
        
        self.tableView.register(UINib(nibName: "LocationListingCell", bundle: nil), forCellReuseIdentifier: "LocationListingCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
    }
    
    func loadUI(){
        self.startRental_btn.isHidden = true
//        self.runningRental_btn.isHidden = true
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "logo_img") { (image) in
            self.logoImg.image = image
        }
        if AppLocalStorage.sharedInstance.application_gradient{
            self.navigationImage.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.startRental_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.runningRental_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.navigationImage.backgroundColor = CustomColor.primaryColor
            self.startRental_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
            self.startRental_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        self.startRental_btn.circleObject()
        self.runningRental_btn.circleObject()
        self.view.layoutIfNeeded()
        
        self.startRental_btn.isHidden = false
    }
    
    func addDataToUserDefaultForWidget(){
        var dict : [String:String] = [:]
        dict["user_id"] = StaticClass.sharedInstance.strUserId
        dict["ios_version"] = "\(appDelegate.getCurrentAppVersion)"
        dict["object_id"] = StaticClass.sharedInstance.strObjectId
        dict["booking_id"] = StaticClass.sharedInstance.strBookingId
        self.appGroupDefaults.setValue(dict, forKey: "ride")
    }
    
    func setUpData(dict: [String:Any]){
        
        if let currentRental = dict["CURRENT_RENTAL"] as? [[String:Any]],currentRental.count > 0 {
            for currentRetalObj in currentRental {
                if self.shareDeviceObj.arrBikes.count > 0 {
                    
                } else {
                    self.bikeSharedData.strId = currentRetalObj["object_id"] as? String ?? ""
                    self.bikeSharedData.is_outof_dropzone = Int(String(describing: currentRetalObj["is_outof_dropzone"]!)) ?? -1
                    self.bikeSharedData.outOfDropzoneMsg = currentRetalObj["outof_dropzone_message"]as? String ?? ""
                    self.bikeSharedData.strName = currentRetalObj["name"] as? String ?? ""
                    self.bikeSharedData.strAddress = currentRetalObj["address"] as? String ?? ""
                    self.bikeSharedData.doublePrice = StaticClass.sharedInstance.getDouble(value: currentRetalObj["object_price"] as? String ?? "" )
                    StaticClass.sharedInstance.saveToUserDefaultsString(value:self.bikeSharedData.strId, forKey: Global.g_UserData.ObjectID)
                    self.bikeSharedData.intType = Int(StaticClass.sharedInstance.getDouble(value: currentRetalObj["object_type"] as? String ?? "0"))
                    self.bikeSharedDataArray.append(bikeSharedData)
                }
                
                if let strObjectType = currentRetalObj["object_type"] as? String  {
                    if strObjectType == "2" {
                        
                    } else  {
//                        self.btnGift.isHidden = false
//                        self.referralCount_lbl.isHidden = false
                    }
                }
                if let intObjectType = currentRetalObj["object_type"] as? Int {
                    if intObjectType == 2 {
                        
                    } else {
//                        self.btnGift.isHidden = false
//                        self.referralCount_lbl.isHidden = false
                    }
                }
                
                Global.appdel.strIsUserType = currentRetalObj["user_type"] as? String ?? "0"
                self.addDataToUserDefaultForWidget()
//                if UserDefaults.standard.value(forKey: "isRentalPause") != nil{
//                    let pause = UserDefaults.standard.value(forKey: "isRentalPause")
//                    if "\(pause!)" == "1"{
//                        self.isPause = false
//                    }else{
//                        self.isPause = true
//                    }
//                }
            }
            if currentRental.count > 0{
                self.locationId = currentRental[0]["location_id"] as? String ?? ""
                self.bikeId = currentRental[0]["object_id"] as? String ?? ""                
            }
        }
        
    }
    
}


//MARK: - Select Payment Delegate's
extension LocationListingViewController: SelectedPaymentDelegate{
    
    func selectCard(cardDetail: shareCraditCard, referralSelected: Int ) {
        self.selectedCardDetail = cardDetail
        let QrCodeVController = QRCodeScaneVC(nibName: "QRCodeScaneVC", bundle: nil)
        QrCodeVController.sharedCreditCardObj = self.selectedCardDetail
        QrCodeVController.isReferralApply = referralSelected
        QrCodeVController.selectedObjectId = ""
        self.navigationController?.pushViewController(QrCodeVController, animated: true)
    }
    
}

//MARK: - TableView Delegate's
extension LocationListingViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "LocationListingCell")as! LocationListingCell
        let model = self.locationModelArray[indexPath.row]
        cell.title_lbl.text = model.location_name
        cell.description_lbl.text = model.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationModel = self.locationModelArray[indexPath.row]
        let filtteredArray = self.assetsModelArray.filter({$0.location_id == locationModel.id})
        let vc = AssetsListingViewController(nibName: "AssetsListingViewController", bundle: nil)
        vc.assetsListArray = filtteredArray
        vc.locationModel = locationModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//MARK: - CoreBluetooth Delegate's
extension LocationListingViewController: CheckBluetoothStatusDelegate{
   func response(status: Bool) {
       if status{
        if self.runningRentalView?.rentalActionPerformed == 1{
            self.runningRentalView?.showSlideDown()
           }else{
            self.runningRentalView?.performLockUnlock()
           }
       }else{
           let alert = UIAlertController(title: "Alert", message: "Please turn on bluetooth to perform pause, resume or end rental.", preferredStyle: UIAlertController.Style.alert)
           alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
           self.present(alert, animated: true, completion: nil)
       }
   }
}

//MARK: - Web API
extension LocationListingViewController{
    
    func searchHome_Web(lat: String, long: String) -> Void {
        
        let params: NSMutableDictionary = NSMutableDictionary()
        
        params.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        params.setValue(String(describing: lat), forKey: "latitude")
        params.setValue(String(describing: long), forKey: "longitude")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        params.setValue(StaticClass.sharedInstance.strBookingId, forKey: "payment_id")
        
        APICall.shared.postWeb("search_home", parameters: params, showLoder: true, successBlock: { (response) in
            print(response)
            
            if let data = response as? [String:Any]{
                if let status = data["FLAG"]as? Int, status == 1{
                    if let locationData = data["LOACTION_DATA"]as? [[String:Any]]{
                        self.locationModelArray = LOCATION_DATA.parseData(data: locationData)
                    }
                    if let assets = data["assets_lists"]as? [[String:Any]]{
                        self.assetsModelArray = ASSETS_LIST.parseData(data: assets)
                    }
                    self.tableView.reloadData()
                    
                    if let rentals = data["user_running_rental_detail"]as? [[String:Any]], rentals.count > 0{
                        Singleton.runningRentalArray = rentals[0]["CURRENT_RENTAL"]as? [[String:Any]] ?? []
                        if Singleton.runningRentalArray.count > 0{
                            self.startRental_btn.setTitle("Add new rental", for: .normal)
                            self.runningRental_btn.isHidden = false
                            Singleton.track_location_timer.invalidate()
                            Singleton.track_location_timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { (_) in
                                DispatchQueue.main.async(execute: {
                                    Global.appdel.locationUpdatesCall(vc: self)
                                })
                            })
                            Global.appdel.checkLocationMangereMethod()
                            StaticClass.sharedInstance.saveToUserDefaults(Singleton.runningRentalArray as AnyObject, forKey: "running_rental")
                            Singleton.numberOfCards = Singleton.runningRentalArray[0]["credit_cards_list"]as? [[String:Any]] ?? []
                        }else{
                            self.runningRental_btn.isHidden = true
                            self.startRental_btn.setTitle("Start", for: .normal)
                        }
                        if Singleton.timerArray.count > 0 {
                            for t in Singleton.timerArray {
                                t.invalidate()
                            }
                        }
                        Singleton.timerArray.removeAll()
                        for _ in 0..<Singleton.runningRentalArray.count{
                            let timer = Timer()
                            Singleton.timerArray.append(timer)
                        }
                        if rentals.count > 0{
                            self.setUpData(dict: rentals[0])
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if Singleton.isOpeningAppFromNotification{
                            if !Singleton.notificationRunningRentalDetail.isEmpty{
                                self.selectedRentalIndex = Singleton.runningRentalArray.firstIndex(where: {$0["obj_unique_id"]as? String ?? "" == Singleton.notificationRunningRentalDetail["obj_unique_id"]as? String ?? ""}) ?? -1
                                if self.selectedRentalIndex != -1{
                                    self.loadEndRentalPopUpView(titleMsg: "Alert!", descriptionMsg: Singleton.notificationRunningRentalDetail["popup_msg"]as? String ?? "")
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let data = response as? [String:Any]{
                            if let show_contact_popup = data["show_contact_popup"]as? Int, show_contact_popup == 1{
                                self.loadPrimaryAccountView(data: data)
                            }
                        }
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
}

class LOCATION_DATA{
    
    var id = ""
    var address = ""
    var average_ratings = ""
    var geofence: GEOFENCE?
    var is_affiliate_location = ""
    var is_location_active = ""
    var latitude = 0.0
    var longitude = 0.0
    var location_name = ""
    var location_type = ""
    var total_assets = ""
    var total_review = ""
    
    static func parseData(data: [[String:Any]])-> [LOCATION_DATA]{
        var array: [LOCATION_DATA] = []
        for item in data{
            let model = LOCATION_DATA()
            model.id = item["id"]as? String ?? ""
            model.address = item["address"]as? String ?? ""
            model.average_ratings = item["average_ratings"]as? String ?? ""
            for cordinates in item["geofence"]as? [[String:Any]] ?? []{
                model.geofence?.latitude = cordinates["latitude"]as? Double ?? 0.0
                model.geofence?.longitude = cordinates["longitude"]as? Double ?? 0.0
            }
            model.is_affiliate_location = item["is_affiliate_location"]as? String ?? ""
            model.is_location_active = item["is_location_active"]as? String ?? ""
            model.latitude = item["latitude"]as? Double ?? 0.0
            model.longitude = item["longitude"]as? Double ?? 0.0
            model.location_name = item["location_name"]as? String ?? ""
            model.location_type = item["location_type"]as? String ?? ""
            model.total_assets = item["total_assets"]as? String ?? ""
            model.total_review = item["total_review"]as? String ?? ""
            array.append(model)
        }
        return array
    }
}

class ASSETS_LIST{
    
    var is_icon = ""
    var address = ""
    var assets_average_price = ""
    var assets_color_code = ""
    var assets_img_url = ""
    var assets_initial_mintues = ""
    var assets_initial_price = ""
    var is_accessible_user = 0
    var is_assets_active = 0
    var is_assets_active_msg = ""
    var is_outof_dropzone = 0
    var is_plan_purchase = ""
    var latitude = 0.0
    var longitude = 0.0
    var location_id = ""
    var lock_name = ""
    var outof_dropzone_message = ""
    var partner_name = ""
    var plan_partner_id = ""
    var sub_type = ""
    var sub_type_name = ""
    var type = ""
    var type_name = ""
    var unique_id = ""
    
    static func parseData(data: [[String:Any]])-> [ASSETS_LIST]{
        var array: [ASSETS_LIST] = []
        for item in data{
            let model = ASSETS_LIST()
            model.address = item["address"]as? String ?? ""
            model.is_icon = item["IS_ICON"]as? String ?? ""
            model.assets_average_price = item["assets_average_price"]as? String ?? ""
            model.assets_color_code = item["assets_color_code"]as? String ?? ""
            model.latitude = item["latitude"]as? Double ?? 0.0
            model.longitude = item["longitude"]as? Double ?? 0.0
            model.assets_img_url = item["assets_img_url"]as? String ?? ""
            model.assets_initial_mintues = item["assets_initial_mintues"]as? String ?? ""
            model.assets_initial_price = item["assets_initial_price"]as? String ?? ""
            model.is_accessible_user = item["is_accessible_user"]as? Int ?? 0
            model.is_assets_active = item["is_assets_active"]as? Int ?? 0
            model.is_assets_active_msg = item["is_assets_active_msg"]as? String ?? ""
            model.is_outof_dropzone = item["is_outof_dropzone"]as? Int ?? 0
            model.is_plan_purchase = item["is_plan_purchase"]as? String ?? ""
            model.location_id = item["location_id"]as? String ?? ""
            model.lock_name = item["lock_name"]as? String ?? ""
            model.outof_dropzone_message = item["outof_dropzone_message"]as? String ?? ""
            model.partner_name = item["partner_name"]as? String ?? ""
            model.plan_partner_id = item["plan_partner_id"]as? String ?? ""
            model.sub_type = item["sub_type"]as? String ?? ""
            model.sub_type_name = item["sub_type_name"]as? String ?? ""
            model.type = item["type"]as? String ?? ""
            model.type_name = item["type_name"]as? String ?? ""
            model.unique_id = item["unique_id"]as? String ?? ""
            array.append(model)
        }
        return array
    }
    
}

struct GEOFENCE {
    var latitude = 0.0
    var longitude = 0.0
}
