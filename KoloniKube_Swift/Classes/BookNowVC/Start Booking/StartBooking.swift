//
//  StartBooking.swift
//  KoloniKube_Swift
//
//  Created by Tops on 15/03/21.
//  Copyright © 2021 Self. All rights reserved.
//

import Foundation
import LinkaAPIKit
import CoreBluetooth
import OcsSmartLibrary

class StartBooking: UIViewController{
    
    static var sharedInstance: StartBooking!
    var spinner = AnimatedCircularView()
    var spinnerView = UIView()
    var assetId = ""
    var viewController: UIViewController?
    let objectDetail = ShareBikeKube()
    var sharedCreditCardDetail = shareCraditCard()
    let device = ShareDevice()
    var lockType: LockType?
    var lockCommand = "0"
    var tappedConfirmBooking = false
    var axaLockStatus = ""
    var writingEkeyCommand = false
    var writeCommandArray: [Int] = []
    var scannedDevices: [String] = []
    var batteryPercentage = 50
    var isReferralApply = 0
    var promoCode = ""
    var tryUnlockAgain = false
    
    //Axa Lock
    var centralMannager: CBCentralManager?
    var peripheralDevice: CBPeripheral?
    var ctrCharacteristic: CBCharacteristic?
    //Linka Lock
    let lockConnectionService : LockConnectionService = LockConnectionService.sharedInstance
    var isLinkaConnected = false
    //OCS Lock
    var lock: OcsLock!
    var license: License!
    var extendedLicense: ExtendedLicense!
    var extendedLicenseFrame = ""
    var userCode = ""
    var isConfiguring = false
    
    
    //MARK: - Custom Function's
    func initialize(vc: UIViewController, asset_id: String, refferalApply: Int, shareCraditCard: shareCraditCard){
        type(of: self).sharedInstance = self
        self.viewController = vc
        self.isReferralApply = refferalApply
        self.assetId = asset_id
        self.sharedCreditCardDetail = shareCraditCard
        self.getBikeQrDetail()
        self.startSpinner()
    }
    
    func deinitialize(){
        if self.lockType == LockType.axa{
            if self.peripheralDevice != nil{
                self.centralMannager?.cancelPeripheralConnection(self.peripheralDevice!)
                self.centralMannager = nil
            }
        }else{
            self.lockConnectionService.disconnectWithExistingController()
        }
    }
    
    func startSpinner(){
        self.spinnerView.frame = (appDelegate.window?.bounds)!
        self.spinnerView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.spinner.frame = (appDelegate.window?.bounds)!
        self.spinner.showSpiner(message: "", labelColor: .white) //Starting your rental...
        self.viewController?.view.addSubview(spinnerView)
        self.viewController?.view.addSubview(spinner)
    }
    
    func hideSpinner(){
        self.spinnerView.removeFromSuperview()
        self.spinner.removeFromSuperview()
        self.spinner.hideSpinner()
    }
    
    func fetchAccessToken(callBack: @escaping(_ response: Bool)-> Void) {
        _ = LinkaMerchantAPIService.fetch_access_token { (responseObject, error) in
            DispatchQueue.main.async(execute: {
                if responseObject != nil {
                    callBack(true)
                } else if error != nil {
                    AppDelegate.shared.window?.showBottomAlert(message: "There is an error while fetching acess token")
                } else {
                    AppDelegate.shared.window?.showBottomAlert(message: "Please check your connections,bluetooth range")
                }
            })
        }
    }
    func loadOcsLock(){
        OcsSmartManager.sharedInstance.startScanMaintenance(timeoutSec: 3, scanDelegate: self, scanType: .MAINTENANCE)
    }
    
    func generateExtenedLicense(code: String){
        self.userCode = code
        DispatchQueue.main.async {
            do{
                let asset = NSDataAsset(name: "ocs_license", bundle: Bundle.main)
                let bytes = [UInt8](asset!.data)
                self.extendedLicense = try ExtendedLicense.getLicense(license: Array(bytes).data.hexEncodedString())
                
                if self.objectDetail.ocs_master_code != ""{
                    try self.extendedLicense.setMasterCode(masterCode: self.objectDetail.ocs_master_code)
                }else{
                    self.showTopPop(message: "No master code found for this lcoker, try other locker", response: false)
                    return
                }
                print(self.objectDetail.ocs_master_code, self.userCode)
                self.extendedLicenseFrame = try self.extendedLicense.generateConfigForDedicatedLock(
                    lockNumber: Int(self.lock.getLockNumber()),
                    newMasterCode: self.objectDetail.ocs_master_code,
                    userCode: self.userCode,
                    blockKeypad: true,
                    buzzerOn: true,
                    ledType: Led.LED_ON_TYPE,
                    expirationDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
                    automaticClosing: false)
                self.configureLock()
            }catch let err{
                print("Error catch block: ", err)
            }
        }
    }
    
    func configureLock(){
        self.isConfiguring = true
        OcsSmartManager.sharedInstance.stopScan()
        OcsSmartManager.sharedInstance.connectAndSend(ocsLock: self.lock, connectionTimeoutSec: 6, communicationTimeoutSec: 10, frame: self.extendedLicenseFrame, callback: self)
    }
    
    func configured(){
        DispatchQueue.main.async {
            do{
                let licenseString = try self.extendedLicense.getUserFrameDedicatedLocksString(dedicatedlocks: [Int(self.lock.getLockNumber())], userCode: self.userCode)
                self.license = try License.getLicense(license: licenseString)
                self.lockOcsLock()
            }catch let err {
                print(err.localizedDescription)
            }
        }
    }
    
    func lockOcsLock() {
        if self.lock.getLockStatus() == LockStatus.OPEN {
            self.objectBookingAPI_Called()
        } else {
            self.startSpinner()
            self.isConfiguring = false
            OcsSmartManager.sharedInstance.reconnectAndSendToNode(withTag: self.lock.getTag(), connectionTimeoutSec: 6, communicationTimeoutSec: 10, frame: self.license.getFrame(), callback: self)
        }
    }
    
    func parseJsonData(detail:[String:Any], outputBlock: @escaping(_ response: Bool) -> Void) {
        
        StartBooking.sharedInstance.objectDetail.strId = detail["id"] as? String ?? ""
        StartBooking.sharedInstance.objectDetail.strObjUniqueId = detail["unique_id"]as? String ?? ""
        StartBooking.sharedInstance.objectDetail.strImg = detail["image"] as? String ?? ""
        StartBooking.sharedInstance.objectDetail.strName = detail["name"] as? String ?? ""
        StartBooking.sharedInstance.objectDetail.strBikeName = detail["bike_number"] as? String ?? ""
        StartBooking.sharedInstance.objectDetail.booking_object_type = detail["booking_object_type"] as? String ?? "0"
        StartBooking.sharedInstance.objectDetail.booking_object_sub_type = detail["booking_object_sub_type"]as? String ?? "0"
        StaticClass.sharedInstance.saveToUserDefaultsString(value:StartBooking.sharedInstance.objectDetail.strId, forKey: Global.g_UserData.ObjectID)
        
        StartBooking.sharedInstance.objectDetail.doublePrice = StaticClass.sharedInstance.getDouble(value: detail["object_name"] as? String ?? "0")
        StartBooking.sharedInstance.objectDetail.strDistance = detail["object_name"] as? String ?? ""
        StartBooking.sharedInstance.objectDetail.strAddress = detail["address"] as? String ?? ""
        StartBooking.sharedInstance.objectDetail.intType = Int(StaticClass.sharedInstance.getDouble(value: detail["booking_object_type"] as? String ?? "0"))
        StartBooking.sharedInstance.objectDetail.strDeviceID = detail["device_id"] as? String ?? ""
        Singleton.shared.bikeData.strDeviceID = StartBooking.sharedInstance.objectDetail.strDeviceID
        StartBooking.sharedInstance.objectDetail.strPartnerID = detail["partner_id"] as? String ?? ""
        StaticClass.sharedInstance.saveToUserDefaultsString(value:StartBooking.sharedInstance.objectDetail.strPartnerID, forKey: Global.g_UserData.PartnerID)
        
        StartBooking.sharedInstance.objectDetail.strBooked = detail["is_booked"] as? String ?? ""
        StartBooking.sharedInstance.objectDetail.strLatitude = StaticClass.sharedInstance.getDouble(value: detail["latitude"] as? String ?? "0")
        StartBooking.sharedInstance.objectDetail.strLongitude = StaticClass.sharedInstance.getDouble(value: detail["longitude"] as? String ?? "0")
        StartBooking.sharedInstance.objectDetail.strLocationID = detail["location_id"] as? String ?? ""
        StartBooking.sharedInstance.objectDetail.is_outof_dropzone = Int(String(describing: detail["is_outof_dropzone"]!)) ?? -1
        StartBooking.sharedInstance.objectDetail.outOfDropzoneMsg = detail["outof_dropzone_message"]as? String ?? ""
        StartBooking.sharedInstance.objectDetail.strLocationName = detail["location_name"] as? String ?? ""
        StartBooking.sharedInstance.objectDetail.price_per_hour = detail["price_per_hour"]as? String ?? ""
        StartBooking.sharedInstance.objectDetail.rental_fee = detail["rental_fee"]as? String ?? ""
        StartBooking.sharedInstance.objectDetail.duration_for_rental_fee = detail["duration_for_rental_fee"]as? String ?? ""
        StartBooking.sharedInstance.objectDetail.promotional = detail["promotional"]as? String ?? ""
        StartBooking.sharedInstance.objectDetail.promotional_header = detail["promotional_header"]as? String ?? ""
        StartBooking.sharedInstance.objectDetail.promotional_hours = detail["promotional_hours"]as? String ?? ""
        StartBooking.sharedInstance.objectDetail.show_member_button = "\(detail["show_member_button"]as? Int ?? 0)"
        StartBooking.sharedInstance.objectDetail.partner_name = detail["partner_name"]as? String ?? ""
        StartBooking.sharedInstance.objectDetail.lock_id = detail["lock_id"]as? String ?? ""
        StartBooking.sharedInstance.objectDetail.device_name = detail["axa_device_name"]as? String ?? ""
        StartBooking.sharedInstance.device.arrBikes.add(StartBooking.sharedInstance.objectDetail)
        outputBlock(true)
        
    }
    
    func loadContent(){
        StartBooking.sharedInstance.lockType = StartBooking.sharedInstance.objectDetail.lock_id == "6" ? .axa:.linka
        if StartBooking.sharedInstance.lockType == LockType.axa{
            StartBooking.sharedInstance.centralMannager = CBCentralManager(delegate: self, queue: nil)
            _ = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (_) in
                self.centralMannager?.stopScan()
                if self.peripheralDevice == nil && !self.isLinkaConnected{
                    AppDelegate.shared.window?.showBottomAlert(message: "Please make sure asset is near by you and not connected with other device.")
                    self.hideSpinner()
                    self.deinitialize()
                }
            })
        }else{
            self.hideSpinner()
            if let bookNowVc = self.viewController as? BookNowVC{
                bookNowVc.loadPriceContainerView(self)
            }
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
        }
    }
    
}
//MARK: - OCS Lock Delegate's
extension StartBooking: ScanDelegate, ProcessDelegate{
    func onCompletion() {
        print("onCompletion")
        self.hideSpinner()
        OcsSmartManager.sharedInstance.stopScan()
    }

    func onError(error: OcsSmartManagerError) {
        print("Error while scanning: ", error)
        self.hideSpinner()
        OcsSmartManager.sharedInstance.stopScan()
    }

    func onSearchResult(lock: OcsLock) {
        OcsSmartManager.sharedInstance.stopScan()
        if "\(lock.getLockNumber())" == StartBooking.sharedInstance.objectDetail.ocs_lock_number{
            self.lock = lock
            self.hideSpinner()
            if self.lock != nil{
                if let bookNowVc = self.viewController as? BookNowVC{
                    bookNowVc.loadPriceContainerView(self)
                }
            }
        }
    }
    
    func onSuccess(response: String) {
        print("onSuccess: ", response)
        self.hideSpinner()
        OcsSmartManager.sharedInstance.stopScan()
        do{
            let event = try Event.getEventFromFrame(frame: response)
            print(event.isSuccessEvent())
            if event.isSuccessEvent(){
                if self.isConfiguring{
                    self.configured()
                }else{
                    self.objectBookingAPI_Called()
                }
            }
        }catch let err{
            print("Error catch block: ", err)
        }
    }
    
    func onErrorProcessDelegate(error: OcsSmartManagerError) {
        print("onErrorProcessDelegate: ", error)
        OcsSmartManager.sharedInstance.stopScan()
        self.hideSpinner()
        self.showAlertWithAction(actionTitle: "Try again", cancelTitle: "Cancel", title: "Alert", msg: "Lock is not connected, Please Try again", completion: { (response) in
            if response{
                if self.isConfiguring{
                    self.configureLock()
                }else{
                    self.configured()
                }
            }
        })
    }
}
//MARK: - CBCentralManager & CBPeripheralManager Delegate's
extension StartBooking: CBCentralManagerDelegate, CBPeripheralDelegate{
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
            self.centralMannager?.scanForPeripherals(withServices: nil, options: nil)
            _ = Timer.scheduledTimer(withTimeInterval: 20, repeats: false, block: { (_) in
                self.centralMannager?.stopScan()
                if self.peripheralDevice == nil && !self.isLinkaConnected{
                    AppDelegate.shared.window?.showBottomAlert(message: "Please make sure asset is near by you.")
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
                self.hideSpinner()                
                if let bookNowVc = self.viewController as? BookNowVC{
                    bookNowVc.loadPriceContainerView(self)
                }
            }
        }
        self.peripheralDevice?.setNotifyValue(true, for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor", characteristic)
        
        if characteristic.uuid == stateCharUUID{
            if let bytes = characteristic.value{
                let data = bytes.byteArray
                print("Bytes -", bytes)
                if data.count > 0{
                    print(data[0])
                    switch data[0] {
                    case 0x00, 0x80:
                        print("Unlocked")
                        self.axaLockStatus = "opened"
                        if self.tappedConfirmBooking{
                            lockUnlock_Web(assetId: self.objectDetail.strId) { (response) in
                                self.hideSpinner()
                                self.deinitialize()
                                if let bookNowVc = self.viewController as? BookNowVC{
                                    bookNowVc.isViewDidCall = true
                                    bookNowVc.searchHome_Web(lat: String(describing: Double(StaticClass.sharedInstance.latitude)), long: String(describing: Double(StaticClass.sharedInstance.longitude)))
                                }
                            }
                        }
                        break
                    case 0x01, 0x09, 0x81, 17:
                        print("Locked")
                        self.axaLockStatus = "closed"
                        break
                    case 0x08, 136:
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

//MARK: - Linka Lock Delegate's
extension StartBooking: LockConnectionServiceDelegate  {
    func onQueryLocked(completionHandler: @escaping (Bool) -> Void) {
        if self.batteryPercentage > 25{
            Global().delay(delay: 0.1) {
                self.objectBookingAPI_Called()
            }
        }else{
            self.hideSpinner()
            StaticClass.sharedInstance.HideSpinner()
            Global().delay(delay: 0.5) {
                let batteryLow = Critical_LowBatteryVC(nibName: "Critical_LowBatteryVC", bundle: nil)
                batteryLow.is_Critical = true
                self.viewController?.present(batteryLow, animated: true, completion: nil)
            }
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
            self.hideSpinner()
            StaticClass.sharedInstance.HideSpinner()
            Global().delay(delay: 0.5) {
                let batteryLow = Critical_LowBatteryVC(nibName: "Critical_LowBatteryVC", bundle: nil)
                batteryLow.is_Critical = true
                self.viewController?.present(batteryLow, animated: true, completion: nil)
            }
        }
        self.lockConnectionService.disconnectWithExistingController()
        completionHandler(false)
    }
    
    
    func onPairingUp() {
        print("onPairingUp")
    }
    
    func onPairingSuccess() {
        print("onPairingSuccess")
    }
    
    func onScanFound() {
        print("onScanFound")
        StaticClass.sharedInstance.ShowSpiner()
    }
    
    func onConnected() {
        print("onConnected")
        self.isLinkaConnected = true
    }
    
    func onBatteryPercent(batteryPercent: Int) {
        print("BatteryPercent is :- \(batteryPercent)")
        self.batteryPercentage = batteryPercent
    }
    
    func onUnlockStarted() {
        print("onUnlockStarted")
        StaticClass.sharedInstance.ShowSpiner()
    }
    
    func onLockStarted() {
        print("onLockStarted")
    }
    
    func onLock() {
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "0", "error_message": "", "device_type": "1"])
    }
    
    func onUnlock() {
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "0", "error_message": "", "device_type": "1"])
        lockUnlock_Web(assetId: self.objectDetail.strId) { (response) in
            self.hideSpinner()
            self.deinitialize()
            if let bookNowVc = self.viewController as? BookNowVC{
                bookNowVc.isViewDidCall = true
                bookNowVc.searchHome_Web(lat: String(describing: Double(StaticClass.sharedInstance.latitude)), long: String(describing: Double(StaticClass.sharedInstance.longitude)))
            }
        }
    }
    
    func errorInternetOff() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error Internet Off", "device_type": "1"])
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
    }
    
    func errorBluetoothOff() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error Bluetooth Off", "device_type": "1"])
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
    }
    
    func errorAppNotInForeground() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error App Not In Foreground", "device_type": "1"])
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
    }
    
    func errorInvalidAccessToken() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "There is an error while fetching acess token", "device_type": "1"])
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
    }
    
    func errorMacAddress(errorMsg: String) {
//        AppDelegate.shared.window?.showBottomAlert(message: errorMsg)
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": errorMsg, "device_type": "1"])
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
    }
    
    func errorConnectionTimeout() {
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
        self.loadCustomAlertWithGradientButtonView(title: "Alert!", messageStr: "Make sure Linka is awake, and not connected to another mobile phone. if this problem persists then turn bluetooth off and on", buttonTitle: "Ok")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Connection Timeout", "device_type": "1"])
    }
    
    func errorScanningTimeout() {
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
        self.loadCustomAlertWithGradientButtonView(title: "Alert!", messageStr: "Make sure Linka is awake, and not connected to another mobile phone. if this problem persists then turn bluetooth off and on", buttonTitle: "Ok")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Scaning Timeout", "device_type": "1"])
    }
    
    func errorLockMoving(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
        self.errorInLock("Lock movement detected. locking blocked. please")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Lock Movement Detected. Locking blocked. Stabilize the bike and try again", "device_type": "1"])
    }
    
    func errorLockStall(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
        self.errorInLock("Error lock stall. please")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error Lock Stall", "device_type": "1"])
    }
    
    func errorLockJam() {
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
        self.errorInLock("Error lock jam. lock requires repair. please")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error Lock Jam. Lock requires repair", "device_type": "1"])
    }
    
    func errorUnexpectedDisconnect() {
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Unexpected Disconnect", "device_type": "1"])
    }
    
    func errorLockingTimeout(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Locking Timeout. Remove obstructions and try again.", "device_type": "1"])
    }
    
    func errorUnlockingTimeout(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.hideSpinner()
        StaticClass.sharedInstance.HideSpinner()
        self.errorInLock("Unlocking timeout. remove obstructions and")
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": self.objectDetail.strId, "booking_id": "0", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Unlocking Timeout. Remove obstructions and try again.", "device_type": "1"])        
    }
    
    func showAlertWithAction(title : String, msg:String, completion:@escaping (_ tryAgain : Bool) ->Void){
        
        let alertController = UIAlertController(title: title, message: msg , preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default) {
            UIAlertAction in
            completion(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            completion(false)
        }
        // Add the actions
        alertController.addAction(tryAgainAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: - Web Api's
extension StartBooking{
        
    func getBikeQrDetail(){
        CoreBluetoothClass.sharedInstance.isBluetoothOn(vc: self)
//        if (!MyLinka.shared.isBlutoothisOn){
//            self.viewController?.alert(title: "Alert", msg: "Please turn on bluetooth to start your rental.")
//        }
    }
    
    func objectReservationApiCall(strObjectId:String) {
        
        let dictParam : NSMutableDictionary = NSMutableDictionary()
        
        let strUserId = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserID) as? String ?? ""
        dictParam.setValue(strUserId ,forKey:"user_id")
        dictParam.setValue(strObjectId, forKey: "object_id");
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("object_reserved", parameters: dictParam , showLoder: false, successBlock: { (responseObj) in
            
            if let dict = responseObj as? NSDictionary {
                if (dict["IS_ACTIVE"] as! Bool){
                    if (dict["FLAG"] as! Bool){
                        Global.appdel.strIsUserType = dict["user_type"] as? String ?? "0"
                        if self.lockType == LockType.axa{
                            self.objectBookingAPI_Called()
                        }else{
                            self.fetchAccessToken { (_) in
//                                StaticClass.sharedInstance.ShowSpiner()
                                _ = self.lockConnectionService.doQuery(macAddress: Singleton.shared.bikeData.strDeviceID, delegate: self)
                            }
                        }
                    } else {
                        self.hideSpinner()
                        self.deinitialize()
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self.viewController)
                    }
                } else {
                    self.hideSpinner()
                    self.deinitialize()
                }
            }
        }) { (error) in
            self.hideSpinner()
            self.deinitialize()
        }
    }
    
    func objectBookingAPI_Called() {
        
        let dictParameter = NSMutableDictionary()
        
        let strUserId = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserID) as? String ?? ""
        
        dictParameter.setValue(strUserId ,forKey:"user_id")
        dictParameter.setValue(objectDetail.strId, forKey: "object_id")
        dictParameter.setValue(objectDetail.booking_object_type, forKey: "object_type")
        dictParameter.setValue(objectDetail.booking_object_sub_type, forKey: "object_sub_type")
        dictParameter.setValue(sharedCreditCardDetail.token_id ,forKey:"card_token")
        dictParameter.setValue(objectDetail.is_outof_dropzone, forKey: "is_outof_dropzone")
        dictParameter.setValue(self.isReferralApply, forKey: "is_referral_use_by_user")
        dictParameter.setValue(self.promoCode, forKey: "promo_id")
        dictParameter.setValue(self.objectDetail.strLocationID ,forKey:"location_id")
        
        let strLat = "\(StaticClass.sharedInstance.latitude)"
        let strLong = "\(StaticClass.sharedInstance.longitude)"
        
        dictParameter.setValue(strLat ,forKey:"latitude")
        dictParameter.setValue(strLong,forKey:"longitude")
        dictParameter.setValue("1",forKey:"event")
        dictParameter.setValue("1" ,forKey:"lock_status")
        dictParameter.setValue("\(self.batteryPercentage)" ,forKey:"battery_life")
        dictParameter.setValue(Global.appdel.strIsUserType, forKey: "user_type")
        dictParameter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        print("param for booking Object",dictParameter)
        
        APICall.shared.postWeb("object_book", parameters: dictParameter , showLoder: false, successBlock: { (response) in
            
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
                            self.startSpinner()
                            self.lockUnlock_Web(assetId: self.objectDetail.strId) { (response) in
                                self.hideSpinner()
                                self.deinitialize()
                                if let bookNowVc = self.viewController as? BookNowVC{
                                    bookNowVc.isViewDidCall = true
                                    bookNowVc.searchHome_Web(lat: String(describing: Double(StaticClass.sharedInstance.latitude)), long: String(describing: Double(StaticClass.sharedInstance.longitude)))
                                }
                            }
                        }
                    }else{
                        _ = self.lockConnectionService.doUnLock(macAddress: Singleton.shared.bikeData.strDeviceID, delegate: self)
                    }
                    
                } else {
                    self.hideSpinner()
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict.object(forKey: "MESSAGE") as? String ?? "", vc: self.viewController)
                    self.deinitialize()
                }
            }
        }) { (error) in
            self.hideSpinner()
            self.deinitialize()
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
            StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "", vc: self.viewController)
        }
    }
    
}

//MARK: - Check Bluetooth Delegate's
extension StartBooking: CheckBluetoothStatusDelegate{
    func response(status: Bool) {
        if !self.viewController!.checkLocationService(){
            self.viewController?.alert(title: "Alert", msg: "Please turn on location service to start your rental.")
        }else{
            let params: NSMutableDictionary = NSMutableDictionary()
            params.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
            params.setValue(self.isReferralApply, forKey: "is_referral_use_by_user")
            params.setValue(self.assetId, forKey: "assets_number")
            params.setValue("\(StaticClass.sharedInstance.latitude)", forKey: "current_latitude")
            params.setValue("\(StaticClass.sharedInstance.longitude)", forKey: "current_longitude")
            params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
            
            APICall.shared.postWeb("bike_qr_detail", parameters: params , showLoder: false, successBlock: { (response) in
                if let dict = response as? NSDictionary {
                    if (dict["FLAG"] as! Bool){
                        if let objectArr = dict["OBJECT_DETAILS"] as? [[String:Any]] , objectArr.count > 0 {
                            print("Object Detail: ", objectArr[0])
                            self.parseJsonData(detail: objectArr[0]) { (response) in
                                self.loadContent()
                            }
                        }
                    } else  {
                        self.hideSpinner()
                        self.deinitialize()
                        if let is_maintenance = dict["IS_MAINTENANCE"]as? Int, is_maintenance == 1{
                            self.loadCustomAlertWithGradientButtonView(title: "", messageStr: dict["MESSAGE"] as? String ?? "", buttonTitle: "Got It")
                        }else if let is_reserved = dict["IS_RESERVED"]as? Int, is_reserved == 1{
                            self.loadCustomAlertWithGradientButtonView(title: dict["MESSAGE_TITLE"] as? String ?? "", messageStr: dict["MESSAGE"] as? String ?? "", buttonTitle: "Ok")
                        }else{
                            StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self.viewController)
                        }
                    }
                }
            }) { (error) in
                self.hideSpinner()
                self.deinitialize()
                StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "", vc: self.viewController)
            }
            
        }
    }
}
