//
//  HubListVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/24/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit
import Cosmos


class HubListVC: UIViewController {
        
    //MARK: - Outlet's
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var headerBg_img: UIImageView!
    @IBOutlet weak var headerView_height: NSLayoutConstraint!
    @IBOutlet weak var descriptionText_lbl: UILabel!
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var lblNoResultFound: UILabel!
    
    //Variable's
    var strPartnerID = String()
    var strPartnerName = String()
    var arrHubList : [SharedHubList] = [SharedHubList]()
    var isFrom = UIViewController()
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.callWebserviceForHubList(isLoader: true)
        self.loadContent()        
    }
    
    override func viewDidLayoutSubviews() {
        self.loadUI()
    }
    
    //MARK: - @IBAction's
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Custom Function's
    
    func loadUI(){
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "logo_img") { (image) in
            self.logoImg.image = image
        }
        if AppLocalStorage.sharedInstance.application_gradient{
            self.headerBg_img.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.headerBg_img.backgroundColor = CustomColor.primaryColor
        }
    }
    
    func loadContent(){
        
        self.table_view.register(UINib(nibName: "HubTableViewCell", bundle: nil), forCellReuseIdentifier: "HubTableViewCell")
        self.table_view.delegate = self
        self.table_view.dataSource = self
        
    }
    
    func parseDeviceJson(arr:NSArray) -> Void {
        for dict in arr as! [NSDictionary]{
            let hubListShip = SharedHubList()
            
            hubListShip.strPlanID = dict.object(forKey: "id") as? String ?? ""
            hubListShip.strPlan_name = dict.object(forKey: "plan_name") as? String ?? ""
            hubListShip.strPartner_name = dict.object(forKey: "partner_name") as? String ?? ""
            hubListShip.strduration = dict.object(forKey: "duration") as? String ?? ""
            hubListShip.strPer_ride_cap = dict.object(forKey: "per_ride_cap") as? String ?? ""
            hubListShip.strPrice = dict.object(forKey: "price") as? String ?? "0.00"
            hubListShip.strdescription = dict.object(forKey: "description") as? String ?? ""
            
            self.arrHubList.append(hubListShip)
        }
        if arrHubList.count == 0 {
            self.lblNoResultFound.isHidden = false
            self.table_view.isHidden = true
        }else{
            self.lblNoResultFound.isHidden = true
            self.table_view.isHidden = false
        }
        self.table_view.reloadData()
    }
    
}

//MARK: - Web Api'
extension HubListVC {
    func callWebserviceForHubList(isLoader:Bool) {
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue(strPartnerID, forKey: "partner_id")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("partner_plan_list", parameters:paramer, showLoder: isLoader, successBlock: { (response) in
            if let Dict = response as? NSDictionary {
                if Dict.object(forKey: "FLAG") as! Bool {
                    if let arrResult = Dict["PLAN_LIST"] as? NSArray , arrResult.count > 0{
                        self.arrHubList.removeAll()
                        self.parseDeviceJson(arr: arrResult)
                    } else  {
                        self.lblNoResultFound.isHidden = false
                    }
                } else {
                    StaticClass.sharedInstance.ShowNotification(true, strmsg: Dict.object(forKey: "MESSAGE") as? String ?? "", vc: self)
                }
            }
        }) { (error) in
            
        }
    }
}


//MARK: - TableView Delegate's
extension HubListVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrHubList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.table_view.dequeueReusableCell(withIdentifier: "HubTableViewCell")as! HubTableViewCell
        if AppLocalStorage.sharedInstance.application_gradient{
            cell.containerView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.2, endPosition: 1.0)
        }else{
            cell.containerView.backgroundColor = CustomColor.primaryColor
        }
        cell.price_lbl.textColor = CustomColor.primaryColor
        let sharedHubListOBJ = self.arrHubList[indexPath.row]
        cell.plansName_lbl.text = sharedHubListOBJ.strPlan_name
        cell.price_lbl.text = "$ " + sharedHubListOBJ.strPrice
        cell.duration_lbl.text = (Int(sharedHubListOBJ.strduration) ?? 0) > 1 ? "\(sharedHubListOBJ.strduration) Days": "\(sharedHubListOBJ.strduration) Day"
        cell.perRide_lbl.text = sharedHubListOBJ.strPer_ride_cap + " min free"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let SharedHubListOBJ = arrHubList[indexPath.row]
        let vc = CraditCardAddVC(nibName: "CraditCardAddVC", bundle: nil)
        vc.isStatusCardEdit = false
        vc.isFromHubPlanScreen = true
        vc.membershipPlanId = SharedHubListOBJ.strPlanID
        vc.membershipName = SharedHubListOBJ.strPlan_name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
