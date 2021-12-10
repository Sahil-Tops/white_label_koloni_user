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
    
    
    var startBookingSwift: StartBooking?
    var locationModel: LOCATION_DATA!
    var assetsListArray: [ASSETS_LIST] = []
    var cardListArray: [shareCraditCard] = []
    var selectedCardDetail: shareCraditCard!
    var selectedPaymentView: SelectPaymentPopUpView?
    
    var selectedObjectId = ""
    var cardSelected = 0
    var numberOfReferralRentals = 0
    var referralSelected = 0
    
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
            //            self.bgShadow_btn.isHidden = true
            //            self.selectedPaymentView?.removeFromSuperview()
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
        
    }
    
    func loadUI(){
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "logo_img") { (image) in
            self.logoImg.image = image
        }
        if AppLocalStorage.sharedInstance.application_gradient{
            self.navigationImage.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.navigationImage.backgroundColor = CustomColor.primaryColor
        }
        self.view.layoutIfNeeded()
    }
    
    func loadContent(){
        if self.assetsListArray.count > 0{
            self.registerTableCell()
            self.tableView.isHidden = false
            self.noAssetFound_lbl.isHidden = true
            self.tableView.reloadData()
        }else{
            self.tableView.isHidden = true
            self.noAssetFound_lbl.isHidden = false
        }
    }
    
    func startRental(){
        
        self.startBookingSwift = StartBooking.init()
        self.startBookingSwift?.initialize(vc: self, asset_id: self.selectedObjectId, refferalApply: self.referralSelected, shareCraditCard: self.selectedCardDetail)
        
    }
    
    func checkCardList(){
        if Singleton.shared.cardListsArray.count > 0{
            self.loadSelectPaymentView()
        }
    }
    
}


//MARK: - TableView Delegate's
extension AssetsListingViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assetsListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "AssetsTableViewCell")as! AssetsTableViewCell
        let model = self.assetsListArray[indexPath.row]
        cell.assetId_lbl.text = model.unique_id
        cell.location_lbl.text = self.locationModel.location_name
        cell.assetType_lbl.text = model.type_name
        return cell
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
                self.checkCardList()
            }
        }else if buttonPressed == "private"{
            self.alertBox("Koloni", "This is a private Koloni and hence you cannot access it.") {
            }
        }
    }
    
}

//MARK: - Select Payment Delegate
extension AssetsListingViewController: SelectedPaymentDelegate{
    
    func selectCard(cardDetail: shareCraditCard, referralSelected: Int) {
        self.selectedCardDetail = cardDetail
        self.referralSelected = referralSelected
        self.startRental()
    }
    
}
