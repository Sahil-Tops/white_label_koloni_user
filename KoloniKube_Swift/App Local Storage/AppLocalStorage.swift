//
//  AppStorage.swift
//  KoloniKube_Swift
//
//  Created by Sam Mehra on 02/09/21.
//  Copyright © 2021 Self. All rights reserved.
//

import AVFoundation


class AppLocalStorage{
    
    static var sharedInstance: AppLocalStorage!
    var data: [String:Any] = [:]
    
    init(){
        type(of: self).sharedInstance = self
        if let data = StaticClass.sharedInstance.retriveFromUserDefaults("application_setting")as? [String:Any]{
            self.data = data
            
            for (key, value) in data{
                print(value)
                if key.contains("_img"){
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.storeToFileManager(imgUrl: value as? String ?? "", imageName: key)
                    }
                }
            }
        }
    }
    
    var application_gradient: Bool{        
        return self.data["application_gradient"]as? String ?? "0" == "1" ? true:false
    }
    
    var user_agreement: URL?{
        return URL(string: self.data["user_agreement"]as? String ?? "")
    }
    
    var terms_condition: URL?{
        return URL(string: self.data["terms_condition"]as? String ?? "")
    }
    
    var login_popup_color: UIColor?{
        return self.data["login_popup_color"]as? String ?? "" != "" ? UIColor(hex: self.data["login_popup_color"]as? String ?? ""):.white
    }
    
    var background_img: String{
        return self.data["background_img"]as? String ?? ""
    }
    
    var flag_logo_img: String{
        return self.data["flag_logo_img"]as? String ?? ""
    }
    
    var geofence_border_color_str: String{
        return self.data["geofence_border"]as? String ?? ""
    }
    
    var geofence_color_str: String{
        return self.data["geofence_color"]as? String ?? ""
    }
    
    var geofence_affiliate_color_str: String{
        return self.data["geofence_affiliate_color"]as? String ?? ""
    }
    
    var geofence_affiliate_color: UIColor{
        return UIColor(hex: self.geofence_affiliate_color_str)!
    }
    
    var geofence_color: UIColor{
        return UIColor(hex: self.geofence_color_str)!
    }
    
    var geofence_border_color: UIColor{
        return UIColor(hex: self.geofence_border_color_str)!
    }
    
    var loader_img: String{
        return self.data["loader_img"]as? String ?? ""
    }
    
    var locker_alert_img: String{
        return self.data["locker_alert_img"]as? String ?? ""
    }
    
    var logo_img: String{
        return self.data["logo_img"]as? String ?? ""
    }
    
    var main_img: String{
        return self.data["main_img"]as? String ?? ""
    }
    
    var map_flag_img: String{
        return self.data["map_flag_img"]as? String ?? ""
    }
    
    var primary_color_str: String{
        return self.data["primary_color"]as? String ?? ""
    }
    
    var secondary_color_str: String{
        return self.data["secondary_color"]as? String ?? ""
    }
    
    var primary_color: UIColor{
        return self.primary_color_str != "" ? UIColor(hex: primary_color_str)!:CustomColor.blueColor
    }
    
    var secondary_color: UIColor{
        return self.secondary_color_str != "" ? UIColor(hex: secondary_color_str)!:CustomColor.blueColor
    }
    
    var splash_img: String{
        return self.data["splash_img"]as? String ?? ""
    }
    
    var tertiary_color: String{
        return self.data["tertiary_color"]as? String ?? ""
    }
    
    var fonts: String{
        return self.data["fonts"]as? String ?? ""
    }
    
    var logo_shape: String{
        return self.data["logo_shape"]as? String ?? ""
    }
    
    var refer_friend: String{
        return self.data["refer_friend"]as? String ?? ""
    }
    
    var sitename: String{
        return self.data["sitename"]as? String ?? ""
    }
    
    var button_color_str: String{
        return self.data["button_color"]as? String ?? ""
    }
    
    var button_text_color_str: String{
        return self.data["button_text_color"]as? String ?? ""
    }
    
    var button_color: UIColor{
        return self.primary_color_str != "" ? UIColor(hex: primary_color_str)!:CustomColor.blueColor
    }
    
    var button_text_color: UIColor{
        return self.button_text_color_str != "" ? UIColor(hex: button_text_color_str)!:.white
    }
    
    var pause_button_text: String{
        return self.data["pause_button_text"]as? String ?? "Pause"
    }
    
    var resume_button_text: String{
        return self.data["resume_button_text"]as? String ?? "Resume"
    }
    
    var end_button_text: String{
        return self.data["end_button_text"]as? String ?? "End"
    }
    
    var pause_button_color_str: String{
        return self.data["pause_button_color"]as? String ?? ""
    }
    
    var pause_button_color: UIColor{
        return self.pause_button_color_str != "" ? UIColor(hex: pause_button_color_str)!:CustomColor.customYellow
    }
    
    var end_button_color_str: String{
        return self.data["end_button_color"]as? String ?? ""
    }
    
    var end_button_color: UIColor{
        return self.end_button_color_str != "" ? UIColor(hex: end_button_color_str)!:CustomColor.customAppRed
    }
    
    var resume_button_color_str: String{
        return self.data["resume_button_color"]as? String ?? ""
    }
    
    var resume_button_color: UIColor{
        return self.resume_button_color_str != "" ? UIColor(hex: resume_button_color_str)!:CustomColor.customYellow
    }
    
    var resume_button_str: String{
        return self.data["resume_button_text"]as? String ?? ""
    }
    
    
    func storeToFileManager(imgUrl: String, imageName: String){
        DispatchQueue.main.async {
            print(imgUrl)
            if imgUrl != ""{
                if let filePath = self.filePath(forKey: imageName){
                    do{
                        let imageData = try Data(contentsOf: URL(string: imgUrl)!)
                        try imageData.write(to: filePath, options: .atomic)
                        print("Image Stored on path: ", filePath)
                    }catch let err{
                        print("Error while writing file path: ", err)
                    }
                }
            }
        }
    }
    
    func reteriveImageFromFileManager(imageName: String, outputBlock: @escaping(_ image: UIImage)-> Void){
        if let filePath = self.filePath(forKey: imageName){
            if let fileData = FileManager.default.contents(atPath: filePath.path){
                if let image = UIImage(data: fileData){
                    outputBlock(image)
                }else{
                    print("Nil image")
                }
            }else{
                print("No data")
            }
        }else{
            print("Image Path not found")
        }
    }
    
    private func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".jpeg")
    }
    
}


