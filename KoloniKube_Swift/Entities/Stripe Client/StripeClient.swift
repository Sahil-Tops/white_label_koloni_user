//
//  StripeClient.swift
//  KoloniKube_Swift
//
//  Created by Sam on 18/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import Foundation
import UIKit
import Stripe

protocol StripeClientDelegate {
    func responseFromPayment(response: Bool)
}

class StripeClient: NSObject{
    
    var viewController: UIViewController?
    var delegate: StripeClientDelegate?
    var nav: UINavigationController?
    var paymentSheet: PaymentSheet?
    var checkoutUrl = ""
    
    init(vc: UIViewController) {
        super.init()
        self.viewController = vc
        self.delegate = vc as? StripeClientDelegate        
    }
    
    func getPaymentDetail(urlStr: String, outputBlock: @escaping(_ response: Bool)-> Void){
        if let url = URL(string: urlStr){
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else{
                    outputBlock(false)
                    return
                }
                if let dict = json as? [String: Any]{
                    let customerId = dict["customer"] as? String ?? ""
                    let customerEphemeralKeySecret = dict["ephemeralKey"] as? String ?? ""
                    let paymentIntentClientSecret = dict["paymentIntent"] as? String ?? ""
                    let publishableKey = dict["publishableKey"] as? String ?? ""
                    
                    STPAPIClient.shared.publishableKey = publishableKey
                    var configuration = PaymentSheet.Configuration()
                    configuration.merchantDisplayName = "Koloni"
                    configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
                    configuration.allowsDelayedPaymentMethods = true
                    self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
                    outputBlock(true)
                }
            }
            task.resume()
        }
    }
    
    func openPaymentController(){
        self.paymentSheet?.present(from: self.viewController!, completion: { result in
            switch result{
            case .completed:
                break
            case .canceled:
                break
            default: break
            }
        })
    }
    
    //    func presentCardController(vc: UIViewController){
    //        self.viewController = vc
    //        let config = STPPaymentConfiguration()
    //        let controller = STPAddCardViewController(configuration: config, theme: STPTheme.defaultTheme)
    //        controller.delegate = self
    //        self.nav = UINavigationController(rootViewController: controller)
    //        self.viewController?.present(self.nav!, animated: true, completion: nil)
    //    }
    //
    //    func createSources(amount: Int, returnUrl: String, country: String, descriptionStr: String){
    //
    //        let params = STPSourceParams.sofortParams(withAmount: amount, returnURL: returnUrl, country: country, statementDescriptor: descriptionStr)
    //        STPAPIClient.shared.createSource(with: params) { sources, error in
    //            print("Sources: ", sources ?? "")
    //        }
    //    }
    //
    //    func createToken(name: String, number: String, expMM: Int, expYY: Int, cvc: String){
    //        let cardParams = STPCardParams()
    //        cardParams.name = name
    //        cardParams.number = number
    //        cardParams.expMonth = UInt(expMM)
    //        cardParams.expYear = UInt(expYY)
    //        cardParams.cvc = cvc
    //
    //        STPAPIClient.shared.createToken(withCard: cardParams) { token, error in
    //            if error == nil{
    //                print("Payment Token: ", token ?? "")
    //            }else{
    //                print("Token error: ", error?.localizedDescription ?? "")
    //            }
    //        }
    //    }
}

// MARK: - Stripe Delegate's
//extension StripeClient: STPAddCardViewControllerDelegate{
//    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
//        print("addCardViewControllerDidCancel")
//        self.nav?.dismiss(animated: true, completion: nil)
//    }
//
//    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
//        print("Stripe Id: ", paymentMethod.stripeId)
//        self.nav?.dismiss(animated: true, completion: nil)
//    }
//
//    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: (Error?) -> Void) {
//        print("Payment Token: ", token)
//    }
//}
