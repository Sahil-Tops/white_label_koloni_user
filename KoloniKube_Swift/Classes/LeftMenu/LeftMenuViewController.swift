//
//  LeftMenuViewController.swift
//  SideBarDemo
//
//  Created by Tops on 23/10/19.
//  Copyright © 2019 Tops. All rights reserved.
//

import UIKit

enum NewLeftMenu: Int {
    case map = 0
    case MyBooking
    case MyMembership
    case Settings
    case RateUs
    case Faq
    //    case Logout
}

class LeftMenuViewController: UIViewController {
    
    //MARK: - @IBOutlet's
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName_lbl: UILabel!
    
    //MARK: ViewControllers Variables
    var HomeVController: UIViewController!
    var BookNowVController: UIViewController!
    var MyProfileVController: UIViewController!
    var BuyMembershipVController: UIViewController!
    var MyMemberShipVController: UIViewController!
    var MyBookingVController: UIViewController!
    var ReportVController: UIViewController!
    var RatingVController: UIViewController!
    var ReferalCode: UIViewController!
    var referralEarning: UIViewController!
    var SettingVController: UIViewController!
    var FaqVController: UIViewController!
    
    //MARK: Vaiables
    var titleArray: [String] = ["Home", "Rentals", "Memberships", "Settings", "Rate us", "FAQ"]
    var menuImage = ["","","","","",""]
    var customCell = MenuTableCell()
    var selectedIndex = -1
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setControllerMethod()
        self.loadContent()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "refreshSideMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadContent), name: Notification.Name(rawValue: "refreshSideMenu"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: - @IBAction's
    @IBAction func tapHeaderBtn(_ sender: UIButton) {
        self.sideMenuViewController?.setContentViewController(self.MyProfileVController, animated: true)
        self.sideMenuViewController?.hideMenuViewController()
    }
    
    //MARK: - Custom Function's
    
    @objc func loadContent(){
        
        if let userDataArray = Singleton.userProfileData.value(forKey: "USER_DETAILS")as? NSArray{
            if userDataArray.count > 0{
                if let userData = userDataArray.object(at: 0)as? [String:Any]{
                    if let firstName = userData["first_name"]as? String, firstName != ""{
                        self.userName_lbl.text = firstName
                    }else{
                        self.userName_lbl.text = userData["username"]as? String ?? "Koloni User"
                    }
                    print("\(self.userName_lbl.text!)")
                    if let userProfileImage = userData["profile_image"]as? String{
                        if URL(string: userProfileImage) != nil{
                            self.userImage.sd_setImage(with: URL(string: userProfileImage)!, placeholderImage: UIImage(named: "NoProfileImage"))
                        }else{
                            self.userImage.image = UIImage(named: "NoProfileImage")
                        }
                    }else{
                        self.userImage.image = UIImage(named: "NoProfileImage")
                    }
                }
            }
        }
        
    }
    
    func setControllerMethod() {
        
        let HomeController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        self.HomeVController = UINavigationController(rootViewController: HomeController)
        
        let BookNowController = BookNowVC(nibName: "BookNowVC", bundle: nil)
        self.BookNowVController = UINavigationController(rootViewController: BookNowController)
        
        let MyProfileController = MyProfileVC(nibName: "MyProfileVC", bundle: nil)
        self.MyProfileVController = UINavigationController(rootViewController: MyProfileController)
        
        let BuyMembershipController = BuyMembershipVC(nibName: "BuyMembershipVC", bundle: nil)
        self.BuyMembershipVController = UINavigationController(rootViewController: BuyMembershipController)
        
        let MyMembershipController = MyMemberShipVC(nibName: "MyMemberShipVC", bundle: nil)
        self.MyMemberShipVController = UINavigationController(rootViewController: MyMembershipController)
        
        let MyBookingVController = MyRentalVC(nibName: "MyRentalVC", bundle: nil)
        self.MyBookingVController = UINavigationController(rootViewController: MyBookingVController)
        
        let ReportController = ReportVC(nibName: "ReportVC", bundle: nil)
        self.ReportVController = UINavigationController(rootViewController: ReportController)
        
        let SettingController = SettingVC(nibName: "SettingVC", bundle: nil)
        self.SettingVController = UINavigationController(rootViewController: SettingController)
        
        let FaqController = FAQViewController(nibName: "FAQViewController", bundle: nil)
        self.FaqVController = UINavigationController(rootViewController: FaqController)
        
    }
    
    func changeViewController(_ menuController: NewLeftMenu) {
        
        switch menuController {
        
        case .map:            
            self.sideMenuViewController?.setContentViewController(self.HomeVController, animated: true)
        case .MyMembership:
            self.alert(title: "Alert", msg: "Under Work")
            break
//            self.sideMenuViewController?.setContentViewController(self.BuyMembershipVController, animated: true)
        case .MyBooking:
            self.alert(title: "Alert", msg: "Under Work")
//            self.sideMenuViewController?.setContentViewController(self.MyBookingVController, animated: true)
        case .Settings:
            self.alert(title: "Alert", msg: "Under Work")
//            self.sideMenuViewController?.setContentViewController(self.SettingVController, animated: true)
        case .RateUs:
            self.alert(title: "Alert", msg: "Under Work")
            break
        case .Faq:
            self.alert(title: "Alert", msg: "Under Work")
//            self.sideMenuViewController?.setContentViewController(self.FaqVController, animated: true)
        }
    }
    
    func LogoutAlert(strMessage:String) {
        
        let actionSheetCont = UIAlertController(title: "", message: strMessage, preferredStyle: .
                                                    alert)
        
        let SelectCardAction = UIAlertAction(title: "Yes", style: .default) { (actionClick) in
            self.logoutMethodCall()
        }
        let retryAction = UIAlertAction(title: "No", style: .cancel) { (actionClick) in
        }
        actionSheetCont.addAction(SelectCardAction)
        actionSheetCont.addAction(retryAction)
        self.present(actionSheetCont, animated: true) {
        }
        
    }
    
    func logoutMethodCall() {
        Global().delay(delay: 0.1) {
            Global.appdel.logoutUser()
        }
    }
    
}

//MARK: - TableView Delegate's
extension LeftMenuViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.menuTableView.dequeueReusableCell(withIdentifier: "MenuTableCell")as! MenuTableCell
        
        cell.title_lbl.text = self.titleArray[indexPath.row]
        cell.icon_lbl.text = self.menuImage[indexPath.row]
        if indexPath.row == 7{
            cell.icon_lbl.font = UIFont.init(name: "Kolonishare", size: 17.0)
        }else{
            cell.icon_lbl.font = UIFont.init(name: "Koloni", size: 17.0)
        }
        cell.cell_btn.tag = indexPath.row
        cell.cell_btn.addTarget(self, action: #selector(cellBtnTapped(sender:)), for: .touchUpInside)
        
        if self.selectedIndex == indexPath.row{
            cell.title_lbl.textColor = CustomColor.selectedMenu
            cell.icon_lbl.textColor = CustomColor.selectedMenu
        }else{
            cell.title_lbl.textColor = .white
            cell.icon_lbl.textColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.menuTableView.contentSize.height <= self.menuTableView.frame.height{
            self.menuTableView.isScrollEnabled = false
        }else{
            self.menuTableView.isScrollEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    @objc func cellBtnTapped(sender: UIButton){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selectedIndex = sender.tag
            self.sideMenuViewController?.hideMenuViewController()
            if sender.tag ==  4{
                UIApplication.shared.open(URL(string: "https://itunes.apple.com/us/app/kolonishare/id1265110043?mt=8")!, options: [:]) { (_) in
                    
                }
            } else {
                if let menuController = NewLeftMenu(rawValue: sender.tag) {
                    self.changeViewController(menuController)
                }
            }
            self.menuTableView.reloadData()
        }
    }
    
}

//MARK: - TableView Cell
class MenuTableCell: UITableViewCell{
    
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var cell_btn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var icon_lbl: UILabel!
    
}
