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
    

    // MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerCell()
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewAssets.dequeueReusableCell(withIdentifier: "AssetsListTableCell")as! AssetsListTableCell
        
        return cell
    }
}
