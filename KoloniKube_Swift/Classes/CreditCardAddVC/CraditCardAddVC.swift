//
//  CraditCardAddVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 6/2/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import PureLayout
import SkeletonView
import BraintreeDropIn
import Braintree
import PassKit

protocol ClassCardDetailPasssDelegate: class {
    func changeCardDetail(shareCardDetail :shareCraditCard)
}

class CraditCardAddVC: UIViewController {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tblCard: UITableView!
    @IBOutlet weak var tblCard_height: NSLayoutConstraint!
    @IBOutlet weak var btnBuyPlan: UIButton!
    @IBOutlet weak var add_btn: UIButton!
    @IBOutlet weak var buyBtn_height: NSLayoutConstraint!
    
    //Add Card Container View
    @IBOutlet weak var addCardContainerView: UIView!
    @IBOutlet weak var addCard_btn: UIButton!
    
    weak var delegate: ClassCardDetailPasssDelegate?
    let arrCardList = NSMutableArray ()
    var storeIndex : Int = 100
    var isFromHubPlanScreen = Bool()
    var membershipPlanId = String()
    var membershipName = ""
    var saveBarButton : UIBarButtonItem = UIBarButtonItem ()
    var cardFormNavigationViewController : UINavigationController = UINavigationController()
    var strGetToken: String = ""
    var strCustomerID = ""
    var selectCard : Bool = false
    var indexPathSelection : Int = 0
    var isStatusCardEdit = Bool()
    let shareDevice = ShareDevice()
    let bike = ShareBikeData()
    let shareCreditCardOBJ = shareCraditCard()
    var isFromFinishRental = Bool()
    var isFromProfileView = Bool()
    var isFromSignUpVc = Bool()
    var cardCell = AddCardTableViewCell()
    var strCreditCardToken = String()
    var previousCardImage = ""
    
    var braintreeClient: BTAPIClient?
//    var applePayClient: BTApplePayClient?
    var venmoDriver: BTVenmoDriver?
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CraditCardAddVC")
        tblCard.register(UINib(nibName: "AddCardTableViewCell", bundle: nil), forCellReuseIdentifier: "AddCardTableViewCell")
        if isFromHubPlanScreen == true {
            self.btnBuyPlan.isHidden = false
            self.buyBtn_height.constant = 40
        } else  {
            self.btnBuyPlan.isHidden = true
            self.buyBtn_height.constant = 0
        }
        self.loadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        strCustomerID  = (StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID) as? String ?? "")!
        if self.isMovingToParent {
            if strCustomerID  == "" {
                createCustomerApiCall()
            } else {
                if arrCardList.count > 0 {
                    
                }else {
                    craditCardListApiCall()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - @IBAction's
    
    @IBAction func btnBuyClick(_ sender: UIButton) {
        if self.strCreditCardToken == "" {
            let alert = UIAlertController(title: "Alert", message: "Please select card", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            self.callWebserviceForHubList(isLoader: true)
        }
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapAddBtn(_ sender: UIButton) {
        self.getValidTokerFromAPIforBrainTree()
    }
    
    @IBAction func tapAddCardBtn(_ sender: UIButton) {
        self.getValidTokerFromAPIforBrainTree()
    }
    
    
    //MARK: - Custom Function's
    
    func loadUI(){
        if AppLocalStorage.sharedInstance.application_gradient{
            self.bgImage.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.addCard_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.add_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.btnBuyPlan.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.bgImage.backgroundColor = CustomColor.primaryColor
            self.addCard_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
            self.add_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
            self.btnBuyPlan.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        
    }
    
    func loadContent(){
        self.btnBuyPlan.circleObject()
        self.add_btn.circleObject()
        self.addCard_btn.circleObject()
    }
    
}

//MARK: - Web Api's
extension CraditCardAddVC{
    func callWebserviceForHubList(isLoader:Bool) {
        
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue(membershipPlanId, forKey: "plan_id")
        paramer.setValue(strCreditCardToken, forKey: "card_token")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("perchase_plan", parameters:paramer, showLoder: isLoader, successBlock:{(response) in
            if let Dict = response as? NSDictionary {
                if Dict.object(forKey: "FLAG") as! Bool {
                    self.loadMembershipPurchased(memberhip_name: self.membershipName)                    
                } else {
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: Dict.object(forKey: "MESSAGE") as? String ?? "", vc: self)
                }
            }
        }) { (error) in
            
        }
    }
    
    func createCustomerApiCall(){
        let dictParamter : NSMutableDictionary = NSMutableDictionary()
        
        dictParamter.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")        
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
                        //                        self.braintreeClient = BTAPIClient(authorization: strAPIkey as? String ?? "")
                        //                        self.venmoDriver = BTVenmoDriver(apiClient: self.braintreeClient!)
                        //                        self.venmoDriver?.authorizeAccountAndVault(false, completion: { (venmoAccount, error) in
                        //                            guard let venmoAccount = venmoAccount else {
                        //                                print("Error: \(String(describing: error))")
                        //                                return
                        //                            }
                        //
                        //                            // You got a Venmo nonce!
                        //                            print("Venmo Nonce: ", venmoAccount.nonce)
                        //                        })
                        self.showDropIn(clientTokenOrTokenizationKey: strAPIkey as? String ?? "")
                    }
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dictObj["MESSAGE"] as? String ?? "")
                }
            }
        }) { (error) in
            
        }
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.cardholderNameSetting = .required
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                let selectedPaymentMethod = result.paymentMethod
                print("Heloooooooooo---", result.paymentDescription)
                self.braintreeClient = BTAPIClient(authorization: clientTokenOrTokenizationKey)
                if result.paymentDescription.contains("ending in"){
                    if let nonce = selectedPaymentMethod?.nonce{
                        self.strGetToken = (nonce)
                        StaticClass.sharedInstance.ShowSpiner()
                        self.createCardAPICalled(nonceID: self.strGetToken)
                    }else{
                        StaticClass.sharedInstance.HideSpinner()
                    }
                }else if result.paymentDescription == "Apple Pay"{
//                    self.setupPaymentRequest { (request, error) in
//                        guard error == nil else {
//                            return
//                        }
//                        if let paymentRequest = request{
//                            if let vc = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
//                                as PKPaymentAuthorizationViewController?{
//                                vc.delegate = self
//                                self.present(vc, animated: true, completion: nil)
//                            } else {
//                                print("Error: Payment request is invalid.")
//                            }
//                        }
//                    }
                }
                
            }
            
            controller.dismiss(animated: true, completion: nil)
        }
        DispatchQueue.main.async {
            self.present(dropIn!, animated: true, completion: nil)
        }
    }
    
    func createCardAPICalled(nonceID:String) {
        let dictParamter : NSMutableDictionary = NSMutableDictionary()
        dictParamter.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        dictParamter.setValue(StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID), forKey: "customerId")
        dictParamter.setValue(self.strGetToken, forKey: "nounce")
        dictParamter.setValue("US", forKey: "countryName")
        dictParamter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("createCard", parameters: dictParamter, showLoder: true, successBlock: { (responseOBJ) in
            if let dict = responseOBJ as? NSDictionary {
                if (dict["FLAG"] as? Bool ?? false) {
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
    
    func callDeleteCardAPI_call(intSelectedTag:Int) {
        let cardDetail = arrCardList.object(at: intSelectedTag) as! shareCraditCard
        let dictParamter : NSMutableDictionary = NSMutableDictionary()
        
        dictParamter.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
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
    
    func craditCardListApiCall() {
        
        let dictParam : NSMutableDictionary = NSMutableDictionary()
        let strCustID = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID)as? String ?? ""
        let userId = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserID)as? String ?? ""
        dictParam.setValue(strCustID, forKey: "bt_customer")
        dictParam.setValue(userId, forKey: "user_id")
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("creditCardList", parameters: dictParam, showLoder: true, successBlock: { (responseOBJ) in
            if let dict =  responseOBJ as? NSDictionary {
                self.arrCardList.removeAllObjects()
                if (dict["FLAG"] as! Bool){
                    let arrCard = (dict["bt_card_details"] as? NSArray)!.reversed()
                    if arrCard.count > 0{
                        self.addCardContainerView.isHidden = true
                        for element in arrCard {
                            if let dict = element as? NSDictionary {
                                let cardDetail = shareCraditCard()
                                cardDetail.cardIsActive = dict.object(forKey: "card_is_active") as? String ?? ""
                                cardDetail.cardType = dict.object(forKey: "cardType") as? String ?? ""
                                cardDetail.card_number = dict.object(forKey: "card_number") as? String ?? ""
                                cardDetail.exipry = dict.object(forKey: "exipry") as? String ?? ""
                                cardDetail.exipry_month = dict.object(forKey: "exipry_month") as? String ?? ""
                                cardDetail.exipry_year = dict.object(forKey: "exipry_year") as? String ?? ""
                                cardDetail.name = dict.object(forKey: "name") as? String ?? ""
                                cardDetail.token_id = dict.object(forKey: "token_id") as? String ?? ""
                                self.arrCardList .add(cardDetail)
                            }
                        }
                    }else{
                        self.addCardContainerView.isHidden = false
                    }
                    
                } else {
                    //                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "", vc: self)
                }
                self.tblCard.reloadData()
                self.previousCardImage = ""
            }
        }) { (error) in
            StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "", vc: self)
        }
    }
}


//MARK: - Apple Pay Delegate's

extension CraditCardAddVC : PKPaymentAuthorizationViewControllerDelegate{
    
    func setupPaymentRequest(completion: @escaping (PKPaymentRequest?, Error?) -> Void) {
//        self.applePayClient = BTApplePayClient(apiClient: self.braintreeClient!)
//        self.applePayClient!.paymentRequest { (paymentRequest, error) in
//            guard let paymentRequest = paymentRequest else {
//                completion(nil, error)
//                return
//            }
//            paymentRequest.requiredBillingContactFields = [.postalAddress]
//            paymentRequest.merchantCapabilities = .capability3DS
//            paymentRequest.paymentSummaryItems =
//                [
//                    PKPaymentSummaryItem(label: "Test", amount: NSDecimalNumber(string: "1")),
//                    // Add add'l payment summary items...
//                    PKPaymentSummaryItem(label: "Demo", amount: NSDecimalNumber(string: "1")),
//                ]
//            completion(paymentRequest, nil)
//        }
    }
    
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
//        let applePayClient = BTApplePayClient(apiClient: braintreeClient!)
//        applePayClient.tokenizeApplePay(payment) {
//            (tokenizedApplePayPayment, error) in
//            guard let tokenizedApplePayPayment = tokenizedApplePayPayment else {
//                completion(PKPaymentAuthorizationStatus.failure)
//                return
//            }
//            print("Transection identifier: ", payment.token.transactionIdentifier)
//            print("nonce = \(tokenizedApplePayPayment.nonce)")
//            print("billingPostalCode = \(String(describing: payment.billingContact?.postalAddress?.postalCode))")
//            //Perform API Request Here by passing nonce token or transectionIdentifier.
//            completion(PKPaymentAuthorizationStatus.success)
//        }
    }
}

//MARK: - TableView Delegate's
extension CraditCardAddVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCardList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width*0.532
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tblCard_height.constant = self.tblCard.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"AddCardTableViewCell") as! AddCardTableViewCell
        
        if self.arrCardList.count > 0{
            
            let cardDetail = arrCardList.object(at: indexPath.row) as! shareCraditCard
            let checkCardType = (arrCardList.object(at: indexPath.row) as! shareCraditCard).cardType
            
            if isFromHubPlanScreen == true{
                cell.radioImg_width.constant = 20
                cell.radioImg.isHidden = false
            }else{
                cell.radioImg_width.constant = 0
                cell.radioImg.isHidden = true
            }
            if cardDetail.name == ""{
                cell.cardHolderName_lbl.text = "Unknown"
            }else{
                cell.cardHolderName_lbl.text = cardDetail.name
            }
            cell.cardNumber_lbl.text = "XXXX      XXXX      XXXX      \(cardDetail.card_number)"
            cell.expireDate_lbl.text = cardDetail.exipry_month + "/" + cardDetail.exipry_year
            cell.cardType_Img.image = UIImage(named: "visa_card_icn")
            
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
            
            if storeIndex == indexPath.row{
                cell.radioImg.isHighlighted = false
                let shareCraditCardOBJ = arrCardList.object(at: indexPath.row) as! shareCraditCard
                self.strCreditCardToken = shareCraditCardOBJ.token_id
            }else{
                cell.radioImg.isHighlighted = true
            }
        }
        
        return cell
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
            self.deleteCard(index: indexPath.row)
        }
        
        deleteAction.backgroundColor = UIColor(patternImage: newImage)
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.storeIndex = indexPath.row
        if self.arrCardList.count > 0{
            let shareCraditCardOBJ = arrCardList.object(at: indexPath.row) as! shareCraditCard
            self.strCreditCardToken = shareCraditCardOBJ.token_id
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
    
    func deleteCard(index: Int){
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this card?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
            self.callDeleteCardAPI_call(intSelectedTag: index)
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
