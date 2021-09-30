//
//  InstructionSlidesVC.swift
//  KoloniKube_Swift
//
//  Created by Sahil Mehra on 11/13/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class InstructionSlidesVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    var instructionImageArray: [UIImage] = [UIImage(named: "First_Unlock")!, UIImage(named: "Second_Scan")!, UIImage(named: "Third_Track")!, UIImage(named: "Fourth_Slide")!, UIImage(named: "Five_Return")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.pageController.numberOfPages = self.instructionImageArray.count + 1
    }
    
    func registerCell(){
        
        self.collectionView.register(UINib(nibName: "InstructionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "InstructionCollectionCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
}

//MARK: - CollectionView Delegate's
extension InstructionSlidesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.instructionImageArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "InstructionCollectionCell", for: indexPath)as! InstructionCollectionCell
        if indexPath.row < self.instructionImageArray.count{
            cell.instructionImageView.image = self.instructionImageArray[indexPath.row]
        }else{
            cell.instructionImageView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cell = self.collectionView.visibleCells[0]
        if let index = self.collectionView.indexPath(for: cell){
            print("Index: ", index.row)
            self.pageController.currentPage = index.row
            if index.row == self.instructionImageArray.count{
                self.dismiss(animated: true) {
                    print("Dismissed")
                    UserDefaults.standard.set(false, forKey: "is_app_loaded")
                }
            }
        }
    }
    
}
