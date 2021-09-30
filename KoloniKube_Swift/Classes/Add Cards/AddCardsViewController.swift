//
//  AddCardsViewController.swift
//  KoloniKube_Swift
//
//  Created by Tops on 21/10/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit
import PureLayout
import BraintreeDropIn
import Braintree
import PassKit


class AddCardsViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var addCard_btn: UIButton!
    @IBOutlet weak var skip_btn: UIButton!
    
    var strCustomerID = ""
    var strGetToken: String = ""
    var braintreeClient: BTAPIClient?
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AddCardsViewController")
        self.loadNavigation()
        self.loadContents()
        self.createCustomerApiCall()
    }
    
    //MARK: - @IBAction's
    @IBAction func tapAddCardBtn(_ sender: UIButton) {
        self.getValidTokerFromAPIforBrainTree()
    }
    
    @IBAction func tapSkipBtn(_ sender: UIButton) {
        Global.appdel.setUpSlideMenuController()
    }
    
    //MARK: - Custom Function's
    
    func loadContents(){
        
        self.addCard_btn.circleObject()
        
    }
    
    func loadNavigation(){
        let navBar = Bundle.main.loadNibNamed("NavigationView", owner: nil, options: [:])?.first as? NavigationView
        navBar?.frame = self.headerView.bounds
        navBar?.skip_btn.isHidden = true
        navBar?.back_btn.isHidden = true
        navBar?.navigation = self.navigationController
        navBar?.title_lbl.text = "Add payment"
        self.headerView.addSubview(navBar!)
    }
    
    
    //MARK: - Web Api's
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
                
                if (dict["IS_ACTIVE"] as? Bool ?? false){
                    //self.getValidTokerFromAPIforBrainTree()
                    self.strCustomerID = dict["bt_customer_id"] as? String ?? ""
                    StaticClass.sharedInstance.saveToUserDefaults(dict["bt_customer_id"] as! String? as AnyObject? , forKey: Global.g_UserData.Customer_ID)
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
                if result.paymentDescription.contains("ending in")
                {
                    if let nonce = selectedPaymentMethod?.nonce
                    {
                        self.strGetToken = (nonce)
                        StaticClass.sharedInstance.ShowSpiner()
                        self.createCardAPICalled(nonceID: self.strGetToken)
                    }
                    else
                    {
                        StaticClass.sharedInstance.HideSpinner()
                    }
                }
                else if result.paymentDescription == "Apple Pay"
                {
                    self.setupPaymentRequest { (paymentRequest, error) in
                        
                        guard error == nil else {
                            // Handle error
                            return
                        }
                        
                        // Example: Promote PKPaymentAuthorizationViewController to optional so that we can verify
                        // that our paymentRequest is valid. Otherwise, an invalid paymentRequest would crash our app.
                        if let vc = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest!)
                            as PKPaymentAuthorizationViewController?
                        {
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
    
    func createCardAPICalled(nonceID:String) {
        
        let dictParamter : NSMutableDictionary = NSMutableDictionary()
        dictParamter.setValue(StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID), forKey: "customerId")
        dictParamter.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        dictParamter.setValue(self.strGetToken, forKey: "nounce")
        dictParamter.setValue("US", forKey: "countryName")
        dictParamter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("createCard", parameters: dictParamter, showLoder: true, successBlock: { (responseOBJ) in
            if let dict = responseOBJ as? NSDictionary {
                if (dict["FLAG"] as! Bool) {
                    self.alertBox("Success", "Card added successfully") {
                        Global.appdel.setUpSlideMenuController()
                    }
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"]as? String ?? "", vc: self)
                }
            }
        }) { (error) in
            StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "", vc: self)
        }
    }
    
}

//MARK: - Apple Pay Delegate's

extension AddCardsViewController : PKPaymentAuthorizationViewControllerDelegate
{
    
    func setupPaymentRequest(completion: @escaping (PKPaymentRequest?, Error?) -> Void) {
        
        //        let applePayClient = BTApplePayClient(apiClient: braintreeClient!)
        //        // You can use the following helper method to create a PKPaymentRequest which will set the `countryCode`,
        //        // `currencyCode`, `merchantIdentifier`, and `supportedNetworks` properties.
        //        // You can also create the PKPaymentRequest manually. Be aware that you'll need to keep these in
        //        // sync with the gateway settings if you go this route.
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
        //                    PKPaymentSummaryItem(label: "Test", amount: NSDecimalNumber(string: "2")),
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
        //                // Indicate failure via completion callback.
        //                completion(PKPaymentAuthorizationStatus.failure)
        //                return
        //            }
        //            // Received a tokenized Apple Pay payment from Braintree.
        //            // Send the nonce to your server for processing.
        //            print("nonce = \(tokenizedApplePayPayment.nonce)")
        //            // If requested, address information is accessible in `payment` and may
        //            // also be sent to your server.
        //            print("billingPostalCode = \(String(describing: payment.billingContact?.postalAddress?.postalCode))")
        //            // Then indicate success or failure via the completion callback, e.g.
        //            completion(PKPaymentAuthorizationStatus.success)
        //        }
    }
}
