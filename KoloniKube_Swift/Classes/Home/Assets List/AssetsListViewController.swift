//
//  AssetsListViewController.swift
//  KoloniKube_Swift
//
//  Created by Sam on 17/02/22.
//  Copyright © 2022 Self. All rights reserved.
//

import UIKit

class AssetsListViewController: UIViewController {
    
    // MARK: - Outlet's
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var tableViewAssets: UITableView!
    
    var devicesModel: [DevicesModel] = []
    var stripeClient: StripeClient?

    // MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stripeClient = StripeClient.init(vc: self)
        self.registerCell()
    }
    
    // MARK: - @IBAction's
    @IBAction func tapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Custom Function's
    func registerCell(){
        self.tableViewAssets.register(UINib(nibName: "AssetsListTableCell", bundle: nil), forCellReuseIdentifier: "AssetsListTableCell")
        self.tableViewAssets.delegate = self
        self.tableViewAssets.dataSource = self
    }
    
}

// MARK: - TableView Delegate's
extension AssetsListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devicesModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewAssets.dequeueReusableCell(withIdentifier: "AssetsListTableCell")as! AssetsListTableCell
        let model = self.devicesModel[indexPath.row]
        cell.lblAssignment.text = (model.assignment ?? "").capitalized
        cell.lblMacId.text = model.lock_data?.mac_id ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        OpenAPI.sharedInstance.reserveDevice(deviceId: self.devicesModel[indexPath.row].device_id ?? "") { model in
//
//        }        
    }
}

