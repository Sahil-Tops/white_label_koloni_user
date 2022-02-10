//
//  DropZoneVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 5/27/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class DropZoneVC: UIViewController {
    
    //MARK: - Outlet's
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var headerView: ShadowView!
    @IBOutlet weak var containerView: ShadowView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var logo_img: UIImageView!
    @IBOutlet weak var lblMeters: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    //MARK:- Variable's
    var mapMarker: GMSMarker?
    var mapGoogle: GMSMapView?
    var placesClient : GMSPlacesClient?
    var arrPlaces = NSMutableArray ()
    var geoFenceLocationsArray = NSMutableArray()
    var partnerId = ""
    
    //MARK:- Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nearestDropzone_Web()
        self.googleMapSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.mapGoogle?.frame = CGRect(x: 0, y: 0, width: self.mapView.frame.size.width, height: self.mapView.frame.size.height)
    }
    
    //MARK :- @IBAction's
    @IBAction func btnCurrentLocationPressed(_ sender: UIButton) {
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(StaticClass.sharedInstance.latitude), longitude: CLLocationDegrees(StaticClass.sharedInstance.longitude), zoom: 15.0)
        self.mapGoogle?.animate(to: camera)
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapDirectionBtn(_ sender: UIButton) {
        if self.arrPlaces.count > 0{
            if let sharedPlaces = self.arrPlaces.object(at: 0)as? SharePlaces{
                if let url = URL(string: sharedPlaces.mapLink){
                    if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
                        UIApplication.shared.open(url, options: [:]) { (response) in
                            
                        }
                    } else {
                        print("Can't use comgooglemaps://")
                        UIApplication.shared.open(url, options: [:]) { (_) in
                            
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Custom Function's
    func googleMapSetup() {
        self.placesClient = GMSPlacesClient()
        self.mapMarker = GMSMarker()
        
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(StaticClass.sharedInstance.latitude), longitude: CLLocationDegrees(StaticClass.sharedInstance.longitude), zoom: 12)
        
        self.mapGoogle = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.mapView.frame.size.width, height: self.mapView.frame.size.height), camera: camera)
        self.mapGoogle?.isMyLocationEnabled = true
        self.mapGoogle?.settings.myLocationButton = false
        
        let mainBundle = Bundle.main
        let styleUrl: URL? = mainBundle.url(forResource: "googleOverlay", withExtension: "json")
        
        let style = try? GMSMapStyle(contentsOfFileURL: styleUrl!)
        if style == nil {
        }
        self.mapGoogle?.mapStyle = style
        self.mapGoogle?.delegate = self
        self.mapView.addSubview(self.mapGoogle!)
    }
    
    func setValueOfMap() -> Void {
        self.mapGoogle?.clear()
        var index = 0
        for data in arrPlaces as! [SharePlaces] {
            DispatchQueue.main.async
                {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2DMake(Double(data.strLat)
                        , Double(data.strLong))
                    marker.isTappable = true
                    if index == 0 {
                        if data.strType == "1"{
                            marker.icon = UIImage(named: "location_bike")
                        }else if data.strType == "2"{
                            marker.icon = UIImage(named: "location_kube")
                        }else {
                            marker.icon = UIImage(named: "location_both_green")//location_kube
                        }
                    }else{
                        if data.strType == "1"{
                            marker.icon = UIImage(named: "location_bike")
                        }else if data.strType == "2"{
                            marker.icon = UIImage(named: "location_kube")
                        }else {
                            marker.icon = UIImage(named: "location_both_green")//location_kube
                        }
                    }
                    marker.map = self.mapGoogle
                    marker.userData = index
                    index = index + 1
            }
        }
        if self.arrPlaces.count > 0 {
            let data = arrPlaces [0] as! SharePlaces
            let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(data.strLat), longitude: CLLocationDegrees(data.strLong), zoom: 15.0)
            self.lblMeters.text = "\(data.strDistance) Away!"
            self.lblAddress.text = "\(data.strName),\(data.strAddress)"
            self.mapGoogle?.animate(to: camera)
        }
        self.drawGeoFence()
    }
    
    func drawGeoFence(){
        var count = 0
        for data in geoFenceLocationsArray as! [ShareDevice] {
            let path = GMSMutablePath()
            
            for data1 in data.arrGeofence as! [ShareGeofence]{
                path.add(CLLocationCoordinate2D(latitude: data1.latitude, longitude: data1.longitude))
            }
            let polyline = GMSPolygon(path: path)
            polyline.isTappable = true
            polyline.zIndex = Int32(count)
            polyline.strokeColor = Global().RGB(r: 25.0, g: 191.0, b: 175.0, a: 1.0)
            polyline.fillColor = Global().RGB(r: 25.0, g: 191.0, b: 175.0, a: 0.3)
            polyline.strokeWidth = 1.0
            polyline.map = self.mapGoogle
            count += 1
        }
    }
    
}

//MARK: - Google Map Delegate's
extension DropZoneVC: GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let index = marker.userData as? Int{
            let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees((arrPlaces[index] as! SharePlaces).strLat), longitude: CLLocationDegrees((arrPlaces[index] as! SharePlaces).strLong), zoom: 14.0)
            self.mapGoogle?.animate(to: camera)
            self.lblMeters.text = "\((arrPlaces[index] as! SharePlaces).strDistance) Away!"
            self.lblAddress.text = "\((arrPlaces[index] as! SharePlaces).strName),\((arrPlaces[index] as! SharePlaces).strAddress)"
        }
        return true
    }
    
}

//MARK: - Web Api's
extension DropZoneVC{
    
    func nearestDropzone_Web() -> Void {
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        paramer.setValue("0", forKey: "distance_unit")
        paramer.setValue(StaticClass.sharedInstance.latitude, forKey: "latitude")
        paramer.setValue(StaticClass.sharedInstance.longitude, forKey: "longitude")
        paramer.setObject(self.partnerId, forKey: "partner_id" as NSCopying)
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        Singleton.showSkeltonViewOnViews(viewsArray: [self.containerView])
        APICall.shared.postWeb("nearest_dropzones", parameters: paramer, showLoder: false, successBlock: { (response) in
            Singleton.hideSkeltonViewFromViews(viewsArray: [self.containerView])
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool){
                    if let arrResult = dict["Dropzones"] as? NSArray{
                        for location in arrResult {
                            if let dict =  location as? NSDictionary {
                                let places = SharePlaces()
                                let shareDevice = ShareDevice()
                                places.strId = dict["id"] as? String ?? ""
                                places.strName = dict["name"] as? String ?? ""
                                places.strType = dict["type"] as? String ?? ""
                                places.strAddress = dict["address"] as? String ?? ""
                                places.strLat = Double(dict.object(forKey: "latitude") as? String ?? "0")!
                                places.strLong = Double(dict.object(forKey: "longitude") as? String ?? "0")!
                                places.strDistance = dict["distance"] as? String ?? ""
                                places.mapLink = dict["map_link"]as? String ?? ""
                                if let arrGeofence = dict["geofence"] as? NSArray{
                                    for dictGeofence in arrGeofence as! [NSDictionary]{
                                        let geofence = ShareGeofence()
                                        geofence.latitude = Double(dictGeofence.object(forKey: "latitude") as? Double ?? 0.0)
                                        geofence.longitude = Double(dictGeofence.object(forKey: "longitude") as? Double ?? 0.0)
                                        shareDevice.arrGeofence.add(geofence)
                                    }
                                }
                                self.geoFenceLocationsArray.add(shareDevice)
                                self.arrPlaces.add(places)
                            }
                        }
                        self.setValueOfMap()
                    }
                }else{
                    let msg = dict["MESSAGE"] as? String ?? ""
                    StaticClass.sharedInstance.ShowNotification(false, strmsg: msg, vc: self)
                    self.mapGoogle?.clear()
                }
            }
        }) { (error) in
            Singleton.hideSkeltonViewFromViews(viewsArray: [self.containerView])
        }
    }
    
}
