//
//  MyProfileVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 4/4/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class MyProfileVC: UIViewController {
    
    //MARK:- Outlet's
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    @IBOutlet weak var lblBirthDate: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonCollectionView: UICollectionView!
    @IBOutlet weak var buttonCollection_height: NSLayoutConstraint!
    
    @IBOutlet weak var signOutBtnContainerView: CustomView!
    @IBOutlet weak var btnMyMembership: UIButton!
    @IBOutlet weak var btnPaymenteInfo: UIButton!
    @IBOutlet weak var btnChangePassword: UIButton!
    @IBOutlet weak var btnSignOut: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var btnContainerView: UIView!
    
    @IBOutlet weak var btnBack: IPAutoScalingButton!
    @IBOutlet weak var viewProfile: UIView!
    
    //Variable's
    var buttonArray = ["My Memberships", "Saved Cards"]
    var iconsArray = ["", ""]
    
    //MARK:- Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.btnChangePassword.isHidden = false
        self.storeAllInformation()
        self.buttonCollectionView.reloadData()
        _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (_) in
            self.callUserDetail_Web()
        })
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Global.appdel.is_rentalRunning == true {
        }
        self.viewProfile.setBorder(border_width: 4, border_color: UIColor.white)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.viewProfile.circleObject()
        }
    }
    
    //MARK: - @IBAction's
    
    @IBAction func btnSliderMenuClick(_ sender: UIButton) {
        self.sideMenuViewController?.presentLeftMenuViewController()
    }
    
    @IBAction func btnEditPressed(_ sender: UIButton) {
        let editProfileVController = EditProfileVC(nibName: "EditProfileVC", bundle: nil)
        self.navigationController?.pushViewController(editProfileVController, animated: true)
    }
    
    @IBAction func btnMymembershipPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func btnPaymentInfPressed(_ sender: UIButton) {
        let CraditCardAddVController = CraditCardAddVC(nibName: "CraditCardAddVC", bundle: nil)
        CraditCardAddVController.isFromProfileView = true
        self.navigationController?.pushViewController(CraditCardAddVController, animated: true)
    }
    
    @IBAction func btnChangePasswordPressed(_ sender: UIButton) {
        let changePwdVc = ChangePasswordViewController(nibName: "ChangePasswordViewController", bundle: nil)
        self.navigationController?.pushViewController(changePwdVc, animated: true)
    }
    
    @IBAction func btnSignOutPressed(_ sender: UIButton) {
        self.showAlertWithOkAndCancelBtn("Logout" ,"Are you sure you want to logout?", yesBtn_title: "Yes", noBtn_title: "No") { (response) in
            if response == "ok"{
                Singleton.internetCheckTimer.invalidate()
                Global.appdel.logoutUser()
//                AuthManager(vc: self).logoutAuth0 { (response) in
//                    if response{
//                        Singleton.internetCheckTimer.invalidate()
//                        Global.appdel.logoutUser()
//                    }
//                }
            }
        }
    }
    
    //MARK: - Custom Function's
    func loadContent(){
        
        self.view.layoutIfNeeded()
        self.buttonCollectionView.register(UINib(nibName: "MyProfileCell", bundle: nil), forCellWithReuseIdentifier: "MyProfileCell")
        self.buttonCollectionView.delegate = self
        self.buttonCollectionView.dataSource = self
    }
    
    func storeAllInformation(){
        
        self.lblName.text  = "\(StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USERFIRSTNAME) as? String ?? "")" + " \(StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USERLASTNAME) as? String ?? "")"
        
        self.lblUserEmail.text = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.UserEMail) as? String ?? "";
        
        if let stSocial = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USER_IS_social) as? String {
            self.btnChangePassword.isHidden = stSocial == "1"
        }
        
        if let stbirth = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USER_DOB) as? String {
            
            if stbirth == "0000-00-00"{
                lblBirthDate.text = ""
            }else{
                lblBirthDate.text = stbirth
            }
            
        }else{
            lblBirthDate.text = ""
        }
        let strProfileImage =  StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.USERPROFILEIMAGEURL) as? String ?? ""
        if strProfileImage == "" {
            imgUser.image = nil
        }else {
            imgUser.sd_setImage(with: URL(string: strProfileImage), placeholderImage:nil)
        }
        
        Singleton.hideSkeltonViewFromViews(viewsArray: [self.imgUser,self.lblName,self.lblUserName,self.lblUserEmail,self.lblBirthDate,self.imgUser,self.signOutBtnContainerView,self.buttonCollectionView,self.scrollView])
    }
}

//MARK: - Web Api's
extension MyProfileVC{
    
    func callUserDetail_Web() -> Void {
        Singleton.showSkeltonViewOnViews(viewsArray: [self.imgUser,self.lblName,self.lblUserName,self.lblUserEmail,self.lblBirthDate,self.imgUser,self.signOutBtnContainerView,self.buttonCollectionView,self.scrollView])        
        Global.getUserProfile_Web(vc: self) { (response, data) in            
            
            NotificationCenter.default.post(name:Notification.Name(rawValue:Global.notification.Push_ProfileDataCall),object: nil,userInfo: nil)
            self.storeAllInformation()
        }
    }
    
}

//MARK: - Collection View Delegate's
extension MyProfileVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.buttonArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row%2 == 0 && indexPath.row == self.buttonArray.count - 1{
            return CGSize(width: self.buttonCollectionView.frame.width - 12, height: self.buttonCollectionView.frame.width/2 - 20)
        }else{
            return CGSize(width: self.buttonCollectionView.frame.width/2 - 20, height: self.buttonCollectionView.frame.width/2 - 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.buttonCollection_height.constant = self.buttonCollectionView.contentSize.height
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.buttonCollectionView.dequeueReusableCell(withReuseIdentifier: "MyProfileCell", for: indexPath)as! MyProfileCell
        
        cell.title_lbl.text = self.buttonArray[indexPath.row]
        cell.icon_lbl.text = self.iconsArray[indexPath.row]
        cell.cell_btn.tag = indexPath.row
        cell.cell_btn.addTarget(self, action: #selector(cellBtnTapped(_:)), for: .touchUpInside)
        return cell
        
    }
    
    @objc func cellBtnTapped(_ sender: UIButton){
        print("Button pressed: ", sender.tag)
        
        if self.buttonArray[sender.tag] == "My Memberships"{
            let myMembershipVc = MyMemberShipVC(nibName: "MyMemberShipVC", bundle: nil)
            myMembershipVc.backVc = self
            self.navigationController?.pushViewController(myMembershipVc, animated: true)
        }else if self.buttonArray[sender.tag] == "Saved Cards"{
            let CraditCardAddVController = CraditCardAddVC(nibName: "CraditCardAddVC", bundle: nil)
            CraditCardAddVController.isFromProfileView = true
            self.navigationController?.pushViewController(CraditCardAddVController, animated: true)
        }
    }
    
}
