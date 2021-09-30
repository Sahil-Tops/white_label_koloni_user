//
//  NavigationView.swift
//  KoloniKube_Swift
//
//  Created by Tops on 15/10/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class NavigationView: UIView {
    
    @IBOutlet weak var navigationView: NavigationView!
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var skip_btn: UIButton!
    
    
    var navigation: UINavigationController?
    var viewController = UIViewController()
    
    ///"back" - For pop, "dismiss" - For dismiss.
    var backBtnAction = ""
    
    override func awakeFromNib() {
        //        self.createGradientLayer(color1: CustomColor.customBlue, color2: CustomColor.customlightBlue, startPosition: 0.2, endPosition: 1.0)
    }
    
    @IBAction func tapBackBtn(_ sender: UIButton) {
        if Singleton.emailConfirmationToken != ""{
            Singleton.emailConfirmationToken = ""
            let loginVc = LoginWithGoogleAppleVC(nibName: "LoginWithGoogleAppleVC", bundle: nil)
            Global.changeRootVc(vc: loginVc)
        }else{
            if self.backBtnAction == "back"{
                self.navigation?.popViewController(animated: true)
            }else{
                self.viewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func tapSkipBtn(_ sender: UIButton) {
        Global.appdel.setUpSlideMenuController()
    }
    
    @IBAction func tapMenuBtn(_ sender: UIButton) {
        viewController.sideMenuViewController?.presentLeftMenuViewController()
    }
    
    
}
