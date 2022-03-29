//
//  PaneltyPopupVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/27/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class PaneltyPopupVC: UIViewController,PopupContentViewController {
    
    //MARK:- Outlet's
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var description_lbl: IPAutoScalingLabel!
    @IBOutlet weak var nearBy_btn: UIButton!
    @IBOutlet weak var acceptPenalty_btn: UIButton!
    @IBOutlet weak var findNearestHub_btn: UIButton!
    @IBOutlet weak var cancel_btn: UIButton!
    
    var closeHandler: (() -> ()) = {}
    var strPenaltyPrice = String()
    var shareCraditCardOBJ = shareCraditCard()
    var data = ShareDevice()
    var bikeDataObj = ShareBikeKube()
    var shareRentalObj = shareRental()
    var isMyRental = Bool()
    var strLocationID = String()
    var bookNowVc: BookNowVC!
    var partnerId = ""
    
    
    //MARK:- Default Funtion's
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.acceptPenalty_btn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.nearBy_btn.titleLabel?.adjustsFontSizeToFitWidth = true        
        self.acceptPenalty_btn.circleObject()
        self.nearBy_btn.circleObject()
        self.description_lbl.text = "You're not at a hub, if you end your rental here, you may be assessed a $\(self.data.strPenaltyAmount) penalty"
        self.data.strPenaltyAmount = strPenaltyPrice
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if AppLocalStorage.sharedInstance.application_gradient{
            self.nearBy_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.nearBy_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        self.title_lbl.textColor = CustomColor.secondaryColor
        self.nearBy_btn.layer.cornerRadius  = self.nearBy_btn.layer.frame.height / 2
        self.acceptPenalty_btn.layer.cornerRadius  = self.acceptPenalty_btn.layer.frame.height / 2
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: @IBAction's
    @IBAction func tapPayPenaltyBtn(_ sender: Any) {
        self.bookNowVc.finishBooking_Web(strLocation_ID: self.bookNowVc.strLocationID)
        self.closeHandler()
    }
    
    @IBAction func tapImAtHubBtn(_ sender: Any) {
        self.bookNowVc.iamAtHub = true        
        self.bookNowVc.pickLockImageToFinishRide(cameraType: "hub")
        self.closeHandler()
    }
    
    @IBAction func tapFindNearestHubBtn(_ sender: UIButton) {
        
        if bikeDataObj.intType == 2 { // Bike
            let dropzone = DropZoneVC(nibName: "DropZoneVC", bundle: nil)
            dropzone.partnerId = self.partnerId
            self.navigationController?.pushViewController(dropzone, animated: true)
        }
        self.closeHandler()
    }
    
    @IBAction func tapCancelBtn(_ sender: UIButton) {        
        self.closeHandler()
    }
    
    //MARK: INSTANCE CREATE FOR FILTER
    class func instance() -> PaneltyPopupVC {
        let vc = PaneltyPopupVC(nibName: "PaneltyPopupVC" ,bundle: nil) as PaneltyPopupVC
        return vc;
    }
    
    //MARK: SIZE POPUP SETTING
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
}
