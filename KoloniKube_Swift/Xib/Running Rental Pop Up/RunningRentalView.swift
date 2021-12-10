//
//  RunningRentalView.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 06/10/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit
import CoreBluetooth
import LinkaAPIKit
import UPCarouselFlowLayout

protocol RunningRentalDelegate {
    func actionPerformed()
}

class RunningRentalView: UIView {
    
    @IBOutlet weak var blackBgView: UIView!
    @IBOutlet weak var blurRentalView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var runningRentalContainerView: CustomView!
    @IBOutlet weak var runningRentalContainerBg_imageView: UIImageView!    
    @IBOutlet weak var runningRentalContainerView_bottom: NSLayoutConstraint!
    @IBOutlet weak var numberOfRentals_lbl: UILabel!
    @IBOutlet weak var totalAmount_lbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionView_height: NSLayoutConstraint!
    @IBOutlet weak var addNewRental_btn: UIButton!
    @IBOutlet weak var nearByLocations_btn: CustomButton!
    @IBOutlet weak var hide_btn: CustomButton!
    
    var vc: UIViewController!
    var locationVc: LocationListingViewController?
    var circularLoader = AnimatedCircularView()
    
    var endingRentalData: [String:Any] = [:]
    var writeCommandArray: [Int] = []
    var selectedCard: [String:Any] = [:]
    var cardSelected = 0
    
    var selectedRentalIndex = 0
    var lastSelectedIndex = 0
    var rentalActionPerformed = 0
    var isEndingRentalManual = 0
    var batteryPercentage = 50
    var isTableHide = true
    var isRentalCellChagned = false
    var isRentalViewDown = false
    
    var selectedBikeMacAddress = ""
    var isEventStatus = ""
    var lockCommand = ""
    var lockStatus = ""
    var connectedWithDevice = ""
    var strLocationID = ""
    var strBikeKubeID  = ""
    var locationId = ""
    var penaltyAmount = ""
    var totalCalulationPrice = ""
    var totalCalulationMinute = ""
    var paymentId = ""    
    
    var isPause = false
    var btnPressedPause = false
    var sendingCommand = false
    var writingEkeyCommand = false
    var iamAtHub = false
    var rentalImage: UIImage!
    var isCamBroken = false
    var imagePickerVcPresent = false
    var is_uploadingImg = false

    var peripheralDevice: CBPeripheral?
    var counter_timer = Timer()
    
    
    let lockConnectionService : LockConnectionService = LockConnectionService.sharedInstance
    
    var layout = UPCarouselFlowLayout()
    fileprivate var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    //MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case hide_btn:
            self.closeView()
            break
        case addNewRental_btn:
            break
        case nearByLocations_btn:
            break
        default:
            break
        }
        
    }
    
    
    //MARK: - Custom Functions
    func registerCell(){
        self.collectionView.register(UINib(nibName: "PauseRentalCollectionCell", bundle: nil), forCellWithReuseIdentifier: "PauseRentalCollectionCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func setCollectionLayout(){
        self.layout.itemSize = CGSize(width: self.collectionView.frame.width - 40, height: 265)
        self.layout.scrollDirection = .horizontal
        self.layout.spacingMode = .fixed(spacing: 10)
        self.layout.sideItemScale = 0.8
        self.collectionView.collectionViewLayout = self.layout
    }
    
    func loadContent(){
        
        self.locationVc = self.vc as? LocationListingViewController        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpDown(_:)))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpDown(_:)))
        swipeDown.direction = .down
        swipeUp.direction = .up
        self.runningRentalContainerView.addGestureRecognizer(swipeDown)
        self.runningRentalContainerView.addGestureRecognizer(swipeUp)
        
        self.blurRentalView.cornerRadius(cornerValue: 15)
        self.blurRentalView.alpha = 0
        
    }
    
    func loadUI(){
        if AppLocalStorage.sharedInstance.application_gradient{
            self.runningRentalContainerBg_imageView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.runningRentalContainerBg_imageView.backgroundColor = CustomColor.primaryColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.layoutIfNeeded()
        }
    }
    
    func showLoader(withMsg msg: String){
        self.shadowView.isHidden = false
        self.circularLoader.showSpiner(message: msg, labelColor: .white)
        self.circularLoader.frame = self.bounds
        self.addSubview(self.circularLoader)
    }
    
    func hideLoader(){
        self.shadowView.isHidden = true
        self.circularLoader.hideSpinner()
        self.circularLoader.removeFromSuperview()
    }
    
    func closeView(){
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.size.height
            self.layoutIfNeeded()
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
    @objc func swipeUpDown(_ sender: UISwipeGestureRecognizer){
        
        if sender.direction == .down{
            if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex){
                UIView.animate(withDuration: 0.3, animations: {
                    if self.isTableHide{
                        self.runningRentalContainerView_bottom.constant = -(220 + cell.outOfDtextLabel_height.constant)
                    }else{
                        self.runningRentalContainerView_bottom.constant = -((280 + cell.outOfDtextLabel_height.constant) + CGFloat(((Singleton.numberOfCards.count - 1)) * 40))
                    }
                    self.blackBgView.alpha = 0
                    self.blurRentalView.alpha = 0.5
                    self.layoutIfNeeded()
                })
            }
            self.isRentalViewDown = true
        }else if sender.direction == .up{
            UIView.animate(withDuration: 0.3, animations: {
                self.runningRentalContainerView_bottom.constant = -15
                self.blackBgView.alpha = 1
                self.blurRentalView.alpha = 0
                self.layoutIfNeeded()
            })
            self.isRentalViewDown = false
        }
    }
    
    func pauseResumeEndAlert(action: String){
        switch action {
        case "pause", "resume":
            if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
                
                if self.btnPressedPause{
                    self.showLoader(withMsg: "Unlocking. Please wait...")
                }else{
                    self.showLoader(withMsg: "Locking. Please wait...")
                }
                let device_name = Singleton.runningRentalArray[self.selectedRentalIndex]["assets_device_name"]as? String ?? ""
                if self.locationVc?.axaLockConnection?.peripheralDevice != nil && self.locationVc?.axaLockConnection?.connectedWithDevice == device_name{
                    self.locationVc?.axaLockConnection?.connectToPeripheral(identifire: (self.locationVc?.axaLockConnection?.peripheralDevice)!)
                }else{
                    self.locationVc?.axaLockConnection?.centralMannager?.scanForPeripherals(withServices: nil, options: nil)
                    _ = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (_) in
                        self.locationVc?.axaLockConnection?.centralMannager?.stopScan()
                        if self.locationVc?.axaLockConnection?.peripheralDevice == nil{
                            AppDelegate.shared.window?.showBottomAlert(message: "Please make sure asset is near by you and not connected with other device.")
                            self.hideLoader()
                        }
                    })
                }
            }else{
                CoreBluetoothClass.sharedInstance.isBluetoothOn(vc: self.locationVc!)
            }
            break
        case "end":
            if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
                
                self.showLoader(withMsg: "Locking. Please wait...")
                let device_name = Singleton.runningRentalArray[self.selectedRentalIndex]["assets_device_name"]as? String ?? ""
                if self.locationVc?.axaLockConnection?.peripheralDevice != nil && self.locationVc?.axaLockConnection?.connectedWithDevice == device_name{
                    self.locationVc?.axaLockConnection?.connectToPeripheral(identifire: (self.locationVc?.axaLockConnection?.peripheralDevice)!)
                }else{
                    self.locationVc?.axaLockConnection?.centralMannager?.scanForPeripherals(withServices: nil, options: nil)
                    _ = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (_) in
                        self.locationVc?.axaLockConnection?.centralMannager?.stopScan()
                        if self.locationVc?.axaLockConnection?.peripheralDevice == nil{
                            AppDelegate.shared.window?.showBottomAlert(message: "Please make sure asset is near by you and not connected with other device.")
                            self.hideLoader()
                        }
                    })
                }
            }else{
                
                if Singleton.runningRentalArray[self.selectedRentalIndex]["object_type"] as? String ?? "" == "2"{
//                    self.pauseRentalCollection_bottom.constant = -370
//                    self.rentalContainerView.isHidden = true
                    CoreBluetoothClass.sharedInstance.isBluetoothOn(vc: self.locationVc!)
                }else{
                    self.locationVc?.loadLockerInstructionView()
                }
            }
            break
        default:
            break
        }
    }
    
    func showSlideDown(){
        self.locationVc?.btnSlideToFinish.resetSlideButton()
        self.locationVc?.btnSlideToFinish.delegate = self
        self.locationVc?.finishRentalsView.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
        })
    }
    
    func performLockUnclock(){
        if !self.btnPressedPause{
            self.isPause = true
            self.lockCommand = "0"
            if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
                self.locationVc?.axaLockConnection?.lockDevice()
            }else{
                if self.btnPressedPause{
                    self.showLoader(withMsg: "Unlocking. Please wait...")
                }else{
                    self.showLoader(withMsg: "Locking. Please wait...")
                }
                _ = self.lockConnectionService.doLock(macAddress: self.selectedBikeMacAddress, delegate: self)
            }
        }else{
            self.isPause = false
            self.lockCommand = "1"
            if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
                self.locationVc?.axaLockConnection?.unlockDevice()
            }else{
                if self.btnPressedPause{
                    self.showLoader(withMsg: "Unlocking. Please wait...")
                }else{
                    self.showLoader(withMsg: "Locking. Please wait...")
                }
                _ = self.lockConnectionService.doUnLock(macAddress: self.selectedBikeMacAddress, delegate: self)
            }
        }
    }
    
    func deviceLockedSuccessfully(){
        self.isEventStatus = "3"
        self.changeStateOfPauseButton(isLocked: true)
        if self.rentalActionPerformed == 1{
            if Singleton.runningRentalArray.count > 0{
                if Singleton.runningRentalArray[self.selectedRentalIndex]["object_location_type"]as? String ?? "" == "1"{
                    self.nearestDropZone_Web()
                }else{
                    self.calculationPrice_Web(isNearBy: true)
                }
            }
            UserDefaults.standard.setValue(0, forKey: "isRentalPause")
        }else if self.isPause{
            self.isPause = false
        }
        self.hideLoader()
        self.lockUnlock_Web(strEvent: "0")
    }
    
    func deviceUnlockedSuccessfully(){
        self.btnPressedPause = !self.btnPressedPause
        self.isEventStatus = "4"
        self.changeStateOfPauseButton(isLocked: false)
        if !self.isPause{
            self.isPause = true
        }
        self.hideLoader()
        self.lockUnlock_Web(strEvent: "1")
    }
    
    func photoErrorOnUpload(){
        let alert = UIAlertController.init(title: "Image upload error", message: "Do you want to retry?", preferredStyle: .alert)
        
        let ok = UIAlertAction.init(title: "Retry", style: .default) { (result) in
            self.uploadImgForFinishRide()
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: {(alert) in
            self.closeView()
        })
        alert.addAction(ok)
        alert.addAction(cancel)
        self.locationVc?.present(alert, animated: true, completion: nil)
    }
    
    func changeStateOfPauseButton(isLocked: Bool){
        if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex) {
            if self.collectionView.indexPath(for: cell) != nil{
                if isLocked{
                    if Singleton.runningRentalArray[self.selectedRentalIndex]["object_type"] as? String ?? "" == "2"{
                        cell.pause_resume_lbl.text = AppLocalStorage.sharedInstance.resume_button_text//"Unlock"
                    }else{
                        cell.pause_resume_lbl.text = AppLocalStorage.sharedInstance.resume_button_text//"Open"
                    }
                    AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "pause_img") { (image) in
                        cell.pauseOrStartBtn_img.image = image
                    }
                    cell.pause_btn.backgroundColor = AppLocalStorage.sharedInstance.resume_button_color
                    cell.pause_btn.isSelected = true
                }else{
                    if Singleton.runningRentalArray[self.selectedRentalIndex]["object_type"] as? String ?? "" == "2"{
                        cell.pause_resume_lbl.text = AppLocalStorage.sharedInstance.pause_button_text//"Lock"
                    }else{
                        cell.pause_resume_lbl.text = AppLocalStorage.sharedInstance.pause_button_text//"Close"
                    }
                    AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "resume_img") { (image) in
                        cell.pauseOrStartBtn_img.image = image
                    }
                    cell.pause_btn.backgroundColor = AppLocalStorage.sharedInstance.pause_button_color
                    cell.pause_btn.isSelected = false
                }
            }
        }
    }
    
    func connectToPeripheral(identifire: CBPeripheral){
        self.peripheralDevice = identifire
        print("Peripheral Device", self.peripheralDevice!)
        let strArray = (Singleton.axa_ekey_dictionary["axa_passkey"]as? String ?? "").components(separatedBy: "-")
        let currentIndex = Singleton.axa_ekey_dictionary["current_index"]as? Int ?? -1
        if strArray.count > currentIndex{
            if self.peripheralDevice?.state ?? .disconnected == .connected{
                self.sendingCommand = true
                if self.rentalActionPerformed == 1{
                    //                        self.lockDevice()
                }else{
                    Global().delay(delay: 0.3) {
                        self.performLockUnlock()
                    }
                }
            }else{
                self.getAxaEkeyPasskey_Web(assetId: Singleton.runningRentalArray[self.selectedRentalIndex]["id"]as? String ?? "") { (response) in
                    if response{
                        self.locationVc?.axaLockConnection?.centralMannager?.connect(self.peripheralDevice!, options: [:])
                    }
                }
            }
        }else{
            self.getAxaEkeyPasskey_Web(assetId: Singleton.runningRentalArray[self.selectedRentalIndex]["id"]as? String ?? "") { (response) in
                if response{
                    self.locationVc?.axaLockConnection?.loadAxaFunctionality()
                }
            }
        }
    }
    
    func getAxaEkeyPasskey_Web(assetId: String, outputBlock: @escaping(_ response: Bool)-> Void){
        
        let params: NSMutableDictionary = NSMutableDictionary()
        params.setValue(StaticClass.sharedInstance.strUserId, forKey: "id")
        params.setValue("0", forKey: "parent_id")
        params.setValue(assetId, forKey: "object_id")
        params.setValue("otp", forKey: "passkey_type")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        APICall.shared.postWeb("update_ekey", parameters: params, showLoder: false, successBlock: { (response) in
            if let status = response["FLAG"]as? Int, status == 1{
                if let assets_detail = response["ASSETS_DETAIL"]as? [String:Any]{
                    var dictionary: [String:Any] = ["object_id": assetId]
                    if let ekey = assets_detail["axa_ekey"]as? String{
                        dictionary["axa_ekey"] = ekey
                        Singleton.axa_ekey = ekey
                    }
                    if let passkey = assets_detail["axa_passkey"]as? String{
                        dictionary["axa_passkey"] = passkey
                        Singleton.axa_passkey = passkey
                    }
                    if dictionary["axa_ekey"] as? String ?? "" != "" && dictionary["axa_passkey"] as? String ?? "" != ""{
                        dictionary["current_index"] = 0
                        Singleton.axa_ekey_dictionary = dictionary
                        outputBlock(true)
                    }else{
                        outputBlock(false)
                    }
                }
            }else{
                outputBlock(true)
            }
        }) { (error) in
            outputBlock(true)
            StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "", vc: self.vc)
        }
    }
    
    func lockUnlock_Web(strEvent:String) -> Void {
        
        let paramer: NSMutableDictionary = NSMutableDictionary()
        
        let selectedRentalDic = Singleton.runningRentalArray[selectedRentalIndex]
        
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey:"user_id")
        paramer.setValue(selectedRentalDic["id"]as? String ?? "", forKey:"booking_id")
        paramer.setValue(String(describing: StaticClass.sharedInstance.latitude), forKey:"latitude")
        paramer.setValue(String(describing: StaticClass.sharedInstance.longitude), forKey:"longitude")
        paramer.setValue(strEvent, forKey: "event") // (0:lock, 1:unlock)
        paramer.setValue(self.isEventStatus, forKey:"lock_status") //(1:Booking Started, 2:Booking Finished, 3:Intermediate Lock , 4:Intermediate Unlock)
        paramer.setValue(selectedRentalDic["object_id"]as? String ?? "", forKey: "object_id")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        let stringwsName = "lock_unlock"
        APICall.shared.postWeb(stringwsName, parameters: paramer, showLoder: false, successBlock: { (response) in
            print("lock_unlock response: ", response)
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool){
                    if self.rentalActionPerformed != 1{
                        self.locationVc?.searchHome_Web(lat: "\(StaticClass.sharedInstance.latitude)", long: "\(StaticClass.sharedInstance.longitude)")
                    }
                }else {
                    
                }
            }
        }) { (error) in
            
        }
    }
    
    func performLockUnlock(){
        if !self.btnPressedPause{
            if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
                //Peroform lock
                self.locationVc?.axaLockConnection?.lockDevice()
            }else{
                if self.btnPressedPause{
                    self.showLoader(withMsg: "Unlocking. Please wait...")
                }else{
                    self.showLoader(withMsg: "Locking. Please wait...")
                }
                _ = self.lockConnectionService.doLock(macAddress: self.selectedBikeMacAddress, delegate: self)
            }
        }else{
            if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
                //Peroform unlock
                self.locationVc?.axaLockConnection?.unlockDevice()
            }else{
                if self.btnPressedPause{
                    self.showLoader(withMsg: "Unlocking. Please wait...")
                }else{
                    self.showLoader(withMsg: "Locking. Please wait...")
                }
                _ = self.lockConnectionService.doUnLock(macAddress: self.selectedBikeMacAddress, delegate: self)
            }
        }
    }
    
    func pickLockImageToFinishRide(cameraType: String){
        
        let rentalImageVC = RentalImageViewController(nibName: "RentalImageViewController", bundle: nil)
        rentalImageVC.locationVc = self.locationVc
        rentalImageVC.lastVc = self.locationVc!
        rentalImageVC.cameraType = cameraType
        self.imagePickerVcPresent = true
        self.locationVc?.present(rentalImageVC, animated: true, completion: nil)
        
    }
    
    func collectionCellForIndex(index: Int)-> PauseRentalCollectionCell?{
        return self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PauseRentalCollectionCell
    }
}

//MARK: - VHSliderButton Delegates
extension RunningRentalView: VHSlideButtonDelegate{
   
   func selectedPosition(position: Postion) {
       if position == .bottom{
        self.locationVc?.finishRentalsView.isHidden = true
        self.locationVc?.btnSlideToFinish.resetSlideButton()
           if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
            if self.locationVc?.axaLockConnection?.peripheralDevice != nil{
                self.locationVc?.axaLockConnection?.centralMannager?.cancelPeripheralConnection((self.locationVc?.axaLockConnection?.peripheralDevice!)!)
               }
            self.locationVc?.axaLockConnection?.centralMannager?.scanForPeripherals(withServices: nil, options: nil)
           }else{
            self.locationVc?.runningRentalView?.lockCommand = "0"
            self.locationVc?.runningRentalView?.showLoader(withMsg: "Locking. Please wait....")
            _ = self.lockConnectionService.doLock(macAddress: self.locationVc?.runningRentalView?.selectedBikeMacAddress ?? "", delegate: self)
           }
       }
   }
}

//MARK: - Web API
extension RunningRentalView{
    
    func changeCard_Web(payment_id : String , cardToken : String, index: Int){
        let param = NSMutableDictionary()
        param["payment_id"] = payment_id
        param["card_token"] = cardToken
        param["ios_version"] = "\(appDelegate.getCurrentAppVersion)"
        APICall.shared.postWeb("change_card", parameters: param, showLoder: true, successBlock: { (response) in
            
            if let Dict = response as? NSDictionary {
                if Dict.object(forKey: "FLAG") as! Bool {
                    StaticClass.sharedInstance.ShowNotification(true, strmsg: Dict.object(forKey: "MESSAGE") as? String ?? "Change Card updated successfully", vc: self.vc)
                } else {
                    StaticClass.sharedInstance.ShowNotification(true, strmsg: Dict.object(forKey: "MESSAGE") as? String ?? "", vc: self.vc)
                }
            }
            
        }) { (error) in
            print(error.localizedDescription ?? "")
        }
    }
    
    func nearestDropZone_Web(){
        let dictParameter = NSMutableDictionary()
        dictParameter.setObject(StaticClass.sharedInstance.latitude, forKey: "latitude" as NSCopying)
        dictParameter.setObject(StaticClass.sharedInstance.longitude, forKey: "longitude" as NSCopying)
        dictParameter.setObject(StaticClass.sharedInstance.strUserId, forKey: "user_id" as NSCopying)
        dictParameter.setObject(Singleton.runningRentalArray[self.selectedRentalIndex]["partner_id"]as? String ?? "", forKey: "partner_id" as NSCopying)
        dictParameter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("available_dropzones", parameters: dictParameter, showLoder: true, successBlock: { (responseObj) in
            
            if let dict = responseObj as? NSDictionary {
                print("available_dropzones response: ", responseObj)
                if dict.object(forKey: "FLAG") as! Bool {
                    let arrList = dict.object(forKey: "Dropzones") as? NSArray
                    if (arrList?.count)! > 0 {
                        let dictionary = arrList?[0] as? NSDictionary
                        self.locationId = dictionary?["id"] as? String ?? ""
                    }
                    self.calculationPrice_Web(isNearBy: true)
                } else {
                    self.penaltyAmount = dict.object(forKey: "Panelty") as? String ?? ""
                    self.calculationPrice_Web(isNearBy: false)
                }
            }
        }) { (error) in
            
        }    }
    
    func calculationPrice_Web(isNearBy: Bool){
        
        let dictParameter = NSMutableDictionary()
        
        let selectedRentalDic = Singleton.runningRentalArray[selectedRentalIndex]
        
        dictParameter.setObject(StaticClass.sharedInstance.strUserId, forKey: "user_id" as NSCopying)
        dictParameter.setValue(isNearBy == true ? 0:1, forKey: "is_penalty")
        dictParameter.setObject(selectedRentalDic["id"]as? String ?? "", forKey: "booking_id" as NSCopying)
        dictParameter.setValue(selectedRentalDic["object_id"]as? String ?? "", forKey: "object_id")
        dictParameter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        print("Calculate Params: ", dictParameter)
        self.hideLoader()
        APICall.shared.postWeb("calculate_price", parameters: dictParameter, showLoder: true, successBlock: { (responseObj) in
            print("calculate_price response: ", responseObj)
            if let Dict = responseObj as? NSDictionary {
                if Dict.object(forKey: "FLAG") as! Bool {
                    
                    self.totalCalulationPrice = String(StaticClass.sharedInstance.getDouble(value:Dict.object(forKey: "total_price") ?? "0.0"))
                    self.totalCalulationMinute = String(StaticClass.sharedInstance.getDouble(value:Dict.object(forKey: "total_min") ?? "0"))
                                        
                    if isNearBy == true {
                        self.finishBooking_Web(strLocation_ID: self.locationId)
                    } else {
                        if Global.appdel.strIsUserType == "1" || Global.appdel.strIsUserType == "2" {
                            self.finishBooking_Web(strLocation_ID: self.locationId)
                        } else {
                            let popup = PopupController
                                .create(self.vc)
                            let container = PaneltyPopupVC.instance()
                            container.partnerId = Singleton.runningRentalArray[self.selectedRentalIndex]["partner_id"]as? String ?? ""
                            container.shareCraditCardOBJ = Singleton.shared.cardListsArray[self.selectedRentalIndex]
                            if self.locationVc?.bikeSharedDataArray.count ?? 0 > 0{
                                container.bikeDataObj = self.locationVc?.bikeSharedDataArray[self.selectedRentalIndex] ?? ShareBikeData()
                            }
                            container.strPenaltyPrice = self.locationVc?.shareDeviceObj.strPenaltyAmount ?? ""
                            container.strLocationID = self.locationId
                            container.runningRentalView = self
                            container.closeHandler = {
                                popup.dismiss()
                            }
                            popup.show(container)
                        }
                    }
                }
            }
        }) { (error) in
            
        }
    }
    
    func finishBooking_Web(strLocation_ID:String) {
        
        self.showLoader(withMsg: "Ending your rental...")
        
        let selectedRentalDic = Singleton.runningRentalArray[selectedRentalIndex]
        self.paymentId = selectedRentalDic["id"]as? String ?? ""
        
        let dictionary = NSMutableDictionary()
        dictionary.setObject(selectedRentalDic["id"]as? String ?? "", forKey: "payment_id" as NSCopying)
        dictionary.setObject(self.isEndingRentalManual, forKey: "manually_end" as NSCopying)
        dictionary.setObject(self.totalCalulationPrice, forKey: "amount" as NSCopying)
        dictionary.setObject(self.iamAtHub ? "1":"0", forKey: "at_hub" as NSCopying)
        dictionary.setObject(self.totalCalulationMinute, forKey: "total_min" as NSCopying)
        dictionary.setObject("\(StaticClass.sharedInstance.latitude)", forKey: "latitude" as NSCopying)
        dictionary.setObject("\(StaticClass.sharedInstance.longitude)", forKey: "longitude" as NSCopying)
        dictionary.setValue("0",forKey:"event")
        dictionary.setObject(self.selectedCard["token_id"]as? String ?? "", forKey: "new_card_token" as NSCopying)
        dictionary.setObject(Global.appdel.strIsUserType , forKey: "user_type" as NSCopying)
        dictionary.setValue("\(self.batteryPercentage)" ,forKey:"battery_life")
        
        if self.locationVc?.shareDeviceObj.strPenaltyAmount ?? "" == "" {
            dictionary.setObject("0", forKey: "is_penalty" as NSCopying)
            dictionary.setObject(strLocation_ID, forKey: "location_id" as NSCopying)
        }else {
            dictionary.setObject("1", forKey: "is_penalty" as NSCopying)
            dictionary.setObject("", forKey: "location_id" as NSCopying)
        }
        if self.iamAtHub{
            dictionary.setObject("0", forKey: "is_penalty" as NSCopying)
        }
        
        dictionary.setObject("2", forKey: "lock_status" as NSCopying)
        dictionary.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        APICall.shared.postWeb("finish_booking", parameters: dictionary, showLoder: false) { (response) in
            
            self.hideLoader()
            if let Dict = response as? NSDictionary {
                if (Dict["BOOKING_RUNNING"] as? String ?? "100") == "1" {
                    Global.appdel.is_rentalRunning = true
                }else{
                    Global.appdel.is_rentalRunning = false
                }
                // PARSE BOOKING COMPLETE DATA
                if Dict.object(forKey: "FLAG") as! Bool {
                    self.endingRentalData = Singleton.runningRentalArray[self.selectedRentalIndex]
                    if self.locationVc?.bikeSharedDataArray.count ?? 0 > 0{
                        if StaticClass.sharedInstance.arrRunningBookingId.contains(self.locationVc?.shareDeviceObj.strBookingID ?? "") {
                            StaticClass.sharedInstance.arrRunningBookingId.remove(self.locationVc?.shareDeviceObj.strBookingID ?? "")
                        }
                        if StaticClass.sharedInstance.arrRunningObjectId.contains(self.locationVc?.bikeSharedDataArray[self.selectedRentalIndex].strId ?? "") {
                            StaticClass.sharedInstance.arrRunningObjectId.remove(self.locationVc?.bikeSharedDataArray[self.selectedRentalIndex].strId ?? "")
                        }
                    }
                    
                    StaticClass.sharedInstance.saveToUserDefaults(StaticClass.sharedInstance.arrRunningBookingId as AnyObject , forKey: Global.g_UserData.BookingIDsArr)
                    StaticClass.sharedInstance.saveToUserDefaults(StaticClass.sharedInstance.arrRunningObjectId  as AnyObject , forKey: Global.g_UserData.ObjectIDsArr)
                    
                    if let result = Dict.object(forKey: "RESULT") as? NSDictionary{
                        Singleton.lastRideSummaryData = result as? [String:Any] ?? [:]
                        
                        StaticClass.sharedInstance.saveToUserDefaults(StaticClass.sharedInstance.strBookingId as AnyObject, forKey: Global.g_UserData.TempBookingID)
                        StaticClass.sharedInstance.saveToUserDefaultsString(value:"" , forKey: Global.g_UserData.BookingID)
                        StaticClass.sharedInstance.saveToUserDefaultsString(value:"" , forKey: Global.g_UserData.ObjectID)
                        
                        if UserDefaults.standard.value(forKey: "isRentalPause") != nil{
                            UserDefaults.standard.removeObject(forKey: "isRentalPause")
                        }
                        
                        if self.iamAtHub{
                            self.paymentId = ""
                            self.locationVc?.loadRentalEndedView(message: self.endingRentalData["object_type"] as? String ?? "0")
                            self.closeView()
                        }else{
                            self.closeView()
                            self.pickLockImageToFinishRide(cameraType: "bike")
                        }
                        
                        if Singleton.runningRentalArray.count > self.selectedRentalIndex{
                            Singleton.order_id = Singleton.runningRentalArray[self.selectedRentalIndex]["id"]as? String ?? ""
                            Singleton.axa_ekey_dictionary = [:]
                            Singleton.runningRentalArray.remove(at: self.selectedRentalIndex)
                            self.collectionView.reloadData()
                        }
                    }
                    
                } else {
                    
                }
            }
        } failure: { (error) in
            self.hideLoader()
            self.lockCommand = "1"
        }
    }
    
    func uploadImgForFinishRide(){
        
        self.is_uploadingImg = true
        let dictionPara = NSMutableDictionary()
        dictionPara.setValue(paymentId, forKey: "payment_id")
        dictionPara.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        dictionPara.setValue("\(self.isCamBroken ? "1" : "0")", forKey: "is_camera_issue")
        
        let Imagearray = NSMutableArray()
        if let img = self.rentalImage {
            Imagearray.add(img)
        }
        APICall.shared.callApiForMultipleImageUpload("rental_image", withParameter: dictionPara, true, withImage: Imagearray, withLoader: true, successBlock: { (response) in
            
            print("rental_image response: ", response)
            self.is_uploadingImg = false
            if self.iamAtHub{
                self.finishBooking_Web(strLocation_ID: self.strLocationID)
            }else{
                self.paymentId = ""
                if Singleton.runningRentalArray.count == 0{
                    // Pass static "2" to show locker rental summary for bike also. //Previous param passed self.endingRentalData["object_type"] as? String ?? "0"
                    self.locationVc?.loadSummaryView(summaryType: self.endingRentalData["object_type"] as? String ?? "0")
                    self.closeView()
                }else{
                    let msg = Singleton.runningRentalArray.count == 1 ? "You have \(Singleton.runningRentalArray.count) ongoing rental":"You have \(Singleton.runningRentalArray.count) ongoing rentals"
                    self.locationVc?.loadCustomAlertWithGradientButtonView(title: "One rental ended!", messageStr: msg, buttonTitle: "Got It")
                    self.locationVc?.searchHome_Web(lat: String(describing: StaticClass.sharedInstance.latitude), long: String(describing: StaticClass.sharedInstance.longitude))
                    self.closeView()
                }
            }
        }) { (error) in
            self.photoErrorOnUpload()
        }
    }
    
}


//MARK: - CollectionView Delegate's
extension RunningRentalView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Singleton.runningRentalArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PauseRentalCollectionCell", for: indexPath)as? PauseRentalCollectionCell{
            cell.vc = self.vc
            cell.runningRentalView = self
            cell.tag = indexPath.row
            cell.setDataOnCell(dataDictionary: Singleton.runningRentalArray[indexPath.row])
            cell.report_btn.tag = indexPath.row
            cell.report_btn.addTarget(self, action: #selector(reportBtnTapped(_:)), for: .touchUpInside)
            cell.arrow_btn.tag = indexPath.row
            cell.arrow_btn.addTarget(self, action: #selector(cardDropDownTapped(_:)), for: .touchUpInside)
            cell.pause_btn.tag = indexPath.row
            cell.pause_btn.addTarget(self, action: #selector(pauseBtnTapped(_:)), for: .touchUpInside)
            cell.end_btn.tag = indexPath.row
            cell.end_btn.addTarget(self, action: #selector(endBtnTapped(_:)), for: .touchUpInside)
            return cell
        }
        return PauseRentalCollectionCell()
    }
    
    @objc func reportBtnTapped(_ sender: UIButton){
        self.selectedRentalIndex = sender.tag
        let vc = ReportVC(nibName: "ReportVC", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        vc.showForRunningRental = true
        self.vc.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @objc func cardDropDownTapped(_ sender: UIButton){
        if Singleton.numberOfCards.count > 1{
            self.selectedRentalIndex = sender.tag
            if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex){
                UIView.animate(withDuration: 0.5) {
                    if self.layout.itemSize.height == (265 + cell.outOfDtextLabel_height.constant){
                        if CGFloat((Singleton.numberOfCards.count - 1) * 40) < 100{
                            cell.cardListTable_height.constant = CGFloat((Singleton.numberOfCards.count - 1) * 40)
                            self.layout.itemSize = CGSize(width: self.collectionView.frame.width - 40, height: CGFloat(((Singleton.numberOfCards.count - 1) * 40) + 320) + cell.outOfDtextLabel_height.constant)
                        }else{
                            cell.cardListTable_height.constant = 100
                            self.layout.itemSize = CGSize(width: self.collectionView.frame.width - 40, height: (100 + 320) + cell.outOfDtextLabel_height.constant)
                        }
                        self.isTableHide = false
                    }else{
                        cell.cardListTable_height.constant = 0
                        self.layout.itemSize = CGSize(width: self.collectionView.frame.width - 40, height: (265 + cell.outOfDtextLabel_height.constant))
                        self.isTableHide = true
                    }
                    self.collectionView_height.constant = CGFloat(self.layout.itemSize.height)
//                    self.layoutIfNeeded()
                } completion: { (_) in
                    self.loadUI()
                }

            }
        }
    }
    
    @objc func pauseBtnTapped(_ sender: UIButton){
        self.selectedRentalIndex = sender.tag
        if Singleton.runningRentalArray[sender.tag]["lock_id"] as? String ?? "" != "6"{
            self.selectedBikeMacAddress = Singleton.runningRentalArray[sender.tag]["device_id"] as? String ?? ""
        }
        self.rentalActionPerformed = 0
        if sender.isSelected{
            // For Unlocking
            self.btnPressedPause = true
            self.pauseResumeEndAlert(action: "resume")
        }else{
            // For Locking
            self.btnPressedPause = false
            if !UserDefaults.standard.bool(forKey: "hide_axa_lock_alert_popup"){
                self.vc.loadRentalAlertView()
            }
        }
    }
    
    @objc func endBtnTapped(_ sender: UIButton){
        self.isEndingRentalManual = 0
        self.selectedRentalIndex = sender.tag
        if Singleton.runningRentalArray[sender.tag]["lock_id"] as? String ?? "" != "6"{
            self.selectedBikeMacAddress = Singleton.runningRentalArray[sender.tag]["device_id"] as? String ?? ""
        }
        self.rentalActionPerformed = 1
        self.pauseResumeEndAlert(action: "end")
    }
}

//MARK: - ScrollView Delegate's
extension RunningRentalView: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        self.selectedRentalIndex = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        print("Index",self.selectedRentalIndex, self.lastSelectedIndex)
        if (self.selectedRentalIndex != self.lastSelectedIndex) && !self.isRentalCellChagned{
            self.isRentalCellChagned = true
            if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex){
                cell.tag = selectedRentalIndex
                UIView.animate(withDuration: 0.05) {
                    if self.isTableHide{
                        cell.cardListTable_height.constant = 0
                        self.layout.itemSize = CGSize(width: self.collectionView.frame.width - 40, height: 265 + cell.outOfDtextLabel_height.constant)
                    }else{
                        cell.cardListTable_height.constant = CGFloat((Singleton.numberOfCards.count - 1) * 40)
                        self.layout.itemSize = CGSize(width: self.collectionView.frame.width - 40, height: CGFloat(((Singleton.numberOfCards.count - 1) * 40) + 320) + cell.outOfDtextLabel_height.constant)
                    }
                    self.collectionView_height.constant = CGFloat(self.layout.itemSize.height + 115)                    
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Scrolling End")
        if scrollView == self.collectionView{
            let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
            let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
            let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
            self.selectedRentalIndex = Int(floor((offset - pageSide / 2) / pageSide) + 1)
            self.lastSelectedIndex = self.selectedRentalIndex
            self.isRentalCellChagned = false
            self.numberOfRentals_lbl.text = "\(selectedRentalIndex + 1)/\(Singleton.runningRentalArray.count)"
            if self.selectedRentalIndex < Singleton.trackLocationRentalArray.count{
                self.totalAmount_lbl.text = "$\(Singleton.trackLocationRentalArray[selectedRentalIndex]["total_price"]as? Double ?? 0.0)"
            }
            if Singleton.runningRentalArray.count > selectedRentalIndex{
                self.strLocationID = Singleton.runningRentalArray[selectedRentalIndex]["location_id"] as? String ?? ""
                self.strBikeKubeID = Singleton.runningRentalArray[selectedRentalIndex]["object_id"] as? String ?? ""
                //                if Singleton.runningRentalArray[self.selectedRentalIndex]["object_type"] as? String ?? "" == "2"{
                //                    self.nearestDropZone_btn.isHidden = false
                //                }else{
                //                    self.nearestDropZone_btn.isHidden = true
                //                }
            }
            if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex){
                cell.tag = selectedRentalIndex
                UIView.animate(withDuration: 0.05) {
                    if self.isTableHide{
                        cell.cardListTable_height.constant = 0
                        self.layout.itemSize = CGSize(width: self.collectionView.frame.width - 40, height: 265 + cell.outOfDtextLabel_height.constant)
                    }else{
                        cell.cardListTable_height.constant = CGFloat((Singleton.numberOfCards.count - 1) * 40)
                        self.layout.itemSize = CGSize(width: self.collectionView.frame.width - 40, height: CGFloat(((Singleton.numberOfCards.count - 1) * 40) + 320) + cell.outOfDtextLabel_height.constant)
                    }
                    self.collectionView_height.constant = CGFloat(self.layout.itemSize.height + 115)
                    self.layoutIfNeeded()
                }
            }
        }
    }
}
////MARK: - Core Bluetooth Delegate's
//extension RunningRentalView: CBCentralManagerDelegate, CBPeripheralDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//
//    }
//
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print(peripheral)
//        if Singleton.runningRentalArray.count > 0{
//            let device_name_array = peripheral.name?.components(separatedBy: ":") ?? []
//            if device_name_array.count > 1{
//                if device_name_array[1] == Singleton.runningRentalArray[self.selectedRentalIndex ]["assets_device_name"]as? String ?? ""{
//                    self.centralMannager?.stopScan()
//                    if self.peripheralDevice != nil{
//                        self.centralMannager?.cancelPeripheralConnection(self.peripheralDevice!)
//                    }
//                    self.connectToPeripheral(identifire: peripheral)
//                }
//            }
//        }
//    }
//
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("Did connect: ", peripheral)
//        self.peripheralDevice = peripheral
//        self.peripheralDevice?.delegate = self
//        self.peripheralDevice?.discoverServices([serviceUUID])
//    }
//
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        print("Central Manager Failed To Connect with Error: ", error ?? "Error nill")
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        print("didDiscoverServices", peripheral, peripheral.services ?? [])
//        for service in peripheral.services ?? [] {
//            print("Discovered service \(service)")
//            // Fiter: Only allow the eRLock UUID's to pass.
//            if service.uuid == (serviceUUID) {
//                peripheral.discoverCharacteristics(nil, for: service)
//            }
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        print("didDiscoverCharacteristicsFor: ", service)
//
//        print(ctrUUID)
//        for char in service.characteristics ?? []{
//            if char.uuid == ctrUUID{
//                self.ctrCharacteristic = char
//            }
//            if char.uuid == stateCharUUID{
//                self.peripheralDevice?.readValue(for: char)
//                self.peripheralDevice?.setNotifyValue(true, for: char)
//            }
//        }
//        if self.ctrCharacteristic != nil{
//            self.loadAxaFunctionality()
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("didWriteValueFor", characteristic)
//        if self.writingEkeyCommand{
//            self.writeCommandArray.removeLast()
//            if self.writeCommandArray.count == 0{
//                self.connectedWithDevice = Singleton.runningRentalArray[self.selectedRentalIndex ]["assets_device_name"]as? String ?? ""
//                self.writingEkeyCommand = false
//                self.sendingCommand = true
//                if self.rentalActionPerformed == 1{
//                    //                    self.lockDevice()
//                }else{
//                    self.performLockUnlock()
//                }
//            }
//        }
//        self.peripheralDevice?.setNotifyValue(true, for: characteristic)
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("didUpdateValueFor", characteristic)
//
//        if characteristic.uuid == stateCharUUID{
//            if let bytes = characteristic.value{
//                let data = characteristic.value?.bytes ?? []
//                print("Bytes -", bytes)
//                if data.count > 0{
//                    print(data[0])
//                    switch data[0] {
//                    case 0x00:
//                        print("Unlocked")
//                        if self.sendingCommand && self.lockStatus == "closed"{
//                            self.sendingCommand = false
//                            self.deviceUnlockedSuccessfully()
//                            self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[self.selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[self.selectedRentalIndex]["id"]as? String ?? "", "command_sent": "1", "command_status": "0", "error_message": "", "device_type": "1"])
//                        }else{
//                            if self.sendingCommand{
//                                self.hideLoader()
//                            }
//                        }
//                        self.lockStatus = "opened"
//                        break
//                    case 0x80:
//                        print("Unlocked 0x08")
//                        break
//                    case 0x01, 0x09:
//                        print("Locked")
//                        if self.sendingCommand{
//                            self.sendingCommand = false
//                            self.counter_timer.invalidate()
//                            self.deviceLockedSuccessfully()
//                            self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[self.selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[self.selectedRentalIndex]["id"]as? String ?? "", "command_sent": "0", "command_status": "0", "error_message": "", "device_type": "1"])
//                        }
//                        self.lockStatus = "closed"
//                        break
//                    case 0x81:
//                        print("Locked 0x81")
//                        break
//                    case 0x08:
//                        print("Waiting for lock")
//                        self.lockStatus = "opened"
//                        self.hideLoader()
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            if self.rentalActionPerformed == 1{
//                                self.showLoader(withMsg: "Pull lock lever down to end rental...")
//                            }else{
//                                self.showLoader(withMsg: "Close lock by pulling lever down...")
//                            }
//                        }
//                        break
//                    default:
//                        break
//                    }
//                }
//            }
//        }
//
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        if  let value = characteristic.value{
//            let data = [UInt8](value)
//            print("didUpdateNotificationStateFor", characteristic, data)
//        }
//    }
//
//}

//MARK: - Linka Delegate's
extension RunningRentalView: LockConnectionServiceDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func onQueryLocked(completionHandler: @escaping (Bool) -> Void) {
        self.hideLoader()
        self.isPause = true
        self.btnPressedPause = true
        self.changeStateOfPauseButton(isLocked: true)
        self.lockConnectionService.disconnectWithExistingController()
        completionHandler(false)
    }
    
    func onQueryUnlocked(completionHandler: @escaping (Bool) -> Void) {
        self.hideLoader()
        self.isPause = false
        self.btnPressedPause = false
        self.changeStateOfPauseButton(isLocked: false)
        self.lockConnectionService.disconnectWithExistingController()
        completionHandler(false)
    }
    
    func onPairingUp() {
        
    }
    
    func onPairingSuccess() {
        
    }
    
    func onScanFound() {
        
    }
    
    func onConnected() {
        
    }
    
    func onBatteryPercent(batteryPercent: Int) {
        
        debugPrint("BatteryPercent is :- \(batteryPercent)")
        let topVC = UIApplication.topViewController()
        
        batteryPercentage = batteryPercent
        if batteryPercent < 15 {
            
            if topVC is Critical_LowBatteryVC  {
            }else{
                self.hideLoader()
                let batteryLow = Critical_LowBatteryVC(nibName: "Critical_LowBatteryVC", bundle: nil)
                batteryLow.is_Critical = true
                Global.appdel.window?.rootViewController?.present(batteryLow, animated: true, completion: nil)
            }
        }
        else if  batteryPercent < 25 && batteryPercent > 15 {
            
            if topVC is Critical_LowBatteryVC {
            }else{
                self.hideLoader()
                let batteryLow = Critical_LowBatteryVC(nibName: "Critical_LowBatteryVC", bundle: nil)
                batteryLow.is_Critical = false
                Global.appdel.window?.rootViewController?.present(batteryLow, animated: true, completion: nil)
            }
        }
    }
    
    func onUnlockStarted() {
        let topVC = UIApplication.topViewController()
        if topVC is BookNowVC  {
            self.showLoader(withMsg: "Unlocking. Please wait...")
        }else{
        }
    }
    
    func onLockStarted() {
        let topVC = UIApplication.topViewController()
        if topVC is BookNowVC  {
            self.showLoader(withMsg: "Locking. Please wait...")
        }else{
        }
    }
    
    func onLock() {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": "0", "command_status": "0", "error_message": "", "device_type": "1"])
        self.deviceLockedSuccessfully()
    }
    
    func onUnlock() {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": "1", "command_status": "0", "error_message": "", "device_type": "1"])
        self.deviceUnlockedSuccessfully()
    }
    
    func errorInternetOff() {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Internet Off", "device_type": "1"])
        self.hideLoader()
        self.vc.alert(title: "Alert", msg: popUpMessage.someWrong.rawValue)
    }
    
    func errorBluetoothOff() {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "", "device_type": "1"])
        self.hideLoader()
        self.vc.alert(title: "Alert", msg: "Please turn on bluetooth for connect lock device.")
    }
    
    func errorAppNotInForeground() {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "App not in foreground", "device_type": "1"])
        self.hideLoader()
        AppDelegate.shared.window?.showBottomAlert(message: "App Not in Foreground")
    }
    
    func errorInvalidAccessToken() {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Invalid access token", "device_type": "1"])
        self.hideLoader()
        _ = LinkaMerchantAPIService.fetch_access_token { (responseObject, error) in
            
            DispatchQueue.main.async(execute: {
                if responseObject != nil {
                    AppDelegate.shared.window?.showBottomAlert(message: "Please try again")
                    return
                } else if error != nil {
                    AppDelegate.shared.window?.showBottomAlert(message: "There is an error while fetching acess token")
                    return
                } else {
                    AppDelegate.shared.window?.showBottomAlert(message: "Please check your connections,bluetooth range")
                    return
                }
            })
        }
        
    }
    
    func errorMacAddress(errorMsg: String) {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Invalid mac address", "device_type": "1"])
        self.hideLoader()
        AppDelegate.shared.window?.showBottomAlert(message: errorMsg)
    }
    
    func errorConnectionTimeout() {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Connection timeout", "device_type": "1"])
        self.hideLoader()
        self.vc.loadCustomAlertWithGradientButtonView(title: "Alert!", messageStr: "Make sure Linka is awake, and not connected to another mobile phone. if this problem persists then turn bluetooth off and on", buttonTitle: "Ok")
    }
    
    func errorScanningTimeout() {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Scaning timeout", "device_type": "1"])
        self.hideLoader()
        self.vc.loadCustomAlertWithGradientButtonView(title: "Alert!", messageStr: "Make sure Linka is awake, and not connected to another mobile phone. if this problem persists then turn bluetooth off and on", buttonTitle: "Ok")
    }
    
    func errorLockMoving(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Lock Movement Detected. Locking blocked. Stabilize the bike and try again", "device_type": "1"])
        self.hideLoader()
        self.vc.showAlertWithOkAndCancelBtn("Locking Blocked", "Lock Movement Detected. Locking blocked. Stabilize the bike and try again", yesBtn_title: "Try Again", noBtn_title: "Cancel") { (response) in
            if response == "ok" {
                tryAgainCompletion(true)
            }else {
                tryAgainCompletion(false)
            }
        }
    }
    
    func errorLockStall(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Lock Stall", "device_type": "1"])
        self.hideLoader()
    }
    
    func errorLockJam() {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error Lock Jam. Lock requires repair", "device_type": "1"])
        AppDelegate.shared.window?.showBottomAlert(message: "Error Lock Jam. Lock requires repair")
        self.hideLoader()
        
        let topVC = UIApplication.topViewController()
        if topVC is ObstacleVC  {
        }else{
            let obstacle = ObstacleVC(nibName: "ObstacleVC", bundle: nil)
            obstacle.checkNotifier = true
            Global.appdel.window?.rootViewController?.present(obstacle, animated: true, completion: nil)
        }
        
    }
    
    func errorUnexpectedDisconnect() {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Unexpected Disconnect", "device_type": "1"])
        AppDelegate.shared.window?.showBottomAlert(message: "Unexpected Disconnect")
        self.hideLoader()
    }
    
    func errorLockingTimeout(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Locking Timeout. Remove obstructions and try again.", "device_type": "1"])
        self.hideLoader()
        self.vc.showAlertWithOkAndCancelBtn("Error!", "Locking Timeout. Remove obstructions and try again.", yesBtn_title: "Try Again", noBtn_title: "Cancel") { (response) in
            if response == "ok" {
                tryAgainCompletion(true)
            }else {
                tryAgainCompletion(false)
            }
        }
    }
    
    func errorUnlockingTimeout(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.vc.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Unlocking Timeout. Remove obstructions and try again.", "device_type": "1"])
        self.hideLoader()
        self.vc.showAlertWithOkAndCancelBtn("Error!", "Unlocking Timeout. Remove obstructions and try again.", yesBtn_title: "Try Again", noBtn_title: "Cancel") { (response) in
            if response == "ok" {
                tryAgainCompletion(true)
            }else {
                tryAgainCompletion(false)
                if self.isPause{
                    self.isEventStatus = "4"
                }else{
                    self.isEventStatus = "3"
                    self.lockCommand = "0"
                    _ = self.lockConnectionService.doLock(macAddress: self.selectedBikeMacAddress, delegate: self)
                }
            }
        }
    }
    
}

//MARK: - Running Rental View
extension UIViewController{
    
    func loadRunningRentalView() -> RunningRentalView{
        if let view = Bundle.main.loadNibNamed("RunningRentalView", owner: nil, options: [:])?.first as? RunningRentalView{
            view.frame = self.view.bounds
            view.vc = self
            view.setCollectionLayout()
            view.registerCell()
            view.loadContent()
            view.runningRentalContainerView.isHidden = true
            view.frame.origin.y += view.frame.height
            self.view.addSubview(view)
            return view
        }
        return RunningRentalView()
    }
    
}
