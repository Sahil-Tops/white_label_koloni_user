//
//  BookingPaymentVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/16/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import SkeletonView
import PureLayout

import BraintreeDropIn
import Braintree
import PassKit

enum CardType {
    case Visa
    case Mastro
    case AmericanExpress
    case Master
    case Other
}

struct CardTypeValue {
    
    struct Visa {
        static let strTitle = "Other"
        static let strImg = "visa"
        static let strImgBG = "visa_back"
        static let cardIMG = "visa_card_icn"// master_card_icn // maestro_icn // Discovery_icn // american_icn
    }
    
    struct Mastro {
        static let strTitle = "Other"
        static let strImg = "Maestro"
        static let strImgBG = "Maestro_back"
        static let cardIMG = "maestro_icn"
    }
    struct American {
        static let strTitle = "Other"
        static let strImg = "american_express"
        static let strImgBG = "america_express_back"
        static let cardIMG = "american_icn"
    }
    
    struct Other {
        static let strTitle = "Other"
        static let strImg = "other_card"
        static let strImgBG = "other_back"
        static let cardIMG = "other_card"
    }
    
    struct Master {
        static let strTitle = "Other"
        static let strImg = "master"
        static let strImgBG = "master_back"
        static let cardIMG = "master_card_icn"
    }
    
    struct Discover {
        static let strTitle = "Other"
        static let strImg = "discover"
        static let strImgBG = "discover_back"
        static let cardIMG = "Discovery_icn"
    }
    
    struct Add {
        static let strTitle = "Other"
        static let strImg = "other_add"
        static let strImgBG = "iconAddCard"
    }
}

class BookingPaymentVC: UIViewController {
    
    //MARK:- Outlet's
    @IBOutlet weak var headerBg_img: UIImageView!
    @IBOutlet var tblCard: UITableView!
    @IBOutlet weak var tblCard_height: NSLayoutConstraint!
    @IBOutlet var btnStartRide: UIButton!
    @IBOutlet weak var add_btn: UIButton!
    @IBOutlet weak var btnGiftClose: UIButton!
    @IBOutlet weak var giftImg: UIImageView!
    @IBOutlet weak var giftViewPresent: UIView!
    @IBOutlet weak var addCardContainerView: UIView!
    @IBOutlet weak var addCard_btn: UIButton!
    
    //MARK:- Variable's
    var shareDeviceObj : ShareDevice!
    var isKubeOrBike : Bool = false
    var apiClientKey : BTAPIClient?
    var storeIndex : Int = -1
    var saveBarButton : UIBarButtonItem = UIBarButtonItem ()
    var cardFormNavigationViewController : UINavigationController = UINavigationController()
    var strGetToken: String = ""
    var strCustomerID = ""
    var arrCardList = NSMutableArray()
    var selectCard : Bool = false
    var sharedCreditCardObj = shareCraditCard()
    var cardCell = AddCardTableViewCell()
    var previousCardImage = ""
    var isResponed: Bool = false
    var referralView: ReferralView!
    var numberOfReferral = 0
    var referralSelected = 0
    var selectedObjectId = ""
    var braintreeClient: BTAPIClient?
    
    //MARK:- Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        print("BookingPaymentVC")
        self.registerCell()
        self.loadContent()
    }
    
    override func viewDidLayoutSubviews() {
        self.loadUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - @IBAction's
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapAddBtn(_ sender: UIButton) {
        self.getValidTokerFromAPIforBrainTree()                         //This function is using for add new card.
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        Global().delay(delay: 0.2) {
            let QrCodeVController = QRCodeScaneVC(nibName: "QRCodeScaneVC", bundle: nil)
            QrCodeVController.sharedCreditCardObj = self.sharedCreditCardObj
            QrCodeVController.isReferralApply = self.referralSelected
            QrCodeVController.selectedObjectId = self.selectedObjectId
            Global.appdel.navigation?.pushViewController(QrCodeVController, animated: true)
            self.giftViewPresent.isHidden = true
        }
    }
    
    @IBAction func btnStartRideClicked(_ sender: Any) {
        if selectCard == true {
            
            if sharedCreditCardObj.token_id == "" {
                sharedCreditCardObj = self.arrCardList[0] as! shareCraditCard
            }
            CoreBluetoothClass.sharedInstance.isBluetoothOn(vc: self)
        } else {
            self.alert(title: "Alert", msg: "Please add card")
        }
    }
    
    //MARK: - Custom Function's
    
    func loadUI(){
        if AppLocalStorage.sharedInstance.application_gradient{
            self.headerBg_img.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.btnStartRide.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.addCard_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.add_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.headerBg_img.backgroundColor = CustomColor.primaryColor
            self.btnStartRide.backgroundColor = AppLocalStorage.sharedInstance.button_color
            self.addCard_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
            self.add_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
    }
    
    func loadContent(){
        self.btnStartRide.circleObject()
        self.add_btn.circleObject()
        self.addCard_btn.circleObject()
        self.giftViewPresent.isHidden = true
        self.storeIndex  = 0
        
        self.strCustomerID  = (StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID) as? String ?? "")!
        if Global.Obj_Type == "Kube" {
            self.btnStartRide.setTitle("START YOUR BOOKING", for: .normal)
        } else {
            self.btnStartRide.setTitle("START YOUR RENTAL", for: .normal)
        }
        if self.strCustomerID  == "" {
            self.createCustomerApiCall()
        } else {
            if self.arrCardList.count > 0 {
            } else {
                self.craditCardListApiCall()
            }
        }
    }
    
    func registerCell(){
        self.tblCard.register(UINib(nibName: "AddCardTableViewCell", bundle: nil), forCellReuseIdentifier: "AddCardTableViewCell")
    }
    
    func deleteCard(strMessage:String,tag:Int) {
        
        let actionSheetCont = UIAlertController(title: "", message: strMessage, preferredStyle: .
                                                    alert)
        let selectCardAction = UIAlertAction(title: "Yes", style: .default) { (actionClick) in
            
            let cardDetail = self.arrCardList.object(at: tag) as! shareCraditCard
            let dictParamter : NSMutableDictionary = NSMutableDictionary()
            dictParamter.setValue(StaticClass.sharedInstance.strUserId ,forKey:"user_id")
            dictParamter.setValue(cardDetail.token_id, forKey: "card_token")
            dictParamter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
            
            APICall.shared.postWeb("creditCardDelete", parameters: dictParamter, showLoder: true, successBlock: { (response) in
                if let dict = response as? NSDictionary {
                    if (dict["FLAG"] as! Bool){
                        self.craditCardListApiCall()
                    } else {
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
                    }
                }
            }) { (error) in
                
            }
        }
        let retryAction = UIAlertAction(title: "No", style: .cancel) { (actionClick) in
        }
        actionSheetCont.addAction(selectCardAction)
        actionSheetCont.addAction(retryAction)
        self.present(actionSheetCont, animated: true)
    }
    
    @objc func btnDeleteClicked(index: Int) {
        self.deleteCard(strMessage: "Are you sure, you want to delete this card", tag: index)
    }
    
    @objc func btnAddClicked(sender:UIButton) {
        self.getValidTokerFromAPIforBrainTree()
    }
}

//MARK: - Braintree Custom Function's
extension BookingPaymentVC{
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.cardholderNameSetting = .required
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request) { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                _ = result.paymentOptionType
                let selectedPaymentMethod = result.paymentMethod
                _ = result.paymentIcon
                _ = result.paymentDescription
                
                if result.paymentDescription.contains("ending in"){
                    if let nonce = selectedPaymentMethod?.nonce{
                        self.strGetToken = (nonce)
                        StaticClass.sharedInstance.ShowSpiner()
                        self.createCardAPICalled(nonceID: self.strGetToken)
                    }else{
                        StaticClass.sharedInstance.HideSpinner()
                    }
                }else if result.paymentDescription == "Apple Pay"{
                    self.setupPaymentRequest { (paymentRequest, error) in
                        
                        guard error == nil else {
                            // Handle error
                            return
                        }
                        // Example: Promote PKPaymentAuthorizationViewController to optional so that we can verify
                        // that our paymentRequest is valid. Otherwise, an invalid paymentRequest would crash our app.
                        if let vc = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest!)
                            as PKPaymentAuthorizationViewController?{
                            vc.delegate = self
                            self.present(vc, animated: true, completion: nil)
                        } else {
                            print("Error: Payment request is invalid.")
                        }
                    }
                }
                
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
}

//MARK: - Web Api's
extension BookingPaymentVC{
    
    func craditCardListApiCall() {
        let dictParam : NSMutableDictionary = NSMutableDictionary()
        let strCustID = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID)as? String ?? ""
        dictParam.setValue(strCustID, forKey: "bt_customer")
        dictParam.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("creditCardList", parameters: dictParam, showLoder: true, successBlock: { (responseOBJ) in
            if let dict =  responseOBJ as? NSDictionary {
                self.arrCardList.removeAllObjects()
                if dict["booking_user_type"] != nil{
                    let booking_Type = "\(dict["booking_user_type"] ?? "0")"
                    if (booking_Type  == "1" || booking_Type  == "2") {
                        StaticClass.sharedInstance.HideSpinner()
                        Global().delay(delay: 0.2) {
                            let QrCodeVController = QRCodeScaneVC(nibName: "QRCodeScaneVC", bundle: nil)
                            QrCodeVController.sharedCreditCardObj = self.sharedCreditCardObj
                            QrCodeVController.isReferralApply = self.referralSelected
                            QrCodeVController.selectedObjectId = self.selectedObjectId
                            Global.appdel.navigation?.pushViewController(QrCodeVController, animated: true)
                            self.giftViewPresent.isHidden = true
                        }
                        return
                    }
                }
                
                if (dict["FLAG"] as! Bool){
                    let arrCard = (dict["bt_card_details"] as? NSArray)?.reversed()
                    if (arrCard?.count)! > 0{
                        for element in arrCard! {
                            if let dict = element as? NSDictionary {
                                let cardDetail = shareCraditCard()
                                cardDetail.cardType = dict.object(forKey: "cardType") as? String ?? ""
                                cardDetail.card_number = dict.object(forKey: "card_number") as? String ?? ""
                                cardDetail.exipry = dict.object(forKey: "exipry") as? String ?? ""
                                cardDetail.exipry_month = dict.object(forKey: "exipry_month") as? String ?? ""
                                cardDetail.exipry_year = dict.object(forKey: "exipry_year") as? String ?? ""
                                cardDetail.name = dict.object(forKey: "name") as? String ?? ""
                                cardDetail.token_id = dict.object(forKey: "token_id") as? String ?? ""
                                self.arrCardList.add(cardDetail)
                            }
                        }
                        self.storeIndex  = 0
                        self.add_btn.isHidden = false
                        self.btnStartRide.isHidden = false
                        self.addCardContainerView.isHidden = true
                    }else{
                        self.addCardContainerView.isHidden = false
                        self.add_btn.isHidden = true
                        self.btnStartRide.isHidden = true
                    }
                }else {
                    self.addCardContainerView.isHidden = false
                    self.add_btn.isHidden = true
                    self.btnStartRide.isHidden = true
                }
                self.previousCardImage = ""
                self.isResponed = true
                self.tblCard.reloadData()
            }
        }) { (error) in
            
        }
    }
    
    func createCustomerApiCall(){
        let dictParamter : NSMutableDictionary = NSMutableDictionary()
        dictParamter.setValue(StaticClass.sharedInstance.strUserId ,forKey:"user_id")
        dictParamter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("createCustomer", parameters: dictParamter, showLoder: true, successBlock: { (response) in
            if let dict = response as? NSDictionary {
                
                if dict["FORCE_TO_UPDATE"] != nil{
                    let isActive = "\(dict["FORCE_TO_UPDATE"] ?? "0")"
                    print("force update ",isActive)
                    if (isActive  == "1") {
                        let alert = GlobalAlert(nibName: "GlobalAlert", bundle: nil)
                        alert.modalPresentationStyle = .overFullScreen
                        alert.message = dict["MESSAGE"] as? String ?? ""
                        Global.appdel.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        StaticClass.sharedInstance.HideSpinner()
                        return
                    }
                }
                
                if (dict["IS_ACTIVE"] as! Bool){
                    self.strCustomerID = dict["bt_customer_id"] as? String ?? ""
                    StaticClass.sharedInstance.saveToUserDefaults(dict["bt_customer_id"] as! String? as AnyObject? , forKey: Global.g_UserData.Customer_ID)
                    self.craditCardListApiCall()
                }
            }
        }) { (error) in
            
        }
    }
    
    func getValidTokerFromAPIforBrainTree() {
        APICall.shared.getWeb("createClientToken", withLoader: true, successBlock: { (responseObj) in
            if let dictObj = responseObj as? NSDictionary {
                if let success = dictObj["FLAG"] as? Bool{
                    if (success) {
                        StaticClass.sharedInstance.saveToUserDefaults(dictObj["clientToken"] as! String? as AnyObject? , forKey: Global.g_UserData.CreateToken)
                        let strAPIkey = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.CreateToken)
                        self.braintreeClient = BTAPIClient(authorization: strAPIkey as? String ?? "")
                        self.showDropIn(clientTokenOrTokenizationKey: strAPIkey as? String ?? "")
                    }
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dictObj["MESSAGE"] as? String ?? "")
                }
            }
        }) { (error) in
            
        }
    }
    
    func createCardAPICalled(nonceID:String) {
        
        let dictParamter : NSMutableDictionary = NSMutableDictionary()
        
        dictParamter.setValue(StaticClass.sharedInstance.strUserId ,forKey:"user_id")
        dictParamter.setValue(StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID), forKey: "customerId")
        dictParamter.setValue(self.strGetToken, forKey: "nounce")
        dictParamter.setValue("US", forKey: "countryName")
        dictParamter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("createCard", parameters: dictParamter, showLoder: true, successBlock:  { (responseOBJ) in
            if let dict = responseOBJ as? NSDictionary {
                if (dict["FLAG"] as! Bool) {
                    self.alertBox("Success", "Card added successfully") {
                        self.craditCardListApiCall()
                    }
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"]as? String ?? "", vc: self)
                }
            }
        }) { (error) in
            
        }
    }
}

//MARK: - TableView Delegate's
extension BookingPaymentVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrCardList.count == 0 && self.isResponed == false{
            return 10
        }else{
            return arrCardList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width*0.532
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tblCard_height.constant = self.tblCard.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.numberOfReferral > 0{
            return 58
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.numberOfReferral > 0 && self.arrCardList.count > 0{
            referralView = Bundle.main.loadNibNamed("ReferralView", owner: nil, options: [:])?.first as? ReferralView
            referralView?.frame = CGRect(x: 2, y: 2, width: tableView.frame.width - 2, height: tableView.frame.height - 2)
            referralView?.bookingPaymentVc = self
            if self.referralSelected == 1{
                referralView?.checkBox_btn.setImage(UIImage(named: "checked_blue"), for: .normal)
            }
            referralView?.numberOfReferral_lbl.text = "User Free Rental (\(numberOfReferral) Rentals Left)"
            return referralView
        }else{
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: tableView.frame.size.height))
        backView.backgroundColor = UIColor.white
        
        let frame = tableView.rectForRow(at: indexPath)
        
        let myImage = UIButton(frame: CGRect(x: 10, y: frame.size.height/2-20, width: 40, height: 40))
        myImage.backgroundColor = UIColor.red
        myImage.setImage(UIImage(named: "delete_white")!, for: .normal)
        myImage.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        myImage.layer.cornerRadius = 20
        backView.addSubview(myImage)
        
        let label = UILabel(frame: CGRect(x: myImage.frame.origin.x, y: (myImage.frame.origin.y + myImage.frame.height) + 4, width: myImage.frame.width, height: 15))
        label.text = "Delete"
        label.textColor = UIColor.red
        label.font = UIFont.init(name: "AvenirNext-Regular", size: 12.0)
        label.textAlignment = .center
        backView.addSubview(label)
        
        let imgSize: CGSize = tableView.frame.size
        UIGraphicsBeginImageContextWithOptions(imgSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        backView.layer.render(in: context!)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let deleteAction = UITableViewRowAction(style: .normal, title: " ") {
            (action, indexPath) in
            print("Delete Tapped")
            self.btnDeleteClicked(index: indexPath.row)
        }
        
        deleteAction.backgroundColor = UIColor(patternImage: newImage)
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"AddCardTableViewCell") as! AddCardTableViewCell
        
        Singleton.showSkeltonViewOnViews(viewsArray: [cell.cardImage,cell.cardHolderName_lbl,cell.cardNumber_lbl,cell.expireDate_lbl,cell.cardType_Img,cell.radioImg])
        
        if self.arrCardList.count > 0{
            
            Singleton.hideSkeltonViewFromViews(viewsArray: [cell.cardImage,cell.cardHolderName_lbl,cell.cardNumber_lbl,cell.expireDate_lbl,cell.cardType_Img,cell.radioImg])
            
            let cardDetail = arrCardList.object(at: indexPath.row) as! shareCraditCard
            let checkCardType = (arrCardList.object(at: indexPath.row) as! shareCraditCard).cardType
            
            cell.cardHolderName_lbl.text = cardDetail.name
            cell.cardNumber_lbl.text = "XXXX      XXXX      XXXX      \(cardDetail.card_number)"
            cell.expireDate_lbl.text = cardDetail.exipry_month + "/" + cardDetail.exipry_year
            
            if checkCardType == "Visa" {
                cell.cardType_Img.image = UIImage(named: CardTypeValue.Visa.strImg)
            } else if checkCardType == "Mastro" {
                cell.cardType_Img.image = UIImage(named: CardTypeValue.Mastro.strImg)
            }else if checkCardType == "American Express" {
                cell.cardType_Img.image = UIImage(named: CardTypeValue.American.strImg)
            }else if checkCardType == "MasterCard" {
                cell.cardType_Img.image = UIImage(named: CardTypeValue.Master.strImg)
            }else if checkCardType == "Discover" {
                cell.cardType_Img.image = UIImage(named: CardTypeValue.Discover.strImg)
            }else if checkCardType == "Other" {
                cell.cardType_Img.image = UIImage(named: CardTypeValue.Other.strImg)
            }
            
            if self.previousCardImage == "card_1"{
                cell.cardImage.image = UIImage(named: "card_2")
                self.previousCardImage = "card_2"
            }else if self.previousCardImage == "card_2"{
                cell.cardImage.image = UIImage(named: "card_3")
                self.previousCardImage = "card_3"
            }else{
                cell.cardImage.image = UIImage(named: "card_1")
                self.previousCardImage = "card_1"
            }
            
            if self.arrCardList.count == 1{
                cell.radioImg.isHighlighted = false
                self.selectCard = true
                self.storeIndex = indexPath.row
            }else if indexPath.row == 0{
                self.storeIndex = indexPath.row
                self.selectCard = true
                cell.radioImg.isHighlighted = false
            }else{
                if storeIndex == indexPath.row{
                    cell.radioImg.isHighlighted = false
                    self.selectCard = true
                }else{
                    cell.radioImg.isHighlighted = true
                }
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.storeIndex = indexPath.row
        
        for i in 0..<self.arrCardList.count{
            self.cardCell = self.tblCard.cellForRow(at: IndexPath(row: i, section: 0))as! AddCardTableViewCell
            if indexPath.row == i{
                self.cardCell.radioImg.isHighlighted = false
                self.selectCard = true
            }else{
                self.cardCell.radioImg.isHighlighted = true
            }
        }
        
    }
    
}

//MARK: - Check Bluetooth Delegate's
extension BookingPaymentVC: CheckBluetoothStatusDelegate{
    func response(status: Bool) {
        if status{
            if let status =  UserDefaults.standard.value(forKey: "dont_show_on_linka_view")as? Bool, status == true{
                Global().delay(delay: 0.2) {
                    let QrCodeVController = QRCodeScaneVC(nibName: "QRCodeScaneVC", bundle: nil)
                    QrCodeVController.sharedCreditCardObj = self.sharedCreditCardObj
                    QrCodeVController.isReferralApply = self.referralSelected
                    QrCodeVController.selectedObjectId = self.selectedObjectId
                    Global.appdel.navigation?.pushViewController(QrCodeVController, animated: true)
                    self.giftViewPresent.isHidden = true
                }
            }else{
                Global().delay(delay: 0.2) {
                    let QrCodeVController = QRCodeScaneVC(nibName: "QRCodeScaneVC", bundle: nil)
                    QrCodeVController.sharedCreditCardObj = self.sharedCreditCardObj
                    QrCodeVController.isReferralApply = self.referralSelected
                    QrCodeVController.selectedObjectId = self.selectedObjectId
                    Global.appdel.navigation?.pushViewController(QrCodeVController, animated: true)
                    self.giftViewPresent.isHidden = true
                }
            }
        }else{
            let alert = UIAlertController(title: "Alert", message: "Please turn on bluetooth to start your rental.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - Apple Pay Delegate's

extension BookingPaymentVC : PKPaymentAuthorizationViewControllerDelegate{
    
    func setupPaymentRequest(completion: @escaping (PKPaymentRequest?, Error?) -> Void) {        
        
        //        let applePayClient = BTApplePayClient(apiClient: braintreeClient!)
        // You can use the following helper method to create a PKPaymentRequest which will set the `countryCode`,
        // `currencyCode`, `merchantIdentifier`, and `supportedNetworks` properties.
        // You can also create the PKPaymentRequest manually. Be aware that you'll need to keep these in
        // sync with the gateway settings if you go this route.
        //        applePayClient.paymentRequest { (paymentRequest, error) in
        //            guard let paymentRequest = paymentRequest else {
        //                completion(nil, error)
        //                return
        //            }
        //
        //            // We recommend collecting billing address information, at minimum
        //            // billing postal code, and passing that billing postal code with all
        //            // Apple Pay transactions as a best practice.
        //            //            paymentRequest.requiredBillingContactFields = [.postalAddress]
        //
        //            // Set other PKPaymentRequest properties here
        ////            paymentRequest.requiredShippingAddressFields = PKAddressField.all
        //            paymentRequest.requiredShippingContactFields = [PKContactField.emailAddress, PKContactField.name, PKContactField.phoneNumber, PKContactField.postalAddress]
        //            paymentRequest.merchantCapabilities = .capability3DS
        //            paymentRequest.paymentSummaryItems =
        //                [
        //                    PKPaymentSummaryItem(label: "Test", amount: NSDecimalNumber(string: "1")),
        //                    // Add add'l payment summary items...
        //                    //                    PKPaymentSummaryItem(label: "Tops", amount: NSDecimalNumber(string: "0")),
        //            ]
        //            completion(paymentRequest, nil)
        //        }
    }
    
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        // Example: Tokenize the Apple Pay payment
        //        let applePayClient = BTApplePayClient(apiClient: braintreeClient!)
        //        applePayClient.tokenizeApplePay(payment) {
        //            (tokenizedApplePayPayment, error) in
        //            guard let tokenizedApplePayPayment = tokenizedApplePayPayment else {
        //                // Tokenization failed. Check `error` for the cause of the failure.
        //
        //                // Indicate failure via completion callback.
        //                completion(PKPaymentAuthorizationStatus.failure)
        //
        //                return
        //            }
        //
        //            // Received a tokenized Apple Pay payment from Braintree.
        //
        //            // Send the nonce to your server for processing.
        //            print("nonce = \(tokenizedApplePayPayment.nonce)")
        //
        //            self.strGetToken = (tokenizedApplePayPayment.nonce)
        //            StaticClass.sharedInstance.ShowSpiner()
        //            self.createCardAPICalled(nonceID: self.strGetToken)
        //            //
        //            // If requested, address information is accessible in `payment` and may
        //            // also be sent to your server.
        //            print("billingPostalCode = \(String(describing: payment.billingContact?.postalAddress?.postalCode))")
        //
        //            // Then indicate success or failure via the completion callback, e.g.
        //            completion(PKPaymentAuthorizationStatus.success)
        //        }
    }
}
