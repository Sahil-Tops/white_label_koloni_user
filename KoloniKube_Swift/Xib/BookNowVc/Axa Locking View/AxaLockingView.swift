//
//  LinkaLockingView.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 04/06/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class AxaLockingView: UIView {

    @IBOutlet weak var descriptionMsg_lbl: UILabel!
    
}

extension UIViewController{
    ///Loading Linka Locking View
    func loadAxaLockingView(descriptionMsg: String){
        if let view = Bundle.main.loadNibNamed("AxaLockingView", owner: nil, options: [:])?.first as? AxaLockingView{
            view.frame = self.view.bounds
            view.descriptionMsg_lbl.text = descriptionMsg
            view.alpha = 0.0
            self.view.addSubview(view)
            
            UIView.animate(withDuration: 1.0) {
                view.alpha += 1.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
