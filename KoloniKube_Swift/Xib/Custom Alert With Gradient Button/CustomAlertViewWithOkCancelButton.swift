//
//  CustomAlertViewWithOkCancelButton.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 27/05/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class CustomAlertViewWithOkCancelButton: UIView {

    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var description_lbl: UILabel!
    @IBOutlet weak var cancel_btn: CustomButton!
    @IBOutlet weak var ok_btn: CustomButton!
    
    var okCallBack: (()->()) = {}
    var cancelCallBack: (()->()) = {}
    
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case ok_btn:
            self.okCallBack()
            self.removeView()
            break
        case cancel_btn:
            self.cancelCallBack()
            self.removeView()
            break
        default:
            break
        }
        
    }
    
    func loadContent(_ title: String = "Alert", msg: String, okBtnStr: String, cancelBtnStr: String){
        
        self.title_lbl.text = title
        self.description_lbl.text = msg
        self.ok_btn.setTitle(okBtnStr, for: .normal)
        self.cancel_btn.setTitle(cancelBtnStr, for: .normal)
        self.cancel_btn.fitFontSize()
        self.ok_btn.fitFontSize()
    }
    
    func removeView(){
        UIView.animate(withDuration: 0.5) {
            self.frame.origin.y += self.frame.height
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
}

extension UIViewController{
    
    func loadCustomAlertWithOkCancelBtn(title: String, msg: String, okBtnTitle: String, cancelBtnTitle: String)-> CustomAlertViewWithOkCancelButton{
        
        if let view = Bundle.main.loadNibNamed("CustomAlertViewWithOkCancelButton", owner: nil, options: [:])?.first as? CustomAlertViewWithOkCancelButton{
            view.frame = self.view.bounds
            view.loadContent(msg: msg, okBtnStr: okBtnTitle, cancelBtnStr: cancelBtnTitle)
            view.frame.origin.y += view.frame.height
            self.view.addSubview(view)
            
            UIView.animate(withDuration: 0.5) {
                view.frame.origin.y = 0
                self.view.layoutIfNeeded()
            }
            return view
        }else{
            return CustomAlertViewWithOkCancelButton()
        }
        
    }
    
}
