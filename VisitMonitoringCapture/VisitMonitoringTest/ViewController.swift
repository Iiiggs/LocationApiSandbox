//
//  ViewController.swift
//  VisitMonitoringTest
//
//  Created by Igor Kantor on 10/28/14.
//  Copyright (c) 2014 Igor Kantor. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var dateFormatter = NSDateFormatter()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm:ss"
        
        startMonitoringVisits()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startMonitoringVisits()
    {
        if(self.locationManager == nil)
        {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startMonitoringVisits()
        }
    }
    
    func doubleToString(degrees:Double) -> NSString
    {
        return NSNumber(double: degrees).stringValue
//        return [[NSNumber numberWithDouble:degrees] stringValue];
    }
    
    func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {

        let visitDict: [String: String] = [ "latitude": doubleToString(visit.coordinate.latitude),
                                            "longitude": doubleToString(visit.coordinate.longitude),
                                            "horizontalAccuracy": doubleToString(visit.horizontalAccuracy),
                                            "arrivalDate": dateFormatter.stringFromDate(visit.arrivalDate),
                                            "departureDate": dateFormatter.stringFromDate(visit.departureDate)]
        
        postData(visitDict)
    }

    func postData(deviceData: NSDictionary )
    {
        //        let url = NSURL(string: "http://10.0.0.7:3000/items")
        let url = NSURL(string: "http://54.183.73.223/visits")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(deviceData, options: NSJSONWritingOptions(0), error: &err)
        
        let now = NSDate()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            if(error != nil)
            {
                //                println("Error posting \(error)")
            }
            if(response != nil)
            {
                //                println("Response: \(response)")
            }
            if(data != nil)
            {
                //                println("Data: \(NSString(data:data, encoding:NSUTF8StringEncoding))")
            }
        }
    }


}

