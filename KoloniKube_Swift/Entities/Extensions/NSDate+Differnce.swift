//
//  NSDate+Differnce.swift
//  Lyst
//
//  Created by Tops on 4/18/16.
//  Copyright © 2016 Tops. All rights reserved.
//

import Foundation

extension Date {
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))hh"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))mm" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
    
    func isOnThisMonth(_ dateToCompare: Date) -> Bool {
        let calendar: Calendar = Calendar.current
        let today: Date = Date()
        let todaysWeek: Int = (calendar as NSCalendar).components(NSCalendar.Unit.month, from: today).month!
        let dateToCompareWeek: Int = (calendar as NSCalendar).components(.month, from: dateToCompare).month!
        let todaysYear: Int = (calendar as NSCalendar).components(NSCalendar.Unit.year, from: today).year!
        let dateToCompareYear: Int = (calendar as NSCalendar).components(NSCalendar.Unit.year, from: dateToCompare).year!
        if todaysWeek == dateToCompareWeek && todaysYear == dateToCompareYear {
            return true
        }
        return false
    }
    
    func isOnThisWeek(_ dateToCompare: Date) -> Bool {
        let calendar: Calendar = Calendar.current
        let today: Date = Date()
        let todaysWeek: Int = (calendar as NSCalendar).components(NSCalendar.Unit.weekday, from: today).weekday!
        let dateToCompareWeek: Int = (calendar as NSCalendar).components(.weekday, from: dateToCompare).weekday!
        let todaysYear: Int = (calendar as NSCalendar).components(NSCalendar.Unit.year, from: today).year!
        let dateToCompareYear: Int = (calendar as NSCalendar).components(NSCalendar.Unit.year, from: dateToCompare).year!
        if todaysWeek == dateToCompareWeek && todaysYear == dateToCompareYear {
            return true
        }
        return false
    }
    
    func dateStringWithFormat(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func DateAddDays(_ days:Int) -> Date {
        var dayComponenet = DateComponents()
        dayComponenet.day = days
        let theCalendar = Calendar.current
        return (theCalendar as NSCalendar).date(byAdding: dayComponenet, to: self, options: NSCalendar.Options(rawValue: UInt(0)))!
    }
}
