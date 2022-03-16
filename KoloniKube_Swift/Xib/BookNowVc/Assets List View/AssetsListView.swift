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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var left_arrow_btn: UIButton!
    @IBOutlet weak var right_arrow_btn: UIButton!
        
    var assetsListArray: [AvailabelBike] = []
    var delegate: AssetsListViewDelegate?
    var vc: BookNowVC!
    
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
            if i.item < self.assetsListArray.count - 1{
                let indexPath = IndexPath(item: i.item + 1, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                if i.item + 1 == self.assetsListArray.count - 1{
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
        return self.assetsListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "AssetsListCollectionCell", for: indexPath)as! AssetsListCollectionCell
        cell.tag = indexPath.item
        cell.assetsListView = self
        cell.setDataOnCell(data: self.assetsListArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
    
}

extension BookNowVC{
    
    func loadAssestListView(assetList: [AvailabelBike]){
        if let assetsView = Bundle.main.loadNibNamed("AssetsListView", owner: nil, options: [:])?.first as? AssetsListView{
            assetsView.frame = self.view.bounds
            assetsView.delegate = self as AssetsListViewDelegate
            assetsView.vc = self
            assetsView.assetsListArray = assetList
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


