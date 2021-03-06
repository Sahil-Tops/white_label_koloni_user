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
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerView_height: NSLayoutConstraint!
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var lblNoResultFound: UILabel!
    @IBOutlet weak var lblpartnerName: UILabel!
    @IBOutlet weak var innerShadowView: UIView!
    
    
    var strPartnerID = String()
    var strPartnerName = String()
    var arrHubList : [SharedHubList] = [SharedHubList]()
    var isFrom = UIViewController()
  
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblpartnerName.text = strPartnerName
        self.navigationController?.navigationBar.isHidden = true
        self.callWebserviceForHubList(isLoader: true)
        self.loadContent()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        Global.appdel.setUpSlideMenuController()
    }
    
    //MARK: - Custom Function's
    
    func loadContent(){
        
        if self.isDeviceHasSafeArea(){
            self.headerView_height.constant = 88
            self.headerView.frame.size.height = 88
        }else{
            self.headerView_height.constant = 60
            self.headerView.frame.size.height = 60
        }
        self.loadNavigationView()
        self.table_view.register(UINib(nibName: "HubTableViewCell", bundle: nil), forCellReuseIdentifier: "HubTableViewCell")
        self.table_view.delegate = self
        self.table_view.dataSource = self
        
    }
    
    func loadNavigationView(){
        
        self.headerView.createGradientLayer(color1: CustomColor.customBlue, color2: CustomColor.customAppGreen, startPosition: 0.2, endPosition: 1.0)
        let navigationView = Bundle.main.loadNibNamed("NavigationView", owner: nil, options: nil)?.first as? NavigationView
        navigationView?.frame = self.headerView.bounds
        navigationView?.title_lbl.text = strPartnerName
        navigationView?.navigation = self.navigationController!
        self.headerView.addSubview(navigationView!)
        
    }
    
}

//MARK: -
extension HubListVC {
    //MARK: Web Api's
    func callWebserviceForHubList(isLoader:Bool) {
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue(strPartnerID, forKey: "partner_id")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")

        APICall.shared.Post("partner_plan_list", parameters:paramer, showLoder: isLoader, successBlock: { (response) in
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

extension HubListVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrHubList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.table_view.dequeueReusableCell(withIdentifier: "HubTableViewCell")as! HubTableViewCell
        
        let sharedHubListOBJ = arrHubList[indexPath.row]
        cell.plansName_lbl.text = sharedHubListOBJ.strPlan_name
        cell.price_lbl.text = "$ " + sharedHubListOBJ.strPrice
        cell.duration_lbl.text = sharedHubListOBJ.strduration + " Days"
        cell.perRide_lbl.text = sharedHubListOBJ.strPer_ride_cap + " minutes free"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let SharedHubListOBJ = arrHubList[indexPath.row]
        let addCreditCardController = CraditCardAddVC(nibName: "CraditCardAddVC", bundle: nil)
        addCreditCardController.isStatusCardEdit = false
        addCreditCardController.isFromHubPlanScreen = true
        addCreditCardController.strHubPlan_ID = SharedHubListOBJ.strPlanID
        Global.appdel.nav?.pushViewController(addCreditCardController, animated: true)
    }
    
}
