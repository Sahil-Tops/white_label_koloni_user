//
//  CoreBluetoothClass.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 25/05/21.
//  Copyright © 2021 Self. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol CheckBluetoothStatusDelegate {
    func response(status: Bool)
}

class CoreBluetoothClass: NSObject {
    
    static var sharedInstance = CoreBluetoothClass()
    var centralManager = CBCentralManager()
    var delegate: CheckBluetoothStatusDelegate?
    
    func isBluetoothOn(vc: UIViewController){
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.delegate = vc as? CheckBluetoothStatusDelegate
    }
    
}

extension CoreBluetoothClass: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.delegate?.response(status: true)
            self.delegate = nil
            break
        case .poweredOff:
            self.delegate?.response(status: false)
            self.delegate = nil
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        default:
            break
        }
    }
}
