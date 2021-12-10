//
//  PauseRentalCollectionCell.swift
//  KoloniKube_Swift
//
//  Created by Tops on 07/02/20.
//  Copyright © 2020 Self. All rights reserved.
//

import UIKit

class PauseRentalCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var report_btn: CustomButton!
    @IBOutlet weak var orderNum_lbl: UILabel!
    @IBOutlet weak var timer_lbl: UILabel!
    @IBOutlet weak var pause_btn: CustomButton!
    @IBOutlet weak var pause_resume_lbl: UILabel!
    @IBOutlet weak var end_btn: CustomButton!
    @IBOutlet weak var cardNum_lbl: UILabel!
    @IBOutlet weak var arrow_btn: UIButton!
    @IBOutlet weak var chooseOherCardView: UIView!
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var pauseOrStartBtn_img: UIImageView!
    @IBOutlet weak var endBtn_img: UIImageView!
    @IBOutlet weak var cardListTableView: UITableView!
    @IBOutlet weak var cardListTable_height: NSLayoutConstraint!
    
    @IBOutlet weak var pauseBtnView: UIView!
    @IBOutlet weak var endBtnView: UIView!
    @IBOutlet weak var outOfDropZoneText_lbl: UILabel!
    @IBOutlet weak var outOfDtextLabel_height: NSLayoutConstraint!
    
    var arrayOfshareCraditCard = [shareCraditCard]()
    var timer: Timer?
    var vc: UIViewController?
    var runningRentalView: RunningRentalView!
//    var bookNowVc: BookNowVC!
//    var locationListingVc: LocationListingViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print(Singleton.runningRentalArray)
        self.registerTableCell()
    }
    
    func registerTableCell(){
        self.cardListTableView.register(UINib(nibName: "CardsListCell", bundle: nil), forCellReuseIdentifier: "CardsListCell")
        self.cardListTableView.delegate = self
        self.cardListTableView.dataSource = self
    }
    
    //Setting Data on collection cell
    func setDataOnCell(dataDictionary: [String:Any]){
                
        DispatchQueue.main.async {
            AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "end_img") { (image) in
                self.endBtn_img.image = image
            }
            self.end_btn.backgroundColor = AppLocalStorage.sharedInstance.end_button_color
            if dataDictionary["lock_status"]as? String ?? "0" == "0"{
                self.pause_btn.isSelected = true
                
                if dataDictionary["object_type"]as? String ?? "" == "2"{
                    self.pause_resume_lbl.text = AppLocalStorage.sharedInstance.resume_button_text//"Unlock"
                }else{
                    self.pause_resume_lbl.text = AppLocalStorage.sharedInstance.resume_button_text//"Open"
                }
                AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "pause_img") { (image) in
                    self.pauseOrStartBtn_img.image = image
                }
                self.pause_btn.backgroundColor = AppLocalStorage.sharedInstance.resume_button_color
            }else{
                self.pause_btn.isSelected = false
                
                if dataDictionary["object_type"]as? String ?? "" == "2"{
                    self.pause_resume_lbl.text = AppLocalStorage.sharedInstance.pause_button_text//"Lock"
                }else{
                    self.pause_resume_lbl.text = AppLocalStorage.sharedInstance.pause_button_text//"Close"
                }
                AppLocalStorage.sharedInstance.reteriveImageFromFileManager(imageName: "resume_img") { (image) in
                    self.pauseOrStartBtn_img.image = image
                }
                self.pause_btn.backgroundColor = AppLocalStorage.sharedInstance.pause_button_color
//                self.pause_btn.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
            }
            
            self.orderNum_lbl.text = dataDictionary["obj_unique_id"]as? String ?? ""
            if Singleton.numberOfCards.count > 0{
                self.cardContainerView.isHidden = false
                let cardDetail = Singleton.numberOfCards[0]
                self.cardNum_lbl.text = "xxxx    xxxx    xxxx    \(String(describing: cardDetail["card_number"]!).suffix(4))"
            }else{
                self.cardContainerView.isHidden = true
            }
            self.cardListTable_height.constant = 0
            self.startTimer(dataDictionary: dataDictionary)
                        
            if let is_out_of_dropzone = dataDictionary["is_outof_dropzone"]as? String, is_out_of_dropzone == "0"{
                self.outOfDropZoneText_lbl.isHidden = false
                self.outOfDropZoneText_lbl.text = "If you end your rental at a designated hub, you get 30 minutes free, followed by hourly rates."//(dataDictionary["outof_dropzone_message"]as? String ?? "").html2String
            }else{
                self.outOfDropZoneText_lbl.isHidden = true
                self.outOfDtextLabel_height.constant = 0
            }
            if let bookNowVc = self.vc as? BookNowVC{
                if bookNowVc.loadingCollectionFirstTime{
                    bookNowVc.loadingCollectionFirstTime = false
                    let count = self.outOfDropZoneText_lbl.getNumberofLines()
                    self.outOfDtextLabel_height.constant = CGFloat(count * 25)
                    bookNowVc.layout.itemSize = CGSize(width: bookNowVc.pauseRentalCollectionView.frame.width - 40, height: 265 + self.outOfDtextLabel_height.constant)
                    bookNowVc.pauseRentalCollectionView_height.constant = CGFloat(bookNowVc.layout.itemSize.height + 115)
                    bookNowVc.view.layoutIfNeeded()
                }
                bookNowVc.loadUI()
            }else if self.vc is LocationListingViewController{
                let count = self.outOfDropZoneText_lbl.getNumberofLines()
                self.outOfDtextLabel_height.constant = CGFloat(count * 30)
                self.runningRentalView.layout.itemSize = CGSize(width: self.runningRentalView.collectionView.frame.width - 40, height: 265 + self.outOfDtextLabel_height.constant)
                self.runningRentalView.collectionView_height.constant = CGFloat(self.runningRentalView.layout.itemSize.height)
                self.runningRentalView.runningRentalContainerView_bottom.constant = -15 //self.runningRentalView.runningRentalContainerView.frame.size.height
                self.runningRentalView.runningRentalContainerView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.runningRentalView.loadUI()
                    UIView.animate(withDuration: 0.5) {
                        self.runningRentalView.frame.origin.y = 0
                        self.runningRentalView.layoutIfNeeded()
                    } completion: { (_) in
                    }
                }
            }
            
            self.pauseOrStartBtn_img.circleObject()
            self.endBtn_img.circleObject()
            self.cardListTableView.reloadData()
        }
        
    }
    
    func startTimer(dataDictionary: [String:Any]){
        
        let startTime = (dataDictionary["start_time"]as? String ?? "").changeStringToDate(enterFormat: "yyyy-MM-dd HH:mm:ss")
        var endTime = Date()
        if Singleton.endTime == ""{
            endTime = (dataDictionary["end_time"]as? String ?? "").changeStringToDate(enterFormat: "yyyy-MM-dd HH:mm:ss")
        }else{
            endTime = Singleton.endTime.changeStringToDate(enterFormat: "yyyy-MM-dd HH:mm:ss")
        }
        
        var hours = endTime.hoursFrom(startTime)
        var minute = endTime.minutesFrom(startTime)
        var seconds = endTime.secondsFrom(startTime)
//        var h = 0
        var m = 0
        var s = 0
        if Singleton.timerArray.count > 0{
            (Singleton.timerArray[self.tag]).invalidate()
            if !Singleton.timerArray[self.tag].isValid{
                Singleton.timerArray[self.tag] = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
                    seconds += 1
                    minute = seconds / 60
                    hours = seconds / 3600
                    
                    if (minute / 60) >= 1{
                        m = minute % 60
                    }else{
                        m = minute
                    }
                    if (seconds / 60) >= 1{
                        s = seconds % 60
                    }else{
                        s = seconds
                    }
                    if hours < 10{
                        if m < 10{
                            if s < 10{
                                self.timer_lbl.text = "0\(hours):0\(m):0\(s)"
                            }else{
                                self.timer_lbl.text = "0\(hours):0\(m):\(s)"
                            }
                        }else{
                            if s < 10{
                                self.timer_lbl.text = "0\(hours):\(m):0\(s)"
                            }else{
                                self.timer_lbl.text = "0\(hours):\(m):\(s)"
                            }
                        }
                    }else{
                        if m < 10{
                            if s < 10{
                                self.timer_lbl.text = "\(hours):0\(m):0\(s)"
                            }else{
                                self.timer_lbl.text = "\(hours):0\(m):\(s)"
                            }
                        }else{
                            if s < 10{
                                self.timer_lbl.text = "\(hours):\(m):0\(s)"
                            }else{
                                self.timer_lbl.text = "\(hours):\(m):\(s)"
                            }
                        }
                    }
//                    print(hours, minute, seconds)
                })
            }
        }
    }
}

extension PauseRentalCollectionCell: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.numberOfCards.count - 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.cardListTableView.contentSize.height < 100{
            self.cardListTableView.frame.size.height = self.cardListTableView.contentSize.height
            self.cardListTableView.isScrollEnabled = false
        }else{
            self.cardListTableView.frame.size.height = 100
            self.cardListTableView.isScrollEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.cardListTableView.dequeueReusableCell(withIdentifier: "CardsListCell")as! CardsListCell
        
        let cardDetail = Singleton.numberOfCards[indexPath.row + 1]
        let checkCardType = String(describing: cardDetail["cardType"]!)
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
        cell.cardNumber_lbl.text = "xxxx    xxxx    xxxx    \((cardDetail["card_number"] as? String ?? "").suffix(4))"
        if indexPath.row == 0{
            self.runningRentalView.selectedCard = cardDetail
            self.runningRentalView.cardSelected = 1
            cell.containerView.backgroundColor = CustomColor.primaryColor
            cell.cardNumber_lbl.textColor = UIColor.white
        }else{
            cell.containerView.backgroundColor = UIColor.white
            cell.cardNumber_lbl.textColor = UIColor.darkGray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let bookNowVc = self.vc as? BookNowVC{
            bookNowVc.changeCard_Web(payment_id: Singleton.runningRentalArray[0]["id"]as? String ?? "", cardToken: Singleton.numberOfCards[(indexPath.row + 1)]["token_id"]as? String ?? "", index: (indexPath.row))
        }else if self.vc is LocationListingViewController{
            self.runningRentalView.changeCard_Web(payment_id: Singleton.runningRentalArray[0]["id"]as? String ?? "", cardToken: Singleton.numberOfCards[indexPath.row + 1]["token_id"]as? String ?? "", index: (indexPath.row))
        }
        
        let temp = Singleton.numberOfCards[0]
        let item2 = Singleton.numberOfCards[indexPath.row + 1]
         
        if indexPath.row + 1 == Singleton.numberOfCards.count - 1 {
            Singleton.numberOfCards.remove(at: indexPath.row + 1)
            Singleton.numberOfCards.remove(at: 0)
            Singleton.numberOfCards.insert(item2, at: 0)
            Singleton.numberOfCards.append(temp)
        }else{
            Singleton.numberOfCards.remove(at: indexPath.row + 1)
            Singleton.numberOfCards.remove(at: 0)
            Singleton.numberOfCards.insert(item2, at: 0)
            Singleton.numberOfCards.insert(temp, at: indexPath.row + 1)
        }
        
        let cardDetail = Singleton.numberOfCards[0]
        self.cardNum_lbl.text = "xxxx    xxxx    xxxx    \((cardDetail["card_number"] as? String ?? "").suffix(4))"
        self.cardListTableView.reloadData()
    }
    
}

