//
//  ObstacleVC.swift
//  KoloniKube_Swift
//
//  Created by tops on 22/08/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit
import LinkaAPIKit

class ObstacleVC: UIViewController {

    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    
     let lockConnectionService : LockConnectionService = LockConnectionService.sharedInstance
    var yesBlock : ()->() = {}
    var checkNotifier = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnYes.layer.cornerRadius = 10
        self.btnYes.layer.masksToBounds = true
        
        self.btnNo.layer.cornerRadius = 10
        self.btnNo.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnYesAction(_ sender: Any) {
        // Put the logic for payment transfer
        
        if checkNotifier {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishBooking"), object: nil)
        }else{
            yesBlock()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnNoAction(_ sender: Any) {
        lockConnectionService.disconnectWithExistingController()
        self.dismiss(animated: true, completion: nil)
    }
}
