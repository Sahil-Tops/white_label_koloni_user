//
//  SentryCaptureManager.swift
//  KoloniKube_Swift
//
//  Created by Sam on 15/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import Foundation
import Sentry


class SentryCaptureManager{
    
    static let instance: SentryCaptureManager = {
       return SentryCaptureManager()
    }()
    
    
    func captureError(error: Error){
        SentrySDK.capture(error: error)
    }
    
    func captureException(exception: NSException){
        SentrySDK.capture(exception: exception)
    }
    
    func captureMessage(msg: String){
        SentrySDK.capture(message: msg)        
    }
}
