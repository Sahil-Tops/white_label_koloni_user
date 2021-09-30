//
//  TemperWarningVC.swift
//  KoloniKube_Swift
//
//  Created by tops on 23/08/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit

class TemperWarningVC: UIViewController {

    @IBOutlet weak var btnClose: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
