//
//  DateTimePicker.swift
//  KoloniPartner
//
//  Created by Sahil Mehra on 4/3/20.
//  Copyright © 2020 Sahil Mehra. All rights reserved.
//

import UIKit

protocol DateTimePickerDelegate {
    func selectedDateTime(value: String)
}

//enum picker_type{
//    case date
//    case time
//}

class DateTimePicker: UIView {

    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var picker: UIDatePicker!
    
    var delegate: DateTimePickerDelegate?    
    var format = ""
    
    //MARK: - @IBAction's
    @IBAction func tapCancelBtn(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.3, animations: {
            self.pickerContainerView.frame.origin.y += self.pickerContainerView.frame.height
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func tapDoneBtn(_ sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.format
        let dateTimeString = dateFormatter.string(from: picker.date)
        print(dateTimeString)
        self.delegate?.selectedDateTime(value: dateTimeString)
        UIView.animate(withDuration: 0.3, animations: {
            self.pickerContainerView.frame.origin.y += self.pickerContainerView.frame.height
        }) { (_) in
            self.removeFromSuperview()
        }
    }

    func setupDatePicker(maximumYear: Int){
        let currentDate = Date()
        let calender = Calendar(identifier: .gregorian)
        var component = DateComponents()
        component.calendar = calender
        component.year = maximumYear
        let max_date = calender.date(byAdding: component, to: currentDate)
        self.picker.maximumDate = max_date
    }
}

extension UIViewController{
    ///max_date_year - Give max date year in minues form. If you want to set maximun date year 2000 then minues the number of year from the current date.
    func loadDateTimePickerView(mode: UIDatePicker.Mode, date_format: String, max_date_year: Int){
        
        let pickerView = Bundle.main.loadNibNamed("DateTimePicker", owner: nil, options: [:])?.first as? DateTimePicker
        pickerView?.pickerContainerView.shadow(color: .lightGray, radius: 4, opacity: 0.5)
        pickerView?.frame = self.view.bounds
        pickerView?.delegate = self as? DateTimePickerDelegate
        pickerView?.picker.datePickerMode = mode
        pickerView?.format = date_format
        pickerView?.setupDatePicker(maximumYear: max_date_year)
        pickerView?.pickerContainerView.frame.origin.y += pickerView!.pickerContainerView.frame.height
        self.view.addSubview(pickerView!)
        UIView.animate(withDuration: 0.3) {
            pickerView?.pickerContainerView.frame.origin.y -= pickerView!.pickerContainerView.frame.height
        }
    }
    
}

extension UIView{
    
    func loadDateTimePickerViewOnView(mode: UIDatePicker.Mode, date_format: String){
        
        let pickerView = Bundle.main.loadNibNamed("DateTimePicker", owner: nil, options: [:])?.first as? DateTimePicker
        pickerView?.pickerContainerView.shadow(color: .lightGray, radius: 4, opacity: 0.5)
        pickerView?.frame = self.bounds
        pickerView?.delegate = self as? DateTimePickerDelegate
        pickerView?.picker.datePickerMode = mode
        pickerView?.format = date_format
        pickerView?.pickerContainerView.frame.origin.y += pickerView!.pickerContainerView.frame.height
        self.addSubview(pickerView!)
        UIView.animate(withDuration: 0.3) {
            pickerView?.pickerContainerView.frame.origin.y -= pickerView!.pickerContainerView.frame.height
        }
    }
    
}
