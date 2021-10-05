//
//  AssetsListingViewController.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 04/10/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class AssetsListingViewController: UIViewController {
    
    @IBOutlet weak var navigationImage: UIImageView!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noAssetFound_lbl: UILabel!
    @IBOutlet weak var bgShadow_btn: UIButton!
    
    //SelectPaymentView Outlet's
    @IBOutlet weak var selectPaymentContainerView: CustomView!
    @IBOutlet weak var selectPatmentContainerView_bottom: NSLayoutConstraint!
    @IBOutlet weak var cardListStackBackgroundView: UIView!
    @IBOutlet weak var cardListTableContainerVie: UIView!
    @IBOutlet weak var freeRentalContainerView: UIView!
    @IBOutlet weak var numberOfFreeRentals_lbl: UILabel!
    @IBOutlet weak var cardListTableView: UITableView!
    @IBOutlet weak var cardListTable_height: NSLayoutConstraint!
    @IBOutlet weak var freeRentalCheckBox_btn: UIButton!
    @IBOutlet weak var chooseOther_btn: UIButton!
    @IBOutlet weak var paymentNext_btn: CustomButton!
    
    
    var locationModel: LOCATION_DATA!
    var assetsListArray: [ASSETS_LIST] = []
    var arrCardList: [shareCraditCard] = []
    var selectedObjectId = ""
    var selectedCardDetail: shareCraditCard!
    var cardSelected = 0
    var numberOfReferralRentals = 0
    
    //Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadUI()
    }
    
    //MARK: - @IBAction
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case back_btn:
            self.navigationController?.popViewController(animated: true)
            break
        case bgShadow_btn:
            self.bgShadow_btn.isHidden = true
            self.selectPaymentContainerView.isHidden = true
            self.selectPatmentContainerView_bottom.constant += self.selectPaymentContainerView.frame.height
            self.view.layoutIfNeeded()
            break
        default:
            break
        }
        
    }
    
    //MARK: - Custom Function's
    func registerTableCell(){
        
        self.tableView.register(UINib(nibName: "AssetsTableViewCell", bundle: nil), forCellReuseIdentifier: "AssetsTableViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        self.cardListTableView.register(UINib(nibName: "CardsListCell", bundle: nil), forCellReuseIdentifier: "CardsListCell")
        self.cardListTableView.delegate = self
        self.cardListTableView.dataSource = self
                
    }
    
    func loadUI(){
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "logo_img") { (image) in
            self.logoImg.image = image
        }
        if AppLocalStorage.sharedInstance.application_gradient{
            self.navigationImage.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.paymentNext_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.navigationImage.backgroundColor = CustomColor.primaryColor
            self.paymentNext_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        self.cardListStackBackgroundView.backgroundColor = CustomColor.primaryColor
        self.paymentNext_btn.circleObject()
        self.view.layoutIfNeeded()
    }
    
    func loadContent(){
        if self.assetsListArray.count > 0{
            self.registerTableCell()
            self.tableView.isHidden = false
            self.noAssetFound_lbl.isHidden = true
            self.getCardsList_Web()
        }else{
            self.tableView.isHidden = true
            self.noAssetFound_lbl.isHidden = false
        }
    }
    
    func startRental(){
        
        if self.arrCardList.count > 0{
            self.bgShadow_btn.isHidden = false
            self.selectPaymentContainerView.isHidden = false
            self.selectPatmentContainerView_bottom.constant = -40
            self.view.layoutIfNeeded()
        }else{
            
        }
        
    }
    
}

//MARK: - Web API
extension AssetsListingViewController{
    
    func getCardsList_Web(){
        let dictParam : NSMutableDictionary = NSMutableDictionary()
        let strCustID = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID)as? String ?? ""
        dictParam.setValue(strCustID, forKey: "bt_customer")
        dictParam.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        self.selectPaymentContainerView.isHidden = true
        self.arrCardList.removeAll()
        APICall.shared.postWeb("creditCardList", parameters: dictParam, showLoder: false, successBlock: { (responseOBJ) in
            
            if let dict =  responseOBJ as? NSDictionary {
                if let flag = dict.value(forKey: "FLAG")as? Int, flag == 1{
                    
                    if let referalCount = dict["referral_count"]as? String{
                        if Int(referalCount)! == 0{
                            self.freeRentalContainerView.isHidden = true
                        }else{
                            self.freeRentalContainerView.isHidden = false
                            self.numberOfFreeRentals_lbl.text = "Free Rentals (\(referalCount) Left)"
                            self.numberOfReferralRentals = Int(referalCount)!
                            Singleton.numberOfReferralRides = referalCount
                        }
                    }
                    
                    if let bookingUserType = dict.value(forKey: "booking_user_type")as? String, bookingUserType == "1"{
                        self.arrCardList = []
                        self.cardListTable_height.constant = 0
                    }else{
                        let arrCard = (dict["bt_card_details"] as? NSArray)
                        DispatchQueue.main.async(execute: {
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
                                    self.arrCardList.append(cardDetail)
                                }
                            }
                            if self.arrCardList.count > 0{
                                self.cardListTable_height.constant = CGFloat((self.arrCardList.count * 45))
                                self.cardListTableView.reloadData()
                            }else{
                                self.cardListTable_height.constant = 0
                            }
                        })
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.selectPaymentContainerView.isHidden = true
                        self.selectPatmentContainerView_bottom.constant += self.selectPaymentContainerView.frame.height
                        self.view.layoutIfNeeded()
                    }
                }else{
                }
            }
        }) { (error) in
            
        }
    }
    
}


//MARK: - TableView Delegate's
extension AssetsListingViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.cardListTableView{
            return self.arrCardList.count
        }else{
            return self.assetsListArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.cardListTableView{
            let cell = self.cardListTableView.dequeueReusableCell(withIdentifier: "CardsListCell")as! CardsListCell
            let cardDetail = self.arrCardList[indexPath.row]
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
                self.selectedCardDetail = cardDetail
                self.cardSelected = 1
                cell.containerView.backgroundColor = CustomColor.primaryColor
                cell.cardNumber_lbl.textColor = UIColor.white
            }else{
                cell.containerView.backgroundColor = UIColor.white
                cell.cardNumber_lbl.textColor = UIColor.darkGray
            }
            return cell
        }else{
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "AssetsTableViewCell")as! AssetsTableViewCell
            let model = self.assetsListArray[indexPath.row]
            cell.assetId_lbl.text = model.unique_id
            cell.location_lbl.text = self.locationModel.location_name
            cell.assetType_lbl.text = model.type_name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.cardListTableView{
            self.cardListTable_height.constant = self.cardListTableView.contentSize.height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.loadAssetInfo(vc: self, assetList: [self.assetsListArray[indexPath.row]])
    }
    
}

//MARK: - Assets Listing Delegate's
extension AssetsListingViewController: AssetsListViewDelegate{
    
    func selectedAsset(buttonPressed: String, assetId: String) {
        if buttonPressed == "book"{
            if self.checkAccountValidForRental(){
                self.selectedObjectId = assetId
                self.startRental()
            }
        }else if buttonPressed == "private"{
            self.alertBox("Koloni", "This is a private Koloni and hence you cannot access it.") {
            }
        }
    }
    
}
