//
//  AnimatedCircularView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 10/2/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit
import GradientCircularProgress

class AnimatedCircularView: UIView {
    
    //    @IBOutlet weak var description_lbl: UILabel!
    
    var progressBar = GradientCircularProgress()
    var shareDevice = ShareDevice()
    let logoImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 68, height: 68))
    let description_lbl = UILabel()
    var keyWindow: UIWindow?
    
    func showSpiner(message: String, labelColor: UIColor = .black) {
        DispatchQueue.main.async {
            AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "loader_img") { (image) in
                self.keyWindow = UIApplication.shared.keyWindow
                self.progressBar.show(message: "", style: MyStyle())
                self.logoImg.image = image
                self.logoImg.contentMode = .scaleAspectFit
                self.logoImg.center = self.keyWindow!.center
                self.description_lbl.frame = CGRect(x: 15, y: (self.logoImg.frame.origin.y + self.logoImg.frame.height) + 10, width: self.keyWindow!.frame.width - 30, height: 100)
                self.description_lbl.textColor = labelColor
                self.description_lbl.text = message
                self.description_lbl.textAlignment = .center
                self.description_lbl.font = .boldSystemFont(ofSize: 20.0)
                self.description_lbl.numberOfLines = 0
                self.logoImg.circleObject()
                self.keyWindow?.addSubview(self.logoImg)
                self.keyWindow?.addSubview(self.description_lbl)
            }
        }
    }
    func hideSpinner() -> Void {
        DispatchQueue.main.async {
            self.progressBar.dismiss()
            self.logoImg.removeFromSuperview()
            self.description_lbl.removeFromSuperview()
        }
    }
}
