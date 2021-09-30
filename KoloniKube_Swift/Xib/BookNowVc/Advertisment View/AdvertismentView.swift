//
//  AdvertismentView.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 04/06/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class AdvertismentView: UIView {

    @IBOutlet weak var advertismentContainerView: CustomView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var close_btn: UIButton!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var locationName_lbl: UILabel!
    @IBOutlet weak var description_textView: UITextView!
    @IBOutlet weak var descriptionTextView_height: NSLayoutConstraint!
    
    var bookNowVc: UIViewController?

    @IBAction func tapCloseBtn(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
            self.layoutIfNeeded()
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
    
    func loadContent(data: ShareAd){
        self.logoImageView.sd_setImage(with: URL(string: (data.logo_image)), placeholderImage: UIImage())
        self.bannerImageView.sd_setImage(with: URL(string: (data.banner_image)), placeholderImage: UIImage())
        self.locationName_lbl.text = data.title
        self.description_textView.text = data.descriptionn
        if CGFloat(self.description_textView.numberOfLines() * 25) > 100{
            self.descriptionTextView_height.constant = 100
            self.description_textView.isUserInteractionEnabled = true
        }else{
            self.descriptionTextView_height.constant = CGFloat(self.description_textView.numberOfLines() * 25)
            self.description_textView.isUserInteractionEnabled = false
        }
    }
    
    func setAdsImageScrollFunctionality(){
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.showsVerticalScrollIndicator = true
        self.scrollView.flashScrollIndicators()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnImage(_:)))
        tap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(tap)
    }
    
    @objc func tapOnImage(_ sender: UITapGestureRecognizer){
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale{
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }else{
            self.scrollView.setZoomScale(4.0, animated: true)
        }
    }
}

//MARK: - ScrollView Delegate's
extension AdvertismentView: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.bannerImageView
    }
}

extension UIViewController{
    ///Loading Linka Locking View
    func loadAdvertismentLockingView(data: ShareAd){
        if let view = Bundle.main.loadNibNamed("AdvertismentView", owner: nil, options: [:])?.first as? AdvertismentView{
            view.frame = self.view.bounds
            view.bookNowVc = self            
            view.alpha = 0.0
            view.setAdsImageScrollFunctionality()
            view.loadContent(data: data)
            self.view.addSubview(view)
            UIView.animate(withDuration: 1.0) {
                view.alpha += 1.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
