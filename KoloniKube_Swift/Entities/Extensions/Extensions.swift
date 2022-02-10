//
//  Extensions.swift
//  KoloniKube_Swift
//
//  Created by Tops on 19/09/19.
//  Copyright © 2019 Self. All rights reserved.
//

import Foundation
import UIKit
import PhoneNumberKit

extension UIView{
    
    func animateView(){
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
}

extension Date {
    
    func timeInterval(fromDate date: Date) -> DateComponents {
        
        _ = Calendar.current
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let differenceOfDate = Calendar.current.dateComponents(components, from: date, to: self)
        return differenceOfDate
    }
}

extension String{
    
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    func changeStringToDate(enterFormat: String)-> Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = enterFormat
        return dateFormatter.date(from: self)!
        
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension UIViewController{
    
    func alert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertBox(_ title: String,_ str: String,outputBlock: @escaping()-> Void){
        let alert = UIAlertController(title: title, message: str, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            outputBlock()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithOkAndCancelBtn(_ title: String, _ str: String, yesBtn_title: String, noBtn_title: String, outputBlock: @escaping(_ button: String)-> Void){
        
        let alert = UIAlertController(title: title, message: str, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: yesBtn_title, style: .default, handler: { (_) in
            outputBlock("ok")
        }))
        alert.addAction(UIAlertAction(title: noBtn_title, style: .cancel, handler: { (_) in
            outputBlock("cancel")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertWithOkTitle(title: String, message: String, btnTitle: String, outputBlock: @escaping(_ response: Bool)-> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: btnTitle, style: .default, handler: { (_) in
            outputBlock(true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithTextField(outputBlock: @escaping(_ response: String)->Void){
        let alertVc = UIAlertController(title: "", message: "Enter 4 digit code to lock and open the lock", preferredStyle: .alert)
        alertVc.addTextField { (textField) in
            textField.placeholder = "Enter 4 digit code"
            textField.keyboardType = .numberPad
        }
        
        let saveBtn = UIAlertAction(title: "Save", style: .default) { (_) in
            outputBlock((alertVc.textFields![0] as UITextField).text ?? "1234")
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            outputBlock("")
        }
        
        alertVc.addAction(saveBtn)
        alertVc.addAction(cancelBtn)
        self.present(alertVc, animated: true, completion: nil)
    }
    
}

extension UITextField{
    
    func isEmptyTextField() -> Bool {
        
        guard let _ = self.text, !self.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else{
            //return true if text field is emplty
            return true
        }
        
        return false
    }
    
    func isContainsCharacters() -> Bool {
        let characterset = CharacterSet(charactersIn: "0123456789")
        if self.text!.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        }else{
            return false
        }
    }
    
    func isContainNumber() -> Bool{
        let decimalCharacters = CharacterSet.decimalDigits
        let decimalRange = self.text!.rangeOfCharacter(from: decimalCharacters)
        if decimalRange != nil {
            return true
        }else{
            return false
        }
    }
    
    func isContainOnlyNumber() -> Bool{
        let characterset = CharacterSet(charactersIn: "0123456789")
        if self.text!.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        }else{
            return false
        }
    }
    
    func isValidUsername() -> Bool {
        
        return self.text!.range(of: "\\A\\w{6,14}\\z", options: .regularExpression) != nil
        
    }
    
    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text!)
    }
    
}

extension String{
    
    func isContainOnlyNumber() -> Bool{
        let characterset = CharacterSet(charactersIn: "0123456789")
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }else{
            return true
        }
    }
    
    func isEmptryString() -> Bool{
        
        return self.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? true:false
    
    }
    
}

extension UIView{
    
    func addUnderLine(color: UIColor){
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        self.layer.addSublayer(border)
    }
    
    func createGradientLayer(color1: UIColor, color2: UIColor, startPosition: CGFloat, endPosition: CGFloat) {
        
        let gradientLayer = CAGradientLayer()
        //        gradientLayer.frame = self.bounds
        gradientLayer.frame.size.height = self.frame.height
        gradientLayer.frame.size.width = self.frame.width * 2
        gradientLayer.colors = [color1.cgColor,color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: startPosition, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: endPosition/2, y: 0.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    func createGradientLayerForLeftMenu(color1: UIColor, color2: UIColor, startPosition: CGFloat, endPosition: CGFloat) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size.height = self.frame.height
        gradientLayer.frame.size.width = self.frame.width * 2
        gradientLayer.colors = [color1.cgColor,color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: startPosition, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: endPosition/2, y: 0.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    func shadow(color: UIColor, radius: CGFloat, opacity: Float){
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0,height: 0)
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
    }
    
    //MARK: Remove Shadow
    
    func removeShadow(Outlet : AnyObject) {
        
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 0
        self.layer.shadowColor = UIColor.white.cgColor
        
    }
    
    //MARK: To Round Onject
    
    func circleObject(){
        
        self.layer.cornerRadius = self.layer.frame.size.height/2
        self.layer.masksToBounds = true
        
    }
    
    //MARK: Set Border
    
    func setBorder(border_width: CGFloat,border_color: UIColor){
        
        self.layer.borderWidth = border_width
        self.layer.borderColor = border_color.cgColor
        
    }
    
    func removeBorder(){
        
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    //MARK: Set Corner Radious
    
    func cornerRadius(cornerValue: Int){
        
        self.layer.cornerRadius = CGFloat(cornerValue)
        self.layer.masksToBounds = true
        
    }
    
    
    func setCornerRadius(_ isTopLeft: Bool = false,_ isTopRight: Bool = false,_ isBootmLeft: Bool = false,_ isBottomRight: Bool = false,_ radius: CGSize = CGSize(width: 10, height: 10)){
        
        let layer = CAShapeLayer()
        layer.bounds = self.frame
        layer.position = self.center
        layer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: radius).cgPath
        self.layer.mask = layer
        
    }
    
    func applyGradient() -> Void {
        let colours = [UIColor(red: 139/255, green: 234/255, blue: 224/255, alpha: 1.0),UIColor(red: 44/255, green: 173/255, blue: 114/255, alpha: 1.0)]
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.addSublayer(gradient)
    }
}

extension CALayer {
    func addGradienBorder(colors:[UIColor],width:CGFloat = 1) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = colors.map({$0.cgColor})
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = UIBezierPath(rect: self.bounds).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        self.addSublayer(gradientLayer)
    }
    
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIViewController{
    
    func isDeviceHasSafeArea()-> Bool{
        let deviceName = UIDevice.model_name
        if deviceName == "iPhone X" || deviceName == "iPhone XS" || deviceName == "iPhone XS Max" || deviceName == "iPhone XR" || deviceName == "iPhone 11" || deviceName == "iPhone 11 Pro" || deviceName == "iPhone 11 Pro Max"{
            return true
        }else{
            return false
        }
    }
    
    func isValidPhoneNumber(_ number: String)-> Bool{
        let phoneNumberKit = PhoneNumberKit()
        do{
            let phoneNumber = try phoneNumberKit.parse(number)
            let result = phoneNumberKit.format(phoneNumber, toType: .international, withPrefix: false)
            print("Result: ", result)
            return true
        }catch{
            return false
        }
    }
    
}

extension UIViewController{
    func generate4DigitRandomCode()-> Int{
        let digits = 0...9
        let shuffledDigits = digits.shuffled()
        let fourDigits = shuffledDigits.prefix(4)
        let value = fourDigits.reduce(0) {
            $0*10 + $1
        }
        return value
    }
}

extension UIView{
    func animShow(){
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.center.y -= self.bounds.height
                        self.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    func animHide(){
        UIView.animate(withDuration: 0, delay: 0, options: [.curveLinear],
                       animations: {
                        self.center.y += self.bounds.height
                        self.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            self.isHidden = true
        })
    }
}

extension UIDevice {
    
    static let model_name: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}

extension UIWindow{
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "Ok", style: .default) { (_) in
            
        }
        alert.addAction(okBtn)
        self.makeKeyAndVisible()
        self.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            var hexColor = String(hex[start...])
            hexColor = "0x\(hexColor)"
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000FF) / 255
                    a = 1.0

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

extension UIImage {
    
    func fixOrientation() -> UIImage {
        
        if self.imageOrientation == UIImage.Orientation.up {
            
            return self
            
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return normalizedImage;
        
    }
}

extension UIViewController{
    
    func checkLocationService()-> Bool{
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")                
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                return true
            @unknown default:
                break
            }
        } else {
            print("Location services are not enabled")
            return false
        }
        return false
    }
    
}

extension UILabel{
    
    func getNumberofLines()-> Int{
        var count = 0
        let textSize = CGSize(width: self.frame.width, height: CGFloat(MAXFLOAT))
        let height = self.sizeThatFits(textSize).height
        let charSize = self.font.lineHeight
        count = Int(height/charSize)
//        print("Number of lines", count)
        return count
    }
    
}

extension UITextView {
    func numberOfLines()-> Int{
        let numberOfGlyphs = self.layoutManager.numberOfGlyphs
        var index = 0, numberOfLines = 0
        var lineRange = NSRange(location: NSNotFound, length: 0)

        while index < numberOfGlyphs {
            self.layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
          index = NSMaxRange(lineRange)
          numberOfLines += 1
        }
        return numberOfLines
    }
}

extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        //let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        //let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                        // locationOfTouchInLabel.y - textContainerOffset.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }

}

extension UIButton{
    
    func fitFontSize(){
        
        self.titleLabel?.minimumScaleFactor = 0.5
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    
}
extension String {
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
}
