//
//  AxaLockConnection.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 9/21/20.
//  Copyright © 2020 Self. All rights reserved.
//

import Foundation
import CoreBluetooth

let serviceUUID = CBUUID(string: ERLOCK_ATTRIBUTES.UUID_SERVICE)
let ctrUUID = CBUUID(string: ERLOCK_ATTRIBUTES.UUID_LOCK_CHAR)
let stateCharUUID = CBUUID(string: ERLOCK_ATTRIBUTES.UUID_STATE_CHAR)

class AXALOCK_CONNECTION: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    static var sharedInstance:AXALOCK_CONNECTION?
    var bookNowVc: BookNowVC?
    var locationVc: LocationListingViewController?
    var vc: UIViewController?
    var centralMannager: CBCentralManager?
    var peripheralDevice: CBPeripheral?
    var ctrCharacteristic: CBCharacteristic?
    var counter_timer = Timer()
    var sendingCommand = false
    var lockStatus = ""
    var writingEkeyCommand = false
    var writeCommandArray: [Int] = []
    var connectedWithDevice = ""
    
    init(vc: UIViewController) {
        super.init()
        type(of: self).sharedInstance = self
        self.vc = vc
        if let viewController = vc as? BookNowVC{
            self.bookNowVc = viewController
        }else if let viewController = vc as? LocationListingViewController{
            self.locationVc = viewController
        }
        self.centralMannager = CBCentralManager(delegate: self, queue: nil)
    }
    
    deinit {
        print("Calling Deinit")
    }
    
    func connectToPeripheral(identifire: CBPeripheral){
        self.peripheralDevice = identifire
        if self.peripheralDevice != nil{
            print("Peripheral Device", self.peripheralDevice!)
            let strArray = (Singleton.axa_ekey_dictionary["axa_passkey"]as? String ?? "").components(separatedBy: "-")
            let currentIndex = Singleton.axa_ekey_dictionary["current_index"]as? Int ?? -1
            if strArray.count > currentIndex{
                if self.peripheralDevice?.state ?? .disconnected == .connected{
                    self.sendingCommand = true
                    if self.vc is BookNowVC{
                        if self.bookNowVc?.rentalActionPerformed == 1{
                            self.lockDevice()
                        }else{
                            Global().delay(delay: 0.3) {
                                self.bookNowVc?.paseLockUnlock()
                            }
                        }
                    }else if self.vc is LocationListingViewController{
                        if self.locationVc?.runningRentalView?.rentalActionPerformed == 1{
                            self.lockDevice()
                        }else{
                            self.locationVc?.runningRentalView?.performLockUnlock()
                        }
                    }
                }else{
                    if self.vc is BookNowVC{
                        self.bookNowVc?.getAxaEkeyPasskeyForBookNow_Web(assetId: Singleton.runningRentalArray[self.bookNowVc?.selectedRentalIndex ?? 0]["object_id"]as? String ?? "", outputBlock: { (response) in
                            if response{
                                self.centralMannager?.connect(self.peripheralDevice!, options: [:])
                            }
                        })
                    }else{
                        self.locationVc?.runningRentalView?.getAxaEkeyPasskey_Web(assetId: Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["object_id"]as? String ?? "", outputBlock: { (response) in
                            if response{
                                self.centralMannager?.connect(self.peripheralDevice!, options: [:])
                            }
                        })
                    }
                }
            }else{
                if self.vc is BookNowVC{
                    self.bookNowVc?.getAxaEkeyPasskeyForBookNow_Web(assetId: Singleton.runningRentalArray[self.bookNowVc?.selectedRentalIndex ?? 0]["object_id"]as? String ?? "", outputBlock: { (response) in
                        if response{
                            self.loadAxaFunctionality()
                        }
                    })
                }else{
                    self.locationVc?.runningRentalView?.getAxaEkeyPasskey_Web(assetId: Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["object_id"]as? String ?? "", outputBlock: { (response) in
                        if response{
                            self.loadAxaFunctionality()
                        }
                    })
                }
            }
        }
    }
    
    func loadAxaFunctionality(){
        let eKeyArray = (Singleton.axa_ekey_dictionary["axa_ekey"]as? String ?? "").components(separatedBy: "-")
        self.writingEkeyCommand = true
        for item in eKeyArray{
            if self.ctrCharacteristic != nil{
                self.writeCommandArray.append(1)
                let bytes = self.vc is BookNowVC ? self.bookNowVc?.stringToBytes(item)! ?? []:self.locationVc?.stringToBytes(item)! ?? []
                let data = Data(bytes: bytes, count: bytes.count)
                self.peripheralDevice?.writeValue(data, for: self.ctrCharacteristic!, type: .withResponse)
            }
        }
    }
    
    func lockDevice(){
        if self.lockStatus == "opened"{
            if self.vc is BookNowVC{
                if self.ctrCharacteristic != nil && self.bookNowVc != nil{
                    let strArray = (Singleton.axa_ekey_dictionary["axa_passkey"]as? String ?? "").components(separatedBy: "-")
                    let currentIndex = Singleton.axa_ekey_dictionary["current_index"]as? Int ?? -1
                    if currentIndex != -1{
                        let bytes = self.bookNowVc?.stringToBytes(strArray[currentIndex])! ?? []
                        let data = Data(bytes: bytes, count: bytes.count)
                        self.peripheralDevice?.writeValue(data, for: self.ctrCharacteristic!, type: .withResponse)
                        Singleton.axa_ekey_dictionary["current_index"] = currentIndex + 1
                    }
                }
            }else{
                if self.ctrCharacteristic != nil && self.locationVc != nil{
                    let strArray = (Singleton.axa_ekey_dictionary["axa_passkey"]as? String ?? "").components(separatedBy: "-")
                    let currentIndex = Singleton.axa_ekey_dictionary["current_index"]as? Int ?? -1
                    if currentIndex != -1{
                        let bytes = self.locationVc?.stringToBytes(strArray[currentIndex])! ?? []
                        let data = Data(bytes: bytes, count: bytes.count)
                        self.peripheralDevice?.writeValue(data, for: self.ctrCharacteristic!, type: .withResponse)
                        Singleton.axa_ekey_dictionary["current_index"] = currentIndex + 1
                    }
                }
            }
        }else{
            if self.sendingCommand{
                self.sendingCommand = false
                if self.vc is BookNowVC{
                    self.bookNowVc?.deviceLockedSuccessfully()
                    self.bookNowVc?.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[self.bookNowVc?.selectedRentalIndex ?? 0]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[self.bookNowVc?.selectedRentalIndex ?? 0]["id"]as? String ?? "", "command_sent": "0", "command_status": "0", "error_message": "", "device_type": "1"])
                }else{
                    self.locationVc?.runningRentalView?.deviceLockedSuccessfully()
                    self.locationVc?.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["id"]as? String ?? "", "command_sent": "0", "command_status": "0", "error_message": "", "device_type": "1"])
                }
            }
        }
    }
    
    func unlockDevice(){
        if self.lockStatus == "closed"{
            if self.vc is BookNowVC{
                if self.ctrCharacteristic != nil && self.bookNowVc != nil{
                    let strArray = (Singleton.axa_ekey_dictionary["axa_passkey"]as? String ?? "").components(separatedBy: "-")
                    let currentIndex = Singleton.axa_ekey_dictionary["current_index"]as? Int ?? -1
                    if currentIndex != -1{
                        let bytes = self.bookNowVc?.stringToBytes(strArray[currentIndex])! ?? []
                        let data = Data(bytes: bytes, count: bytes.count)
                        self.peripheralDevice?.writeValue(data, for: self.ctrCharacteristic!, type: .withResponse)
                        Singleton.axa_ekey_dictionary["current_index"] = currentIndex + 1
                    }
                }
            }else{
                if self.ctrCharacteristic != nil && self.locationVc != nil{
                    let strArray = (Singleton.axa_ekey_dictionary["axa_passkey"]as? String ?? "").components(separatedBy: "-")
                    let currentIndex = Singleton.axa_ekey_dictionary["current_index"]as? Int ?? -1
                    if currentIndex != -1{
                        let bytes = self.locationVc?.stringToBytes(strArray[currentIndex])! ?? []
                        let data = Data(bytes: bytes, count: bytes.count)
                        self.peripheralDevice?.writeValue(data, for: self.ctrCharacteristic!, type: .withResponse)
                        Singleton.axa_ekey_dictionary["current_index"] = currentIndex + 1
                    }
                }
            }
        }else{
            if self.sendingCommand{
                self.sendingCommand = false
                if self.vc is BookNowVC{
                    self.bookNowVc?.deviceUnlockedSuccessfully()
                    self.bookNowVc?.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[self.bookNowVc?.selectedRentalIndex ?? 0]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[self.bookNowVc?.selectedRentalIndex ?? 0]["id"]as? String ?? "", "command_sent": "1", "command_status": "0", "error_message": "", "device_type": "1"])
                }else{
                    self.locationVc?.runningRentalView?.deviceUnlockedSuccessfully()
                    self.locationVc?.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["id"]as? String ?? "", "command_sent": "1", "command_status": "0", "error_message": "", "device_type": "1"])
                }
            }
        }
    }
    
    func dissconnectDevice(){
        if self.peripheralDevice != nil{
            self.centralMannager?.cancelPeripheralConnection(self.peripheralDevice!)
            self.centralMannager = nil
            self.peripheralDevice = nil
        }
    }
    
    //MARK: - CBCentralDelegate's & CBPeriheralDelegate's
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
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if Singleton.runningRentalArray.count > 0{
            let device_name_array = peripheral.name?.components(separatedBy: ":") ?? []
            if device_name_array.count > 1{
                var device_name = ""
                if self.vc is BookNowVC{
                    device_name = Singleton.runningRentalArray[self.bookNowVc?.selectedRentalIndex ?? 0]["assets_device_name"]as? String ?? ""
                }else{
                    device_name = Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["assets_device_name"]as? String ?? ""
                }
                if device_name_array[1] == device_name{
                    self.centralMannager?.stopScan()
                    if self.peripheralDevice != nil{
                        self.centralMannager?.cancelPeripheralConnection(self.peripheralDevice!)
                    }
                    self.connectToPeripheral(identifire: peripheral)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Did connect: ", peripheral)
        self.peripheralDevice = peripheral
        self.peripheralDevice?.delegate = self
        self.peripheralDevice?.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Central Manager Failed To Connect with Error: ", error ?? "Error nill")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices", peripheral, peripheral.services ?? [])
        for service in peripheral.services ?? [] {
            print("Discovered service \(service)")
            // Fiter: Only allow the eRLock UUID's to pass.
            if service.uuid == (serviceUUID) {
                peripheral.discoverCharacteristics(nil, for: service)
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
                self.sendingCommand = true
                if self.vc is BookNowVC{
                    self.connectedWithDevice = Singleton.runningRentalArray[self.bookNowVc?.selectedRentalIndex ?? 0]["assets_device_name"]as? String ?? ""
                    if self.bookNowVc?.rentalActionPerformed == 1{
                        self.lockDevice()
                    }else{
                        self.bookNowVc?.paseLockUnlock()
                    }
                }else{
                    self.connectedWithDevice = Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["assets_device_name"]as? String ?? ""
                    if self.locationVc?.runningRentalView?.rentalActionPerformed == 1{
                        self.lockDevice()
                    }else{
                        self.locationVc?.runningRentalView?.performLockUnlock()
                    }
                }
                
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
                        if self.sendingCommand && self.lockStatus == "closed"{
                            self.sendingCommand = false
                            if self.vc is BookNowVC{
                                self.bookNowVc?.deviceUnlockedSuccessfully()
                                self.bookNowVc?.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[self.bookNowVc!.selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[self.bookNowVc!.selectedRentalIndex]["id"]as? String ?? "", "command_sent": "1", "command_status": "0", "error_message": "", "device_type": "1"])
                            }else{
                                self.locationVc?.runningRentalView?.deviceUnlockedSuccessfully()
                                self.locationVc?.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["id"]as? String ?? "", "command_sent": "1", "command_status": "0", "error_message": "", "device_type": "1"])
                            }
                        }else{
                            if self.sendingCommand{
                                if self.vc is BookNowVC{
                                    self.bookNowVc?.hideLockLoader()
                                }else{
                                    self.locationVc?.runningRentalView?.hideLoader()
                                }
                            }
                        }
                        self.lockStatus = "opened"
                        break
                    case 0x80:
                        print("Unlocked 0x08")
                        break
                    case 0x01, 0x09:
                        print("Locked")
                        if self.sendingCommand{
                            self.sendingCommand = false
                            self.counter_timer.invalidate()
                            if self.vc is BookNowVC{
                                self.bookNowVc?.deviceLockedSuccessfully()
                                self.bookNowVc?.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[self.bookNowVc!.selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[self.bookNowVc!.selectedRentalIndex]["id"]as? String ?? "", "command_sent": "1", "command_status": "0", "error_message": "", "device_type": "1"])
                            }else{
                                self.locationVc?.runningRentalView?.deviceLockedSuccessfully()
                                self.locationVc?.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[self.locationVc?.runningRentalView?.selectedRentalIndex ?? 0]["id"]as? String ?? "", "command_sent": "1", "command_status": "0", "error_message": "", "device_type": "1"])
                            }
                        }
                        self.lockStatus = "closed"
                        break
                    case 0x81:
                        print("Locked 0x81")
                        break
                    case 0x08:
                        print("Waiting for lock")
                        self.lockStatus = "opened"
                        if self.vc is BookNowVC{
                            self.bookNowVc?.hideLockLoader()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if self.bookNowVc?.rentalActionPerformed == 1{
                                    self.bookNowVc?.showAxaLockLoaderPopUp(msg: "Pull lock lever down to end rental...")
                                }else{
                                    self.bookNowVc?.showAxaLockLoaderPopUp(msg: "Close lock by pulling lever down...")
                                }
                            }
                        }else{
                            self.locationVc?.runningRentalView?.hideLoader()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if self.locationVc?.runningRentalView?.rentalActionPerformed == 1{
                                    self.locationVc?.runningRentalView?.showLoader(withMsg: "Pull lock lever down to end rental...")
                                }else{
                                    self.locationVc?.runningRentalView?.showLoader(withMsg: "Close lock by pulling lever down...")
                                }
                            }
                        }
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
