//
//  HomeViewController.swift
//  KoloniKube_Swift
//
//  Created by Sam on 17/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout

class HomeViewController: UIViewController {
    
    // MARK: - Outlet's
    @IBOutlet weak var tableViewLocation: UITableView!
    @IBOutlet weak var collectionViewRunningRental: UICollectionView!
    
    @IBOutlet weak var lblNoLocationFound: UILabel!
    @IBOutlet weak var lblFreeRentalCounts: UILabel!
    
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnGift: UIButton!
    
    @IBOutlet weak var viewRipple: UIView!
    @IBOutlet weak var viewRunningRental: CustomView!
    @IBOutlet weak var heightViewRunningRental: NSLayoutConstraint!
    
    // Variable's
    var pageCount = 0
    var isScrolling = false
    var locationsModel: [LocationsModel] = []
    var layout = UPCarouselFlowLayout()
    fileprivate var pageSize: CGSize {
        let layout = self.collectionViewRunningRental.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.registerCell()
        self.setupInitialUI()
        self.setupCollectionLayout()
        self.callLocationApi(count: 10)
    }
    
    // MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        switch sender {
        case btnMenu:
            self.sideMenuViewController?.presentLeftMenuViewController()
            break
        case btnGift:
            break
        default: break
        }
    }
    
    // MARK: - Custom Function's
    func registerCell(){
        self.tableViewLocation.register(UINib(nibName: "HomeTableCell", bundle: nil), forCellReuseIdentifier: "HomeTableCell")
        self.tableViewLocation.delegate = self
        self.tableViewLocation.dataSource = self
    }
    
    func setupCollectionLayout(){
        self.layout.itemSize = CGSize(width: self.collectionViewRunningRental.frame.width - 40, height: 265)
        self.layout.scrollDirection = .horizontal
        self.layout.spacingMode = .fixed(spacing: 10)
        self.layout.sideItemScale = 0.8
        self.collectionViewRunningRental.collectionViewLayout = self.layout
    }
    
    func setupInitialUI(){
        self.heightViewRunningRental.constant = -308
        self.viewRunningRental.isHidden = true
        self.addSwipeGesture()
    }
    
    func addSwipeGesture(){
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpDown(_:)))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpDown(_:)))
        swipeDown.direction = .down
        swipeUp.direction = .up
        self.viewRunningRental.addGestureRecognizer(swipeUp)
        self.viewRunningRental.addGestureRecognizer(swipeDown)
    }
    
    func callLocationApi(count: Int) {
        OpenAPI.sharedInstance.getLocationListing_Web(count: "\(count)") { locationsModel in
            self.locationsModel = locationsModel
            self.tableViewLocation.reloadData()
            self.lblNoLocationFound.isHidden = self.locationsModel.count == 0 ? false:true
        }
    }

    @objc func swipeUpDown(_ sender: UISwipeGestureRecognizer){
        if sender.direction == .down{
            UIView.animate(withDuration: 0.5) {
                self.heightViewRunningRental.constant = -308
                self.view.layoutIfNeeded()
            }
        }else if sender.direction == .up{
            UIView.animate(withDuration: 0.5) {
                self.heightViewRunningRental.constant = -10
                self.view.layoutIfNeeded()
            }
        }
    }
    
}

// MARK: - UIScrollView Delegate's
extension HomeViewController: UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableViewLocation{
            if (self.tableViewLocation.contentOffset.y + self.tableViewLocation.frame.height) > self.tableViewLocation.contentSize.height{
                if self.isScrolling{
                    self.isScrolling = false
//                    self.pageCount += 10
//                    self.callLocationApi(count: self.pageCount)
                }
            }
        }
    }
    
}

// MARK: - TableView Delegate's
extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationsModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableViewLocation.dequeueReusableCell(withIdentifier: "HomeTableCell")as! HomeTableCell
        let model = self.locationsModel[indexPath.row]
        cell.lblLocationName.text = model.name ?? ""
        cell.lblOrgId.text = model.org_id ?? ""
        cell.lblLocationId.text = model.location_id ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        OpenAPI.sharedInstance.getAllDevices_Web(count: 10) { devicesModel in
            let assetsListVc = AssetsListViewController(nibName: "AssetsListViewController", bundle: nil)
            assetsListVc.devicesModel = devicesModel
            self.navigationController?.pushViewController(assetsListVc, animated: true)
        }
    }
    
}
