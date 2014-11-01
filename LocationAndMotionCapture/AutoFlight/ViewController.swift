//
//  ViewController.swift
//  AutoFlight
//
//  Created by Igor Kantor on 9/26/14.
//  Copyright (c) 2014 Igor Kantor. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var label: UILabel!
    var locationManager: CLLocationManager!
    var currentHeading: CLLocationDirection!
    var currentLocation: CLLocation!
    var relativeAltitude: NSNumber = 0
    var pressure: NSNumber = 0
    
    
    let motionManager: CMMotionManager = CMMotionManager()
    let altimeter: CMAltimeter = CMAltimeter()
    var currentAcceleration: CMAcceleration = CMAcceleration(x:0.0, y:0.0, z:0.0)
    var currentRotationRate: CMRotationRate = CMRotationRate(x:0.0, y:0.0, z:0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.startSensorUpdates()
        
//        self.testDb()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("postData"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    func startSensorUpdates()
    {
        if(self.locationManager == nil)
        {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
        }
        
        
        
        if(CLLocationManager.headingAvailable())
        {
            self.locationManager.headingFilter = kCLHeadingFilterNone
            self.locationManager.startUpdatingHeading()
        }
        
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        
        
        self.motionManager.accelerometerUpdateInterval = 1;
        

        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { data, error in
                if error == nil {
                    self.relativeAltitude = data.relativeAltitude
                    self.pressure = data.pressure
                }
            })
        }
        
        self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {data, error in
            if error == nil{
                self.currentAcceleration = data.acceleration
            }
        })
        
        self.motionManager.startGyroUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {data, error in
            if error == nil{
                self.currentRotationRate = data.rotationRate
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        if(newHeading.headingAccuracy < 0)
        {
            return
        }
        
        // Use the true heading if it is valid.
        var  theHeading = ((newHeading?.trueHeading > 0) ? newHeading?.trueHeading : newHeading?.magneticHeading);
        
        self.currentHeading = theHeading;
        self.updateSensorDisplays()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location = locations.last as CLLocation
        
        if(location.horizontalAccuracy < 0)
        {
            return
        }
        
        self.currentLocation = location
    }
    
    func updateSensorDisplays()
    {
        var headingString: String
        if(self.currentHeading != nil)
        {
            headingString = "Heading: \(floor(self.currentHeading)) \n"
        }
        else
        {
            headingString = "Heading Not Available \n"
        }
        
        
        var locationString: String
        var altitudeString: String
        var speedString: String
        var locationAccuracyString: String
        var verticalAccuracyString: String
        
        if(self.currentLocation != nil)
        {
            locationString = "Location: \(self.currentLocation.coordinate.latitude) \n\t\t\t \(self.currentLocation.coordinate.longitude) \n"
            altitudeString = "Altitude: \(floor(self.currentLocation.altitude)) \n"
            speedString = "Speed: \(self.currentLocation.speed) \n"
            locationAccuracyString = "Location Accuracy: \(self.currentLocation.horizontalAccuracy) \n"
            verticalAccuracyString = "Vertical Accuracy: \(self.currentLocation.verticalAccuracy) \n"
        }
        else
        {
            locationString = "Location Not Available \n"
            altitudeString = "Altitude Not Available \n"
            speedString = "Speed Not Available \n"
            locationAccuracyString = ""
            verticalAccuracyString = ""
        }
        
        self.label.text = headingString + locationString + altitudeString + speedString + locationAccuracyString + verticalAccuracyString
    }
    
    
    
    func postData()
    {
        if(self.currentLocation != nil && self.currentHeading != nil)
        {
            let currentHeading = self.currentHeading
            let latitude = self.currentLocation.coordinate.latitude
            let longitude = self.currentLocation.coordinate.longitude
            let altitude = self.currentLocation.altitude
            let speed = self.currentLocation.speed
            let locationAccuracy = self.currentLocation.horizontalAccuracy
            let verticalAccuracy = self.currentLocation.verticalAccuracy
            let device = UIDevice.currentDevice()
            let deviceId = device.identifierForVendor.UUIDString
            let battLevel = device.batteryLevel
            let battState = device.batteryState.toRaw()
            let relativeAltitude = self.relativeAltitude
            let pressure = self.pressure
            let accelerationX = self.currentAcceleration.x
            let accelerationY = self.currentAcceleration.y
            let accelerationZ = self.currentAcceleration.z
            let rotationX = self.currentRotationRate.x
            let rotationY = self.currentRotationRate.y
            let rotationZ = self.currentRotationRate.z
            
            var deviceData = [
                "currentHeading": currentHeading,
                "latitude" : latitude,
                "longitude" : longitude,
                "altitude" : altitude,
                "speed" : speed,
                "locationAccuracy" : locationAccuracy,
                "verticalAccuracy" : verticalAccuracy,
                "deviceId" : deviceId,
                "battLevel" : battLevel,
                "battState" : battState,
                "relativeAltitude" : relativeAltitude,
                "pressure" : pressure,
                "accelerationX" : accelerationX,
                "accelerationY" : accelerationY,
                "accelerationZ" : accelerationZ,
                "rotationX" : rotationX,
                "rotationY" : rotationY,
                "rotationZ" : rotationZ
            ]

            postDeviceData(deviceData)
            putRecordInLocalDb(deviceData)
        }
    }

    func postDeviceData(deviceData: NSDictionary )
    {
//        let url = NSURL(string: "http://10.0.0.7:3000/items")
        let url = NSURL(string: "http://54.183.73.223/items")
        let request = NSMutableURLRequest(URL: url)
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
    
    func putRecordInLocalDb(deviceData:NSDictionary){
        
        var manager = CBLManager.sharedInstance()
        
        var error: NSError?
        var db = manager.databaseNamed("records", error: &error)
        if (error != nil) {
            println(error)
        }
        
        
        var doc = db.createDocument()
        
        var putError: NSError?
        doc.putProperties(deviceData, error: &putError)
        if (putError != nil) {
            println(putError)
        }
        else
        {
            println("Saved \(deviceData)")
        }
    }
}


