//
//  GlobalAlert.swift
//  KoloniKube_Swift
//
//  Created by tops on 05/10/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit

class GlobalAlert: UIViewController {

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var update_btn: UIButton!
    
    var message = ""
    var isMaintainance = false

    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false
        
        self.lblMessage.text = message
        if isMaintainance{
            self.update_btn.setTitle("Logout", for: .normal)
        }
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.alertView.layer.cornerRadius = 10
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func updateClicked(_ sender: Any) {
        if self.update_btn.currentTitle == "Logout"{
            Global.appdel.forceLogout()
        }else{
            self.dismiss(animated: true) {
                guard let url = URL(string: "https://itunes.apple.com/us/app/kolonishare/id1265110043?mt=8") else { return }
                UIApplication.shared.open(url, options: [:]) { (response) in
                    
                }
            }
        }
    }
    

}
