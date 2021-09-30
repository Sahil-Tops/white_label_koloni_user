//
//  RentalEndPopUp.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 28/06/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class EndRentalPopUpView: UIView {

    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var description_lbl: UILabel!
    @IBOutlet weak var cancel_btn: CustomButton!
    @IBOutlet weak var end_btn: CustomButton!
    
    var bookNowVc: BookNowVC?
    
    //MARK: - Custom Function's
    func loadContent(titleMsg: String, desc: String){
        self.title_lbl.text = titleMsg
        self.description_lbl.text = desc
    }
    
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case cancel_btn:
            self.removeFromSuperview()
            break
        case end_btn:
            self.bookNowVc?.isEndingRentalManual = "1"
            self.bookNowVc?.rentalActionPerformed = 1
            self.bookNowVc?.changeStateOfPauseButton(isLocked: true)
            if self.bookNowVc?.selectedRentalIndex != -1{
                self.bookNowVc?.setRentalViewToInitial()
                if Singleton.runningRentalArray.count > 0{
                    if Singleton.runningRentalArray[self.bookNowVc!.selectedRentalIndex]["object_location_type"]as? String ?? "" == "1"{
                        self.bookNowVc?.nearestDropZone_Web()
                    }else{
                        self.bookNowVc?.calculationPrice_Web(isNreaBY: true)
                    }
                }
            }
            self.removeView()
            break
        default:
            break
        }
        
    }
    
    func removeView(){
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.height
        } completion: { (_) in
            Singleton.isOpeningAppFromNotification = false
            self.removeFromSuperview()
        }

    }
    
}

//MARK: -
extension UIViewController{
    
    func loadEndRentalPopUpView(titleMsg: String, descriptionMsg: String){
        
        if let view = Bundle.main.loadNibNamed("EndRentalPopUpView", owner: nil, options: [:])?.first as? EndRentalPopUpView{
            view.frame = self.view.bounds
            view.loadContent(titleMsg: titleMsg, desc: descriptionMsg)
            view.bookNowVc = self as? BookNowVC
            self.view.addSubview(view)
            view.frame.origin.y = view.frame.height
            UIView.animate(withDuration: 0.5) {
                view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
}
