//
//  TodayViewController.swift
//  koloniKube
//
//  Created by Tops on 05/08/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

var appGroupDefaults = UserDefaults.standard

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var rideDetailView: UIView!
    @IBOutlet weak var lbl_bikeNumber: UILabel!
    @IBOutlet weak var lbl_miles: UILabel!
    @IBOutlet weak var lbl_amount: UILabel!
    @IBOutlet weak var lbl_time: UILabel!
    
    var isFirstTime = true
    let baseUrl = "http://13.59.246.255/app/ws/v10/"         //Live Url
//    let baseUrl = "https://kolonishare.com/design/ws/v10/"   //Beta Url
    @IBOutlet weak var noRental_label: UILabel!
    var timer:Timer!
    var date = Date()
    var dict : [String:String] = [:]
    lazy private var locman = CLLocationManager()
    var location : CLLocationCoordinate2D!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locman.delegate = self
        self.noRental_label.isHidden = true
        appGroupDefaults = UserDefaults(suiteName:"group.com.koloni.kolonikube")!
        if let dict = appGroupDefaults.value(forKey: "ride") as? [String:String]{
            self.dict = dict
            self.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
            print("Hurray i got the data from Main App to Extension")
        }
        
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locman.startUpdatingLocation()
    }
    
    @IBAction func openAppTapped(_ sender: Any) {
        extensionContext?.open(URL(string: "foo://")! , completionHandler: nil)
    }
    
    @objc func updateLabel()
    {
        if self.location != nil
        {
            trackLocation(param: self.dict)
        }
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func trackLocation(param:[String:String])
    {
        var paramsDictionary = [String:String]()
        
        paramsDictionary = param
        
        paramsDictionary["latitude"] = "\(self.location.latitude)"
        paramsDictionary["longitude"] = "\(self.location.longitude)"
        self.indicator.startAnimating()
        self.indicator.isHidden = false
        HttpClientApi.instance().makeAPICall(url: "\(self.baseUrl)track_location", params:paramsDictionary, method: .POST, success: { (data, response, error) in
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
            
            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data!) as? [String:AnyObject]{
                    print(responseJSON)
                    print(responseJSON["FLAG"]!)
                    let response1 = responseJSON["FLAG"]! as! Bool
                    print(response1)
                    //Check response from the sever
                    if response1
                    {
                        if let value = responseJSON["BOOKING"] as? [[String:Any]?]
                        {
                            if value.count == 0
                            {
                                self.rideDetailView.isHidden = true
                                self.noRental_label.isHidden = false
                                return
                            }
                            else
                            {
                                self.noRental_label.isHidden = true
                                self.rideDetailView.isHidden = false
                            }
                            
                            if let dict = value[0]{
                                DispatchQueue.main.async {
                                    
                                    self.lbl_bikeNumber.text = "\(dict["obj_unique_id"] ?? "-")"
                                    self.lbl_miles.text = "\(dict["total_distance"] ?? "-")"
                                    
                                    let currentRatio = Double("\(dict["total_price"] ?? "-")")!
                                    
                                    self.lbl_amount.text = String(format: "%.2f", currentRatio)// "\(dict["total_price"] ?? "-")"
                                    
                                    let time = ("\(dict["total_time"] ?? "-")").components(separatedBy: ":")
                                    
                                    if time.count > 0
                                    {
                                        self.lbl_time.text = "\(time[0]) hr. " + "\(time[1]) min."
                                    }
                                }
                            }
                            print(value)
                            
                        }
                    }
                    else
                    {
                        
                    }
                }
            }
            catch {
                print("Error -> \(error)")
            }
            
        }, failure: { (data, response, error) in
            
            // API call Failure
            
        })
    }
    
}

extension TodayViewController:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations[0].coordinate
        if isFirstTime {
            isFirstTime = false
            self.trackLocation(param: self.dict)
        }
    }
}
