//
//  PaneltyPopupVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/27/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class IssuePopupVC: UIViewController,PopupContentViewController {
    
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    var closeHandler: (() -> Void)?
    var strPenaltyPrice = String()

    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lblMessage.text = strPenaltyPrice
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: BUTTON CLOSE CLICKED
    @IBAction func btnCloseClicked(_ sender: Any) {
        closeHandler?()
    }
   
    class func instance() -> IssuePopupVC {
        let vc = IssuePopupVC(nibName: "IssuePopupVC" ,bundle: nil) as IssuePopupVC
        return vc;
    }
    
    //MARK: SIZE POPUP SETTING
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: ((300 * width)/320),height: 250) //((290 * height)/568)
    }
    
}
