//
//  SelectPaymentPopUpView.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 06/10/21.
//  Copyright © 2021 Self. All rights reserved.
//

protocol SelectedPaymentDelegate {
    func selectCard(cardDetail: shareCraditCard, referralSelected: Int)
}

import UIKit

class SelectPaymentPopUpView: UIView {
    
    //SelectPaymentView Outlet's
    @IBOutlet weak var selectPaymentContainerView: CustomView!
    @IBOutlet weak var selectContainerView_bottom: NSLayoutConstraint!
    @IBOutlet weak var cardListStackBackgroundView: UIView!
    @IBOutlet weak var cardListTableContainerView: UIView!
    @IBOutlet weak var freeRentalContainerView: UIView!
    @IBOutlet weak var numberOfFreeRentals_lbl: UILabel!
    @IBOutlet weak var cardListTableView: UITableView!
    @IBOutlet weak var cardListTable_height: NSLayoutConstraint!
    @IBOutlet weak var freeRentalCheckBox_btn: UIButton!
    @IBOutlet weak var chooseOther_btn: UIButton!
    @IBOutlet weak var next_btn: CustomButton!
    @IBOutlet weak var backGround_btn: UIButton!
        
    var selectedCard: shareCraditCard?
    var delegate: SelectedPaymentDelegate?
    var referralSelected = 0
    
    //MARK: - @IBAction
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case chooseOther_btn:
            break
        case next_btn:
            self.delegate?.selectCard(cardDetail: self.selectedCard ?? shareCraditCard(), referralSelected: self.referralSelected)
            self.closeView()
            break
        case backGround_btn:
            self.closeView()
        case self.freeRentalCheckBox_btn:
            if self.freeRentalCheckBox_btn.tag == 0{
                self.freeRentalCheckBox_btn.tag = 1
                self.referralSelected = 1
                self.freeRentalCheckBox_btn.setImage(UIImage(named: "checked_blue"), for: .normal)
            }else{
                self.freeRentalCheckBox_btn.tag = 0
                self.referralSelected = 0
                self.freeRentalCheckBox_btn.setImage(UIImage(named: "unchecked_gray"), for: .normal)
            }
            break
        default:
            break
        }
        
    }
    
    
    func registerTableCell(){
        self.cardListTableView.register(UINib(nibName: "CardsListCell", bundle: nil), forCellReuseIdentifier: "CardsListCell")
        self.cardListTableView.delegate = self
        self.cardListTableView.dataSource = self
    }
    
    func loadContent(){
        if AppLocalStorage.sharedInstance.application_gradient{
            self.next_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.next_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        self.cardListStackBackgroundView.backgroundColor = CustomColor.primaryColor
        self.chooseOther_btn.setTitleColor(CustomColor.primaryColor, for: .normal)
        self.next_btn.circleObject()
    }
    
    func closeView(){
        UIView.animate(withDuration: 0.2) {
            self.selectContainerView_bottom.constant -= 500
            self.layoutIfNeeded()
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
}

extension SelectPaymentPopUpView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.shared.cardListsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cardListTableView.dequeueReusableCell(withIdentifier: "CardsListCell")as! CardsListCell
        let cardDetail = Singleton.shared.cardListsArray[indexPath.row]
        let checkCardType = String(describing: cardDetail.cardType)
        if checkCardType == "Visa" {
            cell.cardImg.image = UIImage(named: CardTypeValue.Visa.strImg)
        } else if checkCardType == "Mastro" {
            cell.cardImg.image = UIImage(named: CardTypeValue.Master.strImg)
        }else if checkCardType == "American Express" {
            cell.cardImg.image = UIImage(named: CardTypeValue.American.strImg)
        }else if checkCardType == "MasterCard" {
            cell.cardImg.image = UIImage(named: CardTypeValue.Master.strImg)
        }else if checkCardType == "Discover" {
            cell.cardImg.image = UIImage(named: CardTypeValue.Discover.strImg)
        }else if checkCardType == "Other" {
            cell.cardImg.image = UIImage(named: CardTypeValue.Other.strImg)
        }else{
            cell.cardImg.image = UIImage(named: CardTypeValue.Master.strImg)
        }
        
        cell.cardNumber_lbl.text = "xxxx    xxxx    xxxx    \(cardDetail.card_number)"
        if indexPath.row == 0{
            self.selectedCard = cardDetail
            cell.containerView.backgroundColor = CustomColor.primaryColor
            cell.cardNumber_lbl.textColor = UIColor.white
        }else{
            cell.containerView.backgroundColor = UIColor.white
            cell.cardNumber_lbl.textColor = UIColor.darkGray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCard = Singleton.shared.cardListsArray[indexPath.row]
        
        for i in 0..<Singleton.shared.cardListsArray.count{
            let cell = self.cardListTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! CardsListCell
            if i == indexPath.row{
                cell.containerView.backgroundColor = CustomColor.primaryColor
                cell.cardNumber_lbl.textColor = UIColor.white
            }else{
                cell.containerView.backgroundColor = UIColor.white
                cell.cardNumber_lbl.textColor = UIColor.darkGray
            }
        }
        
    }
    
}

extension UIViewController{
    
    func loadSelectPaymentView(){
        if let view = Bundle.main.loadNibNamed("SelectPaymentPopUpView", owner: nil, options: [:])?.first as? SelectPaymentPopUpView{
            view.delegate = self as? SelectedPaymentDelegate
            view.loadContent()
            view.registerTableCell()
            view.frame = self.view.bounds
            self.view.addSubview(view)
            UIView.animate(withDuration: 0.2) {
                view.selectContainerView_bottom.constant = -15
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
