// Playground - noun: a place where people can play

import UIKit

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
    
    class func parse(dateStr:String, format:String="yyyy-MM-dd") -> NSDate {
        var dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.dateFromString(dateStr)!
    }
}

let date1 = Date.from(year: 2014, month: 05, day: 20, hour: 12, minute: 25, second:5)
let date2 = Date.from(year: 2014, month: 05, day: 20, hour: 12, minute: 25, second:15)

let ti: NSTimeInterval = date1.timeIntervalSinceDate(date2)



