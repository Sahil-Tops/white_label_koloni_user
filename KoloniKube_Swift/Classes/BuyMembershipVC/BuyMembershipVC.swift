//
//  BuyMembershipVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/2/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit
import SkeletonView

class BuyMembershipVC: UIViewController {
    
    //MARK: - Outlet's
    @IBOutlet weak var headerBg_img: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var btnBack: IPAutoScalingButton!
    @IBOutlet weak var tblBuyMembership: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var btnGift: UIButton!
    @IBOutlet weak var rippleView: UIView!
    @IBOutlet weak var imgSearch: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var referralCount_lbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lblNoResultFound: UILabel!
    
    //Variable's
    var strPageNo = Int()
    var arrMymembership : [SharedMyMembership] = [SharedMyMembership]()
    var nearbyMembership : [SharedMyMembership] = [SharedMyMembership]()
    var otherMembership : [SharedMyMembership] = [SharedMyMembership]()
    var isResponsed: Bool = false
    var nearByArray: [SharedMyMembership] = []
    var otherArray: [SharedMyMembership] = []
    var backVc = ""
    
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadContent()
        self.registerTableCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadVc()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.addUnderLine(color: .lightGray)
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "logo_img") { (image) in
            self.logoImg.image = image
        }
        if AppLocalStorage.sharedInstance.application_gradient{
            self.headerBg_img.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.headerBg_img.backgroundColor = CustomColor.primaryColor
        }
    }
    
    //MARK: - @IBAction's
    @IBAction func btnCloseClick(_ sender: UIButton) {
        strPageNo = 1
        txtSearch.text = ""
        self.imgSearch.image = UIImage(named: "search")
        self.callWebserviceForMyMebership(isLoader: true)
    }
    
    @IBAction func btnGiftClick(_ sender: UIButton) {
        self.loadShareRefferView()
    }
    
    @IBAction func btnSliderMenuClick(_ sender: UIButton) {
        if self.backVc == "QRCodeScaneVC"{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.sideMenuViewController?.presentLeftMenuViewController()
        }
    }
    
    //MARK: - Custom Function's
    func loadContent(){
        self.strPageNo = 1
        if self.backVc == "QRCodeScaneVC"{
            self.btnBack.setTitle("", for: .normal)
        }else{
            self.btnBack.setTitle("", for: .normal)
        }
        self.navigationController?.navigationBar.isHidden = true
        self.referralCount_lbl.circleObject()
        self.txtSearch.delegate = self
        self.txtSearch.addTarget(self, action: #selector(textFieldDidChangeEditing(_:)), for: .editingChanged)
        self.tblBuyMembership.tableFooterView = UIView()
    }
    
    func reloadVc(){
        self.txtSearch.text = ""
        self.isResponsed = false
        self.nearbyMembership = []
        self.otherMembership = []
        self.tblBuyMembership.reloadData()
        self.lblNoResultFound.isHidden = true
        self.callMembershipAPI()
        self.referralCount_lbl.text = Singleton.numberOfReferralRides
    }
    
    func registerTableCell(){
        self.tblBuyMembership.register(UINib(nibName: "BuyMembershipTblCell", bundle: nil), forCellReuseIdentifier: "BuyMembershipTblCell")
        self.tblBuyMembership.delegate = self
        self.tblBuyMembership.dataSource = self
    }
    
    func callMembershipAPI(){
        self.strPageNo = 1
        self.callWebserviceForMyMebership(isLoader: true)
    }
    
    func parseDeviceJson(arr:NSArray,isNearby:Bool) -> Void {
        
        for dict in arr as! [NSDictionary]{
            let mymemberShip = SharedMyMembership()
            
            mymemberShip.strMembershipId = dict.object(forKey: "id") as? String ?? ""
            mymemberShip.strPartnerID = dict.object(forKey: "partner_id") as? String ?? ""
            mymemberShip.strMemberName = dict.object(forKey: "name") as? String ?? ""
            mymemberShip.strMemberAddress = dict.object(forKey: "address") as? String ?? ""
            mymemberShip.strMembershipImage = dict.object(forKey: "image") as? String ?? ""
            mymemberShip.strMemberRating = dict.object(forKey: "rating") as? String ?? ""
            mymemberShip.strMemberReview = dict.object(forKey: "review") as? String ?? ""
            mymemberShip.is_purchased =  "\(dict.object(forKey: "is_purchased") ?? "0")"
            mymemberShip.message = dict.object(forKey: "message") as? String ?? ""
            
            if isNearby{
                self.nearbyMembership.append(mymemberShip)
            }else{
                self.otherMembership.append(mymemberShip)
            }
            
        }
        self.isResponsed = true
        self.nearByArray = self.nearbyMembership
        self.otherArray = self.otherMembership
        self.tblBuyMembership.reloadData()
    }
}

//MARK: - Web Api's
extension BuyMembershipVC {
    
    func callWebserviceForMyMebership(isLoader:Bool) {
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue(txtSearch.text, forKey: "search_keyword")
        paramer.setValue("\(strPageNo)", forKey: "page_no")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        paramer.setValue("0", forKey: "distance_unit")
        paramer.setValue(StaticClass.sharedInstance.latitude, forKey: "latitude")
        paramer.setValue(StaticClass.sharedInstance.longitude, forKey: "longitude")
        
        self.tblBuyMembership.infiniteScrollingView?.stopAnimating()
        self.tblBuyMembership.pullToRefreshView?.stopAnimating()
        
        APICall.shared.postWeb("hub_search", parameters:paramer, showLoder: false, successBlock: { (response) in
            if let Dict = response as? NSDictionary {
                if Dict.object(forKey: "FLAG") as! Bool {
                    
                    if let resultDict = Dict["LOCATION_DETAILS"] as? [String:Any]{
                        if self.strPageNo == 1 {
                            self.nearbyMembership = [SharedMyMembership]()
                            self.otherMembership = [SharedMyMembership]()
                        }
                        
                        self.tblBuyMembership.infiniteScrollingView?.stopAnimating()
                        self.tblBuyMembership.pullToRefreshView?.stopAnimating()
                        
                        if let nearbyLocation = resultDict["nearby_location"] as? NSArray, nearbyLocation.count > 0{
                            self.nearbyMembership = [SharedMyMembership]()
                            self.parseDeviceJson(arr: nearbyLocation, isNearby: true)
                            print(nearbyLocation)
                            self.lblNoResultFound.isHidden = true
                            self.tblBuyMembership.isHidden = false
                        }
                        
                        if let otherLocation = resultDict["other_location"] as? NSArray, otherLocation.count > 0{
                            self.strPageNo = self.strPageNo + 1
                            self.parseDeviceJson(arr: otherLocation, isNearby: false)
                            print(otherLocation)
                            self.lblNoResultFound.isHidden = true
                            self.tblBuyMembership.isHidden = false
                        }
                        
                        if self.nearbyMembership.count == 0 && self.otherMembership.count == 0{
                            self.lblNoResultFound.isHidden = false
                            self.isResponsed = true
                        }else{
                            self.lblNoResultFound.isHidden = true
                            self.tblBuyMembership.isHidden = false
                        }
                        self.tblBuyMembership.reloadData()
                    }else{
                        self.lblNoResultFound.isHidden = false
                    }
                    
                } else {
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: Dict.object(forKey: "MESSAGE") as? String ?? "Error", vc: self)
                }
            }
        }) { (error) in
            self.isResponsed = true
            self.tblBuyMembership.reloadData()
        }
    }
    
}

//MARK: - Text Field Delegate's
extension BuyMembershipVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.strPageNo = 1
        self.callWebserviceForMyMebership(isLoader: true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (txtSearch.text?.count)! > 0 {
            self.imgSearch.image = UIImage(named: "feedbackClose")
        } else  {
            self.imgSearch.image = UIImage(named: "search")
        }
        return true
    }
    
    @objc private func textFieldDidChangeEditing(_ textField: UITextField){
        
        if textField.isEmptyTextField(){
            self.imgSearch.image = UIImage(named: "search")
            self.nearbyMembership = self.nearByArray
            self.otherMembership = self.otherArray
        }else{
            self.imgSearch.image = UIImage(named: "feedbackClose")
            self.nearbyMembership = self.nearByArray.filter({ $0.strMemberName.lowercased().contains(textField.text!.lowercased())})
            self.otherMembership = self.otherArray.filter({ $0.strMemberName.lowercased().contains(textField.text!.lowercased())})
        }
        
        if self.nearbyMembership.count == 0 && self.otherMembership.count == 0{
            self.lblNoResultFound.isHidden = false
        }else{
            self.lblNoResultFound.isHidden = true
        }
        self.tblBuyMembership.reloadData()
    }
    
}

//MARK:- Table View Delegate's
extension BuyMembershipVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if (txtSearch.text?.count)! > 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if self.nearbyMembership.count == 0 && self.isResponsed == false{
                return 10
            }else{
                return self.nearbyMembership.count
            }
        } else {
            
            if self.otherMembership.count == 0 && self.isResponsed == false{
                return 10
            }else{
                return self.otherMembership.count
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuyMembershipTblCell") as! BuyMembershipTblCell
        
        if indexPath.section == 0{
            var buyMemebershipOBJ : SharedMyMembership!
            if self.txtSearch.text?.count ?? 0 > 0{
                
                if self.isResponsed == false{
                    Singleton.showSkeltonViewOnViews(viewsArray: [cell.imgProfile, cell.lblUserName])
                }else{
                    if self.otherMembership.count > 0{
                        Singleton.hideSkeltonViewFromViews(viewsArray: [cell.contentView,cell.imgProfile, cell.lblUserName])
                        buyMemebershipOBJ = self.otherMembership[indexPath.row]
                        cell.imgProfile.sd_setImage(with: URL(string: buyMemebershipOBJ.strMembershipImage), placeholderImage:nil)
                        cell.lblUserName.text = buyMemebershipOBJ.strMemberName
                    }
                }
            } else{
                if self.isResponsed == false{
                    Singleton.showSkeltonViewOnViews(viewsArray: [cell.contentView,cell.imgProfile, cell.lblUserName])
                }else if self.nearbyMembership.count > 0{
                    Singleton.hideSkeltonViewFromViews(viewsArray: [cell.contentView,cell.imgProfile, cell.lblUserName])
                    buyMemebershipOBJ = self.nearbyMembership[indexPath.row]
                    if indexPath.row == self.nearbyMembership.count - 1
                    {
                        cell.seperator.isHidden = true
                    }
                    else
                    {
                        cell.seperator.isHidden = false
                    }
                    cell.imgProfile.sd_setImage(with: URL(string: buyMemebershipOBJ.strMembershipImage), placeholderImage:nil)
                    cell.lblUserName.text = buyMemebershipOBJ.strMemberName
                }
            }
            cell.selectionStyle = .none
        }else{
            Singleton.showSkeltonViewOnViews(viewsArray: [cell.contentView,cell.imgProfile, cell.lblUserName])
            if self.otherMembership.count > 0 {
                Singleton.hideSkeltonViewFromViews(viewsArray: [cell.contentView,cell.imgProfile, cell.lblUserName])
                let buyMemebershipOBJ = self.otherMembership[indexPath.row]
                cell.imgProfile.clipsToBounds = true
                cell.imgProfile.sd_setImage(with: URL(string: buyMemebershipOBJ.strMembershipImage), placeholderImage:nil)
                cell.lblUserName.text = buyMemebershipOBJ.strMemberName
                DispatchQueue.main.async {
                    cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.height / 2
                }
                cell.selectionStyle = .none
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && self.nearbyMembership.count > 0{
            var buyMemebershipOBJ : SharedMyMembership!
            buyMemebershipOBJ = self.nearbyMembership[indexPath.row]
            if buyMemebershipOBJ.is_purchased.trimmingCharacters(in: .whitespacesAndNewlines) == "1" {
                self.loadAlreadyPurchasedMembershio(membershipData: buyMemebershipOBJ)
            }else{
                let HubListVCController = HubListVC(nibName: "HubListVC", bundle: nil)
                HubListVCController.strPartnerName = buyMemebershipOBJ.strMemberName
                HubListVCController.strPartnerID = buyMemebershipOBJ.strPartnerID
                self.navigationController?.pushViewController(HubListVCController, animated: true)
            }
        } else if self.otherMembership.count > 0 {
            let buyMemebershipOBJ =  self.otherMembership[indexPath.row]
            if buyMemebershipOBJ.is_purchased.trimmingCharacters(in: .whitespacesAndNewlines) == "1" {
                self.loadAlreadyPurchasedMembershio(membershipData: buyMemebershipOBJ)
            }else{
                let HubListVCController = HubListVC(nibName: "HubListVC", bundle: nil)
                HubListVCController.strPartnerName = buyMemebershipOBJ.strMemberName
                HubListVCController.strPartnerID = buyMemebershipOBJ.strPartnerID
                self.navigationController?.pushViewController(HubListVCController, animated: true)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: nil, options: [:])?.first as? HeaderView
        headerView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70)
        if section == 0 {
            if self.nearbyMembership.count > 0{
                headerView?.header_lbl.text = "Nearby Memberships"
            }else{
                headerView?.header_lbl.text = ""
            }
        } else {
            if self.otherMembership.count > 0{
                headerView?.header_lbl.text = "Other plans"
            }else{
                headerView?.header_lbl.text = ""
            }
            
        }
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            if self.nearbyMembership.count > 0{
                return 70
            }else{
                return 0
            }
        }else{
            if self.otherMembership.count > 0{
                return 70
            }else{
                return 0
            }
        }
       
    }
    
}
