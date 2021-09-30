//
//  CustomRangeSeekSlider.swift
//  RangeSeekSlider
//
//  Created by Keisuke Shoji on 2017/03/16.
//
//

import UIKit

@IBDesignable final class CustomRangeSeekSlider: RangeSeekSlider {

    override func setupStyle() {
        let pink: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // greenCSS3 #008000
        let gray: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) // gray #808080

        minValue = 0
        maxValue = 100
        selectedMinValue = 0.0
        selectedMaxValue = 0.0
        minDistance = 0.0
        handleColor = pink
        minLabelColor = pink
        maxLabelColor = pink
        colorBetweenHandles = pink
        tintColor = gray
        numberFormatter.locale = Locale(identifier: "ja_JP")
        numberFormatter.numberStyle = .currency
        labelsFixed = true
        initialColor = gray

        delegate = self
    }

    fileprivate func priceString(value: CGFloat) -> String {
        let priceString: String? = numberFormatter.string(from: value as NSNumber)
        return priceString ?? ""
    }
}


// MARK: - RangeSeekSliderDelegate

extension CustomRangeSeekSlider: RangeSeekSliderDelegate {

    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        return priceString(value: minValue)
    }

    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        return priceString(value: maxValue)
    }
}
