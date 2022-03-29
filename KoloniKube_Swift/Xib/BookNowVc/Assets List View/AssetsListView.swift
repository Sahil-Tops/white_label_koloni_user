//
//  AssetsListView.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 4/24/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

protocol AssetsListViewDelegate {
    func selectedAsset(buttonPressed: String, assetId: String)
}

class AssetsListView: UIView {

    @IBOutlet weak var containerView: CustomView!
    @IBOutlet weak var titleBackgroundView: UIView!
    @IBOutlet weak var titleBacgkground_imgView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var left_arrow_btn: UIButton!
    @IBOutlet weak var right_arrow_btn: UIButton!
    
    
    var availabelBikeArray: [AvailabelBike] = []
    var delegate: AssetsListViewDelegate?
    var bookNowVc: BookNowVC!
    
    //MARK: Custom Function's
    
    func addTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnBgView))
        self.addGestureRecognizer(tap)
    }
    
    func registerCollectionCell(){
        self.collectionView.register(UINib(nibName: "AssetsListCollectionCell", bundle: nil), forCellWithReuseIdentifier: "AssetsListCollectionCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func rightButtonClicked() {
        let index = self.collectionView.indexPathsForVisibleItems.first
        if let i = index{
            if i.item < self.availabelBikeArray.count - 1{
                let indexPath = IndexPath(item: i.item + 1, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                if i.item + 1 == self.availabelBikeArray.count - 1{
                    self.right_arrow_btn.alpha = 0.2
                }
                self.left_arrow_btn.alpha = 1
            }
        }
    }
    
    func leftButtonClicked() {
        let index = self.collectionView.indexPathsForVisibleItems.first
        if let i = index{
            if i.item > 0{
                let indexPath = IndexPath(item: i.item - 1, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                if i.item - 1 == 0{
                    self.left_arrow_btn.alpha = 0.2
                }
                self.right_arrow_btn.alpha = 1
            }
        }
    }
    
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        if sender == left_arrow_btn{
            self.leftButtonClicked()
        }else if sender == right_arrow_btn{
            self.rightButtonClicked()
        }
        
    }
    
    @objc func tapOnBgView(){
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
}

extension AssetsListView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.availabelBikeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "AssetsListCollectionCell", for: indexPath)as! AssetsListCollectionCell
        cell.tag = indexPath.item
        cell.assetsListView = self
        cell.setAvailableBikeDataOnCell(data: self.availabelBikeArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
    
}

extension UIViewController{
    
    func loadAssestListView(vc: BookNowVC, assetList: [AvailabelBike]){
        if let assetsView = Bundle.main.loadNibNamed("AssetsListView", owner: nil, options: [:])?.first as? AssetsListView{            
            assetsView.frame = self.view.bounds
            assetsView.delegate = vc as AssetsListViewDelegate
            assetsView.bookNowVc = vc
            if AppLocalStorage.sharedInstance.application_gradient{
                assetsView.titleBacgkground_imgView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            }else{
                assetsView.titleBacgkground_imgView.backgroundColor = CustomColor.primaryColor
            }
            assetsView.availabelBikeArray = assetList
            if assetList.count < 2{
                assetsView.left_arrow_btn.isHidden = true
                assetsView.right_arrow_btn.isHidden = true
            }
            assetsView.registerCollectionCell()
            assetsView.addTapGesture()
            assetsView.containerView.alpha = 0
            self.view.addSubview(assetsView)
            UIView.animate(withDuration: 0.2) {
                assetsView.containerView.alpha += 1
                self.view.layoutIfNeeded()
            }
        }
    }
}


