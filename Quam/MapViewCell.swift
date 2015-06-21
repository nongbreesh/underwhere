//
//  MapViewCell.swift
//  Quam
//
//  Created by Breeshy Sama on 6/4/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit


class MapViewCell: UITableViewCell , CLLocationManagerDelegate ,MKMapViewDelegate {

    @IBOutlet var bgview: UIView!
    @IBOutlet var bg: UIView!
    var issetloc:Bool = true
    @IBOutlet var themap: MKMapView!
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    let spanX = 0.003
    let spanY = 0.003
    let _radius:CLLocationDistance = 1500
    var lat:Double!
    var lng:Double!
    var title:String!
     var distance:String!
    var parent:UIViewController!
    override func awakeFromNib() {
        super.awakeFromNib()


        self.bgview.backgroundColor =  colorize(0xFFFFFF, alpha: 1)
        self.bg.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        self.bgview.layer.cornerRadius = 3.0

        self.bgview.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.bgview.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.bgview.layer.shadowOpacity = 0.3
        self.bgview.layer.shadowRadius = 1
        self.bgview.layer.masksToBounds = false
        self.bgview.clipsToBounds = false


        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()

        //Setup our Map View



        self.themap.delegate = self
        self.themap.mapType = MKMapType.Standard



        let delay = 0.3 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            let center = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
            let newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(self.spanX, self.spanY))
            self.themap.setRegion(newRegion, animated: false)
            let newannotation = MKPointAnnotation()
            newannotation.coordinate = center
            self.themap.addAnnotation(newannotation)
        }

        let recognizer = UITapGestureRecognizer(target: self, action: Selector("openFullmap:"))
        self.themap.addGestureRecognizer(recognizer)


    }


    func openFullmap(recognizer: UITapGestureRecognizer) {
        let vc : PostMapViewController! =  self.parent.storyboard?.instantiateViewControllerWithIdentifier("postmapview") as! PostMapViewController
        vc.titlename = self.title
        vc.lat = self.lat
         vc.lng = self.lng
        vc.distance = self.distance
        self.parent.showViewController(vc, sender: vc)
    }

    class var reuseIdentifier: String {
        get {
            return "MapViewCell"
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    
    
}
