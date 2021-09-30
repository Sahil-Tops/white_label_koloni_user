//
//  SettingVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/31/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
//change
class SettingVC: UIViewController,UITextViewDelegate,UITextFieldDelegate{
    
    //MARK: - Outlet's
    @IBOutlet weak var headerBg_img: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var swithOnOff: UISwitch!
    @IBOutlet weak var lblPushnotification: UILabel!
    @IBOutlet weak var lblSetting: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var rippleView: UIView!
    @IBOutlet weak var btnGift: IPAutoScalingButton!
    @IBOutlet weak var referralCount_lbl: UILabel!
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.referralCount_lbl.circleObject()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.referralCount_lbl.text = Singleton.numberOfReferralRides
        self.checkNotificationStatus()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.addUnderLine(color: .lightGray)
        self.loadUI()
    }
    
    //MARK: - @IBAction's
    @IBAction func btnBackClicked(_ sender: Any) {
        self.sideMenuViewController?.presentLeftMenuViewController()
    }
    
    @IBAction func btnGiftClick(_ sender: UIButton) {
        self.loadShareRefferView()
    }
    
    @IBAction func switchOnOff(_ sender: UISwitch) {
        if sender.isOn {
            self.callNotificationAPI_Call(isOn:"1")
        } else {
            self.callNotificationAPI_Call(isOn:"0")
        }
    }
 
    func loadUI(){
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "logo_img") { (image) in
            self.logoImg.image = image
        }
        self.swithOnOff.onTintColor = CustomColor.primaryColor
        if AppLocalStorage.sharedInstance.application_gradient{
            self.headerBg_img.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.headerBg_img.backgroundColor = CustomColor.primaryColor
        }
    }
}

//MARK: - Web Api's
extension SettingVC{
    
    func checkNotificationStatus() {
        
        let dictPara = NSMutableDictionary()
        
        dictPara.setObject(StaticClass.sharedInstance.strUserId, forKey: "user_id" as NSCopying)
        dictPara.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("check_notification", parameters: dictPara, showLoder: true, successBlock: { (responseObj) in
            if let dict = responseObj as? NSDictionary {
                if (dict["FLAG"] as! Bool) {
                    let arrList = dict["RESULT"] as! NSArray
                    let arrDict = arrList[0] as! NSDictionary
                    let isNotificationStatus = arrDict.object(forKey: "is_notification")as? String ?? ""
                    if isNotificationStatus == "1" {
                        self.swithOnOff.isOn = true
                    }else {
                        self.swithOnOff.isOn = false
                    }
                    
                } else {
                    let msg = dict["MESSAGE"] as? String ?? ""
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: msg, vc: self)
                }
            }
        }) { (error) in
            
        }
    }
    
    func callNotificationAPI_Call(isOn:String) {
        
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue(isOn, forKey: "is_notification")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("settings", parameters: paramer, showLoder: true, successBlock: { (response) in
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool) {
                    let msg = dict["MESSAGE"] as? String ?? ""
                    StaticClass.sharedInstance.ShowNotification(true, strmsg: msg, vc: self)
                    
                } else {
                    let msg = dict["MESSAGE"] as? String ?? ""
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: msg, vc: self)
                }
            }
        }) { (error) in
            
        }
    }
    
}
