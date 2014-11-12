//
//  ViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 11/9/2557 BE.
//  Copyright (c) 2557 Breeshy Sama. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController , CLLocationManagerDelegate ,MKMapViewDelegate{
    

    @IBOutlet var tabbars: [UITabBarItem]!
    @IBOutlet weak var maintab: UITabBar!
    @IBOutlet weak var theMap: MKMapView!
    var countpress = 0
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var hasFirstannotation:Bool = false
    let spanX = 0.1
    let spanY = 0.1
    var issetloc:Bool = true
    @IBOutlet var targetView: UIView!
    let  helper:Helper! = Helper()
    
    @IBAction func button_currentloc(sender: AnyObject) {
        let center = CLLocationCoordinate2D(latitude:myLocations.last!.coordinate.latitude, longitude: myLocations.last!.coordinate.longitude)
        var newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(spanX, spanY))
        theMap.setRegion(newRegion, animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setUpHeader()
        
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Setup our Map View
        
        //13.762392, 100.568065
        
        
        theMap.delegate = self
        theMap.mapType = MKMapType.Standard
        theMap.showsUserLocation = true
        theMap.zoomEnabled = true
        
        
        /*var annotation = MKPointAnnotation()
        annotation.title = "test"
        annotation.subtitle = "another test"
        theMap.addAnnotation(annotation)*/
        
        
        var lpgr = UILongPressGestureRecognizer(target: self, action: "mapclick:")
        //lpgr.minimumPressDuration = 1.0;
        
        theMap.addGestureRecognizer(lpgr)
        
    }
    
    func setUpHeader(){
        let logo = UIImage(named: "logo.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
    }
    
    
    
    func mapclick(gestureRecognizer:UIGestureRecognizer){
        
        
        if(countpress == 0){
            countpress++
            
            var touchPoint:CGPoint = gestureRecognizer.locationInView(self.theMap)
            
            var touchMapCoordinate:CLLocationCoordinate2D = theMap.convertPoint(touchPoint, toCoordinateFromView: theMap)
            
            var newannotation = MKPointAnnotation()
            newannotation.coordinate = touchMapCoordinate
            newannotation.title = "You Mark here"
            newannotation.subtitle = "You will see what's happenning around 3 km.  \(touchMapCoordinate.latitude),\(touchMapCoordinate.longitude)"
            theMap.addAnnotation(newannotation)
            var circle = MKCircle(centerCoordinate: touchMapCoordinate, radius: 3000 as CLLocationDistance)
            theMap.addOverlay(circle)
            
            
            
            //println(touchMapCoordinate.latitude)
            //println(touchMapCoordinate.longitude)
            
            var ceo:CLGeocoder = CLGeocoder()
            
            
            
            var arr = []
            
            var err = []
            
            var churchLocationn:CLLocation = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(churchLocationn, completionHandler:
                {(placemarks, error) in
                    if (error != nil) {println("reverse geodcode fail: \(error.localizedDescription)")}
                    let pm = placemarks
                    let p = CLPlacemark(placemark: pm?[0] as CLPlacemark)
                    //println(p.subThoroughfare)
                    //println(p.thoroughfare)
            })
            
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerState.Ended) {
            println("UIGestureRecognizerStateEnded")
            countpress = 0
        }
        else if (gestureRecognizer.state == UIGestureRecognizerState.Began){
            println("UIGestureRecognizerStateBegan")
        }
        
        
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        //println("\(locations[0])")
        myLocations.append(locations[0] as CLLocation)
        if(issetloc){
            let location = locations.last as CLLocation
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            var newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(spanX, spanY))
            theMap.setRegion(newRegion, animated: true)
            var circle = MKCircle(centerCoordinate: self.myLocations.last!.coordinate, radius: 3000 as CLLocationDistance)
            theMap.addOverlay(circle)
            issetloc = false
        }
        
        if (myLocations.count > 1){
            var sourceIndex = myLocations.count - 1
            var destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            var polyline = MKPolyline(coordinates: &a, count: a.count)
            theMap.addOverlay(polyline)
            
            
        }
    }
    
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        
        if !(annotation is MKPointAnnotation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView.image = UIImage(named:"pinonmap")
            anView.canShowCallout = true
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView.annotation = annotation
        }
        
        return anView
        
    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        /*if overlay is MKPolyline {
        var polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blueColor()
        polylineRenderer.lineWidth = 4
        return polylineRenderer
        }*/
        
        if overlay is MKCircle {
            var circle = MKCircleRenderer(overlay: overlay)
            //circle.strokeColor = uicolorFromHex(0x36A84B)
            circle.fillColor = helper.uicolorFromHex2(0x36A84B)
            circle.lineWidth = 0.5
            return circle
        } else {
            return nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

