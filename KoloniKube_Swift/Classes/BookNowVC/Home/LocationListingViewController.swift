//
//  LocationListingViewController.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 01/10/21.
//  Copyright © 2021 Self. All rights reserved.
//

import UIKit

class LocationListingViewController: UIViewController {
    
    @IBOutlet weak var navigationImage: UIImageView!
    @IBOutlet weak var menu_btn: UIButton!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var locationModelArray: [LOCATION_DATA] = []
    var assetsModelArray: [ASSETS_LIST] = []

    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.searchHome_Web(lat: "\(StaticClass.sharedInstance.latitude)", long: "\(StaticClass.sharedInstance.longitude)")
        self.registerTableCell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadUI()
    }
    
    //MARK: - Custom Function's
    func registerTableCell(){
        
        self.tableView.register(UINib(nibName: "LocationListingCell", bundle: nil), forCellReuseIdentifier: "LocationListingCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
    }
    
    func loadUI(){
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "logo_img") { (image) in
            self.logoImg.image = image
        }
        self.navigationImage.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        self.view.layoutIfNeeded()
    }
    
    //MARK: - @IBAction
    @IBAction func clickOnBtn(_ sender: UIButton) {
        
        switch sender {
        case menu_btn:
            self.sideMenuViewController?.presentLeftMenuViewController()
            break
        default:
            break
        }
        
    }
    

}

//MARK: - TableView Delegate's
extension LocationListingViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "LocationListingCell")as! LocationListingCell
        let model = self.locationModelArray[indexPath.row]
        cell.title_lbl.text = model.location_name
        cell.description_lbl.text = model.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationModel = self.locationModelArray[indexPath.row]
        let filtteredArray = self.assetsModelArray.filter({$0.location_id == locationModel.id})
        let vc = AssetsListingViewController(nibName: "AssetsListingViewController", bundle: nil)
        vc.assetsListArray = filtteredArray
        vc.locationModel = locationModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//MARK: - Web API
extension LocationListingViewController{
    
    func searchHome_Web(lat: String, long: String) -> Void {
        
        let params: NSMutableDictionary = NSMutableDictionary()
        
        params.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        params.setValue(String(describing: lat), forKey: "latitude")
        params.setValue(String(describing: long), forKey: "longitude")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        params.setValue(StaticClass.sharedInstance.strBookingId, forKey: "payment_id")
        
        APICall.shared.postWeb("search_home", parameters: params, showLoder: true, successBlock: { (response) in
            print(response)
            
            if let data = response as? [String:Any]{
                if let status = data["FLAG"]as? Int, status == 1{
                    if let locationData = data["LOACTION_DATA"]as? [[String:Any]]{
                        self.locationModelArray = LOCATION_DATA.parseData(data: locationData)
                    }
                    if let assets = data["assets_lists"]as? [[String:Any]]{
                        self.assetsModelArray = ASSETS_LIST.parseData(data: assets)
                    }
                    self.tableView.reloadData()
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
}

class LOCATION_DATA{
    
    var id = ""
    var address = ""
    var average_ratings = ""
    var geofence: GEOFENCE?
    var is_affiliate_location = ""
    var is_location_active = ""
    var latitude = 0.0
    var longitude = 0.0
    var location_name = ""
    var location_type = ""
    var total_assets = ""
    var total_review = ""
    
    static func parseData(data: [[String:Any]])-> [LOCATION_DATA]{
        var array: [LOCATION_DATA] = []
        for item in data{
            let model = LOCATION_DATA()
            model.id = item["id"]as? String ?? ""
            model.address = item["address"]as? String ?? ""
            model.average_ratings = item["average_ratings"]as? String ?? ""
            for cordinates in item["geofence"]as? [[String:Any]] ?? []{
                model.geofence?.latitude = cordinates["latitude"]as? Double ?? 0.0
                model.geofence?.longitude = cordinates["longitude"]as? Double ?? 0.0
            }
            model.is_affiliate_location = item["is_affiliate_location"]as? String ?? ""
            model.is_location_active = item["is_location_active"]as? String ?? ""
            model.latitude = item["latitude"]as? Double ?? 0.0
            model.longitude = item["longitude"]as? Double ?? 0.0
            model.location_name = item["location_name"]as? String ?? ""
            model.location_type = item["location_type"]as? String ?? ""
            model.total_assets = item["total_assets"]as? String ?? ""
            model.total_review = item["total_review"]as? String ?? ""
            array.append(model)
        }
        return array
    }
}

class ASSETS_LIST{
    
    var is_icon = ""
    var address = ""
    var assets_average_price = ""
    var assets_color_code = ""
    var assets_img_url = ""
    var assets_initial_mintues = ""
    var assets_initial_price = ""
    var is_accessible_user = 0
    var is_assets_active = 0
    var is_assets_active_msg = ""
    var is_outof_dropzone = 0
    var is_plan_purchase = ""
    var latitude = 0.0
    var longitude = 0.0
    var location_id = ""
    var lock_name = ""
    var outof_dropzone_message = ""
    var partner_name = ""
    var plan_partner_id = ""
    var sub_type = ""
    var sub_type_name = ""
    var type = ""
    var type_name = ""
    var unique_id = ""
    
    static func parseData(data: [[String:Any]])-> [ASSETS_LIST]{
        var array: [ASSETS_LIST] = []
        for item in data{
            let model = ASSETS_LIST()
            model.address = item["address"]as? String ?? ""
            model.is_icon = item["IS_ICON"]as? String ?? ""
            model.assets_average_price = item["assets_average_price"]as? String ?? ""
            model.assets_color_code = item["assets_color_code"]as? String ?? ""
            model.latitude = item["latitude"]as? Double ?? 0.0
            model.longitude = item["longitude"]as? Double ?? 0.0
            model.assets_img_url = item["assets_img_url"]as? String ?? ""
            model.assets_initial_mintues = item["assets_initial_mintues"]as? String ?? ""
            model.assets_initial_price = item["assets_initial_price"]as? String ?? ""
            model.is_accessible_user = item["is_accessible_user"]as? Int ?? 0
            model.is_assets_active = item["is_assets_active"]as? Int ?? 0
            model.is_assets_active_msg = item["is_assets_active_msg"]as? String ?? ""
            model.is_outof_dropzone = item["is_outof_dropzone"]as? Int ?? 0
            model.is_plan_purchase = item["is_plan_purchase"]as? String ?? ""
            model.location_id = item["location_id"]as? String ?? ""
            model.lock_name = item["lock_name"]as? String ?? ""
            model.outof_dropzone_message = item["outof_dropzone_message"]as? String ?? ""
            model.partner_name = item["partner_name"]as? String ?? ""
            model.plan_partner_id = item["plan_partner_id"]as? String ?? ""
            model.sub_type = item["sub_type"]as? String ?? ""
            model.sub_type_name = item["sub_type_name"]as? String ?? ""
            model.type = item["type"]as? String ?? ""
            model.type_name = item["type_name"]as? String ?? ""
            model.unique_id = item["unique_id"]as? String ?? ""
            array.append(model)
        }
        return array
    }
    
}

struct GEOFENCE {
    var latitude = 0.0
    var longitude = 0.0
}
