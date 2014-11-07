//
//  extensions.swift
//  WheresIgorMap
//
//  Created by Igor Kantor on 11/1/14.
//  Copyright (c) 2014 Igor Kantor. All rights reserved.
//

import Foundation

class Date {
    class func from(#year:Int, month:Int, day:Int, hour:Int, minute:Int, second:Int) -> NSDate {
        var c = NSDateComponents()
        c.year = year
        c.month = month
        c.day = day
        c.hour = hour
        c.minute = minute
        c.second = second
        
        let gregorian: NSCalendar! = NSCalendar(identifier:NSGregorianCalendar)
        var date: NSDate! = gregorian.dateFromComponents(c)
        return date
    }

    class func parse(dateStr:String, format:String="yyyy-MM-dd 'at' HH:mm:ss") -> NSDate {
        var dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.dateFromString(dateStr)!
    }
}
//
//class Double {
//    class func parse(doubleString:String) -> Double{
//        let formatter = NSNumberFormatter()
//        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
//        let number = formatter.numberFromString(doubleString)!
//        return number.doubleValue
//    }
//}