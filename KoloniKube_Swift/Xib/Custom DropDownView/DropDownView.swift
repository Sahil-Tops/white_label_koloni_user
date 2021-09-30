//
//  DropDownView.swift
//  KoloniPartner
//
//  Created by Sahil Mehra on 2/2/21.
//  Copyright © 2021 Sahil Mehra. All rights reserved.
//

import UIKit

protocol DropDownViewDelegate {
    func selectedItem(item: String, index: Int)
}

struct CustomDropDown{
    static var dropDownView: DropDownView?
}

class DropDownView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_height: NSLayoutConstraint!
    
    var vc: UIViewController?
    var delegate: DropDownViewDelegate?
    var seprateLineColor: UIColor?
    var showSepratorOnIndex: [Int] = []
    var tableArray: [[String]] = []
    var isHasSection: Bool = false
    var showBgViewColorChange = false
    
    
    func registerTableCell(){
        self.tableView.register(UINib(nibName: "DropDownViewCell", bundle: nil), forCellReuseIdentifier: "DropDownViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func loadContent(){
//        self.cornerRadius(cornerValue: 5)
        self.shadowWithCorner(corner: 5)
    }
    
}

//MARK: - TableView Delegate's
extension DropDownView: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isHasSection{
            return self.tableArray.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DropDownViewCell")as! DropDownViewCell
        cell.title_lbl.text = self.tableArray[indexPath.section][indexPath.row]
        if indexPath.section == 0 && self.isHasSection{
            cell.title_lbl.textAlignment = .center
            cell.underLine_lbl.isHidden = false
            cell.title_lbl.alpha = 0.5
        }else{
            cell.title_lbl.textAlignment = .left
            cell.underLine_lbl.isHidden = true
            cell.title_lbl.alpha = 1.0
        }
        
        if self.showBgViewColorChange{
            cell.bgView.isHidden = false
            cell.bgView.backgroundColor = CustomColor.customLightGray
        }else{
            cell.bgView.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.isHasSection{
            self.delegate?.selectedItem(item: self.tableArray[indexPath.section][indexPath.row], index: indexPath.row)
        }else if indexPath.section > 0{
            self.delegate?.selectedItem(item: self.tableArray[indexPath.section][indexPath.row], index: indexPath.row)
        }
        self.removeFromSuperview()
    }
    
}

extension UIViewController{
    
    func loadDropDown(_ array: [[String]],_ sepratorColor: UIColor,_ showBgView: Bool = false, view_frame: CGRect)-> DropDownView{
        CustomDropDown.dropDownView?.removeFromSuperview()
        let view = Bundle.main.loadNibNamed("DropDownView", owner: nil, options: [:])?.first as! DropDownView
        if array.count > 0{
            CustomDropDown.dropDownView = view
            view.frame.origin.x = view_frame.origin.x
            view.frame.origin.y = view_frame.origin.y
            view.frame.size.width = view_frame.width
            if CGFloat(array[0].count * 40) < view.frame.height{
                view.frame.size.height = CGFloat(array[0].count * 45)
                view.tableView_height.constant = CGFloat(array[0].count * 45)
            }else{
                view.frame.size.height = view_frame.height
                view.tableView_height.constant = view_frame.height
            }
            
            view.delegate = self as? DropDownViewDelegate
            view.tableArray = array
            if array.count > 1{
                view.isHasSection = true
            }
            view.showBgViewColorChange = showBgView
            view.loadContent()
            view.registerTableCell()
            self.view.addSubview(view)
        }
        return view
    }
    
}
