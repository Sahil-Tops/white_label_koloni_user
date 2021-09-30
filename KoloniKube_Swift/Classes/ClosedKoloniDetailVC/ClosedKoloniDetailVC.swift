//
//  ClosedKoloniDetailVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 13/09/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ClosedKoloniDetailVC: UIViewController {
    
    //MARK: - Outlet's
    @IBOutlet weak var btn_Back: UIButton!
    @IBOutlet weak var lbl_affiatedProgramLocation: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lbl_UserName: UILabel!
    @IBOutlet weak var lbl_hourlyRate: UILabel!
    @IBOutlet weak var lbl_expirationDate: UILabel!
    
    //Variable's
    var shareParameters = ShareHomeParam()
    var affliatedProgram : AffliatedProgram!
    private var clusterManager: GMUClusterManager!
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAffiliatedDetail()
    }
    
    //MARK: - @IBAction's
    @IBAction func btn_BackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Custom Function's
    func googleMapSetup() {
        
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(StaticClass.sharedInstance.latitude), longitude: CLLocationDegrees(StaticClass.sharedInstance.longitude), zoom: 13)
        self.mapView.camera = camera
        
        self.mapView?.settings.myLocationButton = false
        let mainBundle = Bundle.main
        let styleUrl: URL? = mainBundle.url(forResource: "googleOverlay", withExtension: "json")
        
        let style = try? GMSMapStyle(contentsOfFileURL: styleUrl!)
        self.mapView?.mapStyle = style
        self.mapView?.delegate = self
        
        self.loadContent()
    }
    
    func loadContent(){
        if let partnerName = self.affliatedProgram.partnerName{
            self.lbl_UserName.text = partnerName
        }
        
        if let expDate = self.affliatedProgram.expiryDate{
            self.lbl_expirationDate.text = expDate
        }
        
        if let affiliatedData = self.affliatedProgram.affiliateData{
            if affiliatedData.count > 0{
                let position = CLLocationCoordinate2D(latitude: Double(affiliatedData[0].latitude) ?? 0.0, longitude: Double(affiliatedData[0].longitude) ?? 0.0)
                let newCamera = GMSCameraPosition.camera(withTarget: position,zoom: (self.mapView!.camera.zoom))
                let update = GMSCameraUpdate.setCamera(newCamera)
                self.mapView?.moveCamera(update)
                self.lbl_affiatedProgramLocation.text = affiliatedData[0].locationName
                
                for data in affiliatedData{
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(data.latitude) ?? 0.0, longitude: Double(data.longitude) ?? 0.0))
                    marker.map = self.mapView
                    marker.icon = #imageLiteral(resourceName: "pin_loation_icn")
                    marker.userData = data
                    drawGeoFence(geofence: data.geofence)
                }
            }
        }
    }
    
    func drawGeoFence(geofence:[Geofence]){
        
        let path = GMSMutablePath()
        for data1 in geofence{
            path.add(CLLocationCoordinate2D(latitude: data1.latitude, longitude: data1.longitude))
        }
        let polyline = GMSPolygon(path: path)
        polyline.strokeColor = Global().RGB(r: 25.0, g: 191.0, b: 175.0, a: 1.0)
        polyline.fillColor = Global().RGB(r: 25.0, g: 191.0, b: 175.0, a: 0.1)
        polyline.strokeWidth = 1.0
        polyline.map = self.mapView
    }
    
}

// MARK: - GoogleMap Delegate
extension ClosedKoloniDetailVC : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? AffiliateData {
            self.lbl_affiatedProgramLocation.text = poiItem.locationName ?? ""
        } else {
            NSLog("Did tap a normal marker")
        }
        return false
    }
}

//MARK: - Web Api's
extension ClosedKoloniDetailVC{
    
    func getAffiliatedDetail(){
        
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        APICall.shared.postWeb("user_affiliate_detail", parameters: paramer, showLoder: true, successBlock: { (response) in
            self.affliatedProgram = AffliatedProgram.init(fromDictionary: response as! [String:Any])
            
            if let flag = self.affliatedProgram.fLAG, flag == true{
                self.googleMapSetup()
            }else{
                let msg = (response as? [String:Any] ?? [:])["MESSAGE"]as? String ?? ""
                StaticClass.sharedInstance.ShowNotification(false, strmsg: msg, vc: self)
            }
            
        }) { (erroe) in
            StaticClass.sharedInstance.HideSpinner()
        }
        
    }
}
