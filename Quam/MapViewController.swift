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

class MapViewController: UIViewController , CLLocationManagerDelegate ,MKMapViewDelegate{

    @IBOutlet var btnSetLocation: UIButton!
    @IBOutlet weak var theMap: MKMapView!
    var userid:NSString = ""
    var countpress = 0
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var hasFirstannotation:Bool = false
    let spanX = 0.1
    let spanY = 0.1
    var issetloc:Bool = true
    let  helper:Helper! = Helper()
    let _radius:CLLocationDistance = 1500
    var lat:Double = 0.0
    var lng:Double = 0.0
    var fqlocname = " Unknow "

    @IBOutlet var viewPlaceHere: UIView!
    @IBOutlet var lblPlaceHere: UILabel!
    @IBOutlet var lblPlaceDescHere: UILabel!
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

        self.viewPlaceHere.layer.cornerRadius = 5.0
        self.lblPlaceHere.text  = "Loading..."
        self.lblPlaceDescHere.text  = "Loading..."

        self.title = "Location select"
        self.pinUserFavoriteLoc(0,lng: 0)


        let lpgr = UILongPressGestureRecognizer(target: self, action: "mapclick:")

        self.theMap.addGestureRecognizer(lpgr)



    }

    override func viewWillAppear(animated: Bool){

        self.navigationController?.navigationBarHidden = false
        
    }

    
    @IBAction func btn_suggest(sender: AnyObject) {

        //self.tabBarController?.title = ""
        let vc : SuggestController! =  self.storyboard?.instantiateViewControllerWithIdentifier("Suggest") as! SuggestController
        vc.is_frommap = true
        vc.maplat = self.lat
        vc.maplng = self.lng
        vc.maptitle = self.fqlocname
        vc.root = self
        self.showViewController(vc, sender: vc)


    }

    @IBOutlet var btn_suggest: UIButton!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func button_currentloc(sender: AnyObject) {


        if (myLocations.last?.hashValue != nil) {
            let center = CLLocationCoordinate2D(latitude:myLocations.last!.coordinate.latitude, longitude: myLocations.last!.coordinate.longitude)
            let newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(spanX, spanY))

            self.theMap.setRegion(newRegion, animated: true)
        }

        //let vc = TimeViewController(nibName:nil, bundle: nil)
        //navigationController?.pushViewController(vc, animated: false)
    }

    func mapclick(gestureRecognizer:UIGestureRecognizer){
        if(countpress == 0){
            countpress++

            var touchPoint:CGPoint = gestureRecognizer.locationInView(self.theMap)

            var touchMapCoordinate:CLLocationCoordinate2D = theMap.convertPoint(touchPoint, toCoordinateFromView: theMap)

            //println(touchMapCoordinate.latitude)
            //println(touchMapCoordinate.longitude)

            var ceo:CLGeocoder = CLGeocoder()




            var arr = []

            var err = []

            var churchLocationn:CLLocation = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)



            CLGeocoder().reverseGeocodeLocation(churchLocationn, completionHandler:
                {(placemarks, error) in
                    if (error != nil) {
                        print("reverse geodcode fail: \(error.localizedDescription)")
                    }
                    let pm = placemarks
                    let p = CLPlacemark(placemark: pm?[0] as! CLPlacemark)
                    //println(p)
                    //println(p.subThoroughfare)
                    //println(p.thoroughfare)
                    //println("Inside what is in p: \(p.name)")


                    var locname = ""
                    var sublocname = ""
                    if p.thoroughfare != nil{
                        locname = p.thoroughfare
                    }
                    if p.subThoroughfare != nil{
                        sublocname = p.subThoroughfare
                    }

                    //                    self.getfqloc(locname,sublocname: sublocname,lat: touchMapCoordinate.latitude,lng: touchMapCoordinate.longitude,touchMapCoordinate:touchMapCoordinate)


            })

        }

        if (gestureRecognizer.state == UIGestureRecognizerState.Ended) {
            //println("UIGestureRecognizerStateEnded")
            countpress = 0
        }
        else if (gestureRecognizer.state == UIGestureRecognizerState.Began){
            //println("UIGestureRecognizerStateBegan")
        }


    }

    @IBAction func btnSetLocation(sender: AnyObject) {
        self.btnSetLocation.enabled = false
        self.DoSetLocation()

    }

    func DoSetLocation(){
        var ceo:CLGeocoder = CLGeocoder()


        let center = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)

        var touchMapCoordinate:CLLocationCoordinate2D = center

        var arr = []

        var err = []

        var churchLocationn:CLLocation = CLLocation(latitude: self.lat, longitude:self.lng)



        CLGeocoder().reverseGeocodeLocation(churchLocationn, completionHandler:
            {(placemarks, error) in
                if (error != nil) {
                    print("reverse geodcode fail: \(error.localizedDescription)")
                }
                let pm = placemarks
                let p = CLPlacemark(placemark: pm?[0] as! CLPlacemark)


                var locname = ""
                var sublocname = ""
                if p.thoroughfare != nil{
                    locname = p.thoroughfare
                }
                if p.subThoroughfare != nil{
                    sublocname = p.subThoroughfare
                }

                self.getfqloc(locname,sublocname: sublocname,lat: self.lat,lng: self.lng,touchMapCoordinate:touchMapCoordinate)


        })


    }
    func pinUserFavoriteLoc(lat:Double,lng:Double){
        let url = NSURL(string:"http://api.underwhere.in/api/getalllocation")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)&lat=\(lat)&lng=\(lng)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in

            var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
            var data: [AnyObject]! = result?.objectForKey("result") as! [AnyObject]!

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    if data != nil {
                    var removeAnotations : [AnyObject]! = self.theMap.annotations
                    self.theMap.removeAnnotations(removeAnotations)

                    for (index, element) in enumerate(data) {
                        var lat:NSString? = element.objectForKey("lat") as! NSString?
                        var lng:NSString? = element.objectForKey("lng")as! NSString?
                        let dlat:CLLocationDegrees  =  NSNumberFormatter().numberFromString(lat! as String)!.doubleValue
                        let dlng:CLLocationDegrees  =  NSNumberFormatter().numberFromString(lng! as String)!.doubleValue


                        let center = CLLocationCoordinate2D(latitude: dlat, longitude:dlng)


                        //var newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(self.spanX, self.spanY))
                        //self.theMap.setRegion(newRegion, animated: true)
                        //println(center.latitude)
                        var newannotation = MKPointAnnotation()
                        newannotation.coordinate = center
                        newannotation.title = element.objectForKey("locname") as! String?
                        newannotation.subtitle = element.objectForKey("sublocname") as! String?
                        self.theMap.addAnnotation(newannotation)
                        //var an:MKAnnotation = self.theMap.annotations[index] as MKAnnotation
                        //self.theMap.selectAnnotation(an, animated: true)

                        //                        var circle = MKCircle(centerCoordinate: center, radius: self._radius)
                        //                        self.theMap.addOverlay(circle)

                    }
                    }
                    else{
                        
                    }


                })




            }



        }
        task.resume()
    }

    func getfqloc(locname:String,sublocname:String,lat:CLLocationDegrees,lng:CLLocationDegrees,touchMapCoordinate:CLLocationCoordinate2D){
        ActivityIndicatory(self.view ,true,false)
        let fqurl = NSURL(string:"https://api.foursquare.com/v2/venues/search?ll=\(lat),\(lng)&oauth_token=RNECEIHZPPNZAXNR2EGXZCI55UDDKCM3HU1E42XNYVIDFMMK&v=20150401")
        let fqrequest = NSMutableURLRequest(URL:fqurl!)
        fqrequest.HTTPMethod = "GET"
        let fqtask = NSURLSession.sharedSession().dataTaskWithRequest(fqrequest) {
            data, response, error in

            dispatch_async(dispatch_get_main_queue(), {
                var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                if result?["response"]?.objectForKey("venues")?.count > 0 {
                    self.fqlocname = result?["response"]?.objectForKey("venues")?[0]["name"]! as! String
                }
                self.addLoc(self.fqlocname,sublocname: "",lat: touchMapCoordinate.latitude,lng: touchMapCoordinate.longitude,touchMapCoordinate:touchMapCoordinate)
            })

        }
        fqtask.resume()
    }


    func addLoc(locname:String,sublocname:String,lat:CLLocationDegrees,lng:CLLocationDegrees,touchMapCoordinate:CLLocationCoordinate2D){

        let url = NSURL(string:"http://api.underwhere.in/api/adduserlocation")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)&locname=\(locname)&sublocname=\(sublocname)&lat=\(lat)&lng=\(lng)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
            var data:NSString! = result?.objectForKey("result") as! NSString!
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    if data == "success" {
                        var newannotation = MKPointAnnotation()
                        newannotation.coordinate = touchMapCoordinate
                        newannotation.title = locname
                        newannotation.subtitle = sublocname
                        self.theMap.addAnnotation(newannotation)
                        var circle = MKCircle(centerCoordinate: touchMapCoordinate, radius: self._radius)
                        self.theMap.addOverlay(circle)
                        ActivityIndicatory(self.view ,false,false)
                          self.btnSetLocation.enabled = true
                        self.navigationController?.popToRootViewControllerAnimated(true)

                    }

                })
            }

        }
        task.resume()
    }



    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        //println("\(locations[0])")
        myLocations.append(locations[0] as! CLLocation)
        if(issetloc){
            let location = locations.last as! CLLocation

            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(spanX, spanY))
            theMap.setRegion(newRegion, animated: false)
            //            var circle = MKCircle(centerCoordinate: self.myLocations.last!.coordinate, radius: _radius)
            //            theMap.addOverlay(circle)
            issetloc = false
        }


        /* if (myLocations.count > 1){
        var sourceIndex = myLocations.count - 1
        var destinationIndex = myLocations.count - 2

        let c1 = myLocations[sourceIndex].coordinate
        let c2 = myLocations[destinationIndex].coordinate
        var a = [c1, c2]
        var polyline = MKPolyline(coordinates: &a, count: a.count)
        theMap.addOverlay(polyline)
        }*/
    }

    //    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!){
    //        for av in views {
    //            // println("\(av.annotation)")
    //            self.theMap.selectAnnotation(av.annotation as  MKAnnotation!, animated: false)
    //            break
    //        }
    //
    //    }



    //    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    //
    //
    //        if !(annotation is MKPointAnnotation) {
    //            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
    //            //return nil so map draws default view for it (eg. blue dot)...
    //            return nil
    //        }
    //
    //        let reuseId = "test"
    //
    //        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
    //        if anView == nil {
    //            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    //            anView.image = UIImage(named:"pinonmap")
    //            anView.canShowCallout = true
    //        }
    //        else {
    //            //we are re-using a view, update its annotation reference...
    //            anView.annotation = annotation
    //        }
    //
    //        return anView
    //
    //    }


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
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool){
        self.lblPlaceHere.text = "Loading..."
        self.lblPlaceDescHere.text  = "Loading..."
    }
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){

        var strlat =  mapView.centerCoordinate.latitude
        var strlng =  mapView.centerCoordinate.longitude

        self.lat  =  mapView.centerCoordinate.latitude
        self.lng  =  mapView.centerCoordinate.longitude


        var removeOverlays : [AnyObject]! = self.theMap.overlays
        self.theMap.removeOverlays(removeOverlays)

         self.pinUserFavoriteLoc(strlat,lng: strlng)

        let center = CLLocationCoordinate2D(latitude: strlat, longitude: strlng)
        var circle = MKCircle(centerCoordinate: center, radius: self._radius)

        self.theMap.addOverlay(circle)



        let fqurl = NSURL(string:"https://api.foursquare.com/v2/venues/search?ll=\(strlat),\(strlng)&oauth_token=RNECEIHZPPNZAXNR2EGXZCI55UDDKCM3HU1E42XNYVIDFMMK&v=20150401")
        let fqrequest = NSMutableURLRequest(URL:fqurl!)
        fqrequest.HTTPMethod = "GET"
        let fqtask = NSURLSession.sharedSession().dataTaskWithRequest(fqrequest) {
            data, response, error in

            dispatch_async(dispatch_get_main_queue(), {
                var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                var address = ""
                var city = ""
                var state = ""
                var postalCode = ""
                var country = ""
                
                if result?["response"]?.objectForKey("venues")?.count > 0 {
                    self.fqlocname = result?["response"]?.objectForKey("venues")?[0]["name"]! as! String
                    var location = result?["response"]?.objectForKey("venues")?[0]["location"]
                    if ((location?!.objectForKey("address")) != nil){address = location?!.objectForKey("address") as! String + " "}
                    if ((location?!.objectForKey("city")) != nil){city = location?!.objectForKey("city") as! String + " "}
                    if ((location?!.objectForKey("state")) != nil){state = location?!.objectForKey("state") as! String + " "}
                    if ((location?!.objectForKey("postalCode")) != nil){postalCode = location?!.objectForKey("postalCode") as! String + " "}
                    if ((location?!.objectForKey("country")) != nil){country = location?!.objectForKey("country") as! String + " "}
                }
                self.lblPlaceHere.text = self.fqlocname
                self.lblPlaceDescHere.text  = "\(address)\(city)\(state)\(postalCode)\(country)"
            })
            
        }
        fqtask.resume()
        
    }
    
}
