//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by Tops on 5/1/18.
//  Copyright © 2018 Chirag. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import LinkaAPIKit
import AKSideMenu
import CoreBluetooth
import UPCarouselFlowLayout
import AVFoundation

class QRCodeScaneVC: UIViewController{
    
    //MARK: - Outlet's
    @IBOutlet weak var loaderBgView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var tourch_btn: CustomButton!
    @IBOutlet weak var scannerView: CustomView!
    @IBOutlet weak var animatedLine_Img: UIImageView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var txtEnterKubeBike: UITextField!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var textContentView: UIView!
    @IBOutlet weak var lockGuidContainerView: CustomView!
    @IBOutlet weak var lockGuidContainerView_bottom: NSLayoutConstraint!
    @IBOutlet weak var lockGuidCollectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var dontShowCheck_btn: UIButton!
    @IBOutlet weak var next_btn: UIButton!
    
    //Variable's
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var timer = Timer()
    
    var topTitle:UILabel?
    var isOpenedFlash:Bool = false
    var bottomItemsView:UIView?
    var isLinkaConnected = false
    var isWakeUp = false
    var promoId = ""
    
    let device = ShareDevice()
    let objectDetail = ShareBikeKube()
    var sharedCreditCardObj = shareCraditCard()
    let lockConnectionService : LockConnectionService = LockConnectionService.sharedInstance
    var batteryPercentage = 0
    var isReferralApply = 0
    var selectedObjectId = ""
    
    var lockType: LockType?
    var centralMannager: CBCentralManager?
    var peripheralDevice: CBPeripheral?
    var ctrCharacteristic: CBCharacteristic?
    var lockCommand = "0"
    var tappedConfirmBooking = false
    var axaLockStatus = ""
    var writingEkeyCommand = false
    var writeCommandArray: [Int] = []
    var doQueryCallBack: (()->()) = {}
    var tryUnlockAgain = false
    
    var lockCollectionlayout = UPCarouselFlowLayout()
    fileprivate var cellSize: CGSize {
        let lockCollectionlayout = self.lockGuidCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var cellSize = lockCollectionlayout.itemSize
        if lockCollectionlayout.scrollDirection == .horizontal {
            cellSize.width += lockCollectionlayout.minimumLineSpacing
        } else {
            cellSize.height += lockCollectionlayout.minimumLineSpacing
        }
        return cellSize
    }
    var scannedDevices: [String] = []
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtEnterKubeBike.text = self.selectedObjectId
        self.lockConnectionService.disconnectWithExistingController()
        self.setupCameraView()
        CoreBluetoothClass.sharedInstance.isBluetoothOn(vc: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.registerCollectionCell()
    }
    
    override func viewDidLayoutSubviews() {
        if AppLocalStorage.sharedInstance.application_gradient{
            self.tourch_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.tourch_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.peripheralDevice != nil{
            self.centralMannager?.cancelPeripheralConnection(self.peripheralDevice!)
        }
        self.lockConnectionService.disconnectWithExistingController()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case dontShowCheck_btn:
            if dontShowCheck_btn.tag == 0{
                dontShowCheck_btn.tag = 1
                UserDefaults.standard.set(true, forKey: "qr_dont_show_on_linka_view")
                self.dontShowCheck_btn.setImage(UIImage(named: "checked_blue"), for: .normal)
            }else{
                dontShowCheck_btn.tag = 0
                UserDefaults.standard.set(false, forKey: "qr_dont_show_on_linka_view")
                self.dontShowCheck_btn.setImage(UIImage(named: "unchecked_gray"), for: .normal)
            }
            break
        case next_btn:
            self.hideLockCollection()
        case btnClose:
            Global.appdel.setUpSlideMenuController()
            break
        case tourch_btn:
            if self.tourch_btn.tag == 0 {
                self.tourch_btn.shadow(color: .white, radius: 10, opacity: 0.7)
                self.tourch_btn.tag = 1
            }else {
                self.tourch_btn.removeShadow(Outlet: self.tourch_btn)
                self.tourch_btn.tag = 0
            }
            break
        default:
            break
        }
        
    }
    
    //MARK: - Custom Function's
    func setupCameraView(){
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            self.startAnimating()
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    func startAnimating(){
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (_) in
            self.animatedLine_Img.isHidden = false
            UIView.animate(withDuration: 1, animations: {
                self.animatedLine_Img.frame.origin.y += self.scannerView.frame.height - 10
            }) { (_) in
                UIView.animate(withDuration: 0.9) {
                    self.animatedLine_Img.frame.origin.y = 5
                }
            }
        })
        
    }
    
    func registerCollectionCell(){
        
        self.lockGuidCollectionView.register(UINib(nibName: "GuideCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GuideCollectionCell")
        self.setCollectionLayout()
        self.lockGuidCollectionView.delegate = self
        self.lockGuidCollectionView.dataSource = self
        self.pageController.numberOfPages = Singleton.lockInstructionArray.count
        
    }
    
    func setCollectionLayout(){
        self.lockCollectionlayout.itemSize = CGSize(width: self.lockGuidCollectionView.frame.width - 40, height: self.lockGuidCollectionView.frame.height)
        self.lockCollectionlayout.scrollDirection = .horizontal
        self.lockCollectionlayout.spacingMode = .fixed(spacing: 5)
        self.lockCollectionlayout.sideItemScale = 0.8
        self.lockGuidCollectionView.collectionViewLayout = self.lockCollectionlayout
    }
    
    func showLockCollection(){
        self.lockGuidCollectionView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.lockGuidContainerView_bottom.constant = -20
            self.view.layoutIfNeeded()
        }
    }
    
    func hideLockCollection(){
        self.lockGuidCollectionView.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.lockGuidContainerView_bottom.constant = -370
            self.view.layoutIfNeeded()
        }) { (_) in
            self.loadPriceContainerView(self)
        }
    }
    
    func loadContent(){
        self.lockType = self.objectDetail.lock_id == "6" ? .axa:.linka
        if self.lockType == LockType.axa{
            self.centralMannager = CBCentralManager(delegate: self, queue: nil)
        }else{
            self.loadPriceContainerView(self)
        }
    }
    
    func connectToPeripheral(identifire: CBPeripheral){
        self.peripheralDevice = identifire
        if self.peripheralDevice != nil{
            print("Peripheral Device", self.peripheralDevice!)
            self.getAxaEkeyPasskeyForQrCode_Web(assetId: self.objectDetail.strId) { (response) in
                if response{
                    Singleton.currentIndex = 0
                    self.centralMannager?.connect(self.peripheralDevice!, options: [:])
                }
            }
        }
    }
    
    func loadAxaFunctionality(){
        
        let eKeyArray = Singleton.axa_ekey.components(separatedBy: "-")
        self.writingEkeyCommand = true
        DispatchQueue.global().async {
            for item in eKeyArray{
                if self.ctrCharacteristic != nil{
                    self.writeCommandArray.append(1)
                    let bytes = self.stringToBytes(item)!
                    let data = Data(bytes: bytes, count: bytes.count)
                    self.peripheralDevice?.writeValue(data, for: self.ctrCharacteristic!, type: .withResponse)
                }
            }
        }
    }
    
    func fetchAccessToken(callBack: @escaping(_ response: Bool)-> Void) {
        _ = LinkaMerchantAPIService.fetch_access_token { (responseObject, error) in
            DispatchQueue.main.async(execute: {
                if responseObject != nil {
                    Global().delay(delay: 0.5) {
                        self.loaderBgView.isHidden = false
                        StaticClass.sharedInstance.ShowSpiner()
                        _ = self.lockConnectionService.doQuery(macAddress: Singleton.shared.bikeData.strDeviceID, delegate: self)
                        callBack(true)
                    }
                } else if error != nil {
                    //                    showAlert("There is an error while fetching acess token")
                    AppDelegate.shared.window?.showBottomAlert(message: "There is an error while fetching acess token")
                } else {
                    //                    showAlert("Please check your connections,bluetooth range")
                    AppDelegate.shared.window?.showBottomAlert(message: "Please check your connections,bluetooth range")
                }
            })
        }
    }
    
    @objc func doneButtonClick(){
        self.view.endEditing(false)
        self.selectedObjectId = ""
        CoreBluetoothClass.sharedInstance.isBluetoothOn(vc: self)
    }
    
    func parseQRScannerRespons(detail:[String:Any], outputBlock: @escaping(_ response: Bool) -> Void) {
        
        objectDetail.strId = detail["id"] as? String ?? ""
        objectDetail.strObjUniqueId = detail["unique_id"]as? String ?? ""
        objectDetail.strImg = detail["image"] as? String ?? ""
        objectDetail.strName = detail["name"] as? String ?? ""
        objectDetail.strBikeName = detail["bike_number"] as? String ?? ""
        objectDetail.booking_object_type = detail["booking_object_type"] as? String ?? "0"
        objectDetail.booking_object_sub_type = detail["booking_object_sub_type"]as? String ?? "0"
        StaticClass.sharedInstance.saveToUserDefaultsString(value:objectDetail.strId, forKey: Global.g_UserData.ObjectID)
        
        objectDetail.doublePrice = StaticClass.sharedInstance.getDouble(value: detail["object_name"] as? String ?? "0")
        objectDetail.strDistance = detail["object_name"] as? String ?? ""
        objectDetail.strAddress = detail["address"] as? String ?? ""
        objectDetail.intType = Int(StaticClass.sharedInstance.getDouble(value: detail["booking_object_type"] as? String ?? "0"))
        objectDetail.strDeviceID = detail["device_id"] as? String ?? ""
        Singleton.shared.bikeData.strDeviceID = objectDetail.strDeviceID
        objectDetail.strPartnerID = detail["partner_id"] as? String ?? ""
        StaticClass.sharedInstance.saveToUserDefaultsString(value:objectDetail.strPartnerID, forKey: Global.g_UserData.PartnerID)
        
        objectDetail.strBooked = detail["is_booked"] as? String ?? ""
        objectDetail.strLatitude = StaticClass.sharedInstance.getDouble(value: detail["latitude"] as? String ?? "0")
        objectDetail.strLongitude = StaticClass.sharedInstance.getDouble(value: detail["longitude"] as? String ?? "0")
        objectDetail.strLocationID = detail["location_id"] as? String ?? ""
        objectDetail.is_outof_dropzone = Int(String(describing: detail["is_outof_dropzone"]!)) ?? -1
        objectDetail.outOfDropzoneMsg = detail["outof_dropzone_message"]as? String ?? ""
        objectDetail.strLocationName = detail["location_name"] as? String ?? ""
        objectDetail.price_per_hour = detail["price_per_hour"]as? String ?? ""
        objectDetail.rental_fee = detail["rental_fee"]as? String ?? ""
        objectDetail.duration_for_rental_fee = detail["duration_for_rental_fee"]as? String ?? ""
        objectDetail.promotional = detail["promotional"]as? String ?? ""
        objectDetail.promotional_header = detail["promotional_header"]as? String ?? ""
        objectDetail.promotional_hours = detail["promotional_hours"]as? String ?? ""
        objectDetail.show_member_button = detail["show_member_button"]as? String ?? ""
        objectDetail.partner_name = detail["partner_name"]as? String ?? ""
        objectDetail.lock_id = detail["lock_id"]as? String ?? ""
        objectDetail.device_name = detail["axa_device_name"]as? String ?? ""
        self.device.arrBikes.add(objectDetail)
        outputBlock(true)
        
    }
    
    func errorInLock(_ msg: String = "Error while unlocking the lock please"){
        if self.tryUnlockAgain{
            self.cancelRental_Web(paymentId: StaticClass.sharedInstance.retriveFromUserDefaultsStrings(key: Global.g_UserData.BookingID) ?? "") { (response) in
                if response{
                    Global.appdel.setUpSlideMenuController()
                }
            }
        }else{
            let customAlertView = self.loadCustomAlertWithOkCancelBtn(title: "Alert", msg: "\(msg) try again or cancel the rental, you won't be charged if you cancel the rental.", okBtnTitle: "Try again", cancelBtnTitle: "Cancel rental")
            customAlertView.okCallBack = {
                self.tryUnlockAgain = true
                self.lockConnectionService.disconnectWithExistingController()
                self.fetchAccessToken { (_) in
                    self.loaderBgView.isHidden = false
                    StaticClass.sharedInstance.ShowSpiner()
                    _ = self.lockConnectionService.doUnLock(macAddress: Singleton.shared.bikeData.strDeviceID, delegate: self)
                }
            }
            customAlertView.cancelCallBack = {
                self.cancelRental_Web(paymentId: StaticClass.sharedInstance.retriveFromUserDefaultsStrings(key: Global.g_UserData.BookingID) ?? "") { (response) in
                    if response{
                        Global.appdel.setUpSlideMenuController()
                    }
                }
            }
            self.captureSession.startRunning()
        }
    }
}

//MARK: - QR Code Scanner Delegete's
extension QRCodeScaneVC: AVCaptureMetadataOutputObjectsDelegate{
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print(code)
        self.txtEnterKubeBike.text = code
        self.timer.invalidate()
        self.animatedLine_Img.isHidden = true
        Global.appdel.setupLocationManager()
        self.getBikeDetail_Web(strBikeName: code)
    }
}

//MARK: - Check Bluetooth Delegate's
extension QRCodeScaneVC: CheckBluetoothStatusDelegate{
    func response(status: Bool) {
        if status{
            if self.selectedObjectId != ""{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.getBikeDetail_Web(strBikeName: self.selectedObjectId)
                }
            }else{
                let strText = txtEnterKubeBike.text?.trimmingCharacters(in: .whitespaces)
                if strText != "" {
                    self.txtEnterKubeBike.isUserInteractionEnabled = false
                    self.getBikeDetail_Web(strBikeName: txtEnterKubeBike.text!)
                }
            }
        }else{
            let alert = UIAlertController(title: "Alert", message: "Please turn on bluetooth to start your rental.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - Text Field Delegate's
extension QRCodeScaneVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.txtEnterKubeBike.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        self.doneButtonClick()
    }
}


extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

//MARK: - Web Api's
extension QRCodeScaneVC {
    
    func getBikeDetail_Web(strBikeName:String) {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                let alert = UIAlertController(title: "Alert", message: "Please turn on location service to start your rental.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            @unknown default:
                break
            }
        } else {
            print("Location services are not enabled")
            let alert = UIAlertController(title: "Alert", message: "Please turn on location service to start your rental.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if StaticClass.sharedInstance.latitude != 0  && StaticClass.sharedInstance.latitude != 0 {
            
            let paramer: NSMutableDictionary = NSMutableDictionary()
            
            paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
            paramer.setValue(self.isReferralApply, forKey: "is_referral_use_by_user")
            paramer.setValue(strBikeName, forKey: "assets_number")
            paramer.setValue("\(StaticClass.sharedInstance.latitude)", forKey: "current_latitude")
            paramer.setValue("\(StaticClass.sharedInstance.longitude)", forKey: "current_longitude")
            paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
            self.loaderBgView.isHidden = false
            APICall.shared.postWeb("bike_qr_detail", parameters: paramer , showLoder: true, true, successBlock: { (response) in
                self.loaderBgView.isHidden = true
                print("bike_qr_detail response", response)
                self.txtEnterKubeBike.isUserInteractionEnabled = true
                if let dict = response as? NSDictionary {
                    if (dict["FLAG"] as! Bool){
                        if let objectArr = dict["OBJECT_DETAILS"] as? [[String:Any]] , objectArr.count > 0 {
                            self.parseQRScannerRespons(detail: objectArr[0]) { (response) in
                                self.loadContent()
                            }
                        }
                    } else {
                        if let is_maintenance = dict["IS_MAINTENANCE"]as? Int, is_maintenance == 1{
                            self.loadCustomAlertWithGradientButtonView(title: "", messageStr: dict["MESSAGE"] as? String ?? "", buttonTitle: "Got It")
                        }else if let is_reserved = dict["IS_RESERVED"]as? Int, is_reserved == 1{
                            self.loadCustomAlertWithGradientButtonView(title: dict["MESSAGE_TITLE"] as? String ?? "", messageStr: dict["MESSAGE"] as? String ?? "", buttonTitle: "Ok")
                        }else{
                            StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
                        }
                    }
                }
            }) { (error) in
                self.loaderBgView.isHidden = true
                self.txtEnterKubeBike.isUserInteractionEnabled = true
                StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "", vc: self)
            }
        }else{
            self.txtEnterKubeBike.isUserInteractionEnabled = true
            let alert = UIAlertController(title: "Alert", message: "Please turn on location service to start your rental.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func objectReservationApiCall(strObjectId:String) {
        
        let dictParam : NSMutableDictionary = NSMutableDictionary()
        
        dictParam.setValue(StaticClass.sharedInstance.strUserId ,forKey:"user_id")
        dictParam.setValue(strObjectId, forKey: "object_id");
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        self.loaderBgView.isHidden = false
        APICall.shared.postWeb("object_reserved", parameters: dictParam , showLoder: true, true, successBlock: { (responseObj) in
            self.loaderBgView.isHidden = true
            if let dict = responseObj as? NSDictionary {
                if (dict["IS_ACTIVE"] as! Bool){
                    if (dict["FLAG"] as! Bool){
                        Global.appdel.strIsUserType = dict["user_type"] as? String ?? "0"
                        if self.lockType == LockType.axa{
                            self.objectBookingAPI_Called()
                        }else{
                            self.fetchAccessToken { (_) in
                                self.loaderBgView.isHidden = false
                                StaticClass.sharedInstance.ShowSpiner()
                                _ = self.lockConnectionService.doQuery(macAddress: Singleton.shared.bikeData.strDeviceID, delegate: self)
                            }
                        }
                    } else {
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
                    }
                } else {

                }
            }
        }) { (error) in
            self.loaderBgView.isHidden = true
        }
    }
    
    func objectBookingAPI_Called() {
        
        let dictParameter = NSMutableDictionary()
        
        dictParameter.setValue(StaticClass.sharedInstance.strUserId ,forKey:"user_id")
        dictParameter.setValue(objectDetail.strId, forKey: "object_id")
        dictParameter.setValue(objectDetail.booking_object_type, forKey: "object_type")
        dictParameter.setValue(objectDetail.booking_object_sub_type, forKey: "object_sub_type")
        dictParameter.setValue(sharedCreditCardObj.token_id ,forKey:"card_token")
        dictParameter.setValue(objectDetail.is_outof_dropzone, forKey: "is_outof_dropzone")
        dictParameter.setValue(self.isReferralApply, forKey: "is_referral_use_by_user")
        dictParameter.setValue(self.promoId, forKey: "promo_id")
        dictParameter.setValue(self.objectDetail.strLocationID ,forKey:"location_id")
        
        let strLat = "\(StaticClass.sharedInstance.latitude)"
        let strLong = "\(StaticClass.sharedInstance.longitude)"
        
        dictParameter.setValue(strLat ,forKey:"latitude")
        dictParameter.setValue(strLong,forKey:"longitude")
        dictParameter.setValue("0",forKey:"event")
        dictParameter.setValue("0" ,forKey:"lock_status")
        dictParameter.setValue("\(self.batteryPercentage)" ,forKey:"battery_life")
        dictParameter.setValue(Global.appdel.strIsUserType, forKey: "user_type")
        dictParameter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        self.loaderBgView.isHidden = false
        APICall.shared.postWeb("object_book", parameters: dictParameter , showLoder: true, true, successBlock: { (response) in
            self.loaderBgView.isHidden = true
            StaticClass.sharedInstance.HideSpinner()
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool) {
                    
                    if let intBookingID = dict["BOOKING_ID"] as? Int {
                        if intBookingID != 0 {
                            StaticClass.sharedInstance.saveToUserDefaultsString(value: "\(intBookingID)", forKey: Global.g_UserData.BookingID)
                        }
                    }
                    StaticClass.sharedInstance.saveToUserDefaults(self.objectDetail.strId as AnyObject , forKey: Global.g_UserDefaultKey.ObjectiIdList)
                    self.lockCommand = "1"
                    if self.lockType == LockType.axa{
                        if self.axaLockStatus == "closed"{
                            if self.ctrCharacteristic != nil{
                                let strArray = Singleton.axa_passkey.components(separatedBy: "-")
                                let bytes = self.stringToBytes(strArray[Singleton.currentIndex])!
                                let data = Data(bytes: bytes, count: bytes.count)
                                self.peripheralDevice?.writeValue(data, for: self.ctrCharacteristic!, type: .withResponse)
                                Singleton.currentIndex += 1
                                self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "0", "error_message": "", "device_type": "1"])
                            }else{
                                print("Characteristic nill")
                                self.cancelRental_Web(paymentId: StaticClass.sharedInstance.retriveFromUserDefaultsStrings(key: Global.g_UserData.BookingID) ?? "") { (response) in
                                    if response{
                                        Global.appdel.setUpSlideMenuController()
                                    }
                                }
                            }
                        }else{
                            self.lockUnlock_Web(assetId: self.objectDetail.strId) { (response) in
                                UserDefaults.standard.setValue(1, forKey: "isRentalPause")
                                Global.appdel.setUpSlideMenuController()
                            }
                        }
                    }else{
                        _ = self.lockConnectionService.doUnLock(macAddress: Singleton.shared.bikeData.strDeviceID, delegate: self)
                    }
                    
                } else {
                    
                }
            }
        }) { (error) in
            self.loaderBgView.isHidden = true
        }
    }
    
    func getAxaEkeyPasskeyForQrCode_Web(assetId: String, outputBlock: @escaping(_ response: Bool)-> Void){
        let params: NSMutableDictionary = NSMutableDictionary()
        params.setValue(StaticClass.sharedInstance.strUserId, forKey: "id")
        params.setValue("0", forKey: "parent_id")
        params.setValue(assetId, forKey: "object_id")
        params.setValue("otp", forKey: "passkey_type")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        APICall.shared.postWeb("update_ekey", parameters: params, showLoder: false, successBlock: { (response) in
            if let status = response["FLAG"]as? Int, status == 1{
                if let assets_detail = response["ASSETS_DETAIL"]as? [String:Any]{
                    if let ekey = assets_detail["axa_ekey"]as? String{
                        Singleton.axa_ekey = ekey
                    }
                    if let passkey = assets_detail["axa_passkey"]as? String{
                        Singleton.axa_passkey = passkey
                    }
                    if Singleton.axa_ekey != "" && Singleton.axa_passkey != ""{
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
            StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "")
        }
    }
    
}

//MARK: - Lock Connection Delegate's
extension QRCodeScaneVC: LockConnectionServiceDelegate  {
    
    func onQueryLocked(completionHandler: @escaping (Bool) -> Void) {
        print("onQueryLocked")
        if self.batteryPercentage > 25{
            Global().delay(delay: 0.1) {
                self.objectBookingAPI_Called()
            }
        }else{
            self.loaderBgView.isHidden = true
            StaticClass.sharedInstance.HideSpinner()
            self.captureSession.startRunning()
        }
        self.lockConnectionService.disconnectWithExistingController()
        completionHandler(false)
    }
    
    func onQueryUnlocked(completionHandler: @escaping (Bool) -> Void) {
        print("onQueryUnlocked")
        if self.batteryPercentage > 25{
            Global().delay(delay: 0.1) {
                self.objectBookingAPI_Called()
            }
        }else{
            self.loaderBgView.isHidden = true
            StaticClass.sharedInstance.HideSpinner()
            self.captureSession.startRunning()
        }
        self.lockConnectionService.disconnectWithExistingController()
        completionHandler(false)
    }
    
    func onPairingUp() {
        print("onPairingUp")
        //        showAlert("Pairing...")
        //        AppDelegate.shared.window?.showBottomAlert(message: "Pairing...")
    }
    
    func onPairingSuccess() {
        print("onPairingSuccess")
        //        showAlert("Scanning… Press Power Button on LINKA")
        //        AppDelegate.shared.window?.showBottomAlert(message: "Scanning… Press Power Button on LINKA")
    }
    
    func onScanFound() {
        print("onScanFound")
        self.loaderBgView.isHidden = false
        StaticClass.sharedInstance.ShowSpiner()
        //        showAlert("Connecting...")
        //        AppDelegate.shared.window?.showBottomAlert(message: "Connecting...")
    }
    
    func onConnected() {
        print("onConnected")
        //        showAlert("Connected...")
        //        AppDelegate.shared.window?.showBottomAlert(message: "Connected...")
        isLinkaConnected = true
        //        second = 0
    }
    
    func onBatteryPercent(batteryPercent: Int) {
        print("BatteryPercent is :- \(batteryPercent)")
        self.batteryPercentage = batteryPercent
        if self.batteryPercentage < 15 {
            self.loaderBgView.isHidden = true
            StaticClass.sharedInstance.HideSpinner()
            let batteryLow = Critical_LowBatteryVC(nibName: "Critical_LowBatteryVC", bundle: nil)
            batteryLow.is_Critical = true
            Global.appdel.window?.rootViewController?.present(batteryLow, animated: true, completion: nil)
        }else if  self.batteryPercentage <= 25 && self.batteryPercentage >= 15 {
            self.loaderBgView.isHidden = true
            StaticClass.sharedInstance.HideSpinner()
            let batteryLow = Critical_LowBatteryVC(nibName: "Critical_LowBatteryVC", bundle: nil)
            batteryLow.is_Critical = false
            Global.appdel.window?.rootViewController?.present(batteryLow, animated: true, completion: nil)
        }else{
            
        }
        
    }
    
    func onUnlockStarted() {
        print("onUnlockStarted")
        self.loaderBgView.isHidden = false
        StaticClass.sharedInstance.ShowSpiner()
    }
    
    func onLockStarted() {
        print("onLockStarted")
        //        showAlert("Locking...")
        //        AppDelegate.shared.window?.showBottomAlert(message: "Locking...")
    }
    
    func onLock() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "0", "error_message": "", "device_type": "1"])
        //        showAlert("Lock Success")
        //        AppDelegate.shared.window?.showBottomAlert(message: "Lock Success")
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
    }
    
    func onUnlock() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "0", "error_message": "", "device_type": "1"])
        lockUnlock_Web(assetId: self.objectDetail.strId) { (response) in
            UserDefaults.standard.setValue(1, forKey: "isRentalPause")
            Global.appdel.setUpSlideMenuController()
        }
    }
    
    func errorInternetOff() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error Internet Off", "device_type": "1"])
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
    }
    
    func errorBluetoothOff() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error Bluetooth Off", "device_type": "1"])
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
    }
    
    func errorAppNotInForeground() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error App Not In Foreground", "device_type": "1"])
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
    }
    
    func errorInvalidAccessToken() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "There is an error while fetching acess token", "device_type": "1"])
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
    }
    
    func errorMacAddress(errorMsg: String) {
        print("errorMacAddress")
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": errorMsg, "device_type": "1"])
    }
    
    func errorConnectionTimeout() {
        print("errorConnectionTimeout")
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
        self.captureSession.startRunning()
        self.loadCustomAlertWithGradientButtonView(title: "Alert!", messageStr: "Make sure Linka is awake, and not connected to another mobile phone. if this problem persists then turn bluetooth off and on", buttonTitle: "Ok")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Connection Timeout", "device_type": "1"])
    }
    
    func errorScanningTimeout() {
        print("errorScanningTimeout")
        self.captureSession.startRunning()
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
        self.loadCustomAlertWithGradientButtonView(title: "Alert!", messageStr: "Make sure Linka is awake, and not connected to another mobile phone. if this problem persists then turn bluetooth off and on", buttonTitle: "Ok")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Scaning Timeout", "device_type": "1"])
    }
    
    func errorLockMoving(tryAgainCompletion: @escaping (Bool) -> Void) {
        print("errorLockMoving")
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
        self.errorInLock("Lock movement detected. locking blocked. please")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Lock Movement Detected. Locking blocked. Stabilize the bike and try again", "device_type": "1"])
    }
    
    func errorLockStall(tryAgainCompletion: @escaping (Bool) -> Void) {
        print("errorLockStall")
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
        self.errorInLock("Error lock stall. please")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error Lock Stall", "device_type": "1"])
    }
    
    func errorLockJam() {
        print("errorLockJam")
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
        self.errorInLock("Error lock jam. lock requires repair. please")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error Lock Jam. Lock requires repair", "device_type": "1"])
    }
    
    func errorUnexpectedDisconnect() {
        print("errorUnexpectedDisconnect")
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Unexpected Disconnect", "device_type": "1"])
    }
    
    func errorLockingTimeout(tryAgainCompletion: @escaping (Bool) -> Void) {
        print("errorLockingTimeout")
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Locking Timeout. Remove obstructions and try again.", "device_type": "1"])
    }
    
    func errorUnlockingTimeout(tryAgainCompletion: @escaping (Bool) -> Void) {
        print("errorUnlockingTimeout")
        self.loaderBgView.isHidden = true
        StaticClass.sharedInstance.HideSpinner()
        self.errorInLock("Unlocking timeout. remove obstructions and")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Unlocking Timeout. Remove obstructions and try again.", "device_type": "1"])
    }
    
}

//MARK: - CBCentralManager & CBPeripheralManager Delegate's
extension QRCodeScaneVC: CBCentralManagerDelegate, CBPeripheralDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loaderBgView.isHidden = false
                StaticClass.sharedInstance.ShowSpiner()
            }
            self.centralMannager?.scanForPeripherals(withServices: nil, options: nil)
            _ = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (_) in
                self.centralMannager?.stopScan()
                if self.peripheralDevice == nil && !self.isLinkaConnected{
                    AppDelegate.shared.window?.showBottomAlert(message: "Please make sure asset is near by you and not connected to another device.")
                    self.loaderBgView.isHidden = true
                    StaticClass.sharedInstance.HideSpinner()
                }
            })
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let filter = self.scannedDevices.filter({$0 == peripheral.name})
        if filter.count == 0{
            self.scannedDevices.append(peripheral.name ?? "")
        }
        let device_name_array = peripheral.name?.components(separatedBy: ":") ?? []
        print("Array", device_name_array)
        if device_name_array.count > 1{
            if device_name_array[1] == self.objectDetail.device_name{
                self.centralMannager?.stopScan()
                self.connectToPeripheral(identifire: peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Did connect")
        self.peripheralDevice = peripheral
        self.peripheralDevice?.delegate = self
        self.peripheralDevice?.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Central Manager Failed To Connect with Error: ", error ?? "Error nill")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            // Fiter: Only allow the eRLock UUID's to pass.
            if service.uuid == (serviceUUID) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        if peripheral.services?.count == 0{
            self.alertBox("Warning", "No service found on this device") {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor: ", service)
        
        print(ctrUUID)
        for char in service.characteristics ?? []{
            if char.uuid == ctrUUID{
                self.ctrCharacteristic = char                
            }
            if char.uuid == stateCharUUID{
                self.peripheralDevice?.readValue(for: char)
                self.peripheralDevice?.setNotifyValue(true, for: char)
            }
        }
        if self.ctrCharacteristic != nil{
            self.loadAxaFunctionality()
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueFor", characteristic)
        if self.writingEkeyCommand{
            self.writeCommandArray.removeLast()
            if self.writeCommandArray.count == 0{
                self.writingEkeyCommand = false
                self.loaderBgView.isHidden = true
                StaticClass.sharedInstance.HideSpinner()
                self.loadPriceContainerView(self)
            }
        }
        self.peripheralDevice?.setNotifyValue(true, for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor", characteristic)
        
        if characteristic.uuid == stateCharUUID{
            if let bytes = characteristic.value{
                let data = characteristic.value?.bytes ?? []
                print("Bytes -", bytes)
                if data.count > 0{
                    print(data[0])
                    switch data[0] {
                    case 0x00:
                        print("Unlocked")
                        self.axaLockStatus = "opened"
                        if self.tappedConfirmBooking{
                            lockUnlock_Web(assetId: self.objectDetail.strId) { (response) in
                                UserDefaults.standard.setValue(1, forKey: "isRentalPause")
                                Global.appdel.setUpSlideMenuController()
                            }
                        }
                        break
                    case 0x80:
                        print("Unlocked")
                        self.axaLockStatus = "opened"
                        break
                    case 0x01, 0x09:
                        print("Locked")
                        self.axaLockStatus = "closed"
                        break
                    case 0x81:
                        print("Locked")
                        self.axaLockStatus = "closed"
                        break
                    case 0x08:
                        print("Waiting for lock")
                        break
                    default:
                        break
                    }
                }
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if  let value = characteristic.value{
            let data = [UInt8](value)
            print("didUpdateNotificationStateFor", characteristic, data)
        }
    }
    
}

//MARK: - CollectionView Delegate's
extension QRCodeScaneVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Singleton.lockInstructionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.lockGuidCollectionView.dequeueReusableCell(withReuseIdentifier: "GuideCollectionCell", for: indexPath)as! GuideCollectionCell
        cell.titleContainerView.backgroundColor = CustomColor.primaryColor
        let data = Singleton.lockInstructionArray[indexPath.row]
        cell.title_lbl.text = data["assets_name"]as? String ?? ""
        DispatchQueue.main.async {
            if let url = URL(string: data["first_image"]as? String ?? ""){
                cell.lock_img.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
            }
        }
        cell.description_lbl.text = data["title"]as? String ?? ""
        return cell
    }
    
}

