//
//  OCSLock_Connection.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 21/10/21.
//  Copyright © 2021 Self. All rights reserved.
//

protocol OCSConnectionDelegates {
    func responseFromConnection()
}

import Foundation
import OcsSmartLibrary

class OCSLOCK_CONNECTION: UIViewController{
    
    static var sharedinstance: OCSLOCK_CONNECTION!
    var spinner = AnimatedCircularView()
    var spinnerView = UIView()
    var viewController: UIViewController?
    var lockList: [OcsLock] = []
    var lock: OcsLock!
    var license: License!
    var extendedLicense: ExtendedLicense!
    var extendedLicenseFrame = ""
    var userCode = ""
    var masterCode = ""
    var delegate: OCSConnectionDelegates!
    var isConfiguring = false
    var lockNumber = ""
    var lockStatus = ""
    
    
    func initialize(lock_number: String, vc: UIViewController, user_code: String, master_code: String){
        type(of: self).sharedinstance = self
        self.viewController = vc
        self.delegate = vc as? OCSConnectionDelegates
        self.lockNumber = lock_number
        self.masterCode = master_code
        
        if let bookNowVc = self.viewController as? BookNowVC{
            if bookNowVc.rentalActionPerformed == 1{
                self.userCode = "\(bookNowVc.generate4DigitRandomCode())"
            }else{
                self.userCode = user_code
            }
        }else{
            self.userCode = user_code
        }
        
        self.loadContent()
    }
    
    //MARK: - Custom Function's
    func loadContent(){
        OcsSmartManager.sharedInstance.clearScanDetectedDevicesList()
        self.startSpinner()
        self.startScan()
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
        self.spinner.hideSpinner()
        self.spinnerView.removeFromSuperview()
        self.spinner.removeFromSuperview()
    }
    
    func startScan(){
        print("start ocs scanning")
        OcsSmartManager.sharedInstance.clearScanDetectedDevicesList()
        OcsSmartManager.sharedInstance.startScanMaintenance(timeoutSec: 3, scanDelegate: self, scanType: .MAINTENANCE)
    }
    
    func stopScan(){
        OcsSmartManager.sharedInstance.stopScan()
    }
    
    func generateExtendadLicense(){
        DispatchQueue.main.async {
            do{
                let asset = NSDataAsset(name: "ocs_license", bundle: Bundle.main)
                let bytes = [UInt8](asset!.data)
                print(Array(bytes).data.toHexString())
                self.extendedLicense = try ExtendedLicense.getLicense(license: Array(bytes).data.toHexString())
                if self.masterCode != ""{
                    try self.extendedLicense.setMasterCode(masterCode: self.masterCode)
                }else{
                    self.showTopPop(message: "No master code found for this lcoker, try other locker", response: false)
                    return
                }
                print(self.masterCode, self.userCode)
                self.extendedLicenseFrame = try self.extendedLicense.generateConfigForDedicatedLock(
                    lockNumber: Int(self.lock.getLockNumber()),
                    newMasterCode: self.masterCode,
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
        self.startSpinner()
        self.isConfiguring = true
        self.lockStatus = self.lock.getLockStatus() == LockStatus.OPEN ? "opened":"closed"
        OcsSmartManager.sharedInstance.connectAndSend(ocsLock: self.lock, connectionTimeoutSec: 6, communicationTimeoutSec: 10, frame: self.extendedLicenseFrame, callback: self)
    }
    
    func configured(){
        do{
            let licenseString = try self.extendedLicense.getUserFrameDedicatedLocksString(dedicatedlocks: [Int(self.lock.getLockNumber())], userCode: self.userCode)
            self.license = try License.getLicense(license: licenseString)
            if let bookNowVc = self.viewController as? BookNowVC{
                bookNowVc.paseLockUnlock()
            }
        }catch let err{
            print(err.localizedDescription)
        }
    }
    
    func lockUnlockOcsLock(){
        if let bookNowVc = self.viewController as? BookNowVC{
            if bookNowVc.rentalActionPerformed == 1{
                if self.lock.getLockStatus() == LockStatus.CLOSED{
                    self.hideSpinner()
                    self.delegate.responseFromConnection()
                }else{
                    self.startSpinner()
                    self.isConfiguring = false
                    OcsSmartManager.sharedInstance.reconnectAndSendToNode(withTag: self.lock.getTag(), connectionTimeoutSec: 6, communicationTimeoutSec: 10, frame: self.license.getFrame(), callback: self)
                }
            }else{
                self.startSpinner()
                self.isConfiguring = false
                OcsSmartManager.sharedInstance.reconnectAndSendToNode(withTag: self.lock.getTag(), connectionTimeoutSec: 6, communicationTimeoutSec: 10, frame: self.license.getFrame(), callback: self)
            }
        }else{
            self.startSpinner()
            self.isConfiguring = false
            OcsSmartManager.sharedInstance.reconnectAndSendToNode(withTag: self.lock.getTag(), connectionTimeoutSec: 6, communicationTimeoutSec: 10, frame: self.license.getFrame(), callback: self)
        }
    }
    
}

//MARK: - OCS Delegate's
extension OCSLOCK_CONNECTION: ScanDelegate{
    
    func onSearchResult(lock: OcsLock) {
        if self.lockNumber == "\(lock.getLockNumber())"{
            self.lock = lock
        }
    }
    
    func onCompletion() {
        print("onCompletion")
        self.stopScan()
        self.hideSpinner()
        if self.lock != nil{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.generateExtendadLicense()
            }
        }
    }
    
    func onError(error: OcsSmartManagerError) {
        print("Error while scanning: ", error)
        self.stopScan()
        self.hideSpinner()
    }
}


//MARK: - Process Delegate's
extension OCSLOCK_CONNECTION: ProcessDelegate{
    func onSuccess(response: String) {
        print("On success: ", response)
        self.stopScan()
        do{
            let event = try Event.getEventFromFrame(frame: response)
            print(event.isSuccessEvent())
            if event.isSuccessEvent(){
                if self.isConfiguring{
                    self.configured()
                }else{
                    self.hideSpinner()
                    self.lockStatus = self.lockStatus == "opened" ? "closed":"opened"
                    print("Lock Status: ", self.lock.getLockStatus())
                    self.delegate.responseFromConnection()
                }
            }else{
                self.hideSpinner()
            }
        }catch let err{
            print("Error catch block: ", err)
            self.hideSpinner()
        }
    }
    
    func onErrorProcessDelegate(error: OcsSmartManagerError) {
        print("Error process delegate: ", error)
        self.stopScan()
        self.hideSpinner()
        self.viewController?.showAlertWithAction(actionTitle: "Try again", cancelTitle: "Cancel", title: "Alert", msg: "Lock is not connected, Please Try again", completion: { (response) in
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
