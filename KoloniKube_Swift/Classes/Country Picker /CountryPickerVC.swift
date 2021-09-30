//
//  CountryPickerViewController.swift
//  KoloniKube_Swift
//
//  Created by Tops on 04/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import UIKit
import CountryPickerView

protocol CountryPickerDelegate {
    func countryCodePicker(flag: UIImage, countryCode: String, phoneCode: String)
}

class CountryPickerVC: UIViewController {
    
    @IBOutlet weak var search_textField: UITextField!
    @IBOutlet weak var countryPickerView: CountryPickerView!
    @IBOutlet weak var countryListTableView: UITableView!
    
    //Private variable
    fileprivate var countries: [Country] = []
    fileprivate var sectionsTitles = [String]()
    
    //Variables
    var countryPickerDelegate: CountryPickerDelegate!
    
    //MARK: - Default Function's
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .coverVertical
        self.loadContent()
        self.registerTableCell()
    }
    
    //MARK: - @IBAction's
    @IBAction func tapCrossBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Custom Function's
    func loadContent(){
        self.search_textField.delegate = self
        self.search_textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        self.countries = countryPickerView.countries
    }
    
    func registerTableCell(){
        self.countryListTableView.register(UINib(nibName: "CountryCodeListCell", bundle: nil), forCellReuseIdentifier: "CountryCodeListCell")
        self.countryListTableView.tableFooterView = UIView()
    }
    
}

//MARK: - TextField Delegate's
extension CountryPickerVC: UITextFieldDelegate{
    
    @objc func textFieldEditingChanged(_ textField: UITextField){
        print(textField.text!)
        if textField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            self.countries = countryPickerView.countries.filter({$0.name.lowercased().contains(textField.text!.lowercased())})
            self.countryListTableView.reloadData()
        }else{
            self.countries = countryPickerView.countries
            self.countryListTableView.reloadData()
        }
    }
    
}

//MARK: - TableView Delegate's
extension CountryPickerVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.countryListTableView.dequeueReusableCell(withIdentifier: "CountryCodeListCell")as! CountryCodeListCell
        let country = countries[indexPath.row]
        let name = country.localizedName() ?? country.name
        cell.countryNameAndCode_lbl.text = "\(name) (\(country.code))"
        cell.phoneCode_lbl.text = country.phoneCode
        cell.flag_Img.image = country.flag
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let country = countries[indexPath.row]
        print(country)
        self.countryPickerDelegate.countryCodePicker(flag: country.flag, countryCode: country.code, phoneCode: country.phoneCode)
        self.dismiss(animated: true, completion: nil)
    }
}
