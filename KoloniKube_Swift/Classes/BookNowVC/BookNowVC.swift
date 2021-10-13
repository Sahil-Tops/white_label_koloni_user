 //
 //  BookNowVC.swift
 //  KoloniKube_Swift
 //
 //  Created by Tops on 4/4/17.
 
 //  Copyright © 2017 Self. All rights reserved.
 //
 
 import UIKit
 import GoogleMaps
 import GooglePlaces
 import IQKeyboardManagerSwift
 import MessageUI
 import LinkaAPIKit
 import Cosmos
 import UPCarouselFlowLayout
 import CoreBluetooth
 
 class POIItem: NSObject, GMUClusterItem {
    var color: UIColor!
    var assetImage: UIImage!
    var strName: String!
    var position: CLLocationCoordinate2D
    var name: String!
    let id:NSInteger!
    let strIndex: String!
    
    init(position: CLLocationCoordinate2D, name: String,id:NSInteger, index: String, hexCode: String){
        self.position = position
        self.name = name
        self.id = id
        self.strName = name
        self.strIndex = index
        //        self.assetImage = image
        self.color = UIColor.init(hex: hexCode)
    }
 }
 
 var pickedImage = UIImage()
 
 class BookNowVC: UIViewController{
    
    //MARK:- Outlet's
    
    //View's, ScrollView
    @IBOutlet weak var navigationBgImage: UIImageView!
    @IBOutlet weak var adImageScrollView: UIScrollView!
    @IBOutlet weak var rippleView: UIView!
    @IBOutlet weak var startBtnContainerView: UIView!
    @IBOutlet weak var addRentalContainerView: CustomView!
    @IBOutlet weak var selectPaymentOptView: CustomView!
    @IBOutlet weak var freeRentalsContainerView: UIView!
    @IBOutlet weak var onLinkaLockView: CustomView!
    @IBOutlet weak var popUpAd: UIView!
    @IBOutlet weak var qrBtnView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerKoloniLogo_img: UIImageView!
    @IBOutlet weak var rentalContainerView: CustomView!
    @IBOutlet weak var adTitleView: UIView!
    @IBOutlet weak var bikeLock_imageView: CustomView!
    @IBOutlet var axaLoaderBackGroundView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var loaderBgView: UIView!
    
    //TableView, CollectionView
    @IBOutlet weak var cardListTableView: UITableView!
    @IBOutlet weak var pauseRentalCollectionView: UICollectionView!
    @IBOutlet weak var lockGuidCollection: UICollectionView!
    
    //ImageView
    @IBOutlet weak var imgAd: UIImageView!
    @IBOutlet weak var imgBigAd: UIImageView!
    
    //Button's
    @IBOutlet weak var nearestDropZone_btn: CustomButton!
    @IBOutlet weak var checkBoxReferral_btn: UIButton!
    @IBOutlet weak var choose_btn: UIButton!
    @IBOutlet weak var next_btn: UIButton!
    @IBOutlet weak var checkBox_btn: UIButton!
    @IBOutlet weak var onLinkaViewNext_btn: UIButton!
    @IBOutlet weak var markerPoppuBG: UIButton!
    @IBOutlet weak var btnFindNearest: UIButton!
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var btnStartQRScan: UIButton!
    @IBOutlet weak var btnSliderMenu: UIButton!
    @IBOutlet weak var btnInfo: CustomButton!
    @IBOutlet weak var help_btn: CustomButton!
    @IBOutlet weak var btnGift: UIButton!
    
    //Label's & TextField's & TextView's
    @IBOutlet weak var numberOfFreeRentals_lbl: UILabel!
    @IBOutlet weak var lblTitAd: UILabel!
    @IBOutlet weak var description_textView: UITextView!
    @IBOutlet weak var referralCount_lbl: UILabel!
    
    //Constraints
    @IBOutlet weak var selectPaymentOptView_bottom: NSLayoutConstraint!
    @IBOutlet weak var cardListTable_height: NSLayoutConstraint!
    @IBOutlet weak var onLinkaLock_bottom: NSLayoutConstraint!
    @IBOutlet weak var descriptionAd_height: NSLayoutConstraint!
    @IBOutlet weak var headerView_height: NSLayoutConstraint!
    @IBOutlet weak var bottomContraintOfMap: NSLayoutConstraint!
    @IBOutlet weak var lockGuideCollection_height: NSLayoutConstraint!
    
    //PauseRentalView
    @IBOutlet weak var rentalBgImageView: UIImageView!
    @IBOutlet weak var pauseRentalCollectionView_height: NSLayoutConstraint!
    @IBOutlet weak var pauseRentalCollection_bottom: NSLayoutConstraint!
    @IBOutlet weak var numberOfRentalsRunning_lbl: UILabel!
    @IBOutlet weak var currentRentalAmount_lbl: UILabel!
    @IBOutlet weak var axaLoaderMsg_lbl: UILabel!
    @IBOutlet weak var pageController: UIPageControl!
    
    //SlideToFinish
    @IBOutlet weak var btnSlideToFinish: VHSlideButton!    
    @IBOutlet weak var finishRentalsView: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var widthConstraints: NSLayoutConstraint!
    @IBOutlet weak var lblSlideAnimation: UILabel!
    @IBOutlet weak var lblLoaderTitle: UILabel!
    @IBOutlet var ViewLoader: UIView!
    @IBOutlet weak var linkaLockImg: UIImageView!
    @IBOutlet weak var underLine1_lbl: UILabel!
    
    
    var startBookingSwift: StartBooking?
    var axaLoader = AnimatedCircularView()
    let lockConnectionService : LockConnectionService = LockConnectionService.sharedInstance
    var batteryPercentage = 50
    var isEventStatus = String()
    var isPause = Bool()
    var imagePicker = UIImagePickerController()
    var strLocationID = String()
    var strBikeKubeID = String()
    var isNreaBY = false
    var loadingCollectionFirstTime = true       //Using this in PauseCollection Cell Class for iterate cell frame once on start.
    
    var shareDeviceObj = ShareDevice()
    var sharedCreditCardObj = shareCraditCard()
    var bikeSharedData = ShareBikeData()
    var bikeSharedDataArray: [ShareBikeData] = []
    var endingRentalData: [String:Any] = [:]
    var isMyRental = Bool()
    var currentLat: CGFloat = 0.0;
    var currentLong: CGFloat = 0.0;
    var is_uploadingImg = false
    var paymentId = "" //only used in uploading image
    var shareParameters = ShareHomeParam()
    var arrDeviceData :NSMutableArray = NSMutableArray()
    var arrAdData :NSMutableArray = NSMutableArray()
    var arrayOfBike : NSMutableArray = NSMutableArray()
    private var clusterManager: GMUClusterManager!
    var isSkipCall = false
    var dropzoneArray = [String]()
    var rentalImage : UIImage!
    var isCamBroken = false
    var appGroupDefaults = UserDefaults.standard
    var selectedLocId = ""
    var selectedIndex = -1
    var cameraZoom: Float = 0.0
    var isViewDidCall: Bool = true      //Using this variable for show loader for only when view did load of the class.
    var arrCardList = NSMutableArray()
    var cardListCell = CardsListCell()
    var referralSelected = 0
    var cardSelected = 0
    var numberOfReferralRentals = 0
    var totalRidesTaken = 0
    var isTableHide: Bool = true
    var selectedBikeMacAddress = ""
    var isRentalViewDown = false
    var btnPressedPause = false
    var selectedRentalIndex = 0
    var lastSelectedIndex = 0
    var isRentalCellChagned = false
    var selectedObjectId = ""
    ///0 - Pause rental, 1 - End rental
    var rentalActionPerformed = 0
    var imagePickerVcPresent = false          //Using this for preventing google map setup function call from view will appear while dismissed from image picker vc.
    var directBooking = false
    var centerLatLong_previous: CLLocationCoordinate2D!
    var centerLatLong_current: CLLocationCoordinate2D!
    var isMapDraggin = false
    var requestingApi = true
    var iamAtHub = false
    var isEndingRentalManual = ""
    
    var lockType: LockType?
    var axaLockConnection: AXALOCK_CONNECTION?
    var lockCommand = "0"
    var isAxaLoaderLoad = false
    
    var layout = UPCarouselFlowLayout()
    fileprivate var pageSize: CGSize {
        let layout = self.pauseRentalCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    var lockCollectionlayout = UPCarouselFlowLayout()
    fileprivate var cellSize: CGSize {
        let lockCollectionlayout = self.lockGuidCollection.collectionViewLayout as! UPCarouselFlowLayout
        var cellSize = lockCollectionlayout.itemSize
        if lockCollectionlayout.scrollDirection == .horizontal {
            cellSize.width += lockCollectionlayout.minimumLineSpacing
        } else {
            cellSize.height += lockCollectionlayout.minimumLineSpacing
        }
        return cellSize
    }
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        Singleton.isCalledDidFinishLaunch = false
        self.loadContent()
        self.getlockInstructionList_Web()
        self.setCollectionLayout()
        self.addObserver()
        Global().startInternetCheckTimer()
        self.setAdsImageScrollFunctionality()
        self.registerCollectionCell()
        Global.getUserProfile_Web(vc: self) { (response, data) in
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.craditCardList_Web()
        self.axaLockConnection = AXALOCK_CONNECTION(vc: self)
        if !self.imagePickerVcPresent{
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.setupGoogleMap()
            }
        }else{
            self.imagePickerVcPresent = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.axaLockConnection?.dissconnectDevice()
        if !self.imagePickerVcPresent{
            for i in 0..<Singleton.timerArray.count{
                (Singleton.timerArray[i]).invalidate()
            }
            Singleton.timerArray.removeAll()
        }else{
            self.imagePickerVcPresent = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadUI()
        self.btnStartQRScan.layer.cornerRadius = btnStartQRScan.frame.size.height/2
        self.btnFindNearest.layer.cornerRadius = btnFindNearest.frame.size.height/2
        self.qrBtnView.circleObject()
    }
    
    deinit {
        if self.axaLockConnection?.peripheralDevice != nil{
            self.axaLockConnection?.centralMannager?.cancelPeripheralConnection((self.axaLockConnection?.peripheralDevice!)!)
        }
    }
    
 }
 
 //MARK: - @IBAction's
 extension BookNowVC{
    
    @IBAction func btnSliderMenuClick(_ sender: UIButton) {
        self.sideMenuViewController?.presentLeftMenuViewController()
    }
    
    @IBAction func tapNearDropZone(_ sender: UIButton) {
        let dropzone = DropZoneVC(nibName: "DropZoneVC", bundle: nil)
        if Singleton.runningRentalArray.count > self.selectedRentalIndex{
            dropzone.partnerId = Singleton.runningRentalArray[selectedRentalIndex]["partner_id"]as? String ?? ""
        }
        self.navigationController?.pushViewController(dropzone, animated: true)
    }
    
    @IBAction func btnCheckBoxReferralPressed(_ sender: UIButton) {
        
        if sender.tag == 0{
            sender.tag = 1
            self.referralSelected = 1
            self.checkBoxReferral_btn.setImage(UIImage(named: "checked_blue"), for: .normal)
        }else{
            sender.tag = 0
            self.referralSelected = 0
            self.checkBoxReferral_btn.setImage(UIImage(named: "unchecked_gray"), for: .normal)
        }
        
    }
    
    @IBAction func btnChoosePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let bookingPayment = BookingPaymentVC(nibName: "BookingPaymentVC", bundle: nil)
        let strCustID = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID)as? String ?? ""
        bookingPayment.strCustomerID = strCustID
        bookingPayment.numberOfReferral = self.numberOfReferralRentals
        bookingPayment.referralSelected = self.referralSelected
        bookingPayment.selectedObjectId = self.selectedObjectId
        self.selectPaymentOptView_bottom.constant = -(self.selectPaymentOptView.frame.height + AppDelegate().getBottomSafeAreaHeight())
        self.markerPoppuBG.isHidden = true
        self.navigationController?.pushViewController(bookingPayment, completion: {
        })
    }
    
    @IBAction func btnNextPressed(_ sender: UIButton) {
        
        if sender == next_btn{
            if self.referralSelected != 0 || self.cardSelected != 0{
                self.selectPaymentOptView_bottom.constant = -(self.selectPaymentOptView.frame.height + AppDelegate().getBottomSafeAreaHeight())
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                }) { (_) in
                    self.selectPaymentOptView.isHidden = true
                    if self.directBooking{
                        self.markerPoppuBG.isHidden = true
                        self.btnBgTapped(UIButton())
                        self.startBookingSwift = StartBooking.init()
                        self.startBookingSwift?.initialize(vc: self, asset_id: self.selectedObjectId, refferalApply: self.referralSelected, shareCraditCard: self.sharedCreditCardObj)
                    }else{
                        self.markerPoppuBG.isHidden = true
                        self.markerPoppuBG.tag = 0
                        Global().delay(delay: 0.2) {
                            let QrCodeVController = QRCodeScaneVC(nibName: "QRCodeScaneVC", bundle: nil)
                            QrCodeVController.sharedCreditCardObj = self.sharedCreditCardObj
                            QrCodeVController.isReferralApply = self.referralSelected
                            QrCodeVController.selectedObjectId = self.selectedObjectId
                            self.navigationController?.pushViewController(QrCodeVController, animated: true)
                        }
                    }
                }
            }else{
                StaticClass.sharedInstance.ShowNotification(false, strmsg: "Please select payment option", vc: self)
            }
        }else if sender == self.onLinkaViewNext_btn{
            self.markerPoppuBG.isHidden = true
            self.loadPriceContainerView(self.startBookingSwift ?? UIViewController())
        }
        
    }
    
    @IBAction func btnCheckBoxPressed(_ sender: UIButton) {
        
        if sender.tag == 0{
            sender.tag = 1
            UserDefaults.standard.set(true, forKey: "dont_show_on_linka_view")
            self.checkBox_btn.setImage(UIImage(named: "checked_blue"), for: .normal)
        }else{
            sender.tag = 0
            UserDefaults.standard.set(false, forKey: "dont_show_on_linka_view")
            self.checkBox_btn.setImage(UIImage(named: "unchecked_gray"), for: .normal)
        }
        
    }
    
    @IBAction func btnCurrentLocationPressed(_ sender: UIButton) {
        
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(StaticClass.sharedInstance.latitude), longitude: CLLocationDegrees(StaticClass.sharedInstance.longitude), zoom: 17.0)
        self.mapView?.animate(to: camera)
    }
    
    @IBAction func btnInfoPressed(_ sender: UIButton) {
        let vc = ReportVC(nibName: "ReportVC", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnHelpPressed(_ sender: UIButton) {
        let helpTipsVc = HelpTipsViewController(nibName: "HelpTipsViewController", bundle: nil)
        helpTipsVc.bookNowVc = self
        helpTipsVc.modalPresentationStyle = .overFullScreen
        self.present(helpTipsVc, animated: true, completion: nil)
    }
    
    @IBAction func btnGiftPressed(_ sender: UIButton) {
        Singleton.smRippleView?.removeFromSuperview()
        self.loadShareRefferView()
    }
    
    @IBAction func btnQRCodeScannerPressed(_ sender: UIButton) {
        print("Scan btn pressed")
        if self.checkAccountValidForRental(){
            self.selectedObjectId = ""
            self.directBooking = false
            self.scanQrBtnPressed()
            self.startBtnContainerView.animateView()
        }
    }
    
    @IBAction func btnFindNearestPressed(_ sender: UIButton) {
        shareParameters.doubleLat = Double(self.currentLat)
        shareParameters.doubleLong = Double(self.currentLong)
        shareParameters.strIsNearest = "1"
        shareParameters.strKeyword = ""
        self.isSkipCall = true
        self.searchHome_Web(lat: String(describing: shareParameters.doubleLat), long: String(describing: shareParameters.doubleLong))
    }
    
    @IBAction func btnBgTapped(_ sender : UIButton) {
        
        self.markerPoppuBG.isHidden = true
        if self.markerPoppuBG.tag == 0{
            self.btnStartQRScan.tag = 0
        }else if self.markerPoppuBG.tag == 1{
            self.selectPaymentOptView_bottom.constant = -(self.selectPaymentOptView.frame.height + AppDelegate().getBottomSafeAreaHeight())
        }else if self.markerPoppuBG.tag == 2{
            self.onLinkaLock_bottom.constant -= (self.onLinkaLockView.frame.height + AppDelegate().getBottomSafeAreaHeight())
        }
        self.popUpAd.isHidden = true
        self.markerPoppuBG.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.markerPoppuBG.alpha = 0
            self.view.layoutIfNeeded()
        }) { (anim) in
        }
    }
    
    @IBAction func btnCancelClick(_ sender: UIButton) {
        self.setRentalViewToInitial()
        self.rentalContainerView.isHidden = false
        finishRentalsView.isHidden = true
    }
 }
 
 //MARK: - Custom Function's
 extension BookNowVC{
    
    func loadUI(){
        
        AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "logo_img") { (image) in
            self.headerKoloniLogo_img.image = image
        }
        
        if AppLocalStorage.sharedInstance.application_gradient{
            self.rentalBgImageView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.navigationBgImage.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.qrBtnView.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.next_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
            self.onLinkaViewNext_btn.createGradientLayer(color1: CustomColor.primaryColor, color2: CustomColor.secondaryColor, startPosition: 0.0, endPosition: 0.9)
        }else{
            self.rentalBgImageView.backgroundColor = CustomColor.primaryColor
            self.navigationBgImage.backgroundColor = CustomColor.primaryColor
            self.qrBtnView.backgroundColor = AppLocalStorage.sharedInstance.button_color
            self.next_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
            self.onLinkaViewNext_btn.backgroundColor = AppLocalStorage.sharedInstance.button_color
        }
        self.referralCount_lbl.backgroundColor = CustomColor.primaryColor
        self.choose_btn.setTitleColor(CustomColor.secondaryColor, for: .normal)
        self.underLine1_lbl.backgroundColor = CustomColor.secondaryColor        
        self.view.layoutIfNeeded()
    }
    
    func loadContent(){
        self.appGroupDefaults = UserDefaults(suiteName:"group.com.koloni.kolonikube")!
        Singleton.smRippleView = nil        
        self.centerLatLong_current = CLLocationCoordinate2D(latitude: CLLocationDegrees(StaticClass.sharedInstance.latitude), longitude: CLLocationDegrees(StaticClass.sharedInstance.longitude))
        self.shareParameters.strUser_id = StaticClass.sharedInstance.strUserId
        self.shareParameters.doubleLat = Double(StaticClass.sharedInstance.latitude)
        self.shareParameters.doubleLong = Double(StaticClass.sharedInstance.longitude)
        trackUserInFirebase(userId: shareParameters.strUser_id)
        self.shareParameters.strIsNearest = "0"
        self.shareParameters.intMaxVal = 0
        self.shareParameters.intMinVal = 0
        
        self.next_btn.circleObject()
        self.onLinkaViewNext_btn.circleObject()
        self.btnGift.isHidden = false
        self.referralCount_lbl.isHidden = false
        self.markerPoppuBG.isHidden = true
        self.selectPaymentOptView_bottom.constant = -(self.selectPaymentOptView.frame.height + AppDelegate().getBottomSafeAreaHeight())
        self.onLinkaLock_bottom.constant -= (self.onLinkaLockView.frame.height + AppDelegate().getBottomSafeAreaHeight())
        self.referralCount_lbl.circleObject()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpDown(_:)))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpDown(_:)))
        swipeDown.direction = .down
        swipeUp.direction = .up
        self.rentalContainerView.addGestureRecognizer(swipeDown)
        self.rentalContainerView.addGestureRecognizer(swipeUp)
        self.btnSlideToFinish.delegate = self
        self.btnSlideToFinish.resetSlideButton()
        self.btnSlideToFinish.isUserInteractionEnabled = true
        self.lblSlideAnimation.isHidden = true
        
        
    }
    
    func setAdsImageScrollFunctionality(){
        self.adImageScrollView.delegate = self
        self.adImageScrollView.minimumZoomScale = 1.0
        self.adImageScrollView.maximumZoomScale = 5.0
        self.adImageScrollView.alwaysBounceVertical = false
        self.adImageScrollView.alwaysBounceHorizontal = false
        self.adImageScrollView.showsVerticalScrollIndicator = true
        self.adImageScrollView.flashScrollIndicators()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnImage(_:)))
        tap.numberOfTapsRequired = 2
        self.adImageScrollView.addGestureRecognizer(tap)
    }
    
    @objc func tapOnImage(_ sender: UITapGestureRecognizer){
        
        if self.adImageScrollView.zoomScale > self.adImageScrollView.minimumZoomScale{
            self.adImageScrollView.setZoomScale(self.adImageScrollView.minimumZoomScale, animated: true)
        }else{
            self.adImageScrollView.setZoomScale(4.0, animated: true)
        }
        
    }
    
    func addObserver(){
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "reloadVc"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadVc), name: Notification.Name(rawValue: "reloadVc"), object: nil)
        
    }
    
    @objc func reloadVc(){
        
        DispatchQueue.main.async {
            Global().delay(delay: 0.1) {
                self.isViewDidCall = false
                self.searchHome_Web(lat: String(describing: self.centerLatLong_current.latitude), long: String(describing: self.centerLatLong_current.longitude))
            }
        }
        
    }
    
    func loadRippleView(){
        
        if self.totalRidesTaken == 0{
            if !UserDefaults.standard.bool(forKey: "isRippleEffectClosed"){
                if !Global.appdel.is_rentalRunning{
                    let fillColor: UIColor? = CustomColor.primaryColor
                    Singleton.smRippleView = SMRippleView(frame: self.rippleView.bounds, rippleColor: UIColor.black, rippleThickness: 0.2, rippleTimer: 2, fillColor: fillColor, animationDuration: 3, parentFrame: CGRect(x: 0, y: 0, width: 100, height: 100))
                    self.rippleView.addSubview(Singleton.smRippleView)
                }
            }
        }
        self.view.layoutIfNeeded()
    }
    
//    func showReferralPopup(){
//
//        if !StaticClass.sharedInstance.retriveFromUserDefaultsBool(key: Global.g_UserData.is_referral_shown) {
//            Global().delay(delay: 0.5, closure: {
//                let referral = Bundle.main.loadNibNamed("Refferal_popup", owner: nil, options: [:])?.first as? Refferal_popup
//                referral!.DisplayPopup()
//            })
//        }
//
//    }
    
    //Google Map Setup
    func setupGoogleMap() {
        
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(self.centerLatLong_current.latitude), longitude: CLLocationDegrees(self.centerLatLong_current.longitude), zoom: 15.0)
        UIView.animate(withDuration: 2) {
            self.mapView.animate(to: camera)
            self.view.layoutIfNeeded()
        }
        
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [10], backgroundImages: [#imageLiteral(resourceName: "cluster")])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: self.mapView,
                                                 clusterIconGenerator: iconGenerator)
        self.clusterManager = GMUClusterManager(map: self.mapView, algorithm: algorithm,
                                                renderer: renderer)
        self.clusterManager.setDelegate(self, mapDelegate: self)
        
        self.mapView?.isMyLocationEnabled = true
        self.mapView?.settings.myLocationButton = false
        
        let mainBundle = Bundle.main
        let styleUrl: URL? = mainBundle.url(forResource: "googleOverlay", withExtension: "json")
        
        let style = try? GMSMapStyle(contentsOfFileURL: styleUrl!)
        if style == nil {
        }
        self.mapView?.mapStyle = style
        self.mapView?.delegate = self;
        self.isSkipCall = true
        
        DispatchQueue.main.async {
            Global().delay(delay: 0.1) {
                self.searchHome_Web(lat: String(describing: self.centerLatLong_current.latitude), long: String(describing: self.centerLatLong_current.longitude))
            }
        }
        
    }
    
    func registerCollectionCell(){
        self.pauseRentalCollectionView.register(UINib(nibName: "PauseRentalCollectionCell", bundle: nil), forCellWithReuseIdentifier: "PauseRentalCollectionCell")
        self.lockGuidCollection.register(UINib(nibName: "GuideCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GuideCollectionCell")
        self.cardListTableView.register(UINib(nibName: "CardsListCell", bundle: nil), forCellReuseIdentifier: "CardsListCell")
    }
    
    func setCollectionLayout(){
        self.layout.itemSize = CGSize(width: self.pauseRentalCollectionView.frame.width - 40, height: 265)
        self.layout.scrollDirection = .horizontal
        self.layout.spacingMode = .fixed(spacing: 10)
        self.layout.sideItemScale = 0.8
        self.pauseRentalCollectionView.collectionViewLayout = self.layout
        
        self.lockCollectionlayout.itemSize = CGSize(width: self.lockGuidCollection.frame.width - 40, height: self.lockGuidCollection.frame.height)
        self.lockCollectionlayout.scrollDirection = .horizontal
        self.lockCollectionlayout.spacingMode = .fixed(spacing: 5)
        self.lockCollectionlayout.sideItemScale = 0.8
        self.lockGuidCollection.collectionViewLayout = self.lockCollectionlayout
    }
    
    @objc func swipeUpDown(_ sender: UISwipeGestureRecognizer){
        
        if sender.direction == .down{
            if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex){
                UIView.animate(withDuration: 0.3, animations: {
                    if self.isTableHide{
                        self.pauseRentalCollection_bottom.constant = -(230 + cell.outOfDtextLabel_height.constant)
                    }else{
                        self.pauseRentalCollection_bottom.constant = -((280 + cell.outOfDtextLabel_height.constant) + CGFloat(((Singleton.numberOfCards.count - 1)) * 40))
                    }
                    self.view.layoutIfNeeded()
                })
            }
            self.isRentalViewDown = true
        }else if sender.direction == .up{
            UIView.animate(withDuration: 0.3, animations: {
                self.pauseRentalCollection_bottom.constant = -15
                self.view.layoutIfNeeded()
            })
            self.isRentalViewDown = false
        }
        
    }
    
    func downRunningRentalView(){
        
        if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex){
            UIView.animate(withDuration: 0.3, animations: {
                if self.isTableHide{
                    self.pauseRentalCollection_bottom.constant = -(230 + cell.outOfDtextLabel_height.constant)
                }else{
                    self.pauseRentalCollection_bottom.constant = -((280 + cell.outOfDtextLabel_height.constant) + CGFloat(((Singleton.numberOfCards.count - 1)) * 40))
                }
                self.view.layoutIfNeeded()
            })
        }
        self.isRentalViewDown = true
    }
    
    func hideRentalCollection(){
        self.pauseRentalCollectionView.reloadData()
        StaticClass.sharedInstance.saveToUserDefaults(false as AnyObject , forKey: Global.g_UserDefaultKey.Is_StartBooking)
        self.pauseRentalCollection_bottom.constant = -450
        Singleton.track_location_timer.invalidate()
        Singleton.endTime = ""
        self.addRentalContainerView.isHidden = true
        self.nearestDropZone_btn.isHidden = true
        self.rentalContainerView.isHidden = true
        self.startBtnContainerView.isHidden = false
        self.btnCurrentLocation.isHidden = false
        self.btnInfo.isHidden = false
        self.help_btn.isHidden = false
    }
    
    func showLoader(withMsg msg: String){
        if !self.isAxaLoaderLoad{
            self.bikeLock_imageView.isHidden = true
            self.axaLoaderMsg_lbl.isHidden = true
            self.axaLoader.showSpiner(message: msg, labelColor: .white)
            self.axaLoader.frame = (appDelegate.window?.bounds)!
            self.axaLoaderBackGroundView.frame = (appDelegate.window?.bounds)!
            self.view.addSubview(axaLoaderBackGroundView)
            self.view.addSubview(axaLoader)
            self.isAxaLoaderLoad = true
        }
    }
    
    func showAxaLockLoaderPopUp(msg: String){
        self.bikeLock_imageView.isHidden = false
        self.axaLoaderMsg_lbl.isHidden = false
        self.axaLoaderMsg_lbl.text = msg
        self.axaLoaderBackGroundView.frame = (appDelegate.window?.bounds)!
        self.view.addSubview(axaLoaderBackGroundView)
    }
    
    func hideLockLoader(){
        self.isAxaLoaderLoad = false
        self.axaLoader.hideSpinner()
        self.axaLoaderBackGroundView.removeFromSuperview()
        self.axaLoader.removeFromSuperview()
    }
    
    func setRentalViewToInitial(){
        UIView.animate(withDuration: 0.2, animations: {
            self.downRunningRentalView()
            self.isRentalViewDown = true
            self.isTableHide = true
            self.rentalContainerView.isHidden = false
//            self.nearestDropZone_btn.isHidden = true
            self.addRentalContainerView.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    func scanQrBtnPressed(){
        if Singleton.runningRentalArray.count > 0{
            self.setRentalViewToInitial()
        }
        if self.btnStartQRScan.tag == 1{
            self.alertBox("Koloni", "This is a private Koloni and hence you cannot access it.") {
                
            }
        }else{
            if self.arrCardList.count > 0{
                if self.btnStartQRScan.tag == 1{
                    self.btnStartQRScan.tag = 0
                }
                self.selectPaymentOptView.isHidden = false
                self.selectPaymentOptView_bottom.constant = -15
                self.markerPoppuBG.isHidden = false
                self.markerPoppuBG.tag = 1
                UIView.animate(withDuration: 0.3, animations: {
                    self.markerPoppuBG.alpha = 1.0
                    self.view.layoutIfNeeded()
                }) { (_) in
                    
                }
            }else{
                if self.btnStartQRScan.tag == 1{
                    self.btnStartQRScan.tag = 0
                    self.selectPaymentOptView.isHidden = false
                    self.markerPoppuBG.isHidden = false
                    self.markerPoppuBG.tag = 1
                    UIView.animate(withDuration: 0.3, animations: {
                        self.markerPoppuBG.alpha = 1.0
                        self.view.layoutIfNeeded()
                    }) { (_) in
                        
                    }
                }
                
                let bookingPayment = BookingPaymentVC(nibName: "BookingPaymentVC", bundle: nil)
                let strCustID = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID)as? String ?? ""
                bookingPayment.strCustomerID = strCustID
                bookingPayment.referralSelected = self.referralSelected
                bookingPayment.numberOfReferral = self.numberOfReferralRentals
                bookingPayment.selectedObjectId = self.selectedObjectId
                self.navigationController?.pushViewController(bookingPayment, completion: {
                })
            }
        }
    }
    
    func showRunningRentalItems(){
        self.rentalContainerView.isHidden = false
        self.startBtnContainerView.isHidden = true
        self.btnInfo.isHidden = true
        self.help_btn.isHidden = true
        self.btnCurrentLocation.isHidden = true
    }
    
    func hideRunningRentalItems(){
        Singleton.runningRentalArray = []
        self.rentalContainerView.isHidden = true
        self.startBtnContainerView.isHidden = false
        self.btnCurrentLocation.isHidden = false
        self.btnInfo.isHidden = false
        self.help_btn.isHidden = false
    }
    
    func showSlideDownRental(){
        self.btnSlideToFinish.resetSlideButton()
        self.slideDownRentalView()
        self.nearestDropZone_btn.isHidden = true
        self.addRentalContainerView.isHidden = true
    }
    
    func deviceLockedSuccessfully(){
        if !self.btnPressedPause{
            self.btnPressedPause = !self.btnPressedPause
        }
        self.isEventStatus = "3"
        self.changeStateOfPauseButton(isLocked: true)
        if self.rentalActionPerformed == 1{
            if Singleton.runningRentalArray.count > 0{
                if Singleton.runningRentalArray[self.selectedRentalIndex]["object_location_type"]as? String ?? "" == "1"{
                    self.nearestDropZone_Web()
                }else{
                    self.calculationPrice_Web(isNreaBY: true)
                }
            }
            UserDefaults.standard.setValue(0, forKey: "isRentalPause")
        }else if self.isPause{
            self.isPause = false
        }
        self.lockUnlock_Web(strEvent: "0")
    }
    
    func deviceUnlockedSuccessfully(){
        self.btnPressedPause = !self.btnPressedPause
        self.isEventStatus = "4"
        self.changeStateOfPauseButton(isLocked: false)
        if !isPause{
            isPause = true
        }else{
            
        }
        self.lockUnlock_Web(strEvent: "1")
    }
    
    func showReportAnIssue(){
        let vc = ReportVC(nibName: "ReportVC", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func changeStateOfPauseButton(isLocked: Bool){
        
        if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex) {
            if self.pauseRentalCollectionView.indexPath(for: cell) != nil{
                if isLocked{
                    if Singleton.runningRentalArray[self.selectedRentalIndex]["object_type"] as? String ?? "" == "2"{
                        cell.pause_resume_lbl.text = AppLocalStorage.sharedInstance.resume_button_text//"Unlock"
                    }else{
                        cell.pause_resume_lbl.text = AppLocalStorage.sharedInstance.resume_button_text//"Open"
                    }
                    AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "pause_img") { (image) in
                        cell.pauseOrStartBtn_img.image = image
                    }
                    cell.pause_btn.backgroundColor = AppLocalStorage.sharedInstance.resume_button_color
                    cell.pause_btn.isSelected = true
                }else{
                    if Singleton.runningRentalArray[self.selectedRentalIndex]["object_type"] as? String ?? "" == "2"{
                        cell.pause_resume_lbl.text = AppLocalStorage.sharedInstance.pause_button_text//"Lock"
                    }else{
                        cell.pause_resume_lbl.text = AppLocalStorage.sharedInstance.pause_button_text//"Close"
                    }
                    AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "resume_img") { (image) in
                        cell.pauseOrStartBtn_img.image = image
                    }
                    cell.pause_btn.backgroundColor = AppLocalStorage.sharedInstance.pause_button_color
                    cell.pause_btn.isSelected = false
                }
            }
        }
        if Singleton.runningRentalArray[self.selectedRentalIndex]["object_type"] as? String ?? "" == "2"{
            self.nearestDropZone_btn.isHidden = false
        }else{
            self.nearestDropZone_btn.isHidden = true
        }
    }
    
    func pickLockImageToFinishRide(cameraType: String){
        
        let rentalImageVC = RentalImageViewController(nibName: "RentalImageViewController", bundle: nil)
        rentalImageVC.bookNowVC = self
        rentalImageVC.lastVc = self
        rentalImageVC.cameraType = cameraType
        self.imagePickerVcPresent = true
        self.present(rentalImageVC, animated: true, completion: nil)
        
    }
    
    func photoErrorOnUpload(){
        let alert = UIAlertController.init(title: "Image upload error", message: "Do you want to retry?", preferredStyle: .alert)
        
        let ok = UIAlertAction.init(title: "Retry", style: .default) { (result) in
            self.uploadImgForFinishRide()
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: {(alert) in
            
        })
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addDataToUserDefaultForWidget(){
        var dict : [String:String] = [:]
        dict["user_id"] = StaticClass.sharedInstance.strUserId
        dict["ios_version"] = "\(appDelegate.getCurrentAppVersion)"
        dict["object_id"] = StaticClass.sharedInstance.strObjectId
        dict["booking_id"] = StaticClass.sharedInstance.strBookingId
        self.appGroupDefaults.setValue(dict, forKey: "ride")
    }
    
    func setUPSlider(dict:NSDictionary){
        if let currentRental = dict["CURRENT_RENTAL"] as? [[String:Any]],currentRental.count > 0 {
            for currentRetalObj in currentRental {
                if self.shareDeviceObj.arrBikes.count > 0 {
                    
                } else {
                    self.bikeSharedData.strId = currentRetalObj["object_id"] as? String ?? ""
                    self.bikeSharedData.is_outof_dropzone = Int(String(describing: currentRetalObj["is_outof_dropzone"]!)) ?? -1
                    self.bikeSharedData.outOfDropzoneMsg = currentRetalObj["outof_dropzone_message"]as? String ?? ""
                    self.bikeSharedData.strName = currentRetalObj["name"] as? String ?? ""
                    self.bikeSharedData.strAddress = currentRetalObj["address"] as? String ?? ""
                    self.bikeSharedData.doublePrice = StaticClass.sharedInstance.getDouble(value: currentRetalObj["object_price"] as? String ?? "" )
                    StaticClass.sharedInstance.saveToUserDefaultsString(value:self.bikeSharedData.strId, forKey: Global.g_UserData.ObjectID)
                    self.bikeSharedData.intType = Int(StaticClass.sharedInstance.getDouble(value: currentRetalObj["object_type"] as? String ?? "0"))
                    self.bikeSharedDataArray.append(bikeSharedData)
                }
                
                if let strObjectType = currentRetalObj["object_type"] as? String  {
                    if strObjectType == "2" {
                        
                    } else  {
                        self.btnGift.isHidden = false
                        self.referralCount_lbl.isHidden = false
                    }
                }
                if let intObjectType = currentRetalObj["object_type"] as? Int {
                    if intObjectType == 2 {
                        
                    } else {
                        self.btnGift.isHidden = false
                        self.referralCount_lbl.isHidden = false
                    }
                }
                
                Global.appdel.strIsUserType = currentRetalObj["user_type"] as? String ?? "0"
                self.addDataToUserDefaultForWidget()
                if UserDefaults.standard.value(forKey: "isRentalPause") != nil{
                    let pause = UserDefaults.standard.value(forKey: "isRentalPause")
                    if "\(pause!)" == "1"{
                        self.isPause = false
                    }else{
                        self.isPause = true
                    }
                }
            }
            if currentRental.count > 0{
                self.strLocationID = currentRental[0]["location_id"] as? String ?? ""
                self.strBikeKubeID = currentRental[0]["object_id"] as? String ?? ""
                
            }
        }
    }
    
    //Draw Geo Fence, Set Bikes on map, Set Marker on Geofence's
    func drawGeoFence(){
        var count = 0
        
        if self.selectedLocId != ""{
            
            if let data = self.arrDeviceData.object(at: self.selectedIndex)as? ShareDevice{
                let path = GMSMutablePath()
                for data1 in data.arrGeofence as! [ShareGeofence]{
                    path.add(CLLocationCoordinate2D(latitude: data1.latitude, longitude: data1.longitude))
                }
                let polyline = GMSPolygon(path: path)
                if data.isAffiliateLocation == 1{
                    polyline.strokeColor = AppLocalStorage.sharedInstance.geofence_affiliate_color
                    polyline.fillColor = AppLocalStorage.sharedInstance.geofence_affiliate_color.withAlphaComponent(0.3)
                }else{
                    polyline.strokeColor = AppLocalStorage.sharedInstance.geofence_color
                    polyline.fillColor = AppLocalStorage.sharedInstance.geofence_color.withAlphaComponent(0.3)
                }
                polyline.strokeWidth = 3.0
                polyline.map = self.mapView
            }
        }else{
            
            for data in arrDeviceData as! [ShareDevice] {
                let path = GMSMutablePath()
                
                for data1 in data.arrGeofence as! [ShareGeofence]{
                    path.add(CLLocationCoordinate2D(latitude: data1.latitude, longitude: data1.longitude))
                }
                let polyline = GMSPolygon(path: path)
                
                if data.isAffiliateLocation == 1{
                    polyline.strokeColor = AppLocalStorage.sharedInstance.geofence_affiliate_color
                    polyline.fillColor = AppLocalStorage.sharedInstance.geofence_affiliate_color.withAlphaComponent(0.3)
                }else{
                    polyline.strokeColor = AppLocalStorage.sharedInstance.geofence_color
                    polyline.fillColor = AppLocalStorage.sharedInstance.geofence_color.withAlphaComponent(0.3)
                }
                polyline.isTappable = true
                polyline.zIndex = Int32(count)
                polyline.strokeWidth = 3.0
                polyline.map = self.mapView
                count += 1
            }
        }
    }
    
    //Setting bike pin with cluster
    func setBikesOnMap() -> Void {
        self.mapView?.clear()
        self.clusterManager.clearItems()
        var duplicateArray: [[String:Any]] = []
        var index = 0
        if selectedLocId != ""{
            
            for data in self.arrayOfBike {
                
                if let data1 = data as? AvailabelBike{
                    if data1.strLocationId == self.selectedLocId{
                        var dictionary: [String:Double] = [:]
                        let filterArray = duplicateArray.filter({$0["latitude"]as! Double == data1.strLatitude && $0["longitude"]as! Double == data1.strLongitude})
                        if filterArray.count == 0{
                            dictionary["latitude"] = data1.strLatitude
                            dictionary["longitude"] = data1.strLongitude
                            duplicateArray.append(dictionary)
                            let item = POIItem(position: CLLocationCoordinate2DMake(Double(data1.strLatitude), Double(data1.strLongitude)), name: data1.asset_img_url, id: index, index: "\(index)", hexCode: data1.assets_color_code)
                            self.clusterManager.add(item)
                        }else{
                            //                            print("Same lat long found")
                        }
                    }
                    index = index + 1
                }
            }
        }else{
            
            for data in self.arrayOfBike {
                
                if let data1 = data as? AvailabelBike{
                    var dictionary: [String:Double] = [:]
                    let filterArray = duplicateArray.filter({$0["latitude"]as! Double == data1.strLatitude && $0["longitude"]as! Double == data1.strLongitude})
                    if filterArray.count == 0{
                        dictionary["latitude"] = data1.strLatitude
                        dictionary["longitude"] = data1.strLongitude
                        duplicateArray.append(dictionary)
                        let item = POIItem(position: CLLocationCoordinate2DMake(Double(data1.strLatitude), Double(data1.strLongitude)), name: data1.asset_img_url, id: index, index: "\(index)", hexCode: data1.assets_color_code)
                        self.clusterManager.add(item)
                    }else{
                        //                        print("Same lat long found")
                    }
                }
                index = index + 1
            }
        }
        
        if self.isSkipCall  { // when true move to first result.
            if arrDeviceData.count > 0 {
                let data = arrDeviceData [0] as! ShareDevice
                let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(data.strLat), longitude: CLLocationDegrees(data.strLong), zoom: 17.0)
                UIView.animate(withDuration: 2) {
                    self.mapView.animate(to: camera)
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        self.setAd()
        self.drawGeoFence()
        self.clusterManager.cluster()
        self.clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    
    //Set marker on geofence
    func setMarkerOnGeofence(){
        self.mapView?.clear()
        self.clusterManager.clearItems()
        var index = 0
        for data in self.arrDeviceData{
            if let device = data as? ShareDevice{
                let marker = GMSMarker()
                let latitude = device.strLat
                let longitude = device.strLong
                
                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "map_flag_img") { (image) in
                    let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 50))
                    iconView.backgroundColor = .clear
                    let imageView = UIImageView(frame: CGRect(x: 3, y: 3, width: 38, height: 38))
                    let layer = CAShapeLayer()
                    layer.path = UIBezierPath(roundedRect: CGRect(x: iconView
                                                                    .center.x - 3, y: iconView.center.y, width: 6, height: 20), cornerRadius: 20).cgPath
                    layer.fillColor = CustomColor.primaryColor.cgColor
                    iconView.layer.addSublayer(layer)
                    imageView.image = image
                    imageView.circleObject()
                    iconView.addSubview(imageView)
                    iconView.cornerRadius(cornerValue: 25)
                    iconView.shadow(color: .gray, radius: 1.0, opacity: 0.5)
                    marker.iconView = iconView
                }
                marker.isTappable = true
                marker.userData = "geofence"
                marker.zIndex = Int32(index)
                marker.map = self.mapView
                index += 1
            }
        }
    }
    
    func setAd() {
        var index = 0
        for data in arrAdData as! [ShareAd] {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(Double(data.latitude)
                                                         , Double(data.longitude))
            marker.isTappable = true
            marker.icon = UIImage(named: "offer_marker_pin")
            marker.userData = "ad"
            marker.zIndex = Int32(index)
            marker.map = self.mapView
            index = index + 1
        }
    }
    
    //Permission to pause rental
    func permissionAlertToPause(){
        if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
            
            if self.btnPressedPause{
                self.showLoader(withMsg: "Unlocking. Please wait...")
            }else{
                self.showLoader(withMsg: "Locking. Please wait...")
            }
            let device_name = Singleton.runningRentalArray[self.selectedRentalIndex]["assets_device_name"]as? String ?? ""
            if self.axaLockConnection?.peripheralDevice != nil && self.axaLockConnection?.connectedWithDevice == device_name{
                self.axaLockConnection?.connectToPeripheral(identifire: (self.axaLockConnection?.peripheralDevice)!)
            }else{
                self.axaLockConnection?.centralMannager?.scanForPeripherals(withServices: nil, options: nil)
                _ = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (_) in
                    self.axaLockConnection?.centralMannager?.stopScan()
                    if self.axaLockConnection?.peripheralDevice == nil{
                        AppDelegate.shared.window?.showBottomAlert(message: "Please make sure asset is near by you and not connected with other device.")
                        self.hideLockLoader()
                    }
                })
            }
        }else{
            CoreBluetoothClass.sharedInstance.isBluetoothOn(vc: self)
        }
    }
    
    //Permission alert to end rental
    func permissionAlertToEnd() {
        
        if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
            
            self.showLoader(withMsg: "Locking. Please wait...")
            let device_name = Singleton.runningRentalArray[self.selectedRentalIndex]["assets_device_name"]as? String ?? ""
            if self.axaLockConnection?.peripheralDevice != nil && self.axaLockConnection?.connectedWithDevice == device_name{
                self.axaLockConnection?.connectToPeripheral(identifire: (self.axaLockConnection?.peripheralDevice)!)
            }else{
                self.axaLockConnection?.centralMannager?.scanForPeripherals(withServices: nil, options: nil)
                _ = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (_) in
                    self.axaLockConnection?.centralMannager?.stopScan()
                    if self.axaLockConnection?.peripheralDevice == nil{
                        AppDelegate.shared.window?.showBottomAlert(message: "Please make sure asset is near by you and not connected with other device.")
                        self.hideLockLoader()
                    }
                })
            }
        }else{
            
            if Singleton.runningRentalArray[self.selectedRentalIndex]["object_type"] as? String ?? "" == "2"{
                self.pauseRentalCollection_bottom.constant = -370
                self.rentalContainerView.isHidden = true
                CoreBluetoothClass.sharedInstance.isBluetoothOn(vc: self)
            }else{
                self.loadLockerInstructionView()
            }
        }
    }
    
    /** Function to slide down the rental view while ending the ride */
    func slideDownRentalView(){
        
        Global().delay(delay: 0.2) {
            self.btnSlideToFinish.delegate = self
            self.finishRentalsView.isHidden = false
            UIView.animate(withDuration: 0.1, animations: {
                
            })
        }
        
    }
    
    //Lock Unlock
    func paseLockUnlock(){
        if !self.btnPressedPause{
            self.isPause = true
            self.lockCommand = "0"
            
            if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
                self.axaLockConnection?.lockDevice()
            }else{
                if self.btnPressedPause{
                    self.showLoader(withMsg: "Unlocking. Please wait...")
                }else{
                    self.showLoader(withMsg: "Locking. Please wait...")
                }
                _ = self.lockConnectionService.doLock(macAddress: self.selectedBikeMacAddress, delegate: self)
            }
        }else{
            self.isPause = false
            self.lockCommand = "1"
            
            if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
                self.axaLockConnection?.unlockDevice()
            }else{
                if self.btnPressedPause{
                    self.showLoader(withMsg: "Unlocking. Please wait...")
                }else{
                    self.showLoader(withMsg: "Locking. Please wait...")
                }
                _ = self.lockConnectionService.doUnLock(macAddress: self.selectedBikeMacAddress, delegate: self)
            }
        }
    }
    
    func btnLockAction() {
        self.finishBooking_Web(strLocation_ID: self.strLocationID)
    }
    
 }
 
 //MARK: - UIScrollView Delegate's
 extension BookNowVC: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgBigAd
    }
 }
 
 //MARK: - Check Bluetooth Delegate's
 extension BookNowVC: CheckBluetoothStatusDelegate{
    func response(status: Bool) {
        if status{
            if self.rentalActionPerformed == 1{
                self.showSlideDownRental()
            }else{
                self.paseLockUnlock()
            }
        }else{
            let alert = UIAlertController(title: "Alert", message: "Please turn on bluetooth to perform pause, resume or end rental.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
 }
 
 //MARK: - Web Api's
 extension BookNowVC{
    
    func searchHome_Web(lat: String, long: String) -> Void {
        
        let params: NSMutableDictionary = NSMutableDictionary()
        
        params.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        params.setValue(shareParameters.strIsNearest, forKey: "is_nearest")
        params.setValue(shareParameters.strDistance_Unit, forKey: "distance_unit")
        params.setValue(String(describing: lat), forKey: "latitude")
        params.setValue(String(describing: long), forKey: "longitude")
        params.setValue(String(describing: shareParameters.intMinVal), forKey: "min_price")
        params.setValue(String(describing: shareParameters.intMaxVal), forKey: "max_price")
        params.setValue(String(describing: shareParameters.intRating), forKey: "ratings")
        params.setValue(shareParameters.strSelectedCategory, forKey: "amenities")
        params.setValue(shareParameters.strtype, forKey: "type")
        params.setValue(shareParameters.strKeyword, forKey: "keyword")
        params.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        params.setValue(StaticClass.sharedInstance.strBookingId, forKey: "payment_id")
        
        var showLoader:Bool = true
        if !self.isViewDidCall{
            showLoader = false
        }
        self.startBtnContainerView.alpha = 0.5
        self.btnStartQRScan.isUserInteractionEnabled = false
        self.pauseRentalCollectionView.alpha = 0.5
        self.pauseRentalCollectionView.isUserInteractionEnabled = false
        self.requestingApi = true
        self.loaderBgView.isHidden = false
        APICall.shared.postWeb("search_home", parameters: params, showLoder: showLoader, successBlock: { (response) in
            self.loaderBgView.isHidden = true
            if !self.is_uploadingImg {
                self.hideLockLoader()
            }
            self.startBtnContainerView.alpha = 1.0
            self.btnStartQRScan.isUserInteractionEnabled = true
            if let dict = response as? NSDictionary {
                
                if let referralCount = dict.value(forKey: "referral_count")as? String, Int(referralCount)! > 0{
                    Singleton.numberOfReferralRides = "\(referralCount)"
                    self.referralCount_lbl.isHidden = false
                    self.referralCount_lbl.text = referralCount
                    self.referralCount_lbl.circleObject()
                }else{
                    Singleton.numberOfReferralRides = "0"
                    self.referralCount_lbl.isHidden = true
                }
                
                if (dict["BOOKING_RUNNING"] as? String ?? "100") == "1" {
                    Global.appdel.is_rentalRunning = true
                    self.addRentalContainerView.isHidden = false
                    self.btnStartQRScan.isHidden = true
                    self.view.layoutIfNeeded()
                }else{
                    Global.appdel.is_rentalRunning = false
                    self.addRentalContainerView.isHidden = true
                    self.btnStartQRScan.isHidden = false
                    self.view.layoutIfNeeded()
                }
                
                if let ridesTaken = dict.value(forKey: "total_rides")as? String{
                    self.totalRidesTaken = Int(ridesTaken)!
                }else if let ridesTaken = dict.value(forKey: "total_rides")as? Int{
                    self.totalRidesTaken = ridesTaken
                }else{
                    self.totalRidesTaken = 0
                }
                Singleton.totalRidesTaken = self.totalRidesTaken
                if let showReferral = dict.value(forKey: "show_referral_popup")as? String, showReferral == "1"{
                    UserDefaults.standard.set(true, forKey: "isShowEnterRefBtn")
                }else{
                    UserDefaults.standard.set(false, forKey: "isShowEnterRefBtn")
                }
                
                if AppLocalStorage.sharedInstance.refer_friend == "1"{
                    self.btnGift.isHidden = false
                    if Singleton.smRippleView == nil{
                        self.loadRippleView()
                    }
                }else{
                    self.btnGift.isHidden = true
                }
                
                if (dict["FLAG"] as! Bool){
                    if let arrResult = dict["LOACTION_DATA"] as? NSArray, arrResult.count > 0{
                        self.arrDeviceData.removeAllObjects()
                        Singleton.shared.parseDeviceJson(arr: arrResult, arrOut:self.arrDeviceData)
                        DispatchQueue.main.async {
                            var long : Double = 0.0
                            var lat : Double = 0.0
                            
                            if let dict = arrResult[0] as? NSDictionary{
                                if let lati = dict.object(forKey: "latitude") as? String{
                                    if lati == ""{
                                        lat = 0.0
                                    }else{
                                        lat = Double(lati)!
                                    }
                                }
                                if let longi = dict.object(forKey: "longitude") as? String{
                                    if longi == ""{
                                        long = 0.0
                                    }else{
                                        long = Double(longi)!
                                    }
                                }
                                let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Double(lat)), longitude: CLLocationDegrees(Double(long)), zoom: 17.0)
                                if self.shareParameters.strIsNearest == "1" || self.isViewDidCall{
                                    UIView.animate(withDuration: 2) {
                                        self.mapView.animate(to: camera)
                                        self.view.layoutIfNeeded()
                                    }
                                }
                            }
                            
                        }
                    }
                    
                    if let arrResult = dict["advertising_data"] as? NSArray{
                        self.arrAdData.removeAllObjects()
                        Singleton.shared.parseAdJson(arr: arrResult, arrOut:self.arrAdData)
                    }
                    
                    if let arrResult = dict["assets_lists"] as? NSArray {
                        self.arrayOfBike = []
                        Singleton.shared.parseBikeJson(arr: arrResult, arrOut:self.arrayOfBike)
                    }
                    
                    if let currentRental = dict["user_running_rental_detail"] as? NSArray,currentRental.count > 0{
                        if let dictionary = currentRental.object(at: 0)as? [String:Any]{
                            
                            Singleton.runningRentalArray = dictionary["CURRENT_RENTAL"]as? [[String:Any]] ?? []
                            if Singleton.runningRentalArray.count > 0{
                                StaticClass.sharedInstance.saveToUserDefaults(true as AnyObject , forKey: Global.g_UserDefaultKey.Is_StartBooking)
                                Singleton.track_location_timer.invalidate()
                                Singleton.track_location_timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { (_) in
                                    DispatchQueue.main.async(execute: {
                                        Global.appdel.locationUpdatesCall(vc: self)
                                    })
                                })
                                self.numberOfRentalsRunning_lbl.text = "\(self.selectedRentalIndex + 1)/\(Singleton.runningRentalArray.count)"
//                                self.numberOfRentalRunningTop_lbl.text = "\(self.selectedRentalIndex + 1)/\(Singleton.runningRentalArray.count)"
                                if self.selectedRentalIndex < Singleton.runningRentalArray.count{
                                    self.currentRentalAmount_lbl.text = "$\(Singleton.runningRentalArray[self.selectedRentalIndex]["total_price"]as? Double ?? 0.0)"
                                }
                                StaticClass.sharedInstance.saveToUserDefaults(Singleton.runningRentalArray as AnyObject, forKey: "running_rental")
                                Singleton.numberOfCards = Singleton.runningRentalArray[0]["credit_cards_list"]as? [[String:Any]] ?? []
                                if Singleton.runningRentalArray.count > self.selectedRentalIndex{
                                    if Singleton.runningRentalArray[self.selectedRentalIndex]["object_type"] as? String ?? "" == "2"{
                                        self.nearestDropZone_btn.isHidden = false
                                    }else{
                                        self.nearestDropZone_btn.isHidden = true
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.pauseRentalCollection_bottom.constant = -15
                                    self.view.layoutIfNeeded()
                                }
                                self.loadingCollectionFirstTime = true
                                self.pauseRentalCollectionView.isHidden = false
                                self.pauseRentalCollectionView.reloadData()
                            }else{
                                self.pauseRentalCollectionView.isHidden = true
                                self.hideRentalCollection()
                            }
                            if Singleton.timerArray.count > 0 {
                                for t in Singleton.timerArray {
                                    t.invalidate()
                                }
                            }
                            Singleton.timerArray.removeAll()
                            for _ in 0..<Singleton.runningRentalArray.count{
                                let timer = Timer()
                                Singleton.timerArray.append(timer)
                            }
                            if Singleton.runningRentalArray.count > 0{
                                self.showRunningRentalItems()
                            }else{
                                self.hideRunningRentalItems()
                            }
                        }
                        if let cr = currentRental[0] as? NSDictionary{
                            self.setUPSlider(dict:cr)
                        }
                        self.pauseRentalCollectionView.alpha = 1.0
                        self.pauseRentalCollectionView.isUserInteractionEnabled = true
                    }else{
                        StaticClass.sharedInstance.saveToUserDefaults(false as AnyObject , forKey: Global.g_UserDefaultKey.Is_StartBooking)
                        self.hideRunningRentalItems()
                    }
                    Global.appdel.checkLocationMangereMethod()
                    if let payment_id = dict["payment_id"]as? String, payment_id != "0"{
                        StaticClass.sharedInstance.saveToUserDefaultsString(value: payment_id , forKey: Global.g_UserData.BookingID)
                    }
                    if !self.isMapDraggin{
                        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Double(lat) ?? 0.0), longitude: CLLocationDegrees(Double(long) ?? 0.0), zoom: 17.0)
                        self.mapView.animate(to: camera)
                        DispatchQueue.main.async(execute: {
                            self.setBikesOnMap()
                        })
                    }else{
                        self.isMapDraggin = false
                    }
                } else if dict["payment_id"] as? String ?? "" != ""{
                    
                }else{
                    let msg = dict["MESSAGE"] as? String ?? ""
                    if msg.count > 1{
                        StaticClass.sharedInstance.ShowNotification(false, strmsg: msg, vc: self)
                    }
                    DispatchQueue.main.async {
                        self.mapView?.clear()
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.requestingApi = false
                self.isViewDidCall = false
                if Singleton.isOpeningAppFromNotification{
                    if !Singleton.notificationRunningRentalDetail.isEmpty{
                        self.selectedRentalIndex = Singleton.runningRentalArray.firstIndex(where: {$0["obj_unique_id"]as? String ?? "" == Singleton.notificationRunningRentalDetail["obj_unique_id"]as? String ?? ""}) ?? -1
                        if self.selectedRentalIndex != -1{
                            self.loadEndRentalPopUpView(titleMsg: "Alert!", descriptionMsg: Singleton.notificationRunningRentalDetail["popup_msg"]as? String ?? "")
                        }
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let data = response as? [String:Any]{
                    if let show_contact_popup = data["show_contact_popup"]as? Int, show_contact_popup == 1{
                        self.loadPrimaryAccountView(data: data)
                    }
                }
            }            
        }) { (error) in
            self.loaderBgView.isHidden = true
            self.isViewDidCall = false
            self.hideLockLoader()
        }
    }
    
    func craditCardList_Web() {
        let dictParam : NSMutableDictionary = NSMutableDictionary()
        let strCustID = StaticClass.sharedInstance.retriveFromUserDefaults(Global.g_UserData.Customer_ID)as? String ?? ""
        dictParam.setValue(strCustID, forKey: "bt_customer")
        dictParam.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        dictParam.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        self.selectPaymentOptView.isHidden = true
        self.btnStartQRScan.isUserInteractionEnabled = false
        self.arrCardList.removeAllObjects()
        APICall.shared.postWeb("creditCardList", parameters: dictParam, showLoder: false, successBlock: { (responseOBJ) in
            
            if let dict =  responseOBJ as? NSDictionary {
                if let flag = dict.value(forKey: "FLAG")as? Int, flag == 1{
                    
                    if let referalCount = dict["referral_count"]as? String{
                        if Int(referalCount)! == 0{
                            self.freeRentalsContainerView.isHidden = true
                        }else{
                            self.freeRentalsContainerView.isHidden = false
                            self.numberOfFreeRentals_lbl.text = "Free Rentals (\(referalCount) Left)"
                            self.numberOfReferralRentals = Int(referalCount)!
                            Singleton.numberOfReferralRides = referalCount
                        }
                    }
                    
                    if let bookingUserType = dict.value(forKey: "booking_user_type")as? String, bookingUserType == "1"{
                        self.arrCardList = []
                        self.cardListTable_height.constant = 0
                    }else{
                        let arrCard = (dict["bt_card_details"] as? NSArray)
                        DispatchQueue.main.async(execute: {
                            for element in arrCard! {
                                if let dict = element as? NSDictionary {
                                    let cardDetail = shareCraditCard()
                                    cardDetail.cardType = dict.object(forKey: "cardType") as? String ?? ""
                                    cardDetail.card_number = dict.object(forKey: "card_number") as? String ?? ""
                                    cardDetail.exipry = dict.object(forKey: "exipry") as? String ?? ""
                                    cardDetail.exipry_month = dict.object(forKey: "exipry_month") as? String ?? ""
                                    cardDetail.exipry_year = dict.object(forKey: "exipry_year") as? String ?? ""
                                    cardDetail.name = dict.object(forKey: "name") as? String ?? ""
                                    cardDetail.token_id = dict.object(forKey: "token_id") as? String ?? ""
                                    self.arrCardList.add(cardDetail)
                                }
                            }
                            if self.arrCardList.count > 0{
                                self.cardListTable_height.constant = 75
                                self.cardListTableView.reloadData()
                            }else{
                                self.cardListTable_height.constant = 0
                            }
                        })
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.btnStartQRScan.isUserInteractionEnabled = true
                        self.selectPaymentOptView.isHidden = false
                    }
                }else{
                }
            }
        }) { (error) in
            
        }
    }
    
    func getlockInstructionList_Web(){
        
        let dict = NSMutableDictionary()
        dict.setValue(StaticClass.sharedInstance.strUserId, forKey: "user_id")
        dict.setValue(appDelegate.getCurrentAppVersion, forKey: "ios_version")
        
        APICall.shared.postWeb("lock_instruction", parameters: dict, showLoder: false, successBlock: { (responseOBJ) in
            print("lock_instruction", responseOBJ)
            if let status = responseOBJ["FLAG"]as? Int, status == 1{
                Singleton.lockInstructionArray = responseOBJ["ASSETS_MASTER"]as? [[String:Any]] ?? []
                self.pageController.numberOfPages = Singleton.lockInstructionArray.count
                self.lockGuidCollection.reloadData()
            }else{
                StaticClass.sharedInstance.ShowNotification(false, strmsg: responseOBJ["MESSAGE"] as? String ?? "", vc: self)
            }
        }) { (error) in
            print("lock_instruction error block", error as? String ?? "")
        }
        
    }
    
    func changeCard_Web(payment_id : String , cardToken : String, index: Int){
        let param = NSMutableDictionary()
        param["payment_id"] = payment_id
        param["card_token"] = cardToken
        param["ios_version"] = "\(appDelegate.getCurrentAppVersion)"
        self.loaderBgView.isHidden = false
        APICall.shared.postWeb("change_card", parameters: param, showLoder: true, successBlock: { (response) in
            self.loaderBgView.isHidden = true
            if let Dict = response as? NSDictionary {
                if Dict.object(forKey: "FLAG") as! Bool {
                    StaticClass.sharedInstance.ShowNotification(true, strmsg: Dict.object(forKey: "MESSAGE") as? String ?? "Change Card updated successfully", vc: self)
                } else {
                    StaticClass.sharedInstance.ShowNotification(true, strmsg: Dict.object(forKey: "MESSAGE") as? String ?? "", vc: self)
                }
            }
            
        }) { (error) in
            self.loaderBgView.isHidden = true
            print(error.localizedDescription ?? "")
        }
    }
    
    func nearestDropZone_Web() {
        let dictParameter = NSMutableDictionary()
        dictParameter.setObject(StaticClass.sharedInstance.latitude, forKey: "latitude" as NSCopying)
        dictParameter.setObject(StaticClass.sharedInstance.longitude, forKey: "longitude" as NSCopying)        
        dictParameter.setObject(StaticClass.sharedInstance.strUserId, forKey: "user_id" as NSCopying)
        dictParameter.setObject(Singleton.runningRentalArray[self.selectedRentalIndex]["partner_id"]as? String ?? ""
                                , forKey: "partner_id" as NSCopying)
        dictParameter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        self.loaderBgView.isHidden = false
        APICall.shared.postWeb("available_dropzones", parameters: dictParameter, showLoder: true, successBlock: { (responseObj) in
            self.loaderBgView.isHidden = true
            if let Dict = responseObj as? NSDictionary {
                print("available_dropzones response: ", responseObj)
                if Dict.object(forKey: "FLAG") as! Bool {
                    let arrList = Dict.object(forKey: "Dropzones") as? NSArray
                    self.hideLockLoader()
                    if (arrList?.count)! > 0 {
                        let diction = arrList?[0] as? NSDictionary
                        self.strLocationID = diction?["id"] as? String ?? ""
                    }
                    self.calculationPrice_Web(isNreaBY: true)
                } else {
                    self.shareDeviceObj.strPenaltyAmount = Dict.object(forKey: "Panelty") as? String ?? ""
                    self.calculationPrice_Web(isNreaBY: false)
                }
            }
        }) { (error) in
            self.loaderBgView.isHidden = true
            self.hideLockLoader()
        }
    }
    
    func calculationPrice_Web(isNreaBY: Bool) {
        
        let dictParameter = NSMutableDictionary()
        
        let selectedRentalDic = Singleton.runningRentalArray[selectedRentalIndex]
        dictParameter.setObject(StaticClass.sharedInstance.strUserId, forKey: "user_id" as NSCopying)
        dictParameter.setValue(isNreaBY == true ? 0:1, forKey: "is_penalty")
        dictParameter.setObject(selectedRentalDic["id"]as? String ?? "", forKey: "booking_id" as NSCopying)
        dictParameter.setValue(selectedRentalDic["object_id"]as? String ?? "", forKey: "object_id")
        dictParameter.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        print("Calculate Params: ", dictParameter)
        APICall.shared.postWeb("calculate_price", parameters: dictParameter, showLoder: false, successBlock: { (responseObj) in
            print("calculate_price response: ", responseObj)
            if let Dict = responseObj as? NSDictionary {
                if Dict.object(forKey: "FLAG") as! Bool {
                    
                    self.shareDeviceObj.totalCalulationPrice = String(StaticClass.sharedInstance.getDouble(value:Dict.object(forKey: "total_price") ?? "0.0"))
                    self.shareDeviceObj.totalCalulationMinute = String(StaticClass.sharedInstance.getDouble(value:Dict.object(forKey: "total_min") ?? "0"))
                    
                    self.hideLockLoader()
                    if isNreaBY == true {
                        self.btnLockAction()
                    } else {
                        if Global.appdel.strIsUserType == "1" || Global.appdel.strIsUserType == "2" {
                            self.btnLockAction()
                        } else {
                            let popup = PopupController
                                .create(self)
                            let container = PaneltyPopupVC.instance()
                            container.data = self.shareDeviceObj
                            container.partnerId = Singleton.runningRentalArray[self.selectedRentalIndex]["partner_id"]as? String ?? ""
                            container.shareCraditCardOBJ = self.sharedCreditCardObj
                            if self.bikeSharedDataArray.count > 0{
                                container.bikeDataObj = self.bikeSharedDataArray[self.selectedRentalIndex]//self.BikeSharedData
                            }
                            container.isMyRental = self.isMyRental
                            container.strPenaltyPrice = self.shareDeviceObj.strPenaltyAmount
                            container.strLocationID = self.strLocationID
                            container.bookNowVc = self
                            container.closeHandler = {
                                popup.dismiss()
                            }
                            popup.show(container)
                        }
                    }
                }
            }
        }) { (error) in
            
        }
    }
    
    func lockUnlock_Web(strEvent:String) -> Void {
        
        let paramer: NSMutableDictionary = NSMutableDictionary()
        
        let selectedRentalDic = Singleton.runningRentalArray[selectedRentalIndex]
        
        paramer.setValue(StaticClass.sharedInstance.strUserId, forKey:"user_id")
        paramer.setValue(selectedRentalDic["id"]as? String ?? "", forKey:"booking_id")
        paramer.setValue(String(describing: self.centerLatLong_current.latitude), forKey:"latitude")
        paramer.setValue(String(describing: self.centerLatLong_current.longitude), forKey:"longitude")
        paramer.setValue(strEvent, forKey: "event") // (0:lock, 1:unlock)
        paramer.setValue(isEventStatus, forKey:"lock_status") //(1:Booking Started, 2:Booking Finished, 3:Intermediate Lock , 4:Intermediate Unlock)
        paramer.setValue(selectedRentalDic["object_id"]as? String ?? "", forKey: "object_id")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        
        let stringwsName = "lock_unlock"
        APICall.shared.postWeb(stringwsName, parameters: paramer, showLoder: false, successBlock: { (response) in
            print("lock_unlock response: ", response)
            if let dict = response as? NSDictionary {
                if (dict["FLAG"] as! Bool){
                    if strEvent == "1"{
                        UserDefaults.standard.setValue(1, forKey: "isRentalPause")
                    }else{
                        UserDefaults.standard.setValue(0, forKey: "isRentalPause")
                    }
                    if self.rentalActionPerformed != 1{
                        self.searchHome_Web(lat: String(describing: self.shareParameters.doubleLat), long: String(describing: self.shareParameters.doubleLong))
                    }
                }else {
                    
                }
                if self.isAxaLoaderLoad{
                    if self.rentalActionPerformed == 1{
                        self.isAxaLoaderLoad = false
                    }else{
                        
                    }
                }
            }
        }) { (error) in
            if self.isAxaLoaderLoad{
                self.hideLockLoader()
            }
        }
    }
    
    func finishBooking_Web(strLocation_ID:String) {
        
        self.showLoader(withMsg: "Ending your rental...")
        
        let selectedRentalDic = Singleton.runningRentalArray[selectedRentalIndex]
        self.paymentId = selectedRentalDic["id"]as? String ?? ""
        
        let dictionary = NSMutableDictionary()
        dictionary.setObject(selectedRentalDic["id"]as? String ?? "", forKey: "payment_id" as NSCopying)
        dictionary.setObject(self.isEndingRentalManual, forKey: "manually_end" as NSCopying)
        dictionary.setObject(self.shareDeviceObj.totalCalulationPrice, forKey: "amount" as NSCopying)
        dictionary.setObject(self.iamAtHub ? "1":"0", forKey: "at_hub" as NSCopying)
        dictionary.setObject(self.shareDeviceObj.totalCalulationMinute, forKey: "total_min" as NSCopying)
        dictionary.setObject("\(self.centerLatLong_current.latitude)", forKey: "latitude" as NSCopying)
        dictionary.setObject("\(self.centerLatLong_current.longitude)", forKey: "longitude" as NSCopying)
        dictionary.setValue("\(self.lockConnectionService.lockUnlocked)",forKey:"event")
        dictionary.setObject(sharedCreditCardObj.token_id, forKey: "new_card_token" as NSCopying)
        dictionary.setObject(Global.appdel.strIsUserType , forKey: "user_type" as NSCopying)
        dictionary.setValue("\(self.batteryPercentage)" ,forKey:"battery_life")
        
        if self.shareDeviceObj.strPenaltyAmount == "" {
            dictionary.setObject("0", forKey: "is_penalty" as NSCopying)
            dictionary.setObject(strLocation_ID, forKey: "location_id" as NSCopying)
        }else {
            dictionary.setObject("1", forKey: "is_penalty" as NSCopying)
            dictionary.setObject("", forKey: "location_id" as NSCopying)
        }
        if self.iamAtHub{
            dictionary.setObject("0", forKey: "is_penalty" as NSCopying)
        }
        
        dictionary.setObject("2", forKey: "lock_status" as NSCopying)
        dictionary.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        APICall.shared.postWeb("finish_booking", parameters: dictionary, showLoder: false) { (response) in
            
            self.hideLockLoader()
            if let Dict = response as? NSDictionary {
                if (Dict["BOOKING_RUNNING"] as? String ?? "100") == "1" {
                    Global.appdel.is_rentalRunning = true
                }else{
                    Global.appdel.is_rentalRunning = false
                }
                // PARSE BOOKING COMPLETE DATA
                if Dict.object(forKey: "FLAG") as! Bool {
                    self.endingRentalData = Singleton.runningRentalArray[self.selectedRentalIndex]
                    if self.bikeSharedDataArray.count > 0{
                        if StaticClass.sharedInstance.arrRunningBookingId.contains(self.shareDeviceObj.strBookingID) {
                            StaticClass.sharedInstance.arrRunningBookingId.remove(self.shareDeviceObj.strBookingID)
                        }
                        if StaticClass.sharedInstance.arrRunningObjectId.contains(self.bikeSharedDataArray[self.selectedRentalIndex].strId) {
                            StaticClass.sharedInstance.arrRunningObjectId.remove(self.bikeSharedDataArray[self.selectedRentalIndex].strId)
                        }
                    }
                    
                    StaticClass.sharedInstance.saveToUserDefaults(StaticClass.sharedInstance.arrRunningBookingId as AnyObject , forKey: Global.g_UserData.BookingIDsArr)
                    StaticClass.sharedInstance.saveToUserDefaults(StaticClass.sharedInstance.arrRunningObjectId  as AnyObject , forKey: Global.g_UserData.ObjectIDsArr)
                    
                    if let result = Dict.object(forKey: "RESULT") as? NSDictionary{
                        Singleton.lastRideSummaryData = result as? [String:Any] ?? [:]
                        
                        StaticClass.sharedInstance.saveToUserDefaults(StaticClass.sharedInstance.strBookingId as AnyObject, forKey: Global.g_UserData.TempBookingID)                        
                        StaticClass.sharedInstance.saveToUserDefaultsString(value:"" , forKey: Global.g_UserData.BookingID)
                        StaticClass.sharedInstance.saveToUserDefaultsString(value:"" , forKey: Global.g_UserData.ObjectID)
                        
                        if UserDefaults.standard.value(forKey: "isRentalPause") != nil{
                            UserDefaults.standard.removeObject(forKey: "isRentalPause")
                        }
                        if Singleton.runningRentalArray.count > self.selectedRentalIndex{
                            Singleton.order_id = Singleton.runningRentalArray[self.selectedRentalIndex]["id"]as? String ?? ""
                            Singleton.axa_ekey_dictionary = [:]
                            Singleton.runningRentalArray.remove(at: self.selectedRentalIndex)
                            self.pauseRentalCollectionView.reloadData()
                        }
                        
                        if Singleton.runningRentalArray.count == 0{
                            self.hideRentalCollection()
                        }
                        if self.iamAtHub{
                            self.paymentId = ""
                            self.loadRentalEndedView(message: self.endingRentalData["object_type"] as? String ?? "0")
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.pickLockImageToFinishRide(cameraType: "bike")
                            }
                        }
                    }
                    
                } else {
                    
                }
            }
        } failure: { (error) in
            self.hideLockLoader()            
            self.lockCommand = "1"
        }
    }
    
    func uploadImgForFinishRide(){
        //param: payment_id, image
        self.is_uploadingImg = true
        let dictionPara = NSMutableDictionary()
        dictionPara.setValue(paymentId, forKey: "payment_id")
        dictionPara.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        dictionPara.setValue("\(self.isCamBroken ? "1" : "0")", forKey: "is_camera_issue")
        
        let Imagearray = NSMutableArray()
        if let img = self.rentalImage {
            Imagearray.add(img)
        }
        self.loaderBgView.isHidden = false
        APICall.shared.callApiForMultipleImageUpload("rental_image", withParameter: dictionPara, true, withImage: Imagearray, withLoader: true, successBlock: { (response) in
            self.loaderBgView.isHidden = true
            print("rental_image response: ", response)
            self.is_uploadingImg = false
            if self.iamAtHub{
                self.finishBooking_Web(strLocation_ID: self.strLocationID)
            }else{
                self.paymentId = ""
                if Singleton.runningRentalArray.count == 0{
                    // Pass static "2" to show locker rental summary for bike also. //Previous param passed self.endingRentalData["object_type"] as? String ?? "0"
                    self.loadSummaryView(summaryType: self.endingRentalData["object_type"] as? String ?? "0")
                }else{
                    let msg = Singleton.runningRentalArray.count == 1 ? "You have \(Singleton.runningRentalArray.count) ongoing rental":"You have \(Singleton.runningRentalArray.count) ongoing rentals"
                    self.loadCustomAlertWithGradientButtonView(title: "One rental ended!", messageStr: msg, buttonTitle: "Got It")
                    self.searchHome_Web(lat: String(describing: self.shareParameters.doubleLat), long: String(describing: self.shareParameters.doubleLong))
                }
            }
        }) { (error) in
            self.loaderBgView.isHidden = true
            self.photoErrorOnUpload()
        }
    }
    
    func getAxaEkeyPasskeyForBookNow_Web(assetId: String, outputBlock: @escaping(_ response: Bool)-> Void){
        
        let params: NSMutableDictionary = NSMutableDictionary()
        params.setValue(StaticClass.sharedInstance.strUserId, forKey: "id")
        params.setValue("0", forKey: "parent_id")
        params.setValue(assetId, forKey: "object_id")
        params.setValue("otp", forKey: "passkey_type")
        params.setValue("8.5", forKey: "ios_version")
        APICall.shared.postWeb("update_ekey", parameters: params, showLoder: false, successBlock: { (response) in
            if let status = response["FLAG"]as? Int, status == 1{
                if let assets_detail = response["ASSETS_DETAIL"]as? [String:Any]{
                    var dictionary: [String:Any] = ["object_id": assetId]
                    if let ekey = assets_detail["axa_ekey"]as? String{
                        dictionary["axa_ekey"] = ekey
                        Singleton.axa_ekey = ekey
                    }
                    if let passkey = assets_detail["axa_passkey"]as? String{
                        dictionary["axa_passkey"] = passkey
                        Singleton.axa_passkey = passkey
                    }
                    if dictionary["axa_ekey"] as? String ?? "" != "" && dictionary["axa_passkey"] as? String ?? "" != ""{
                        dictionary["current_index"] = 0
                        Singleton.axa_ekey_dictionary = dictionary
                        outputBlock(true)
                    }else{
                        outputBlock(false)
                    }
                }
            }else{
                outputBlock(true)
            }
        }) { (error) in
            outputBlock(true)
            StaticClass.sharedInstance.ShowNotification(false, strmsg: error as? String ?? "")
        }
    }
    
 }
 
 //MARK: - Image Picker Delegate's 
 extension BookNowVC{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.is_uploadingImg = false
        _ = UIApplication.topViewController()
        Global.appdel.setUpSlideMenuController()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        pickedImage = image
        self.uploadImgForFinishRide()
    }
 }
 
 //MARK: - Linka Lock Delegates Method's
 extension BookNowVC: LockConnectionServiceDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func onQueryLocked(completionHandler: @escaping (Bool) -> Void) {
        self.hideLockLoader()
        self.isPause = true
        self.btnPressedPause = true
        self.changeStateOfPauseButton(isLocked: true)
        UserDefaults.standard.set(0, forKey: "isRentalPause")
        self.lockConnectionService.disconnectWithExistingController()
        completionHandler(false)
    }
    
    func onQueryUnlocked(completionHandler: @escaping (Bool) -> Void) {
        self.hideLockLoader()
        self.isPause = false
        self.btnPressedPause = false
        self.changeStateOfPauseButton(isLocked: false)
        UserDefaults.standard.set(1, forKey: "isRentalPause")
        self.lockConnectionService.disconnectWithExistingController()
        completionHandler(false)
    }
    
    func onPairingUp() {
        
    }
    
    func onPairingSuccess() {
        
    }
    
    func onScanFound() {
        
    }
    
    func onConnected() {
        
    }
    
    func onBatteryPercent(batteryPercent: Int) {
        
        debugPrint("BatteryPercent is :- \(batteryPercent)")
        let topVC = UIApplication.topViewController()
        
        batteryPercentage = batteryPercent
        if batteryPercent < 15 {
            
            if topVC is Critical_LowBatteryVC  {
            }else{
                self.hideLockLoader()
                let batteryLow = Critical_LowBatteryVC(nibName: "Critical_LowBatteryVC", bundle: nil)
                batteryLow.is_Critical = true
                Global.appdel.window?.rootViewController?.present(batteryLow, animated: true, completion: nil)
            }
        }
        else if  batteryPercent < 25 && batteryPercent > 15 {
            
            if topVC is Critical_LowBatteryVC {
            }else{
                self.hideLockLoader()
                let batteryLow = Critical_LowBatteryVC(nibName: "Critical_LowBatteryVC", bundle: nil)
                batteryLow.is_Critical = false
                Global.appdel.window?.rootViewController?.present(batteryLow, animated: true, completion: nil)
            }
        }
    }
    
    func onUnlockStarted() {
        let topVC = UIApplication.topViewController()
        if topVC is BookNowVC  {
            self.showLoader(withMsg: "Unlocking. Please wait...")
        }else{
        }
    }
    
    func onLockStarted() {
        let topVC = UIApplication.topViewController()
        if topVC is BookNowVC  {
            self.showLoader(withMsg: "Locking. Please wait...")
        }else{
        }
    }
    
    func onLock() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": "0", "command_status": "0", "error_message": "", "device_type": "1"])
        self.deviceLockedSuccessfully()
    }
    
    func onUnlock() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": "1", "command_status": "0", "error_message": "", "device_type": "1"])
        self.deviceUnlockedSuccessfully()
    }
    
    func errorInternetOff() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Internet Off", "device_type": "1"])
        self.hideLockLoader()
        self.setRentalViewToInitial()
        let alert = UIAlertController(title: "Alert", message: popUpMessage.someWrong.rawValue, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorBluetoothOff() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "", "device_type": "1"])
        self.hideLockLoader()
        self.setRentalViewToInitial()
        let alert = UIAlertController(title: "Alert", message: "Please turn on bluetooth for connect lock device.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorAppNotInForeground() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "App not in foreground", "device_type": "1"])
        self.hideLockLoader()
        AppDelegate.shared.window?.showBottomAlert(message: "App Not in Foreground")
        self.setRentalViewToInitial()
    }
    
    func errorInvalidAccessToken() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Invalid access token", "device_type": "1"])
        self.setRentalViewToInitial()
        self.hideLockLoader()
        _ = LinkaMerchantAPIService.fetch_access_token { (responseObject, error) in
            
            DispatchQueue.main.async(execute: {
                if responseObject != nil {
                    AppDelegate.shared.window?.showBottomAlert(message: "Please try again")
                    return
                } else if error != nil {
                    AppDelegate.shared.window?.showBottomAlert(message: "There is an error while fetching acess token")
                    return
                } else {
                    AppDelegate.shared.window?.showBottomAlert(message: "Please check your connections,bluetooth range")
                    return
                }
            })
        }
        
    }
    
    func errorMacAddress(errorMsg: String) {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Invalid mac address", "device_type": "1"])
        self.hideLockLoader()
        AppDelegate.shared.window?.showBottomAlert(message: errorMsg)
        self.setRentalViewToInitial()
    }
    
    func errorConnectionTimeout() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Connection timeout", "device_type": "1"])
        self.hideLockLoader()
        self.loadCustomAlertWithGradientButtonView(title: "Alert!", messageStr: "Make sure Linka is awake, and not connected to another mobile phone. if this problem persists then turn bluetooth off and on", buttonTitle: "Ok")
        self.setRentalViewToInitial()
    }
    
    func errorScanningTimeout() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Scaning timeout", "device_type": "1"])
        self.hideLockLoader()
        self.setRentalViewToInitial()
        self.loadCustomAlertWithGradientButtonView(title: "Alert!", messageStr: "Make sure Linka is awake, and not connected to another mobile phone. if this problem persists then turn bluetooth off and on", buttonTitle: "Ok")
    }
    
    func errorLockMoving(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Lock Movement Detected. Locking blocked. Stabilize the bike and try again", "device_type": "1"])
        self.hideLockLoader()
        self.showAlertWithOkAndCancelBtn("Locking Blocked", "Lock Movement Detected. Locking blocked. Stabilize the bike and try again", yesBtn_title: "Try Again", noBtn_title: "Cancel") { (response) in
            if response == "ok" {
                tryAgainCompletion(true)
            }else {
                self.setRentalViewToInitial()
                tryAgainCompletion(false)
            }
        }
    }
    
    func errorLockStall(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Lock Stall", "device_type": "1"])
        self.hideLockLoader()
        self.setRentalViewToInitial()
    }
    
    func errorLockJam() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Error Lock Jam. Lock requires repair", "device_type": "1"])
        AppDelegate.shared.window?.showBottomAlert(message: "Error Lock Jam. Lock requires repair")
        self.hideLockLoader()
        
        let topVC = UIApplication.topViewController()
        if topVC is ObstacleVC  {
        }else{
            let obstacle = ObstacleVC(nibName: "ObstacleVC", bundle: nil)
            obstacle.checkNotifier = true
            self.setRentalViewToInitial()
            Global.appdel.window?.rootViewController?.present(obstacle, animated: true, completion: nil)
        }
        
    }
    
    func errorUnexpectedDisconnect() {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Unexpected Disconnect", "device_type": "1"])
        AppDelegate.shared.window?.showBottomAlert(message: "Unexpected Disconnect")
        self.hideLockLoader()
        self.setRentalViewToInitial()
    }
    
    func errorLockingTimeout(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Locking Timeout. Remove obstructions and try again.", "device_type": "1"])
        self.hideLockLoader()
        self.showAlertWithOkAndCancelBtn("Error!", "Locking Timeout. Remove obstructions and try again.", yesBtn_title: "Try Again", noBtn_title: "Cancel") { (response) in
            if response == "ok" {
                tryAgainCompletion(true)
            }else {
                self.setRentalViewToInitial()
                tryAgainCompletion(false)
            }
        }
    }
    
    func errorUnlockingTimeout(tryAgainCompletion: @escaping (Bool) -> Void) {
        self.lockLog_Web(params: ["user_id": StaticClass.sharedInstance.strUserId, "object_id": Singleton.runningRentalArray[selectedRentalIndex]["object_id"]as? String ?? "", "booking_id": Singleton.runningRentalArray[selectedRentalIndex]["id"]as? String ?? "", "command_sent": self.lockCommand, "command_status": "1", "error_message": "Unlocking Timeout. Remove obstructions and try again.", "device_type": "1"])
        self.hideLockLoader()
        self.setRentalViewToInitial()
        self.showAlertWithOkAndCancelBtn("Error!", "Unlocking Timeout. Remove obstructions and try again.", yesBtn_title: "Try Again", noBtn_title: "Cancel") { (response) in
            if response == "ok" {
                tryAgainCompletion(true)
            }else {
                tryAgainCompletion(false)
                if self.isPause{
                    self.isEventStatus = "4"
                }else{
                    self.isEventStatus = "3"
                    self.lockCommand = "0"
                    _ = self.lockConnectionService.doLock(macAddress: self.selectedBikeMacAddress, delegate: self)
                }
            }
        }
    }
    
 }
 
 //MARK: - VHSliderButton Delegates
 extension BookNowVC: VHSlideButtonDelegate{
    
    func selectedPosition(position: Postion) {
        if position == .bottom{
            self.finishRentalsView.isHidden = true
            self.btnSlideToFinish.resetSlideButton()
            if Singleton.runningRentalArray[self.selectedRentalIndex]["lock_id"] as? String ?? "" == "6"{
                if self.axaLockConnection?.peripheralDevice != nil{
                    self.axaLockConnection?.centralMannager?.cancelPeripheralConnection((self.axaLockConnection?.peripheralDevice!)!)
                }
//                StaticClass.sharedInstance.ShowSpiner()
                self.axaLockConnection?.centralMannager?.scanForPeripherals(withServices: nil, options: nil)
            }else{
                self.lockCommand = "0"
                self.showLoader(withMsg: "Locking. Please wait....")
                _ = self.lockConnectionService.doLock(macAddress: self.selectedBikeMacAddress, delegate: self)
            }
        }
    }
 }
 
 //MARK: - Google Map & Clusters Delegate's
 extension BookNowVC: GMUClusterRendererDelegate, GMSMapViewDelegate, GMUClusterManagerDelegate{
    
    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker {
        
        switch object {
        case let clusterItem as POIItem:
            
            let marker = GMSMarker()
            marker.position = clusterItem.position
            marker.isTappable = true
            var name = clusterItem.name
            if (name == "3"){
                marker.icon = UIImage(named: "location_both_green")
                name = "both"
            }else if (name == "1"){
                marker.icon = UIImage(named: "location_bike")
                name = "bike"
            }else{
                marker.icon = UIImage(named: "location_kube")
                name = "kube"
            }
            
            marker.map = self.mapView
            marker.userData = clusterItem.id
            return marker
        default:
            return GMSMarker()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Coordinates: ", coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        self.shareParameters.doubleLat = Double(mapView.camera.target.latitude)
        self.shareParameters.doubleLong = Double(mapView.camera.target.longitude)
        self.shareParameters.strIsNearest = "0"
        
        if !self.isSkipCall {
        }else {
            self.isSkipCall = false
        }
        
        self.currentLat = CGFloat(mapView.camera.target.latitude)
        self.currentLong = CGFloat(mapView.camera.target.longitude)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        DispatchQueue.main.async {
            let zoom = mapView.camera.zoom
            if self.cameraZoom == zoom || self.cameraZoom > zoom{
                self.selectedIndex = -1
                self.selectedLocId = ""
            }
            
            let distance = Global().distance(lat1: Double(mapView.camera.target.latitude), lon1: Double(mapView.camera.target.longitude), lat2: Double(self.centerLatLong_previous?.latitude ?? 0.0), lon2: Double(self.centerLatLong_previous?.longitude ?? 0.0), unit: "K")
            if distance > 10{
                self.isMapDraggin = true
                self.centerLatLong_previous = CLLocationCoordinate2D(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
                if !self.requestingApi && !Singleton.isOpeningAppFromNotification{
                    self.searchHome_Web(lat: "\(mapView.camera.target.latitude)", long: "\(mapView.camera.target.longitude)")
                }
            }else{
                if zoom < 16.0{
                    self.setMarkerOnGeofence()
                }else{
                    self.setBikesOnMap()
                }
            }
            self.cameraZoom = zoom
            
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if marker.userData as? String ?? "" != "ad"{
            if let data = self.arrDeviceData.object(at: Int(marker.zIndex))as? ShareDevice{
                if data.strLocation_Type == "2"{
                    var array: [AvailabelBike] = []
                    print("Marker index - ", marker.zIndex)
                    for item in self.arrayOfBike{
                        if let bike = item as? AvailabelBike{
                            if data.strLocationId == bike.strLocationId{
                                array.append(bike)
                            }
                        }
                    }
                    if array.count > 0{
                        self.loadAssestListView(vc: self, assetList: array)
                    }else{
                        self.showTopPop(message: "No asset available on this location", response: false)
                    }
                }else{
                    let latitude = data.strLat
                    let longitude = data.strLong
                    self.selectedLocId = data.strId
                    self.selectedIndex = Int(marker.zIndex)
                    let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 17.0)
                    UIView.animate(withDuration: 2) {
                        self.mapView.animate(to: camera)
                        self.view.layoutIfNeeded()
                    }
                    self.setBikesOnMap()
                }
            }
        }else{
            self.popUpAd.isHidden = false
            self.markerPoppuBG.alpha = 0
            self.markerPoppuBG.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.markerPoppuBG.alpha = 1.0
                self.view.layoutIfNeeded()
            }) { (succ) in
                
            }
            
            let index = marker.zIndex
            let data = arrAdData.object(at: Int(index)) as! ShareAd            
            self.imgAd.sd_setImage(with: URL(string: (data.logo_image)), placeholderImage: UIImage())
            self.imgBigAd.sd_setImage(with: URL(string: (data.banner_image)), placeholderImage: UIImage())
            self.lblTitAd.text = data.title
            self.description_textView.text = data.descriptionn
            if CGFloat(self.description_textView.numberOfLines() * 25) > 100{
                self.descriptionAd_height.constant = 100
                self.description_textView.isUserInteractionEnabled = true
            }else{
                self.descriptionAd_height.constant = CGFloat(self.description_textView.numberOfLines() * 25)
                self.description_textView.isUserInteractionEnabled = false
            }
            
        }
        
        return true
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) {
        
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: (mapView!.camera.zoom) + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        
        self.mapView?.moveCamera(update)
        
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) {
        let index = clusterItem.strIndex
        let data = self.arrayOfBike.object(at: Int(index ?? "0") ?? 0) as! AvailabelBike
        var bikesArray: [AvailabelBike] = []
        for item in self.arrayOfBike{
            if let bikeObj = item as? AvailabelBike{
                let distance = Global().distance(lat1: data.strLatitude, lon1: data.strLongitude, lat2: bikeObj.strLatitude, lon2: bikeObj.strLongitude, unit: "K")
                if distance < 0.1{
                    print(bikeObj.strId)
                    bikesArray.append(bikeObj)
                }else{
                }
            }
        }
        if bikesArray.count > 0{
            self.loadAssestListView(vc: self, assetList: bikesArray)
        }else{
            self.loadAssestListView(vc: self, assetList: [data])
        }
    }
 }
 
 //MARK:- TableView Delegate's
 extension BookNowVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCardList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == cardListTableView{
            self.cardListTable_height.constant = self.cardListTableView.contentSize.height + 0
            if indexPath.row == self.arrCardList.count - 1{
                DispatchQueue.main.async {
                    self.selectPaymentOptView_bottom.constant = -(self.selectPaymentOptView.frame.height + AppDelegate().getBottomSafeAreaHeight())
                }
            }
        }
        self.view.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cardListTableView.dequeueReusableCell(withIdentifier: "CardsListCell")as! CardsListCell
        let cardDetail = arrCardList.object(at: indexPath.row) as! shareCraditCard
        let checkCardType = String(describing: cardDetail.cardType)
        if checkCardType == "Visa" {
            cell.cardImg.image = UIImage(named: CardTypeValue.Visa.strImg)
        } else if checkCardType == "Mastro" {
            cell.cardImg.image = UIImage(named: CardTypeValue.Master.strImg)
        }else if checkCardType == "American Express" {
            cell.cardImg.image = UIImage(named: CardTypeValue.American.strImg)
        }else if checkCardType == "MasterCard" {
            cell.cardImg.image = UIImage(named: CardTypeValue.Master.strImg)
        }else if checkCardType == "Discover" {
            cell.cardImg.image = UIImage(named: CardTypeValue.Discover.strImg)
        }else if checkCardType == "Other" {
            cell.cardImg.image = UIImage(named: CardTypeValue.Other.strImg)
        }else{
            cell.cardImg.image = UIImage(named: CardTypeValue.Master.strImg)
        }
        
        cell.cardNumber_lbl.text = "xxxx    xxxx    xxxx    \(cardDetail.card_number)"
        if indexPath.row == 0{
            self.sharedCreditCardObj = self.arrCardList.object(at: indexPath.row)as! shareCraditCard
            self.cardSelected = 1
            cell.containerView.backgroundColor = CustomColor.primaryColor
            cell.cardNumber_lbl.textColor = UIColor.white
        }else{
            cell.containerView.backgroundColor = UIColor.white
            cell.cardNumber_lbl.textColor = UIColor.darkGray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.sharedCreditCardObj = self.arrCardList.object(at: indexPath.row)as! shareCraditCard
        self.cardSelected = 1
        for i in 0..<arrCardList.count{
            self.cardListCell = self.cardListTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! CardsListCell
            if i == indexPath.row{
                self.cardListCell.containerView.backgroundColor = CustomColor.primaryColor
                self.cardListCell.cardNumber_lbl.textColor = UIColor.white
            }else{
                self.cardListCell.containerView.backgroundColor = UIColor.white
                self.cardListCell.cardNumber_lbl.textColor = UIColor.darkGray
            }
        }
    }
 }
 
 
 //MARK: - CollectionView Delegete's
 extension BookNowVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.pauseRentalCollectionView{
            if Singleton.runningRentalArray.count > 0{
                return Singleton.runningRentalArray.count
            }else{
                return 0
            }
        }else{
            return Singleton.lockInstructionArray.count
        }
        
    }
    
    func collectionCellForIndex(index: Int)-> PauseRentalCollectionCell?{
        return self.pauseRentalCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PauseRentalCollectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.pauseRentalCollectionView{
            let cell = self.pauseRentalCollectionView.dequeueReusableCell(withReuseIdentifier: "PauseRentalCollectionCell", for: indexPath)as! PauseRentalCollectionCell
            cell.vc = self
            cell.tag = indexPath.row
            cell.setDataOnCell(dataDictionary: Singleton.runningRentalArray[indexPath.row])
            cell.report_btn.tag = indexPath.row
            cell.report_btn.addTarget(self, action: #selector(reportBtnTapped(_:)), for: .touchUpInside)
            cell.arrow_btn.tag = indexPath.row
            cell.arrow_btn.addTarget(self, action: #selector(cardDropDownTapped(_:)), for: .touchUpInside)
            cell.pause_btn.tag = indexPath.row
            cell.pause_btn.addTarget(self, action: #selector(pauseBtnTapped(_:)), for: .touchUpInside)
            cell.end_btn.tag = indexPath.row
            cell.end_btn.addTarget(self, action: #selector(endBtnTapped(_:)), for: .touchUpInside)
            return cell
        }else{
            let cell = self.lockGuidCollection.dequeueReusableCell(withReuseIdentifier: "GuideCollectionCell", for: indexPath)as! GuideCollectionCell
            cell.titleContainerView.backgroundColor = CustomColor.primaryColor
            let data = Singleton.lockInstructionArray[indexPath.row]
            cell.title_lbl.text = data["assets_name"]as? String ?? ""
            DispatchQueue.main.async {
                if let url = URL(string: data["first_image"]as? String ?? ""){
                    cell.lock_img.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                }
            }
            cell.description_lbl.text = data["title"]as? String ?? ""
            return cell
        }
    }
    
    @objc func reportBtnTapped(_ sender: UIButton){
        self.selectedRentalIndex = sender.tag
        let vc = ReportVC(nibName: "ReportVC", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        vc.showForRunningRental = true
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @objc func cardDropDownTapped(_ sender: UIButton){
        if Singleton.numberOfCards.count > 1{
            self.selectedRentalIndex = sender.tag
            if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex){
                UIView.animate(withDuration: 0.2) {
                    if self.layout.itemSize.height == (265 + cell.outOfDtextLabel_height.constant){
                        cell.cardListTable_height.constant = CGFloat((Singleton.numberOfCards.count - 1) * 40)
                        self.layout.itemSize = CGSize(width: self.pauseRentalCollectionView.frame.width - 40, height: CGFloat(((Singleton.numberOfCards.count - 1) * 40) + 320) + cell.outOfDtextLabel_height.constant)
                        self.isTableHide = false
                    }else{
                        cell.cardListTable_height.constant = 0
                        self.layout.itemSize = CGSize(width: self.pauseRentalCollectionView.frame.width - 40, height: (265 + cell.outOfDtextLabel_height.constant))
                        self.isTableHide = true
                    }
                    self.pauseRentalCollectionView_height.constant = CGFloat(self.layout.itemSize.height + 115)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func pauseBtnTapped(_ sender: UIButton){
        self.selectedRentalIndex = sender.tag
        if Singleton.runningRentalArray[sender.tag]["lock_id"] as? String ?? "" != "6"{
            self.selectedBikeMacAddress = Singleton.runningRentalArray[sender.tag]["device_id"] as? String ?? ""
        }
        if sender.isSelected{
            // For Unlocking
            self.btnPressedPause = true
            self.rentalActionPerformed = 0
            self.permissionAlertToPause()
        }else{
            // For Locking
            self.btnPressedPause = false
            if UserDefaults.standard.bool(forKey: "hide_axa_lock_alert_popup"){
                self.rentalActionPerformed = 0
                self.permissionAlertToPause()
            }else{
                self.loadRentalAlertView()
            }
        }
    }
    
    @objc func endBtnTapped(_ sender: UIButton){
        self.isEndingRentalManual = "0"
        self.setRentalViewToInitial()
        self.selectedRentalIndex = sender.tag
        if Singleton.runningRentalArray[sender.tag]["lock_id"] as? String ?? "" != "6"{
            self.selectedBikeMacAddress = Singleton.runningRentalArray[sender.tag]["device_id"] as? String ?? ""
        }
        self.rentalActionPerformed = 1
        self.permissionAlertToEnd()
    }
    
 }
 
 //MARK: - ScrollView Delegate's
 extension BookNowVC{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = self.pauseRentalCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        self.selectedRentalIndex = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        print("Index",self.selectedRentalIndex, self.lastSelectedIndex)
        if (self.selectedRentalIndex != self.lastSelectedIndex) && !self.isRentalCellChagned{
            self.isRentalCellChagned = true
            if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex){
                cell.tag = selectedRentalIndex
                UIView.animate(withDuration: 0.05) {
                    if self.isTableHide{
                        cell.cardListTable_height.constant = 0
                        self.layout.itemSize = CGSize(width: self.pauseRentalCollectionView.frame.width - 40, height: 265 + cell.outOfDtextLabel_height.constant)
                    }else{
                        cell.cardListTable_height.constant = CGFloat((Singleton.numberOfCards.count - 1) * 40)
                        self.layout.itemSize = CGSize(width: self.pauseRentalCollectionView.frame.width - 40, height: CGFloat(((Singleton.numberOfCards.count - 1) * 40) + 320) + cell.outOfDtextLabel_height.constant)
                    }
                    self.pauseRentalCollectionView_height.constant = CGFloat(self.layout.itemSize.height + 115)
                    if self.isRentalViewDown{
                        self.pauseRentalCollection_bottom.constant = -15
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Scrolling End")
        if scrollView == self.pauseRentalCollectionView{
            let layout = self.pauseRentalCollectionView.collectionViewLayout as! UPCarouselFlowLayout
            let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
            let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
            self.selectedRentalIndex = Int(floor((offset - pageSide / 2) / pageSide) + 1)
            self.lastSelectedIndex = self.selectedRentalIndex
            self.isRentalCellChagned = false
            self.numberOfRentalsRunning_lbl.text = "\(selectedRentalIndex + 1)/\(Singleton.runningRentalArray.count)"
//            self.numberOfRentalRunningTop_lbl.text = "\(selectedRentalIndex + 1)/\(Singleton.runningRentalArray.count)"
            if self.selectedRentalIndex < Singleton.trackLocationRentalArray.count{
                self.currentRentalAmount_lbl.text = "$\(Singleton.trackLocationRentalArray[selectedRentalIndex]["total_price"]as? Double ?? 0.0)"
            }
            if Singleton.runningRentalArray.count > selectedRentalIndex{
                self.strLocationID = Singleton.runningRentalArray[selectedRentalIndex]["location_id"] as? String ?? ""
                self.strBikeKubeID = Singleton.runningRentalArray[selectedRentalIndex]["object_id"] as? String ?? ""
                if Singleton.runningRentalArray[self.selectedRentalIndex]["object_type"] as? String ?? "" == "2"{
                    self.nearestDropZone_btn.isHidden = false
                }else{
                    self.nearestDropZone_btn.isHidden = true
                }
            }
            if let cell = self.collectionCellForIndex(index: self.selectedRentalIndex){
                cell.tag = selectedRentalIndex
                UIView.animate(withDuration: 0.05) {
                    if self.isTableHide{
                        cell.cardListTable_height.constant = 0
                        self.layout.itemSize = CGSize(width: self.pauseRentalCollectionView.frame.width - 40, height: 265 + cell.outOfDtextLabel_height.constant)
                    }else{
                        cell.cardListTable_height.constant = CGFloat((Singleton.numberOfCards.count - 1) * 40)
                        self.layout.itemSize = CGSize(width: self.pauseRentalCollectionView.frame.width - 40, height: CGFloat(((Singleton.numberOfCards.count - 1) * 40) + 320) + cell.outOfDtextLabel_height.constant)
                    }
                    self.pauseRentalCollectionView_height.constant = CGFloat(self.layout.itemSize.height + 115)
                    if self.isRentalViewDown{
                        self.pauseRentalCollection_bottom.constant = -15
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }else if scrollView == self.lockGuidCollection{
            let layout = self.lockGuidCollection.collectionViewLayout as! UPCarouselFlowLayout
            let pageSide = (layout.scrollDirection == .horizontal) ? self.cellSize.width : self.cellSize.height
            let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
            self.pageController.currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        }
    }
 }
 
 //MARK: - Assets list Delegate's
 extension BookNowVC: AssetsListViewDelegate{
    func selectedAsset(buttonPressed: String, assetId: String) {
        if buttonPressed == "book"{
            if self.checkAccountValidForRental(){
                self.directBooking = true
                self.selectedObjectId = assetId
                self.scanQrBtnPressed()
            }
        }else if buttonPressed == "nearly_koloni"{
            btnFindNearestPressed(btnFindNearest)
        }else if buttonPressed == "private"{
            self.alertBox("Koloni", "This is a private Koloni and hence you cannot access it.") {
            }
        }
    }
 }
 
 extension UserDefaults {
    // check for is first launch - only true on first invocation after app install, false on all further invocations
    // Note: Store this value in AppDelegate if you have multiple places where you are checking for this flag
    static func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
 }
 
