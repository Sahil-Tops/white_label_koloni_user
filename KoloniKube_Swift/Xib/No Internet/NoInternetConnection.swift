//
//  NoInternetConnection.swift
//  KoloniKube_Swift
//
//  Created by Tops on 08/01/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class NoInternetConnection: UIView {

    @IBOutlet weak var gifImageView: UIImageView!
    
    func loadGif(){
        let gif = UIImage.gif(name: "no_internet")
        self.gifImageView.image = gif
    }
}

extension UIWindow{
    //MARK: Load No Internet Connection View
    func loadNoInternetConnectionView(){
        DispatchQueue.main.async {
            Singleton.noInternetConnectionView = Bundle.main.loadNibNamed("NoInternetConnection", owner: nil, options: [:])?.first as? NoInternetConnection
            Singleton.noInternetConnectionView?.frame = self.screen.bounds
            Singleton.noInternetConnectionView?.loadGif()
            Singleton.noInternetConnectionView?.frame.origin.y += (Singleton.noInternetConnectionView?.frame.height)!
            self.addSubview(Singleton.noInternetConnectionView!)
            UIView.animate(withDuration: 0.5) {
                Singleton.noInternetConnectionView?.frame.origin.y -= (Singleton.noInternetConnectionView?.frame.height)!
            }
        }
    }
}

