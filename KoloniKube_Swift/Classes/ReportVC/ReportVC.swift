//
//  ReportVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 6/2/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
//import Photos
import DropDown
import KMPlaceholderTextView
import IQKeyboardManagerSwift

class ReportVC: UIViewController {
    
    //MARK: IBOUTLET DECLARATION
    
    @IBOutlet weak var containerView: CustomView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var underLine_lbl: UILabel!
    @IBOutlet weak var navTitle_lbl: UILabel!
    @IBOutlet weak var btnFirst: UIButton!
    @IBOutlet weak var btnSecond: UIButton!
    @IBOutlet weak var btnThird: UIButton!
    @IBOutlet weak var viewThird: UIView!
    @IBOutlet weak var viewSecond: UIView!
    @IBOutlet weak var viewFirst: UIView!
    @IBOutlet weak var imgFirst: UIImageView!
    @IBOutlet weak var imgSecond: UIImageView!
    @IBOutlet weak var imgThird: UIImageView!
    @IBOutlet weak var reportIssue_lbl: UILabel!
    @IBOutlet weak var firstImgPlacholder_lbl: UILabel!
    @IBOutlet weak var secondImgPlacholder_lbl: UILabel!
    @IBOutlet weak var thirdImgPlacholder_lbl: UILabel!
    @IBOutlet weak var bookingIdContainerView: UIView!
    @IBOutlet weak var bookingIdView_height: NSLayoutConstraint!
    @IBOutlet weak var skeltonView: CustomView!
    
    @IBOutlet weak var selectBookingIdView: UIView!
    @IBOutlet weak var whichRentalText_lbl: UILabel!
    @IBOutlet weak var whichRentalText_height: NSLayoutConstraint!
    @IBOutlet weak var btnSelectBookingId: UIButton!
    @IBOutlet weak var txtComment: KMPlaceholderTextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtOrderId_lbl: UILabel!
    @IBOutlet weak var txtOrderId2_lbl: UILabel!
    @IBOutlet weak var dropDownArrow_lbl: UILabel!
    
    //MARK: LOCAL VARIABLE DECLARATION
    var imagePicker = UIImagePickerController()
    var intSegmentSelection = Int()
    var strOrderID = String()
    var issueId = ""
    var selectedIssue = ""
    var strAssetId = String()
    var imageIndex = Int()
    var imageArrayIndex = NSMutableArray()
    var assetsArray: [[String:Any]] = []
    var orderIdArray: [[String:Any]] = []
    var arrImageSelection = NSMutableArray()
    var dropDownView: DropDownView?
    var showForRunningRental = false
    
    
    //MARK: Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.currentReportsetU()
        self.loadContent()
        self.addGesture()
        self.getOrderListAPI_Call()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        self.navTitle_lbl.text = "Report an Issue"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        btnSubmit.layer.cornerRadius = btnSubmit.frame.height / 2
    }
    
    //MARK: - @IBAction's
    @IBAction func btnSelectBookingIdClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender.tag == 100{
            print("Show Select Booking Id")
            var array: [[String]] = []
            array.append(self.orderIdArray.map({$0["order_id"]as? String ?? ""}))
            self.dropDownView = self.loadDropDown(array, .black, true, view_frame: CGRect(x: self.containerView.frame.origin.x + 20, y: self.containerView.frame.origin.y + 165, width: self.containerView.frame.width - 40, height: self.containerView.frame.height - 240))
        }else if sender.tag == 101{
            print("Show Asset Type Listing")
        }else{
            print(sender.tag)
        }
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapCloseBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnFirstClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.imageIndex = 1
        if sender.isSelected == true {
            sender.isSelected = false
            self.imgFirst.image = UIImage(named: "")
            self.btnFirst.setBackgroundImage(UIImage(named: "camIcon"), for: .normal)
            self.arrImageSelection.replaceObject(at: 0, with: (UIImage(named: "imgPlaceHolderIcon")!))
        } else {
            self.actionSheetForPhoto()
            sender.isSelected = true
        }
    }
    
    @IBAction func btnSecondClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.imageIndex = 2
        if sender.isSelected == true {
            sender.isSelected = false
            self.imgSecond.image = UIImage(named: "")
            self.btnSecond.setBackgroundImage(UIImage(named: "camIcon"), for: .normal)
            self.arrImageSelection.replaceObject(at: 1, with: (UIImage(named: "imgPlaceHolderIcon")!))
        } else {
            self.actionSheetForPhoto()
            sender.isSelected = true
        }
    }
    
    @IBAction func btnThirdClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.imageIndex = 3
        if sender.isSelected == true {
            sender.isSelected = false
            self.imgThird.image = UIImage(named: "")
            self.btnThird.setBackgroundImage(UIImage(named: "camIcon"), for: .normal)
            self.arrImageSelection.replaceObject(at: 2, with: (UIImage(named: "imgPlaceHolderIcon")!))
        }else {
            self.actionSheetForPhoto()
            sender.isSelected = true
        }
    }
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        
        if self.txtOrderId_lbl.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || self.txtOrderId_lbl.text! == "Select booking ID"{
        }
        if self.txtComment.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || self.txtComment.text! == "Type your issue here*"{
            self.showRedStar(textField: UITextField(), textLabel: UILabel(), string: "Type your issue here", textView: self.txtComment, selectedFieldType: "textView")
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "KeyVLIssueDisc"), vc: self)
            return
        }
        let strComment = txtComment.text?.trimmingCharacters(in: .whitespaces)
        guard (strComment?.count)! > 0 else {
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "KeyVLIssueDisc"), vc: self)
            return
        }
        
        let dictParam = NSMutableDictionary()
        
        dictParam.setObject(StaticClass.sharedInstance.strUserId, forKey: "user_id" as NSCopying)
        dictParam.setObject(self.issueId, forKey: "type" as NSCopying)
        dictParam.setObject(strOrderID, forKey: "order_id" as NSCopying)
        dictParam.setObject(strAssetId, forKey: "object_type" as NSCopying)
        let strCOmment = txtComment.text ?? ""
        dictParam.setObject(strCOmment, forKey: "description" as NSCopying)
        dictParam.setObject("", forKey: "mobile_no" as NSCopying)
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        dictParam.setValue("\(StaticClass.sharedInstance.latitude)", forKey: "latitude")
        dictParam.setValue("\(StaticClass.sharedInstance.longitude)", forKey: "longitude")
        print(dictParam)
        
        self.reportIssue_Web(params: dictParam)
    }
    
    //MARK: - Custom Function's
    func loadContent(){
        
        self.reportIssue_lbl.text = "Report an Issue"
        self.txtComment.layer.cornerRadius = 10
        self.txtComment.layer.masksToBounds = true
        if AppLocalStorage.sharedInstance.application_gradient{
            self.btnSubmit.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.btnSubmit.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        self.reportIssue_lbl.textColor = CustomColor.primaryColor
        self.txtOrderId2_lbl.textColor = CustomColor.primaryColor
        self.txtOrderId_lbl.textColor = CustomColor.primaryColor
        self.underLine_lbl.backgroundColor = CustomColor.primaryColor
    }
    
    func addGesture(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        self.containerView.addGestureRecognizer(tap)
        
    }
    
    @objc func tapGestureAction(_ sender: UITapGestureRecognizer){
        self.dropDownView?.removeFromSuperview()
    }    
    
    func showSkeltonView(){
        self.skeltonView.isHidden = false
        Singleton.showSkeltonViewOnViews(viewsArray: [self.skeltonView])
        self.skeltonView.cornerRadius(cornerValue: 20)
    }
    
    func hideSkeltonView(){
        self.skeltonView.isHidden = true
        Singleton.hideSkeltonViewFromViews(viewsArray: [self.skeltonView])
    }
    
    func showGrayStar(textField: UITextField,textLabel: UILabel , string: String, textView: UITextView, selectedFieldType: String){
        
        let myString2 = "*"
        let attributedStr = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        let attributedStr2 = NSAttributedString(string: myString2, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        let combination = NSMutableAttributedString()
        combination.append(attributedStr)
        combination.append(attributedStr2)
        if selectedFieldType == "textField"{
            textField.attributedText = combination
        }else if selectedFieldType == "textView"{
            textView.attributedText = combination
        }else{
            textLabel.attributedText = combination
        }
        
    }
    
    func showRedStar(textField: UITextField,textLabel: UILabel , string: String, textView: UITextView, selectedFieldType: String){
        
        let myString2 = "*"
        let attributedStr = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        let attributedStr2 = NSAttributedString(string: myString2, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        let combination = NSMutableAttributedString()
        combination.append(attributedStr)
        combination.append(attributedStr2)
        if selectedFieldType == "textField"{
            textField.attributedText = combination
        }else if selectedFieldType == "textView"{
            textView.attributedText = combination
        }else{
            textLabel.attributedText = combination
        }
        
    }
    
    func currentReportsetU() {
        self.intSegmentSelection = 0
        self.viewFirst.layer.cornerRadius = 7
        self.viewSecond.layer.cornerRadius = 7
        self.viewThird.layer.cornerRadius = 7
        self.imgFirst.layer.cornerRadius = 7
        self.imgSecond.layer.cornerRadius = 7
        self.imgThird.layer.cornerRadius = 7
        self.txtOrderId_lbl.text = "Select booking ID"
        self.txtComment.text = ""
        self.arrImageSelection.removeAllObjects()
        let imgPlaceHoldrt: UIImage = UIImage(named: "imgPlaceHolderIcon")!
        self.arrImageSelection.add(imgPlaceHoldrt)
        self.arrImageSelection.add(imgPlaceHoldrt)
        self.arrImageSelection.add(imgPlaceHoldrt)
        self.imgFirst.contentMode = .center
        self.imgSecond.contentMode = .center
        self.imgThird.contentMode = .center
    }
    
    func showBookingIdView(){
//        self.bookingIdView_height.constant = 90
        self.btnSelectBookingId.isUserInteractionEnabled = true
        self.txtOrderId2_lbl.isHidden = true
        self.selectBookingIdView.isHidden = false
        self.dropDownArrow_lbl.isHidden = false
        self.whichRentalText_lbl.isHidden = false
        self.selectBookingIdView.circleObject()
        self.whichRentalText_height.constant = 25
        self.bookingIdView_height.constant = 90
        self.view.layoutIfNeeded()
    }
    
    func hideBookingIdView(){
        self.bookingIdView_height.constant = 0
        self.btnSelectBookingId.isUserInteractionEnabled = false
        self.txtOrderId2_lbl.isHidden = true
        self.txtOrderId_lbl.isHidden = true
        self.selectBookingIdView.isHidden = true
        self.dropDownArrow_lbl.isHidden = true
        self.whichRentalText_lbl.isHidden = true
        self.whichRentalText_height.constant = 0
//        self.bookingIdView_height.constant = 65
        self.view.layoutIfNeeded()
    }
    
//    @objc func setUpKeyboardOpenFunctionality(notification:Notification) -> Void {
//        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.enableAutoToolbar = true
//    }
    
    func CommentText(strEmail:String) -> Void {
        if (strEmail.count) > 0 {
            txtComment.textColor = CustomColor.primaryColor
        }else{
            txtComment.textColor = UIColor(hexxString:Global.g_ColorString.GreyLightTxt)
        }
    }
    
    //MARK: ACTION SHEET PHOTO OPEN METHOD
    
    func actionSheetForPhoto() {
        
        let optionMenu = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        let saveAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.cameraCaptureMode = .photo
                self.imagePicker.modalPresentationStyle = .fullScreen
                self.imagePicker.delegate = self
                self.present(self.imagePicker, animated: true,completion: nil)
            } else {
                self.noCamera()
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: LocalizeHelper.sharedLocalSystem().localizedString(forKey: "keyCASNoCameraFoundTitleMsg"),
            message: LocalizeHelper.sharedLocalSystem().localizedString(forKey: "keyCASNoCameraFoundDetailMsg"),
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: LocalizeHelper.sharedLocalSystem().localizedString(forKey: "keyCASBtnOK"),
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    
    
    func clearDataFun()  {
        
        self.txtOrderId_lbl.text = "Select booking ID"
        self.txtComment.text = ""
        self.btnFirst.setBackgroundImage(UIImage(named: "camIcon"), for: .normal)
        self.btnSecond.setBackgroundImage(UIImage(named: "camIcon"), for: .normal)
        self.btnThird.setBackgroundImage(UIImage(named: "camIcon"), for: .normal)
        
        self.arrImageSelection.removeAllObjects()
        let imgPlaceHoldrt: UIImage = UIImage(named: "imgPlaceHolderIcon")!
        self.arrImageSelection.add(imgPlaceHoldrt)
        self.arrImageSelection.add(imgPlaceHoldrt)
        self.arrImageSelection.add(imgPlaceHoldrt)
        
        self.imgFirst.image = UIImage(named: "")
        self.imgFirst.contentMode = .center
        
        self.imgSecond.image = UIImage(named: "")
        self.imgSecond.contentMode = .center
        
        self.imgThird.image = UIImage(named: "")
        self.imgThird.contentMode = .center
        
        self.loadContent()
    }

    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
}

//MARK: - TextView Delegate's
extension ReportVC: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtComment.text! == "Type your issue here*"{
            txtComment.text = ""
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            view.endEditing(true)
            return false
        }
        return true
    }
    
    internal func textViewDidEndEditing(_ textView: UITextView) {
        if (textView == txtComment){
            let trimmedString = txtComment.text!.trimmingCharacters(in: .whitespaces) as String
            if trimmedString == ""{
                let myString = "Type your issue here"
                let myString2 = "*"
                let attributedStr = NSAttributedString(string: myString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
                let attributedStr2 = NSAttributedString(string: myString2, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                let combination = NSMutableAttributedString()
                combination.append(attributedStr)
                combination.append(attributedStr2)
                self.txtComment.attributedText = combination
            }else{
                CommentText(strEmail: trimmedString);
            }
            
        }
    }
    
}

//MARK: - ImagePicker Delegate's
extension ReportVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            if self.imageIndex ==  1 {
                
                self.imgFirst.image = pickedImage
                self.imgFirst.contentMode = .scaleToFill
                self.arrImageSelection.replaceObject(at: 0, with: pickedImage)
                self.btnFirst.setBackgroundImage(UIImage(named: "removeIcon"), for: .normal)
            }
            
            if self.imageIndex == 2 {
                self.imgSecond.image = pickedImage
                self.imgSecond.contentMode = .scaleToFill
                self.arrImageSelection.replaceObject(at: 1, with: pickedImage)
                self.btnSecond.setBackgroundImage(UIImage(named: "removeIcon"), for: .normal)
                
            }
            
            if self.imageIndex == 3 {
                self.imgThird.image = pickedImage
                self.imgThird.contentMode = .scaleToFill
                self.arrImageSelection.replaceObject(at: 2, with: pickedImage)
                self.btnThird.setBackgroundImage(UIImage(named: "removeIcon"), for: .normal)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Web Api
extension ReportVC{
    
    func reportIssue_Web(params: NSMutableDictionary){
        
        APICall.shared.callApiForMultipleImageUpload("report_issue", withParameter: params, withImage: arrImageSelection, withLoader: true, successBlock: { (responseObj) in
            if let dict = responseObj as? NSDictionary {
                if (dict["FLAG"] as! Bool) {
                    
                    let popup = PopupController
                        .create(self)
                    let strMessage = dict["MESSAGE"] as? String ?? ""
                    let container = IssuePopupVC.instance()
                    container.strPenaltyPrice = strMessage
                    container.closeHandler = {
                        popup.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            //Here we have to check that last view controller is present or not
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    popup.show(container)
                    self.clearDataFun()
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
                }
            }
        }) { (isError) in
            StaticClass.sharedInstance.HideSpinner()
            StaticClass.sharedInstance.ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey: "ERROR_CALL"), vc: self )
        }
    }
    
    func getOrderListAPI_Call(){
        self.btnSelectBookingId.isUserInteractionEnabled = false
        let dictParam = NSMutableDictionary()
        
        dictParam.setObject(StaticClass.sharedInstance.strUserId, forKey: "user_id" as NSCopying)
        dictParam.setObject("2", forKey: "is_current" as NSCopying)
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        self.showSkeltonView()
        APICall.shared.postWeb("get_order_id", parameters: dictParam, showLoder: false, successBlock: { (response) in
            self.hideSkeltonView()
            if let dict = response as? NSDictionary
            {
                print(dict)
                if (dict["FLAG"] as! Bool){
                    if let arrOrder = dict["RESULT"] as? [[String:Any]]{
                        self.orderIdArray = [["id": "", "order_id": "N/A"]]
                        for i in 0..<arrOrder.count{
                            self.orderIdArray.append(arrOrder[i])
                        }
                        if self.orderIdArray.count > 1 {
                            self.btnSelectBookingId.isUserInteractionEnabled = true
                            self.strOrderID = self.orderIdArray[1]["id"]as? String ?? ""
                            if self.showForRunningRental{
                                self.txtOrderId2_lbl.text = self.orderIdArray[1]["order_id"]as? String ?? ""
                                self.txtOrderId2_lbl.textColor = CustomColor.primaryColor
                                self.hideBookingIdView()
                            }else{
                                self.txtOrderId_lbl.text = self.orderIdArray[1]["order_id"]as? String ?? ""
                                self.txtOrderId_lbl.textColor = CustomColor.primaryColor
                                self.showBookingIdView()
                            }
                        } else {
                            self.strOrderID = ""
                            self.txtOrderId_lbl.text = "No booking ID Found"
                            self.txtOrderId_lbl.textColor = UIColor.darkGray
                            self.hideBookingIdView()
                        }
                    }
                    if let assetList = dict["ASSETS_LIST"]as? [[String:Any]]{
                        self.assetsArray = assetList
                        if self.assetsArray.count > 0{
                            self.strAssetId = self.assetsArray[0]["id"]as? String ?? ""
                        }else{
                            self.strAssetId = ""
                        }
                    }
                } else {
                    self.txtOrderId_lbl.text = "Select booking ID*"
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
                }
            }else{
                
            }
        }) { (error) in
            self.hideSkeltonView()
        }
    }
    
}

//MARK: - DropDown Delegate's
extension ReportVC: DropDownViewDelegate{
    func selectedItem(item: String, index: Int) {
        self.strOrderID = self.orderIdArray[index]["id"]as? String ?? ""
        self.txtOrderId_lbl.text = self.orderIdArray[index]["order_id"]as? String ?? "Select booking ID"
        self.txtOrderId_lbl.textColor = CustomColor.primaryColor
    }
}
