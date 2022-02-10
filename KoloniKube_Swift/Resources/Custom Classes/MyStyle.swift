//
//  MyStyle.swift
//  KoloniKube_Swift
//
//  Created by Tops on 20/11/19.
//  Copyright © 2019 Self. All rights reserved.
//

import Foundation
import GradientCircularProgress

public struct MyStyle : StyleProperty {
    /*** style properties **********************************************************************************/
    
    // Progress Size
    public var progressSize: CGFloat = 80
    
    // Gradient Circular
    public var arcLineWidth: CGFloat = 8
    public var startArcColor: UIColor = UIColor.white.withAlphaComponent(0.9)
    public var endArcColor: UIColor = UIColor.lightGray//UIColor.white.withAlphaComponent(0.5)
    
    // Base Circular
    public var baseLineWidth: CGFloat? = 8
    public var baseArcColor: UIColor? = UIColor.lightGray
    
    // Ratio
    public var ratioLabelFont: UIFont? = UIFont(name: "Avenir Next-Regular", size: 16.0)
    public var ratioLabelFontColor: UIColor? = UIColor.white
    
    // Message
    public var messageLabelFont: UIFont? = UIFont.systemFont(ofSize: 16.0)
    public var messageLabelFontColor: UIColor? = UIColor.white
    
    // Background
    public var backgroundStyle: BackgroundStyles = .transparent
    
    // Dismiss
    public var dismissTimeInterval: Double? = 0.0 // 'nil' for default setting.
    
    /*** style properties **********************************************************************************/
    
    public init() {}
}
