//
//  Constants.swift
//
//  Created by Narendra Pandey on 28/05/18.
//  Copyright © 2018 tops. All rights reserved.

import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

//let GoogleAPIKey = "AIzaSyB53SxlyjXldFZL7okIcXW8RBvtCmauUTc"
let GoogleAPIKey = "AIzaSyB53SxlyjXldFZL7okIcXW8RBvtCmauUTc"//"AIzaSyDGMrjSH93MfjetsAdnud5gK4EilsfCLDU"

enum popUpMessage : String {
    case someWrong          = "No internet connection. Make sure that the Wifi or cellular mobile data  is turned on, then try again"
    case serverError          = "Currently unable to reach server, Try after some time."
}
//func showAlert(_ message: String, position: HRToastPosition = HRToastPosition.Default){
//    if message.count > 0 {
//        DispatchQueue.main.async(execute: {
//            appDelegate.window!.makeToast(message: message , duration: 2, position: position)
//        })
//    }
//}

func showTopAlert(_ message: String, position: HRToastPosition = HRToastPosition.Center)
{
    if message.count > 0 {
        DispatchQueue.main.async(execute: {
            appDelegate.window!.makeToast(message: message , duration: 2, position: position)
        })
    }
}

extension UIViewController
{
    func showAlertWithAction(actionTitle: String, cancelTitle: String,  title : String, msg:String, completion:@escaping (_ tryAgain : Bool) ->Void){
        //        self.alertView.dismiss(withClickedButtonIndex: -1, animated: true)
        let alertController = UIAlertController(title: title, message: msg , preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default) {
            UIAlertAction in
            completion(true)
        }
        let cancelAction = UIAlertAction(title: cancelTitle, style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            completion(false)
        }
        // Add the actions
        alertController.addAction(tryAgainAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}


