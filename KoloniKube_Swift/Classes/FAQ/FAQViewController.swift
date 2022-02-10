//
//  FAQViewController.swift
//  KoloniKube_Swift
//
//  Created by Tops on 09/12/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var menuOrBack_btn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var search_txtField: UITextField!
    @IBOutlet weak var searchIcon_Img: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rippleView: UIView!
    @IBOutlet weak var btnGift: IPAutoScalingButton!
    @IBOutlet weak var referralCount_lbl: UILabel!
    
    //Local Variable's
    var faqCell: FaqTableCell?
    var faqDataModelArray: [FAQDataModel] = []
    var btnTagArray: [Int] = []
    var showLoader = true
    var type = "0"    //0 - Normal, 1 - Dropzone.
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNavigationView()
        self.loadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.faqDataModelArray.removeAll()
        self.tableView.reloadData()
        self.getFaqData_Web(text: "")
        self.referralCount_lbl.text = Singleton.numberOfReferralRides
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.addUnderLine(color: .lightGray)
        self.referralCount_lbl.circleObject()
    }
    
    //MARK: - @IBAction's
    @IBAction func tapMenuBtn(_ sender: UIButton) {
        if sender.tag == 0{
            self.sideMenuViewController?.presentLeftMenuViewController()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnGiftClick(_ sender: UIButton) {
        self.loadShareRefferView()
    }
    
    @IBAction func tapSearchCloseBtn(_ sender: UIButton) {
        
        if self.searchIcon_Img.tag == 0{
            self.searchIcon_Img.tag = 1
            self.searchIcon_Img.setImage(CustomImages.closeImg?.sd_tintedImage(with: .lightGray), for: .normal)
            self.search_txtField.becomeFirstResponder()
        }else{
            self.searchIcon_Img.tag = 0
            self.searchIcon_Img.setImage(CustomImages.searchImg?.sd_tintedImage(with: .lightGray), for: .normal)
            self.search_txtField.endEditing(true)
        }
        
    }
    
    //MARK: - Custom Function's
    
    func loadContent(){
        self.search_txtField.delegate = self
        self.search_txtField.addTarget(self, action: #selector(textFieldEditingChanges(_:)), for: .editingChanged)
        self.tableView.register(UINib(nibName: "FaqTableCell", bundle: nil), forCellReuseIdentifier: "FaqTableCell")
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if self.type == "1"{
            self.menuOrBack_btn.tag = 1
            self.menuOrBack_btn.setTitle("", for: .normal)
        }else{
            self.menuOrBack_btn.tag = 0
            self.menuOrBack_btn.setTitle("", for: .normal)
        }
    }
    
    func loadNavigationView(){        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    //MARK: - Web Api's
    
    func getFaqData_Web(text: String){
        
        let paramer: NSMutableDictionary = NSMutableDictionary()
        paramer.setValue(text, forKey: "keyword")
        paramer.setValue("\(appDelegate.getCurrentAppVersion)", forKey: "ios_version")
        paramer.setValue(self.type, forKey: "type")
        
        APICall.shared.postWeb("faq_question_answer", parameters: paramer, showLoder: self.showLoader, successBlock: { (receivedData) in
            print(receivedData)
            self.faqDataModelArray.removeAll()
            if let flag = (receivedData as! [String:Any])["FLAG"]as? Int, flag == 1{
                if let array = (receivedData as! [String:Any])["faq_master"]as? [[String:Any]]{
                    self.faqDataModelArray = self.parseFaqData(array: array)
                    for _ in 0..<array.count{
                        self.btnTagArray.append(0)
                    }
                }
                self.tableView.reloadData()
            }else{}
        }) { (error) in
            print(error)
        }
        
    }
    
}

//MARK: - UITextField Delegate's
extension FAQViewController: UITextFieldDelegate{
    
    //MARK: Text Field Delegates.
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.searchIcon_Img.tag = 1
        self.searchIcon_Img.setImage(CustomImages.closeImg?.sd_tintedImage(with: .lightGray), for: .normal)
    }
    
    @objc func textFieldEditingChanges(_ textField: UITextField){
        self.showLoader = false
        if textField.isEmptyTextField(){
            self.getFaqData_Web(text: "")
            self.searchIcon_Img.tag = 0
            self.searchIcon_Img.setImage(CustomImages.searchImg?.sd_tintedImage(with: .lightGray), for: .normal)
        }else{
            self.getFaqData_Web(text: textField.text!)
            self.searchIcon_Img.tag = 1
            self.searchIcon_Img.setImage(CustomImages.closeImg?.sd_tintedImage(with: .lightGray), for: .normal)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isEmptyTextField(){
            textField.placeholder = "Search memberships"
            
        }
        self.searchIcon_Img.tag = 0
        self.searchIcon_Img.setImage(CustomImages.searchImg?.sd_tintedImage(with: .lightGray), for: .normal)
    }
    
}

//MARK: - UITableView Delegate's
extension FAQViewController: UITableViewDelegate, UITableViewDataSource{
    
    //MARK: Table View Delegates.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.faqDataModelArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FaqTableCell")as! FaqTableCell
        if self.faqDataModelArray.count > 0{
            let dataModel = self.faqDataModelArray[indexPath.row]
            cell.question_lbl.text = dataModel.question.html2String
            
            if self.btnTagArray[indexPath.row] == 1{
                cell.answer_lbl.text = dataModel.answer.html2String
                cell.arrow_btn.setImage(CustomImages.downArrowImg, for: .normal)
            }else{
                cell.answer_lbl.text = ""
                cell.arrow_btn.setImage(CustomImages.rightArrowImg, for: .normal)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.btnTagArray[indexPath.row] == 0{
            self.btnTagArray[indexPath.row] = 1
        }else{
            self.btnTagArray[indexPath.row] = 0
        }
        self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
    }
    
}
