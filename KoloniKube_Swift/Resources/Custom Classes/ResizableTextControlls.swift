//
//  ResizableTextControlls.swift
//  ResizableController
//
//  Created by Tops on 30/09/19.
//  Copyright © 2019 Tops. All rights reserved.
//

import Foundation

open class EZLabel: UILabel {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.changeFontName()
    }
    
    open func changeFontName()
    {
        let family = self.font.fontName
        let size = self.getDeviceSpecificFontSize_2(self.font!.pointSize)
        self.font = UIFont(name: family, size: size)
//        print("Change Font Name:", size)
    }
    
    open func getDeviceSpecificFontSize_2(_ fontsize: CGFloat) -> CGFloat {
        return ((UIScreen.main.bounds.size.width) * fontsize) / 300
    }
}

open class EZButton: UIButton {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        changeFontName()
    }
    
    func changeFontName()
    {
        let family = self.titleLabel?.font.fontName//familyName
        let size = getDeviceSpecificFontSize_2(self.titleLabel!.font.pointSize)
        self.titleLabel?.font = UIFont(name: family!, size: size)
        
    }
    
    func getDeviceSpecificFontSize_2(_ fontsize: CGFloat) -> CGFloat {
        return ((UIScreen.main.bounds.size.width) * fontsize) / 300
    }
    
}

open class EZTextView: UITextView {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        changeFontName()
    }
    
    func changeFontName()
    {
        let family = self.font?.fontName//familyName
        let size = getDeviceSpecificFontSize_2(self.font!.pointSize)
        self.font = UIFont(name: family!, size: size)
    }
    
    func getDeviceSpecificFontSize_2(_ fontsize: CGFloat) -> CGFloat {
        return ((UIScreen.main.bounds.size.width) * fontsize) / 300
    }
}

open class EZTextField: UITextField {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        changeFontName()
    }
    
    func changeFontName()
    {
        let family = self.font?.fontName//familyName
        let size = getDeviceSpecificFontSize_2(self.font!.pointSize)
        self.font = UIFont(name: family!, size: size)
    }
    
    func getDeviceSpecificFontSize_2(_ fontsize: CGFloat) -> CGFloat {
        return ((UIScreen.main.bounds.size.width) * fontsize) / 300
    }
    
}
