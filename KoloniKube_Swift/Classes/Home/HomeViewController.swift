//
//  HomeViewController.swift
//  KoloniKube_Swift
//
//  Created by Sam on 17/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Outlet's
    @IBOutlet weak var tableViewLocation: UITableView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var viewRipple: UIView!
    @IBOutlet weak var btnGift: UIButton!
    @IBOutlet weak var lblFreeRentalCounts: UILabel!
   
    
    // Variable's
    var locationsModel: [LocationsModel] = []
    

    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        OpenAPI.sharedInstance.getLocationListing_Web { locationsModel in
            self.locationsModel = locationsModel
            self.tableViewLocation.reloadData()
        }
    }
    
    // MARK: - @IBAction's
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case btnMenu:
            self.sideMenuViewController?.presentLeftMenuViewController()
            break
        case btnGift:
            break
        default:break
        }
        
    }
    
    // MARK: - Custom Function's
    func registerCell(){
        self.tableViewLocation.register(UINib(nibName: "HomeTableCell", bundle: nil), forCellReuseIdentifier: "HomeTableCell")
        self.tableViewLocation.delegate = self
        self.tableViewLocation.dataSource = self
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
        OpenAPI.sharedInstance.getDevices_Web(count: 10) { devicesModel in

        }
        let assetsListVc = AssetsListViewController(nibName: "AssetsListViewController", bundle: nil)
        self.navigationController?.pushViewController(assetsListVc, animated: true)
    }
    
}
