//
//  ViewController.swift
//  WheresIgorMap
//
//  Created by Igor Kantor on 11/1/14.
//  Copyright (c) 2014 Igor Kantor. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let location = CLLocationCoordinate2D(
            latitude: 39.92719908390535,
            longitude: -105.1448931572472
        )
        // 2
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let visits: [Visit] = [
            Visit(
                startDate: Date.from(year: 2014, month: 11, day: 1, hour: 11, minute: 51, second: 11),
                endDate: Date.from(year: 2014, month: 11, day: 1, hour: 11, minute: 58, second: 37),
                location: CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(39.92836096335576),
                    longitude: CLLocationDegrees(-105.1392876955421)),
                accuracy:71.90446647609897,
                name: "Visit 2"),
            Visit(
                startDate: Date.from(year: 2014, month: 11, day: 1, hour: 9, minute: 18, second: 33),
                endDate: Date.from(year: 2014, month: 11, day: 1, hour: 11, minute: 44, second: 25),
                location: CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(39.92727129916211),
                    longitude: CLLocationDegrees(-105.1447143358513)),
                accuracy:17.80771638969961,
                name: "Visit 1")
                            ]
        
        for visit in visits {
            dropVisitsOnMap(visit, mapView: mapView)
        }
    }
    
    func dropVisitsOnMap(visit: Visit, mapView:MKMapView){
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(visit.location)
        annotation.title = visit.name
        annotation.subtitle = "Duration: \(visit.formattedDuration), Accuracy: \(visit.accuracy)"
        mapView.addAnnotation(annotation)

    }
    
    class Visit
    {
        var location: CLLocationCoordinate2D;
        var startDate: NSDate
        var endDate: NSDate
        var name: NSString
        var accuracy: Double
        
        var duration: NSTimeInterval {
            get{
                return endDate.timeIntervalSinceDate(startDate)
            }
        }
        
        var formattedDuration: NSString{
            get{
                let formatter: NSDateComponentsFormatter = NSDateComponentsFormatter()
                return formatter.stringFromTimeInterval(duration)!
            }
        }
        
        init(startDate: NSDate, endDate: NSDate, location: CLLocationCoordinate2D, accuracy: Double, name: NSString)
        {
            self.startDate = startDate
            self.endDate = endDate
            self.location = location
            self.name = name
            self.accuracy = accuracy
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

