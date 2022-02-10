//
//  PriceContainerView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 8/13/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class PriceContainerView: UIView {
    
    @IBOutlet weak var priceDetailView: CustomView!    
    @IBOutlet weak var priceDetailTitle_lbl: UILabel!
    @IBOutlet weak var closeRentalPrice_btn: UIButton!
    @IBOutlet weak var firstHourFeeValue_lbl: UILabel!
    @IBOutlet weak var pricePerHourValue_lbl: UILabel!
    @IBOutlet weak var buyMembership_btn: UIButton!
    @IBOutlet weak var startRental_btn: UIButton!
    @IBOutlet weak var buy_startRental_stackView: UIStackView!
    
    @IBOutlet weak var membershipPriceView: CustomView!
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var closeMembershipPriceView_btn: UIButton!
    @IBOutlet weak var membership_lbl: UILabel!
    @IBOutlet weak var enjoyFirstMinutesText_lbl: UILabel!
    @IBOutlet weak var afterPrice_lbl: UILabel!
    @IBOutlet weak var startRental2_btn: CustomButton!
    @IBOutlet weak var buy_startRental2_stackView: UIStackView!
    
//    @IBOutlet weak var promoCodeContainerView: UIView!
    @IBOutlet weak var promoCodeCheck_btn: UIButton!
    @IBOutlet weak var promoCodeText_lbl: UILabel!
    @IBOutlet weak var promoCodeResponseText_lbl: UILabel!
        
    var controller = ""
    var qrCode: QRCodeScaneVC!
    var startBooking: StartBooking!
    
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender{
        
        case closeRentalPrice_btn, closeMembershipPriceView_btn:
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.y += self.frame.height
            }) { (_) in
                if self.controller == "start_booking"{
                    self.startBooking.deinitialize()
                }else if self.controller == "qr_code"{
                    self.qrCode.captureSession.startRunning()
                }
                self.removeFromSuperview()
            }
            break
        case startRental_btn, startRental2_btn:
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.y += self.frame.height
            }) { (_) in
                if self.controller == "qr_code"{
                    self.qrCode.tappedConfirmBooking = true
                    self.qrCode.objectReservationApiCall(strObjectId: self.qrCode.objectDetail.strId)
                }else{
                    self.startBooking.startSpinner()
                    self.startBooking.tappedConfirmBooking = true
                    self.startBooking.objectReservationApiCall(strObjectId: self.startBooking.objectDetail.strId)
                }
                self.removeFromSuperview()
            }
            break
        case buyMembership_btn:
            
            let vc = HubListVC(nibName: "HubListVC", bundle: nil)
            if controller == "qr_code"{
                vc.strPartnerID = self.qrCode.objectDetail.strPartnerID
                vc.strPartnerName = self.qrCode.objectDetail.partner_name
            }else{
                vc.strPartnerID = self.startBooking.objectDetail.strPartnerID
                vc.strPartnerName = self.startBooking.objectDetail.partner_name
            }
            if self.controller == "qr_code"{
                self.qrCode.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.startBooking.viewController?.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case promoCodeCheck_btn:
            if self.promoCodeCheck_btn.tag == 0{
                if self.controller == "qr_code"{
                    self.loadPromoCodeView(vc: self.qrCode, partner_id: self.qrCode.objectDetail.strPartnerID)
                }else{
                    self.loadPromoCodeView(vc: self.startBooking.viewController, partner_id: self.startBooking.objectDetail.strPartnerID)
                }
                self.promoCodeResponseText_lbl.text = ""
            }else{
                self.promoCodeText_lbl.text = "I have a Promo Code"
                self.promoCodeResponseText_lbl.text = ""
                self.promoCodeCheck_btn.tag = 0
                self.promoCodeCheck_btn.setTitle("", for: .normal)
                self.promoCodeCheck_btn.setTitleColor(.darkGray, for: .normal)
            }
        default:
            break
        }
        
    }
    
    func loadContent(){
        self.startRental_btn.circleObject()
        self.buyMembership_btn.circleObject()
        self.startRental2_btn.circleObject()
        self.promoCodeResponseText_lbl.text = ""
        
        if self.controller == "qr_code"{
            if self.qrCode.objectDetail.promotional_header == ""{
                self.buyMembership_btn.isHidden = false
                self.priceDetailView.isHidden = false
                self.buy_startRental_stackView.isHidden = false
                self.membershipPriceView.isHidden = true
                self.buy_startRental2_stackView.isHidden = true
                self.closeMembershipPriceView_btn.isHidden = true
                self.closeRentalPrice_btn.isHidden = false
            }else{
                self.buyMembership_btn.isHidden = true
                self.membershipPriceView.isHidden = false
                self.buy_startRental2_stackView.isHidden = false
                self.priceDetailView.isHidden = true
                self.buy_startRental_stackView.isHidden = true
                self.closeMembershipPriceView_btn.isHidden = false
                self.closeRentalPrice_btn.isHidden = true
            }
            self.title_lbl.text = self.qrCode.objectDetail.promotional_header
            self.firstHourFeeValue_lbl.text = " $\(self.qrCode.objectDetail.rental_fee)/\(self.qrCode.objectDetail.duration_for_rental_fee)Mins"
            self.pricePerHourValue_lbl.text = "$\(self.qrCode.objectDetail.price_per_hour)"
            self.membership_lbl.text = self.qrCode.objectDetail.promotional
            self.enjoyFirstMinutesText_lbl.text = self.qrCode.objectDetail.promotional_hours
            self.afterPrice_lbl.text = "After that: $\(Int(round(Double(self.qrCode.objectDetail.rental_fee)!)))/h"
        }else{
            if self.startBooking.objectDetail.promotional_header == ""{                
                self.priceDetailView.isHidden = false
                self.buy_startRental_stackView.isHidden = false
                self.membershipPriceView.isHidden = true
                self.buy_startRental2_stackView.isHidden = true
                self.closeMembershipPriceView_btn.isHidden = true
                self.closeRentalPrice_btn.isHidden = false
            }else{
                self.membershipPriceView.isHidden = false
                self.buy_startRental2_stackView.isHidden = false
                self.priceDetailView.isHidden = true
                self.buy_startRental_stackView.isHidden = true
                self.closeMembershipPriceView_btn.isHidden = false
                self.closeRentalPrice_btn.isHidden = true
            }
            if self.startBooking.objectDetail.show_member_button == "0"{
                self.buyMembership_btn.isHidden = true
            }else{
                self.buyMembership_btn.isHidden = false
            }
            self.title_lbl.text = self.startBooking.objectDetail.promotional_header
            self.firstHourFeeValue_lbl.text = " $\(self.startBooking.objectDetail.rental_fee)/\(self.startBooking.objectDetail.duration_for_rental_fee)Mins"
            self.pricePerHourValue_lbl.text = "$\(self.startBooking.objectDetail.price_per_hour)"
            self.membership_lbl.text = self.startBooking.objectDetail.promotional
            self.enjoyFirstMinutesText_lbl.text = self.startBooking.objectDetail.promotional_hours
            self.afterPrice_lbl.text = "After that: $\(Int(round(Double(self.startBooking.objectDetail.price_per_hour)!)))/h"
        }
        
    }
    
}

//MARK: - PromoCode View Delegate's
extension PriceContainerView: PromoCodeDelegate{
    func didGetPromoCode(code: String, msg: String, response: Bool, promo_id: String) {
        self.promoCodeResponseText_lbl.text = msg
        if self.controller == "qr_code"{
            self.qrCode.promoId = promo_id
        }else{
            self.startBooking.promoCode = promo_id
        }
        if response{
            self.promoCodeText_lbl.text = "Apply Promo Code"
            self.promoCodeResponseText_lbl.textColor = CustomColor.customAppGreen
            self.promoCodeCheck_btn.tag = 1
            self.promoCodeCheck_btn.setTitle("", for: .normal)
            self.promoCodeCheck_btn.setTitleColor(CustomColor.customBlue, for: .normal)
        }else{
            self.promoCodeText_lbl.text = "I have a Promo Code"
            self.promoCodeResponseText_lbl.textColor = CustomColor.customAppRed
            self.promoCodeCheck_btn.tag = 0
            self.promoCodeCheck_btn.setTitle("", for: .normal)
        }
    }
}

extension UIViewController{
    
    func loadPriceContainerView(_ vc: UIViewController = UIViewController()){
        
        let view = Bundle.main.loadNibNamed("PriceContainerView", owner: nil, options: [:])?.first as! PriceContainerView
        view.frame = self.view.bounds
        if self.isKind(of: QRCodeScaneVC.self){
            view.qrCode = vc as? QRCodeScaneVC
            view.controller = "qr_code"
        }else{
            view.startBooking = vc as? StartBooking
            view.controller = "start_booking"
        }
        view.loadContent()
        view.frame.origin.y += view.frame.height
        self.view.addSubview(view)
        
        UIView.animate(withDuration: 0.3) {
            view.frame.origin.y = 0
        }
    }
    
}
