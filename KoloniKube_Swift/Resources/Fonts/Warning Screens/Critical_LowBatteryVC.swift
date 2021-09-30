//
//  Critical_LowBatteryVC.swift
//  KoloniKube_Swift
//
//  Created by tops on 22/08/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit

class Critical_LowBatteryVC: UIViewController {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblCritical: UILabel!
    @IBOutlet weak var lblCritical_Description: UILabel!
    @IBOutlet weak var imgCritical: UIImageView!

    var is_Critical = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if is_Critical {
            imgCritical.image = UIImage(named: "critical_Low")
            lblCritical.text = "Critical Low Battery"
            lblCritical.textColor = UIColor.red
            lblCritical_Description.text = "Please connect linka to charger"
        }else{
            imgCritical.image = UIImage(named: "lowbattery")
            lblCritical.text = "Low Battery"
            lblCritical.textColor = UIColor(red: 250.0/255.0, green: 106.0/255.0, blue: 47.0/255.0, alpha: 1.0)
            lblCritical_Description.text = "Please connect linka to charger"
        }
        
        self.btnClose.layer.cornerRadius = 15
        self.btnClose.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
