//
//  MapViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 2/3/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PostMapViewController: UIViewController , CLLocationManagerDelegate ,MKMapViewDelegate{


    @IBOutlet weak var theMap: MKMapView!
    var userid:NSString = ""
    var countpress = 0
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var hasFirstannotation:Bool = false
    let spanX = 0.2
    let spanY = 0.2
    var issetloc:Bool = true
    let  helper:Helper! = Helper()
    let _radius:CLLocationDistance = 1500
    var lat:Double = 0.0
    var lng:Double = 0.0
    var distance:String!
    var titlename:String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.userid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as! NSString

        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()


        theMap.delegate = self
        theMap.mapType = MKMapType.Standard
        theMap.showsUserLocation = true
        theMap.zoomEnabled = true

        self.title = self.titlename


        let delay = 0.3 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            let center = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
            let newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(self.spanX, self.spanY))
            self.theMap.setRegion(newRegion, animated: false)
            let newannotation = MKPointAnnotation()
    

            newannotation.coordinate = center
            newannotation.title = self.titlename
            newannotation.subtitle = self.distance

            self.theMap.addAnnotation(newannotation)
        }

    }



    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }











    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        //println("\(locations[0])")
        myLocations.append(locations[0] as! CLLocation)
        if(issetloc){
            let location = locations.last as! CLLocation

            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            var newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(spanX, spanY))
//            theMap.setRegion(newRegion, animated: false)
            //            var circle = MKCircle(centerCoordinate: self.myLocations.last!.coordinate, radius: _radius)
            //            theMap.addOverlay(circle)
            issetloc = false
        }
    }

        
        func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
            
            /*if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            return polylineRenderer
            }*/
            
            if overlay is MKCircle {
                let circle = MKCircleRenderer(overlay: overlay)
                //circle.strokeColor = uicolorFromHex(0x36A84B)
                circle.fillColor = helper.uicolorFromHex2(0x496AC9)
                circle.lineWidth = 0.5
                return circle
            } else {
                return nil
            }
        }
}
