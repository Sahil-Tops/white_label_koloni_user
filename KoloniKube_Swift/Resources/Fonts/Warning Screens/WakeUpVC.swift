//
//  WakeUpVC.swift
//  KoloniKube_Swift
//
//  Created by tops on 22/08/18.
//  Copyright © 2018 Self. All rights reserved.
//

import UIKit
import LinkaAPIKit

class WakeUpVC: UIViewController {

    // MARK: - Outlets -
    @IBOutlet weak var imgGif: UIImageView!
    @IBOutlet weak var obstacleView: UIView!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var lblMessage: UILabel!

    // MARK: - Variables -
    var showObstacle = false
    var CountScreen = 0
    let lockConnectionService : LockConnectionService = LockConnectionService.sharedInstance

    // MARK: - View Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()

        StaticClass.sharedInstance.HideSpinner()

        lblMessage.text = "Lock is disconnected, Are you sure you want to end booking?"
        if showObstacle == false {
            obstacleView.isHidden = true
        }

        self.btnYes.layer.cornerRadius = 10
        self.btnYes.layer.masksToBounds = true

        self.btnNo.layer.cornerRadius = 10
        self.btnNo.layer.masksToBounds = true

        self.imgGif.image = UIImage.gif(name: "KoloniGIFImg")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - View Action -
    @IBAction func btnCloseAction(_ sender: Any) {

        if CountScreen != 100 {
            // Fire Notification for Next Connection
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SlideEnd"), object: nil)
        }
        lockConnectionService.disconnectWithExistingController()

        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnYesAction(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishBooking"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
