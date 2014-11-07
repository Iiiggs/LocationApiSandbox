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
    
    var visits: [VisitCircle] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let location = CLLocationCoordinate2D(
            latitude: 39.92719908390535,
            longitude: -105.1448931572472
        )
        // 2
        let span = MKCoordinateSpanMake(0.10, 0.10)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        getVisits()
        
    }
    
    func getVisits(){
        // todo: publish latest backend to aws, replace local ip with 54.183.73.223
        let visitsUrl = "http://192.168.0.102:3000/visits"
        let url = NSURL(string: visitsUrl)
        var request = NSMutableURLRequest(URL: url!)
        request.setValue("application/json", forHTTPHeaderField:"Accepts")
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            // TODO: Implenet Reachability, otherwise you get a fatal error: unexpectedly found nil while unwrapping an Optional value
            if((response as NSHTTPURLResponse).statusCode == 200)
            {
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                // convert to json
                var jsonVisits = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSArray
                println(jsonVisits)
                // parse through visits
                for visitDict in jsonVisits{
                    let arrivalDateString = visitDict.objectForKey("arrivalDate") as NSString
                    let arrivalDate = Date.parse(arrivalDateString)
                    
                    let departureDateString = visitDict.objectForKey("departureDate") as NSString
                    let departureDate = Date.parse(departureDateString)
                    
                    let latitude = (visitDict.objectForKey("latitude") as NSString).doubleValue
                    let longitude = (visitDict.objectForKey("longitude") as NSString).doubleValue
                    let horizontalAccuracy = (visitDict.objectForKey("horizontalAccuracy") as NSString).doubleValue
                    let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                    
//                    println("Response from api is a visit: \(arrivalDate) \(departureDate) \(latitude) \(longitude) \(horizontalAccuracy)")

                    var visit = VisitCircle(centerCoordinate: location, radius: horizontalAccuracy)
                    visit.startDate = arrivalDate
                    visit.endDate = departureDate
                    visit.location = location
                    visit.accuracy = horizontalAccuracy
                    visit.name = "Points at \(latitude) \(longitude)"
                    
                    self.dropVisitsOnMap(visit, mapView: self.mapView)
                }
            }
        })
        
        
    }
    
    func addVisitsToMap(){
        for visit in visits {
            dropVisitsOnMap(visit, mapView: mapView)
        }
    }
    
    
    func dropVisitsOnMap(visit: VisitCircle, mapView:MKMapView){
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(visit.location!)
        annotation.title = visit.name
        annotation.subtitle = "Duration: \(visit.formattedDuration), Accuracy: \(visit.accuracy)"
        mapView.addAnnotation(annotation)
        
        mapView.addOverlay(visit)
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!
    {

        if overlay is VisitCircle {
            var circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = UIColor.blueColor()
            circleRenderer.lineWidth = 5
            circleRenderer.alpha = (overlay as VisitCircle).ageAlpha!
            return circleRenderer
        }
        
        return nil
    }
    
    class VisitCircle: MKCircle
    {
        var location: CLLocationCoordinate2D?
        var startDate: NSDate?
        var endDate: NSDate?
        var name: NSString?
        var accuracy: Double?
        var ageAlpha: CGFloat? {
            get{
                let now = NSDate()
                let then = startDate
                
                let age = now.timeIntervalSinceDate(then!)
                
                let alpha = 1.0 - (age / (86400 * 4)) // completely clear after 4 days day (4 X 86,400 seconds)
                
                return CGFloat(alpha)
            }
        }

        var duration: NSTimeInterval {
            get{
                return endDate!.timeIntervalSinceDate(startDate!)
            }
        }
        
        var formattedDuration: NSString{
            get{
                let formatter: NSDateComponentsFormatter = NSDateComponentsFormatter()
                return formatter.stringFromTimeInterval(duration)!
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

