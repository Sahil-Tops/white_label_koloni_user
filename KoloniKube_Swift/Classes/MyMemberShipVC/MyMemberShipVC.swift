//
//  MyMemberShipVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/2/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit

class MyMemberShipVC: UIViewController {
    
    //MARK: - Outlet's
    @IBOutlet weak var navigationImg: UIImageView!
    @IBOutlet weak var skeltonView: UIView!
    @IBOutlet weak var tblMembership: UITableView!
    @IBOutlet weak var btnBack: IPAutoScalingButton!
    @IBOutlet weak var lblNoresultFound: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    //Variable's
    var arrBuyMemebershipOBJ : [SharedBuyMembership] = [SharedBuyMembership]()
    var strPageNo = Int()
    var backVc = UIViewController()
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadContent()
        self.callWebserviceForMyMebership()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadUI()
    }
    
    //MARK: - @IBAction's
    @IBAction func tapBackBtn(_ sender: UIButton) {
        if self.backVc.isKind(of: CraditCardAddVC.self){
            Global.appdel.setUpSlideMenuController()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Custom Function's
    
    func loadUI(){
        if AppLocalStorage.sharedInstance.application_gradient{
            self.navigationImg.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.navigationImg.backgroundColor = CustomColor.primaryColor
        }
    }
    
    func loadContent(){
        tblMembership.register(UINib(nibName: "MyMemberCustomCell", bundle: nil), forCellReuseIdentifier: "MyMemberCustomCell")
        self.navigationController?.navigationBar.isHidden = true
        self.strPageNo = 1
    }
    
    func showSkeltonView(){
        self.skeltonView.isHidden = false
        Singleton.showSkeltonViewOnViews(viewsArray: [self.skeltonView])
    }
    
    func hideSkeltonView(){
        self.skeltonView.isHidden = true
        Singleton.hideSkeltonViewFromViews(viewsArray: [self.skeltonView])
    }
    
    @objc func checkMymbershipFromNotification(notification:Notification) -> Void {
        callWebserviceForMyMebership()
    }
    
}

//MARK: - Web Api'S
extension MyMemberShipVC {
    func callWebserviceForMyMebership() {
        
        let stringwsName = "my_membership_list/user_id/\(StaticClass.sharedInstance.strUserId)"
        
        self.showSkeltonView()
        APICall.shared.getWeb(stringwsName, withLoader: false, successBlock: { (response) in
            
            self.hideSkeltonView()
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool) {
                    if let arrResult = dict["MEMBERSHIP_LIST"] as? NSArray,arrResult.count > 0 {
                        self.arrBuyMemebershipOBJ.removeAll()
                        
                        for dicResult in arrResult as! [NSDictionary]{
                            let shreByMembershipOBJ = SharedBuyMembership()
                            shreByMembershipOBJ.strAmount = dicResult.object(forKey: "amount") as? String ?? ""
                            shreByMembershipOBJ.strID = dicResult.object(forKey: "id") as? String ?? ""
                            shreByMembershipOBJ.strImage = dicResult.object(forKey: "image") as? String ?? ""
                            shreByMembershipOBJ.strPurchaseDate = dicResult.object(forKey: "perchase_date") as? String ?? ""
                            shreByMembershipOBJ.strExpireDate = dicResult.object(forKey: "expire_date") as? String ?? ""
                            shreByMembershipOBJ.strPlanID = dicResult.object(forKey: "plan_id") as? String ?? ""
                            shreByMembershipOBJ.strPlanName = dicResult.object(forKey: "plan_name") as? String ?? ""
                            shreByMembershipOBJ.strFreeRentalHours = dicResult.object(forKey: "free_rental_hours")as? String ?? ""
                            shreByMembershipOBJ.strUserName = dicResult.object(forKey: "username") as? String ?? ""
                            shreByMembershipOBJ.strTotalPlanDay = dicResult.object(forKey: "total_plan_day") as? String ?? ""
                            shreByMembershipOBJ.strAvailableFreeRentalHours = dicResult.object(forKey: "available_free_rental_hours")as? String ?? ""
                            self.arrBuyMemebershipOBJ.append(shreByMembershipOBJ)
                        }
                        
                        self.tblMembership.reloadData()
                        self.lblNoresultFound.isHidden = true
                    } else  {
                        self.tblMembership.reloadData()
                        self.tblMembership.isHidden = true
                        self.lblNoresultFound.isHidden = false
                    }
                }else{
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "")
                }
            }
        }) { (error) in
            self.hideSkeltonView()
        }
    }
}

//MARK: - TableView Delegate's
extension MyMemberShipVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrBuyMemebershipOBJ.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: MyMemberCustomCell = tableView.dequeueReusableCell(withIdentifier: "MyMemberCustomCell") as! MyMemberCustomCell
        let shareBuyMember = self.arrBuyMemebershipOBJ[indexPath.row]
        if AppLocalStorage.sharedInstance.application_gradient{
            cell.titleView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.2, endPosition: 1.0)
        }else{
            cell.titleView.backgroundColor = CustomColor.primaryColor
        }
        cell.dropDown_btn.tintColor = CustomColor.primaryColor
        cell.planName_lbl.text = shareBuyMember.strPlanName
        cell.price_lbl.textColor = CustomColor.primaryColor
        cell.price_lbl.text = "$\(shareBuyMember.strAmount)"
        cell.planExpiresDate_lbl.text = "Expires \(shareBuyMember.strExpireDate)"
        cell.duration_lbl.text = (Int(shareBuyMember.strTotalPlanDay) ?? 0) > 1 ? "\(shareBuyMember.strTotalPlanDay) Days":"\(shareBuyMember.strTotalPlanDay) Day"
        cell.perRide_lbl.text = "\(shareBuyMember.strFreeRentalHours) min free"
        cell.dropDown_btn.tag = indexPath.row
        cell.dropDown_btn.addTarget(self, action: #selector(dropDownBtnTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func dropDownBtnTapped(_ sender: UIButton){
        let shareBuyMember = self.arrBuyMemebershipOBJ[sender.tag]
        let cell = self.tblMembership.cellForRow(at: IndexPath(row: sender.tag, section: 0))as! MyMemberCustomCell
        if cell.dropDown_btn.isSelected{
            cell.dropDown_btn.isSelected = false
            cell.descriptionText_lbl.text = ""
            cell.dropDown_btn.setImage(UIImage(named: "down_arrow_2"), for: .normal)
        }else{
            cell.dropDown_btn.isSelected = true
            cell.descriptionText_lbl.text = shareBuyMember.strAvailableFreeRentalHours
            cell.dropDown_btn.setImage(UIImage(named: "up_arrow_2"), for: .normal)
        }
        self.tblMembership.reloadData()
        self.view.layoutIfNeeded()
    }
}
