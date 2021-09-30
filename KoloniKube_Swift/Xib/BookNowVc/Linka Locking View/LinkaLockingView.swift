//
//  LinkaLockingView.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 04/06/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class LinkaLockingView: UIView {

    @IBOutlet weak var descriptionMsg_lbl: UILabel!    

}

extension UIViewController{
    ///Loading Linka Locking View
    func loadLinkaLockingView(descriptionMsg: String){
        if let view = Bundle.main.loadNibNamed("LinkaLockingView", owner: nil, options: [:])?.first as? LinkaLockingView{
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
