//
//  DeviceDetailsVC.swift
//  KoloniKube_Swift
//
//  Created by Tops on 4/11/17.
//  Copyright © 2017 Self. All rights reserved.
//  test commit for updates all the changes.

import UIKit
import Cosmos
import HMSegmentedControl

class DeviceDetailsVC: UIViewController,iCarouselDelegate,iCarouselDataSource,RatingVCDelegate {
    
    @IBOutlet weak var collectionBikeView: UICollectionView!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    //@IBOutlet weak var btnBookNow: UIButton!
    //@IBOutlet weak var lblAvg: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var btnDirection: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet      var ratingView: CosmosView!
    @IBOutlet weak var lblKubeAvailable:UILabel!
    //@IBOutlet weak var lblAvailableValue:UILabel!
    @IBOutlet weak var segmentedControl: HMSegmentedControl!
    @IBOutlet weak var viewKubesListing:UIView!
    @IBOutlet weak var viewBikesListing:UIView!
    @IBOutlet weak var btnAvailable: UIButton!
    @IBOutlet weak var btnKubeAvailable: UIButton!
    
    @IBOutlet weak var lblBikePrice: UILabel!  //Remove CR by Cliebt
    @IBOutlet weak var lblBikeAvailable: UILabel!
    @IBOutlet weak var lblSorryAlert: UILabel!
    @IBOutlet weak var lblAlert2: UILabel!
    @IBOutlet weak var lblAminities: UILabel!
    @IBOutlet weak var cns_aminitiesHeight : NSLayoutConstraint!
    
    let identifier = "MarkerCell"
    
    var data = ShareDevice()
    var arrImages = NSMutableArray()
    var popup : PopupController!
    var is_FromNotification = false
    var strId = "0"
    @IBOutlet weak var ViewCarouse: iCarousel!
    @IBOutlet weak var ViewItemCarouse: iCarousel!
    
    //MARK:- VIEW DID LOAD METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // segment controller
        segmentedControl.sectionTitles = ["BIKES","KUBES"]
        
        segmentedControl.backgroundColor = #colorLiteral(red: 0.2684213221, green: 0.7833573818, blue: 0.7374846339, alpha: 1)
        //segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        viewKubesListing.isHidden = true
        segmentedControl.selectionIndicatorColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        segmentedControl.selectionStyle = HMSegmentedControlSelectionStyle.fullWidthStripe
        segmentedControl.selectionIndicatorLocation = .down
        segmentedControl.selectionIndicatorHeight = 2.0
        
        Global.Obj_Type = "Bike"
        
        segmentedControl.titleTextAttributes = [
            NSForegroundColorAttributeName : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            NSFontAttributeName : UIFont(name: Global.CFName.Muli_Regular, size: 17.0) ?? UIFont.systemFont(ofSize: 17)
        ]
        
        segmentedControl.selectedTitleTextAttributes = [
            NSForegroundColorAttributeName : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            NSFontAttributeName : UIFont(name: Global.CFName.Muli_Bold, size: 17.0) ??  UIFont.boldSystemFont(ofSize: 17)
        ]
        
        segmentedControl.addTarget(self, action:#selector(segmentValuesPressed(_:)), for: .valueChanged)
        
        // carousel for Location images
        ViewCarouse.tag = 1
        ViewCarouse.delegate = self
        ViewCarouse.dataSource = self
        ViewCarouse.type = .linear
        
        // carousel for Kube images
        ViewItemCarouse.tag =  2
        ViewItemCarouse.delegate = self
        ViewItemCarouse.dataSource = self
        ViewItemCarouse.type = .rotary
        
        // btnBookNow.layer.cornerRadius = 5;
        self.collection.register(UINib(nibName: "MarkerCell", bundle: nil), forCellWithReuseIdentifier: "MarkerCell")
        
        self.collectionBikeView.register(UINib(nibName: "BikeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BikeCollectionCell")
        
    }
    
    @IBAction func btnBookNowPressed(_ sender: UIButton) {
        let index = ViewItemCarouse.currentItemIndex
        Global.Obj_Type = "Kube"
        let getDataObj = data.arrKubes.object(at: index) as! ShareBikeKube
        Singleton.shared.bikeData = getDataObj
        
        StaticClass().saveToUserDefaults(getDataObj.strObjName as AnyObject as AnyObject, forKey: Global.sharedBikeData.strObjName)
        
        StaticClass().saveToUserDefaults(getDataObj.strId as AnyObject as AnyObject, forKey: Global.sharedBikeData.strId)
        self.objectReservationApiCall(strObjectId: getDataObj.strId);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ADD NOTIFICATION FOR REFRESH SCREEN
        Global.appdel.tabBarController.hideTabBar()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Global.notification.Push_forLocation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.GetNonification(_:)), name: NSNotification.Name(rawValue: Global.notification.Push_forLocation), object: nil)
        
        Singleton.shared.is_LocationVisible = true
        arrImages.removeAllObjects()
        if is_FromNotification {
            self.CallForDeviceDetails()
        }else{
            self.SetDataOfScreen()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        Singleton.shared.is_LocationVisible = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Global.notification.Push_forLocation), object: nil)
        super.viewDidDisappear(animated)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //  btnBookNow.layer.cornerRadius = btnBookNow.frame.size.height/2;
        btnAvailable.layer.cornerRadius = btnAvailable.frame.size.height/2;
        btnKubeAvailable.layer.cornerRadius = btnKubeAvailable.frame.size.height/2;
    }
    
    
    //MARK:-  CUSTOM METHODS
    func SetDataOfScreen() -> Void {
        
        ratingView.rating = data.strAvgRating
        lblReview.text = "\(data.strReview) reviews";
        lblRating.text = String(format: "%.1f",data.strAvgRating);
        lblItemName.text = data.strLocationName;
        lblAddress.text = data.strAddress;
        Global.objectAddress = data.strAddress
        print(data.strAvailableKube)
        print(data.strKubeAvgPrice)
        
        lblBikeAvailable.text = String(data.strAvailableBike)
        //Hide Arverage price accoring Cliet CR :- 12/10/2017 Ilesh
        //lblBikePrice.text = StaticClass().PriceFormater(price:data.strBikeAvgPrice)
        
        if data.arrImage.count == 0 {
            data.arrImage.add(ShareDeviceImage())
        }
        
        if data.strAvailableKube == 0 {
            //btnBookNow.isHidden = true
        }else{
            //btnBookNow.isHidden = false
        }
        
        if data.arrAmenities.count > 0 {
            self.collection.reloadData()
            self.lblAminities.isHidden =  true
            self.cns_aminitiesHeight.constant = 80
        } else  {
            self.lblAminities.isHidden =  true
            self.cns_aminitiesHeight.constant = 0
        }
        
        setPhotoGallary()
        SetBikesValues()
    }
    
    func SetBikesValues() -> Void {
        if data.arrBikes.count > 0 {
            collectionBikeView.isHidden = false
        }else{
            collectionBikeView.isHidden = true
        }
    }
    
    func setPhotoGallary() -> Void {
        arrImages.removeAllObjects()
        
        if data.arrKubes.count > 0 {
            for element in data.arrKubes {
                if let kubeD = element as? ShareBikeKube {
                    let dataB = ShareBothBikeKube()
                    dataB.strId = kubeD.strId
                    dataB.strName = kubeD.strName
                    dataB.strImg = kubeD.strImg
                    dataB.strBooked = kubeD.strBooked
                    dataB.doublePrice = kubeD.doublePrice
                    arrImages.add(dataB)
                }
            }
        }
        
        if arrImages.count > 0 {
            ViewItemCarouse.isHidden = false
            btnKubeAvailable.isHidden = true
        } else {
            ViewItemCarouse.isHidden = true
            btnKubeAvailable.isHidden = false
            btnKubeAvailable.addTarget(self, action: #selector(btnAvailableClick(_:)), for: .touchUpInside)
            
        }
        ViewCarouse.reloadData()
        ViewItemCarouse.reloadData()
    }
    
    //MARK:- APICALL
    func CallAvailableBike(isType:String,isObjectiId:String) {
        
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(data.strId, forKey: "location_id")
        paramer.setValue(StaticClass().strUserId, forKey: "user_id")
        paramer.setValue(isType, forKey: "type")
        paramer.setValue(isObjectiId, forKey: "object_id")
        
        print(data.strId)
        print(data.arrBikes.count)
        //let stringwsName = "any_object_free"
        
        APICall.shared.Post("any_object_free", parameters: paramer, showLoder: true) { (responsObj) in
            print(responsObj)
            
            if let dict = responsObj as? NSDictionary {
                if (dict["FLAG"] as! Bool){
                    if Global.Obj_Type == "Kube" {
                        StaticClass().ShowNotification(true, strmsg: "Alert will be sent when kube is available at this location.")
                    } else  {
                        StaticClass().ShowNotification(true, strmsg: "Alert will be sent when bike is available at this location.")
                    }
                    
                }
                else {
                    
                    if Global.Obj_Type == "Kube" {
                        StaticClass().ShowNotification(true, strmsg: "Alert will be sent when kube is available at this location.")
                    } else  {
                        StaticClass().ShowNotification(true, strmsg: "Alert will be sent when bike is available at this location.")
                    }
                }
            }
        }
        
        
        /*  APICall.shared.Get(stringwsName, withLoader: true) { (response) in
         print(response)
         if let dict = response as? NSDictionary {
         if (dict["FLAG"] as! Bool){
         //let msg = dict["MESSAGE"] as? String ?? ""
         //StaticClass().ShowNotification(true, strmsg: msg)
         }
         else{
         let msg = dict["MESSAGE"] as? String ?? ""
         StaticClass().ShowNotification(false, strmsg: msg)
         }
         }
         }*/
    }
    
    func GetNonification(_ notification: NSNotification) {
        print(notification.object ?? "")
        if let dict = notification.object as? NSDictionary {
            if let id = dict["location_id"] as? String{
                strId =  id
            }
        }
        self.CallForDeviceDetails()
    }
    
    func CallForDeviceDetails() -> Void {
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(strId, forKey: "location_id")
        paramer.setValue(StaticClass().strUserId, forKey: "user_id")
        print(paramer)
        APICall.shared.Post("location_details", parameters: paramer, showLoder: true) { (response) in
            print(response)
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool){
                    if let arrResult = dict["LOACTION_DATA"] as? NSArray{
                        let arrData = NSMutableArray()
                        Singleton.shared.parseDeviceJson(arr: arrResult, arrOut: arrData)
                        self.data = arrData [0] as! ShareDevice
                        /*for dict in arrResult as! [NSDictionary]{
                         
                         self.data .strId = dict.object(forKey: "id") as? String ?? ""
                         self.data .strAddress = dict.object(forKey: "address") as? String ?? ""
                         self.data .strAvailableBike = StaticClass().getInterGer(value: dict.object(forKey: "available_bikes")  ?? "0")
                         self.data .strAvailableKube = StaticClass().getInterGer(value: dict.object(forKey: "available_kubes")  ?? "0")
                         
                         self.data .strLat = Double(dict.object(forKey: "latitude") as? String ?? "0")!
                         self.data .strLong = Double(dict.object(forKey: "longitude") as? String ?? "0")!
                         self.data .strLocationName = dict.object(forKey: "location_name") as? String ?? ""
                         self.data .strReview = dict.object(forKey: "total_review") as? String ?? ""
                         self.data .strRating = StaticClass().getDouble(value: dict.object(forKey: "average_ratings") ?? "0")
                         self.data .strAvgRating = StaticClass().getDouble(value: dict.object(forKey: "average_ratings") ?? "0")
                         self.data .strKubeAvgPrice = StaticClass().getDouble(value: dict.object(forKey: "kube_average_price") ?? "0")
                         self.data .strBikeAvgPrice = StaticClass().getDouble(value: dict.object(forKey: "bike_average_price") ?? "0")
                         //device.strImg = dict.value(forKeyPath: "location_image") as? String ?? ""
                         if let arrKube = dict["kube_list"] as? NSArray{
                         for dictKube in arrKube as! [NSDictionary]{
                         let kube = ShareKube()
                         kube.strId = dictKube.object(forKey: "id") as? String ?? ""
                         kube.strImg = dictKube.object(forKey: "image") as? String ?? ""
                         //kube.strAvgPrice = dictKube.object(forKey: "") as? String ?? ""
                         //kube.strRating = dictKube.object(forKey: "") as? String ?? ""
                         kube.strName = dictKube.object(forKey: "name") as? String ?? ""
                         kube.strObjName = dictKube.object(forKey: "object_name") as? String ?? ""
                         kube.strPrice = StaticClass().getDouble(value: dictKube.object(forKey: "price") as? String ?? "0")
                         kube.strDistance = dictKube.object(forKey: "distance") as? String ?? ""
                         self.data  .arrKubes.add(kube)
                         }
                         }
                         if let arrBike = dict["bike_list"] as? NSArray{
                         for dictBike in arrBike as! [NSDictionary]{
                         let Bike = ShareBike()
                         Bike.strId = dictBike.object(forKey: "id") as? String ?? ""
                         Bike.strImg = dictBike.object(forKey: "image") as? String ?? ""
                         //Bike.strAvgPrice = dictBike.object(forKey: "") as? String ?? ""
                         //Bike.strRating = dictBike.object(forKey: "") as? String ?? ""
                         Bike.strName = dictBike.object(forKey: "name") as? String ?? ""
                         Bike.strObjName = dictBike.object(forKey: "object_name") as? String ?? ""
                         Bike.doublePrice = StaticClass().getDouble(value: dictBike.object(forKey: "price") as? Double ?? 0.0)
                         
                         Bike.strDistance = dictBike.object(forKey: "distance") as? String ?? ""
                         Bike.strDeviceID = dictBike.object(forKey: "device_id") as? String ?? ""
                         self.data  .arrBikes.add(Bike)
                         }
                         }
                         if let arrAmenities = dict["amenities"] as? NSArray{
                         for dictKube in arrAmenities as! [NSDictionary]{
                         let kube = ShareAmenities()
                         kube.strId = dictKube.object(forKey: "id") as? String ?? ""
                         kube.strImage = dictKube.object(forKey: "image") as? String ?? ""
                         kube.strName = dictKube.object(forKey: "name") as? String ?? ""
                         self.data  .arrAmenities.add(kube)
                         }
                         }
                         
                         if let arrImage = dict["location_image"] as? NSArray{
                         for dictKube in arrImage as! [NSDictionary]{
                         let kube = ShareDeviceImage()
                         kube.strImage = dictKube.object(forKey: "image") as? String ?? ""
                         self.data  .arrImage.add(kube)
                         }
                         }
                         
                         }*/
                    }
                    
                }
                else{
                    let msg = dict["MESSAGE"] as? String ?? ""
                    StaticClass().ShowNotification(false, strmsg: msg)
                }
            }
            self.SetDataOfScreen()
        }
    }
    
    //MARK:- CAROUSEL METHODS
    func numberOfItems(in carousel: iCarousel) -> Int {
        if carousel.tag == 1 {
            return data.arrImage.count
        }
        else{
            return arrImages.count
        }
        
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        if carousel.tag == 1 {
            var viewMy : CarousalImageLocationView!
            if let view = view as? CarousalImageLocationView {
                viewMy = view
                
            } else {
                
                let subviewArray = Bundle.main.loadNibNamed("CarousalImageLocationView", owner: self, options: nil)
                viewMy = subviewArray?[0] as! CarousalImageLocationView
                viewMy.frame = CGRect(x: 0, y: 0, width: ViewCarouse.frame.width - 5, height: self.ViewCarouse.frame.height - 5)
            }
            
            if (self.data.arrImage.count > 0) {
                let data = self.data.arrImage[index] as! ShareDeviceImage
                if data.strImage == "" {
                    viewMy.imgObject.image = UIImage(named:"placeholder")
                }else{
                    viewMy.imgObject.sd_setImage(with: URL(string: data.strImage), placeholderImage: UIImage(named:"placeholder"))
                }
                viewMy.layer.cornerRadius = 2.0
                viewMy.layer.borderWidth = 1.0
            }else  {
                
            }
            print("Carousel :- \(carousel.frame)")
            print("MyView :-\(viewMy.frame)")
            return viewMy
            
        }
        else{
            var viewMy : CarousalImageDetailsView!
            if let view = view as? CarousalImageDetailsView {
                viewMy = view
                
            } else {
                
                let subviewArray = Bundle.main.loadNibNamed("CarousalImageDetailView", owner: self, options: nil)
                viewMy = subviewArray?[0] as! CarousalImageDetailsView
                //viewMy.frame = CGRect(x: 0, y: 0, width: ViewItemCarouse.frame.width - 5, height: self.ViewItemCarouse.frame.height - 5)
                viewMy.frame = CGRect(x: 0, y: 0, width: ViewItemCarouse.frame.width - 5, height: ViewItemCarouse.frame.height + 10)
            }
            
            if (arrImages.count > 0) {
                viewMy.btnBook.layer.cornerRadius = viewMy.btnBook.frame.size.height / 2
                let data = arrImages[index] as! ShareBothBikeKube
                viewMy.lblKubeName.text = data.strName
                viewMy.lblHourValue.text = StaticClass().PriceFormater(price: data.doublePrice) //"$\(data.strId)"
                viewMy.imgObject.sd_setImage(with: URL(string: data.strImg), placeholderImage: UIImage(named:"kubePlaceholder"))
                viewMy.innerView.layer.cornerRadius = 2.0
                viewMy.innerView.layer.borderWidth = 0.5
                viewMy.innerView.layer.borderColor = UIColor.lightGray.cgColor
                viewMy.btnBook.tag = index
                if data.strBooked == "1" || data.strBooked == "2" { //red
                    viewMy.btnBook.setTitle("ALERT WHEN AVAILABLE", for: .normal)
                    viewMy.btnBook.addTarget(self, action: #selector(btnAvailableClick(_:)), for: .touchUpInside)
                    viewMy.btnBook.backgroundColor = UIColor.red
                    
                } else {
                    viewMy.btnBook.setTitle("BOOK NOW", for: .normal)
                    viewMy.btnBook.addTarget(self, action: #selector(btnBookNowPressed(_:)), for: .touchUpInside)
                }
                
                btnKubeAvailable.isHidden = true
                lblSorryAlert.isHidden = true
                lblAlert2.isHidden = true
            } else {
                viewMy.btnBook.tag = index
                btnAvailable.addTarget(self, action: #selector(btnAvailableClick(_:)), for: .touchUpInside)
                
                btnKubeAvailable.isHidden = false
                lblSorryAlert.isHidden = false
                lblAlert2.isHidden = false
            }
            
            
            print("Carousel :- \(carousel.frame)")
            print("MyView :-\(viewMy.frame)")
            return viewMy
        }
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }
    
    
    //MARK:-  BUTTON BUTTON PRESS
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAvailableClick(_ sender: UIButton) {
        //strId
        if viewBikesListing.isHidden == true {
            print(arrImages.count)
            if arrImages.count == 0 {
                self.CallAvailableBike(isType: "1", isObjectiId: "")
                
            }else  {
                let data = arrImages[sender.tag] as! ShareBothBikeKube
                self.CallAvailableBike(isType: "1", isObjectiId: data.strId)
                
            }
        } else {
            self.CallAvailableBike(isType: "2", isObjectiId: "")
        }
    }
    
    @IBAction func btnDirectionPressed(_ sender: Any) {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=\(StaticClass.sharedInstance.latitude),\(StaticClass.sharedInstance.longitude)&daddr=\(Float(data.strLat)),\(Float(data.strLong))&directionsmode=driving")! as URL)
            
        } else {
            let googleMapUrlString = "http://maps.google.com/?saddr=\(StaticClass.sharedInstance.latitude),\(StaticClass.sharedInstance.longitude)&daddr=\(Float(data.strLat)),\(Float(data.strLong))"
            UIApplication.shared.openURL(URL(string: googleMapUrlString)!)
        }
    }
    
    @IBAction func segmentValuesPressed(_ sender: UIButton) {
        if viewBikesListing.isHidden {
            Global.Obj_Type = "Bike"
            viewBikesListing.isHidden = false
            viewKubesListing.isHidden = true
            lblBikeAvailable.text = String(data.strAvailableBike)
            //lblBikePrice.text = StaticClass().PriceFormater(price:data.strBikeAvgPrice)
            ViewItemCarouse.isHidden = true
            btnAvailable.isHidden = false
            btnAvailable.addTarget(self, action: #selector(btnAvailableClick(_:)), for: .touchUpInside)
            collectionBikeView.reloadData()
            
        } else {
            
            if arrImages.count > 0 {
                ViewItemCarouse.isHidden = false
                btnKubeAvailable.isHidden = true
            } else {
                ViewItemCarouse.isHidden = true
                btnKubeAvailable.isHidden = false
                btnKubeAvailable.addTarget(self, action: #selector(btnAvailableClick(_:)), for: .touchUpInside)
            }
            lblKubeAvailable.text = String(data.strAvailableKube)
            //lblAvailableValue.text = StaticClass().PriceFormater(price:data.strKubeAvgPrice)
            Global.Obj_Type = "Kube"
            viewBikesListing.isHidden = true
            viewKubesListing.isHidden = false
        }
    }
    
    @IBAction func btnRatingPressed(_ sender: Any) {
        popup = PopupController
            .create(self)
        let container = RatingVC.instance()
        container.delegate = self
        container.strLocationId = data.strId
        container.CurrentRating = data.strAvgRating
        container.closeHandler = { _ in
            self.popup.dismiss()
        }
        popup.show(container)
    }
    
    func btnBookClicked(btnBookSender:UIButton) {
        
        if viewBikesListing.isHidden == true {
            Global.Obj_Type = "Kube"
            let getDataObj = data.arrKubes.object(at: btnBookSender.tag) as! ShareBikeKube
            Singleton.shared.bikeData = getDataObj
            self.objectReservationApiCall(strObjectId: getDataObj.strId);
        }
        else {
            Global.Obj_Type = "Bike"
            let getDataObj = data.arrBikes.object(at: btnBookSender.tag) as! ShareBikeKube
            Singleton.shared.bikeData = getDataObj
            StaticClass().saveToUserDefaults(getDataObj.strObjName as AnyObject as AnyObject, forKey: Global.sharedBikeData.strObjName)
            StaticClass().saveToUserDefaults(getDataObj.strId as AnyObject as AnyObject, forKey: Global.sharedBikeData.strId)
            self.objectReservationApiCall(strObjectId: getDataObj.strId);
        }
    }
    
    //MARK:- RATING VIEW DELEGATE
    func SucessRatingCall(strMsg: String, rating: Double, avgRate: Double, strReview: String) {
        popup.dismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.data.strAvgRating = rating
                self.data.strReview = strReview
                self.ratingView.rating = self.data.strAvgRating
                self.lblReview.text = "\(self.data.strReview) reviews";
                self.lblRating.text = String(format: "%.1f",self.data.strAvgRating);
            }
        }
    }
    //MARK: Function for Object Reserved
    func objectReservationApiCall(strObjectId:String) {
        
        let dictParam : NSMutableDictionary = NSMutableDictionary()
        let strUserId = StaticClass().retriveFromUserDefaults(Global.g_UserData.UserID)as! String?
        dictParam.setValue(strUserId, forKey: "user_id")
        dictParam.setValue(strObjectId, forKey: "object_id");
        
        APICall.shared.Post("object_reserved", parameters: dictParam , showLoder: true) { (responseObj) in
            print(responseObj)
            
            if let dict = responseObj as? NSDictionary {
                if (dict["IS_ACTIVE"] as! Bool){
                    if (dict["FLAG"] as! Bool){
                        Global.appdel.strIsUserType = dict["user_type"] as? String ?? "0"
                        //Global.appdel.strIsUserType = "1"
                        //SKIP THIS STEP FOR CLIENT CHANGE :- 12/10/2017
                        //self.setUpAlertController() ADD BELOW METHOD FOR CHECK CUSTOMER AVAILABLE OR NOT.
                        self.checkCustIDAvailableOrNot()
                    } else {
                        StaticClass().ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "")
                    }
                } else {
                    self.callLogOutMethod()
                }
            }
        }
    }
    
    //MARK: LOGOUT METHOD
    func callLogOutMethod() {
        Global.appdel.LogoutUser()
    }
    
    //MARK: CHECK CUSTOMER AVAILABLE OR NOT
    func checkCustIDAvailableOrNot() {
        let strCustID = StaticClass().retriveFromUserDefaults(Global.g_UserData.Customer_ID)as! String?
        if strCustID == "" {
            if Global.appdel.strIsUserType ==  "0" {
                self.craditCardListingPageScreen(strCustomerId: strCustID!)
            } else if Global.appdel.strIsUserType == "1" || Global.appdel.strIsUserType == "2" {
                self.bikeDetailVC(strCustomerId: strCustID!)
            }
        } else {
            if Global.appdel.strIsUserType == "1" || Global.appdel.strIsUserType == "2" {
                self.bikeDetailVC(strCustomerId: strCustID!)
            } else  {
                self.craditCardListingPageScreen(strCustomerId: strCustID!)
            }
        }
    }
    
    //MARK: NAVIGATE CRADIT CARD LISTING PAGE
    func bikeDetailVC(strCustomerId:String) {
        /* let booking = BikeDetailVC(nibName: "BikeDetailVC", bundle: nil)
         booking.data = data
         booking.bikeDataObj = Singleton.shared.bikeData
         self.navigationController?.pushViewController(booking, animated: true)*/
        
        let bookingTrip = LinkaDeviceConnectionVC(nibName: "LinkaDeviceConnectionVC", bundle: nil)
        bookingTrip.shareCraditCardOBJ = shareCraditCard()
        bookingTrip.data = data
        bookingTrip.bikeDataObj = Singleton.shared.bikeData
        self.navigationController?.pushViewController(bookingTrip, animated: true)
        
    }
    
    
    //MARK: NAVIGATE CRADIT CARD LISTING PAGE
    func craditCardListingPageScreen(strCustomerId:String) {
        print("Object_Type: /(Global.Obj_Type)")
        let bookingPayment = BookingPaymentVC(nibName: "BookingPaymentVC", bundle: nil)
        bookingPayment.strCustomerID = strCustomerId
        bookingPayment.data = data
        self.navigationController?.pushViewController(bookingPayment, completion: {
            print("Success");
        })
    }
    
    
    func passwordVarification(txtPassword:String) {
        let diction = NSMutableDictionary ()
        diction.setValue(txtPassword, forKey: "password")
        diction.setValue(StaticClass().strUserId, forKey: "user_id")
        
        APICall.shared.Post("check_user_details", parameters:diction , showLoder: true) { (responseObj) in
            if let dict = responseObj as? NSDictionary {
                if (dict["IS_ACTIVE"] as! Bool){
                    if (dict["FLAG"] as! Bool){
                        self.checkCustIDAvailableOrNot()
                    } else {
                        StaticClass().ShowNotification(false, strmsg: dict["MESSAGE"] as? String ?? "")
                        self.setUpAlertController()
                    }
                }
            }
        }
    }
    
    func setUpAlertController() {
        
        if Global.appdel.strIsUserType ==  "0" { // PAIND OR NORMAIL USER ASK PASSWORD FOR PCI COMPLINER
            let alertController = UIAlertController(title: "Confirm Password", message: "", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Submit", style: .default, handler: {
                alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                
                let trimmedString = firstTextField.text!.trimmingCharacters(in: .whitespaces) as String
                if (trimmedString == ""){
                    StaticClass().ShowNotification(false, strmsg:LocalizeHelper().localizedString(forKey:"KeyVMPassword"))
                }
                
                self.passwordVarification(txtPassword: firstTextField.text!)
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }else if Global.appdel.strIsUserType == "1" || Global.appdel.strIsUserType == "2" { //FREE OR DEMO USER
            self.checkCustIDAvailableOrNot()
        }
        else{
            print("Unknow type")
        }
    }
    
}


extension DeviceDetailsVC : UICollectionViewDataSource {
    
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,for:indexPath) as! MarkerCell
            cell.lblCell.text = (data.arrAmenities.object(at: indexPath.row) as! ShareAmenities).strName
            var strAminities = String()
            strAminities = (data.arrAmenities.object(at: indexPath.row) as! ShareAmenities).strImage
            cell.imgCell.sd_setImage(with: URL(string: strAminities), placeholderImage: UIImage(named:""))
            
            print("Amenities Url: \(strAminities)")
            
            //            if ((data.arrAmenities.object(at: indexPath.row) as! ShareAmenities).strId == "1"){
            //                cell.imgCell.image = UIImage(named: "wif_fi")
            //            }else if ((data.arrAmenities.object(at: indexPath.row) as! ShareAmenities).strId == "2") {
            //                cell.imgCell.image = UIImage(named: "charging")
            //            }
            //            else if ((data.arrAmenities.object(at: indexPath.row) as! ShareAmenities).strId == "3") {
            //                cell.imgCell.image = UIImage(named: "bike_pump")
            //            }
            //            else {
            //                cell.imgCell.image = UIImage(named: "ball_pump")
            //            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BikeCollectionCell",for:indexPath) as! BikeCollectionCell
            cell.layer.borderColor = UIColor.lightGray.cgColor;
            cell.layer.borderWidth =  0.5;
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.lightGray.cgColor
            
            cell.lblBikeCount.text = (data.arrBikes.object(at: indexPath.row) as! ShareBikeKube).strName
            cell.btnBookNow.tag = indexPath.row;
            cell.btnBookNow.addTarget(self, action: #selector(btnBookClicked(btnBookSender:)), for: .touchUpInside)
            cell.lblBikePrice.text = StaticClass().PriceFormater(price:(data.arrBikes.object(at: indexPath.row) as! ShareBikeKube).doublePrice)
            return cell;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collection {
            return data.arrAmenities.count
        } else {
            return data.arrBikes.count;
        }
    }
}

extension DeviceDetailsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionBikeView {
            return CGSize(width: collectionView.frame.width/2 - 7, height: collectionView.frame.height/2 - 7);
        }else {
            return CGSize(width: 88, height: 80)
        }
    }
}

// MARK:- UICollectionViewDelegate Methods
extension DeviceDetailsVC : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collection {
            return
        }
        if viewBikesListing.isHidden == true {
            
            Global.Obj_Type = "Kube"
            let getDataObj = data.arrKubes.object(at: indexPath.row) as! ShareBikeKube
            Singleton.shared.bikeData = getDataObj
            self.objectReservationApiCall(strObjectId: getDataObj.strId);
            
        } else {
            
            Global.Obj_Type = "Bike"
            let getDataObj = data.arrBikes.object(at: indexPath.row) as! ShareBikeKube
            Singleton.shared.bikeData = getDataObj
            
            StaticClass().saveToUserDefaults(getDataObj.strObjName as AnyObject as AnyObject, forKey: Global.sharedBikeData.strObjName)
            
            StaticClass().saveToUserDefaults(getDataObj.strId as AnyObject as AnyObject, forKey: Global.sharedBikeData.strId)
            
            self.objectReservationApiCall(strObjectId: getDataObj.strId);
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}
