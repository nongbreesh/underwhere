//
//  ViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 11/9/2557 BE.
//  Copyright (c) 2557 Breeshy Sama. All rights reserved.
//
import Foundation
import UIKit
import CoreLocation
import MapKit

class PlaceViewController: UIViewController , CLLocationManagerDelegate ,MKMapViewDelegate , UITableViewDelegate,UITableViewDataSource ,UINavigationControllerDelegate ,UITabBarControllerDelegate{



    @IBOutlet weak var theMap: MKMapView!
    var userid:NSString = ""
    var countpress = 0
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var hasFirstannotation:Bool = false
    let spanX = 0.08
    let spanY = 0.08
    var issetloc:Bool = true
    @IBOutlet var targetView: UIView!
    let  helper:Helper! = Helper()
    @IBOutlet weak var tvPlaces: UITableView!
    var ListArray = NSMutableArray()
    let _radius:CLLocationDistance = 1500
    var refreshControl:UIRefreshControl!
    var TAG = "following"
    var cnttabbed:Int = 0

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func indexChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            //Folllowing
            self.TAG = "following"
            self.pinUserFavoriteLoc()
        case 1:
            //My Place
            self.TAG = "myplace"
            self.pinUserFavoriteLoc()
        default:
            break;
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            self.userid = struserid
        }else{
            self.userid = ""
        }



        navigationController?.delegate = self
        self.tvPlaces.delegate = self
        self.tvPlaces.dataSource = self
        //self.tvPlaces.contentInset = UIEdgeInsetsMake(-36,0, 0, 0)

        //self.tvPlaces.separatorColor = UIColor.clearColor()
        self.tvPlaces.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        self.tvPlaces.separatorColor = colorize(0xDFE2E5, alpha: 1)
        self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tvPlaces.addSubview(refreshControl)


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
//        theMap.showsUserLocation = true
//        theMap.zoomEnabled = true

        let lpgr = UILongPressGestureRecognizer(target: self, action: "handlelngPress:")
        lpgr.minimumPressDuration = 1.0;
        self.tvPlaces.addGestureRecognizer(lpgr)


        self.theMap.bringSubviewToFront(tvPlaces)

        self.tvPlaces.registerNib(UINib(nibName: "PlaceCell", bundle: nil), forCellReuseIdentifier: "PlaceCell")
        self.tvPlaces.registerNib(UINib(nibName: "UserHeaderCell", bundle: nil), forCellReuseIdentifier: "UserHeaderCell")


        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("openMap:"))
        tapGesture.numberOfTapsRequired = 1
        self.theMap.addGestureRecognizer(tapGesture)
        self.theMap.userInteractionEnabled = true
         self.theMap.showsUserLocation = true


        let lpgtb = UILongPressGestureRecognizer(target:self, action: "handlelngPress")
        lpgtb.minimumPressDuration = 1.0; //seconds

    }


    func openMap(gesture:UIGestureRecognizer!){
          self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("mapview") as! MapViewController, animated: true)
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
        if viewController == tabBarController.selectedViewController {

            if self.cnttabbed > 0 {
                self.tvPlaces.setContentOffset(CGPointZero, animated: true)
            }
            self.cnttabbed++


        }
    }


    func refresh(sender:AnyObject)
    {
        self.pinUserFavoriteLoc()
    }

    override func viewWillAppear(animated: Bool) {
        self.pinUserFavoriteLoc()
        self.cnttabbed = 0
        self.tabBarController?.delegate = self


    }


   override func viewDidAppear(animated: Bool) {
  self.tabBarController?.title = "Place"
    }

    func handlelngPress(gestureRecognizer:UILongPressGestureRecognizer){

        let p = gestureRecognizer.locationInView(self.tvPlaces)
        let indexPath  =  self.tvPlaces.indexPathForRowAtPoint(p)
//        var locname: String? = ListArray.objectAtIndex(indexPath!.row)["locname"] as? String
//        var sublocname: String?  = ListArray.objectAtIndex(indexPath!.row)["sublocname"] as? String
        let lat: String?  = ListArray.objectAtIndex(indexPath!.row)["lat"] as? String
        let lng: String?  = ListArray.objectAtIndex(indexPath!.row)["lng"] as? String

        let dlat:CLLocationDegrees  =  NSNumberFormatter().numberFromString(lat!)!.doubleValue
        let dlng:CLLocationDegrees  =  NSNumberFormatter().numberFromString(lng!)!.doubleValue
        let center = CLLocationCoordinate2D(latitude:dlat, longitude: dlng)
        let newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(spanX, spanY))

        self.theMap.setRegion(newRegion, animated: true)

        //let circle:MKOverlay = MKCircle(centerCoordinate: center, radius: self._radius)
        //self.theMap.addOverlay(circle)


    }


    func clearAllAnotations(){
        var removeAnotations : [AnyObject]! = self.theMap.annotations
        var removeOverlays : [AnyObject]! = self.theMap.overlays
        self.theMap.removeOverlays(removeOverlays)
        self.theMap.removeAnnotations(removeAnotations)
    }

    //    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    //        //
    //        //        //MyViewController shoud be the name of your parent Class
    //        //        //if var myViewController = viewController as? MapViewController {
    //        //        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
    //        //            self.userid = struserid
    //        //        }else{
    //        //            self.userid = ""
    //        //        }
    //        //
    //        //
    //        //
    //        //        var removeAnotations : [AnyObject]! = self.theMap.annotations
    //        //        var removeOverlays : [AnyObject]! = self.theMap.overlays
    //        //        self.theMap.removeOverlays(removeOverlays)
    //        //        self.theMap.removeAnnotations(removeAnotations)
    //        //
    //        //
    //        //        self.ListArray = NSMutableArray()
    //        //        self.pinUserFavoriteLoc()
    //        //        //}
    //    }


    //    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!){
    //        for av in views {
    //            //            println("\(av.annotation)")
    //            self.theMap.selectAnnotation(av.annotation as  MKAnnotation!, animated: false)
    //            break
    //        }
    //
    //    }


    func pinUserFavoriteLoc(){
        self.refreshControl.beginRefreshing()
        self.clearAllAnotations()
        //ActivityIndicatory(self.view ,true,false)

        switch self.TAG
        {
        case "myplace":
            let url = NSURL(string:"http://api.underwhere.in/api/getuserlocation2")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "userid=\(userid)&lat=\(0)&lng=\(0)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in

                  var result = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as! NSDictionary
                var data = result.objectForKey("result") as!  NSArray



                if(error == nil){
                    self.ListArray = NSMutableArray()
                    dispatch_async(dispatch_get_main_queue(), {
                        for (index, element) in enumerate(data) {
                            let place: NSDictionary! = element["place"] as! NSDictionary! // Place

                            let _lat:NSString? = place.objectForKey("lat") as! NSString?
                            let _lng:NSString? = place.objectForKey("lng")as! NSString?
                             let userlng:String! = place.objectForKey("userlng")as! String
                             let userlat:String! = place.objectForKey("userlat")as! String
                            let dlat:CLLocationDegrees  =  NSNumberFormatter().numberFromString(_lat! as String) as! CLLocationDegrees
                            let dlng:CLLocationDegrees  =  NSNumberFormatter().numberFromString(_lng as String!) as! CLLocationDegrees


                            let newannotation = MKPointAnnotation()
                            let center = CLLocationCoordinate2D(latitude: dlat, longitude: dlng)
                            newannotation.coordinate = center
//                            newannotation.title = place.objectForKey("locname") as? String
//                            newannotation.subtitle = place.objectForKey("sublocname")  as? String
                            newannotation.title = place.objectForKey("id") as! String
                            newannotation.subtitle = place.objectForKey("countfollowing") as! String

                            self.theMap.addAnnotation(newannotation)
                            let circle:MKOverlay = MKCircle(centerCoordinate: center, radius: self._radius)
                            self.theMap.addOverlay(circle)




                            var slist =   [String:AnyObject]()
                            let id: String?  = place.objectForKey("id") as? String

                            let locname: String? = place.objectForKey("locname") as? String
                            let sublocname: String? = place.objectForKey("sublocname") as? String
                            let lati: String?  = place.objectForKey("lat")as? String
                            let lng: String?  = place.objectForKey("lng")as? String
                            let createdate: String?  = place.objectForKey("createdate")as? String
                            let fbid: String?  = place.objectForKey("fbid")as? String
                            let createby: String?  = place.objectForKey("name")as? String
                            let distance: String?  = place.objectForKey("distance")as? String
                            let user_image: String?  = place.objectForKey("user_image")as? String


                               slist.updateValue(userlat!, forKey: "userlat")
                               slist.updateValue(userlng!, forKey: "userlng")
                            slist.updateValue(id!, forKey: "id")
                            slist.updateValue(locname!, forKey: "locname")
                            slist.updateValue(sublocname!, forKey: "sublocname")
                            slist.updateValue(lati!, forKey: "lat")
                            slist.updateValue(lng!, forKey: "lng")
                            slist.updateValue(createdate!, forKey: "createdate")
                            slist.updateValue(fbid!, forKey: "fbid")
                            slist.updateValue(createby!, forKey: "createby")
                            slist.updateValue(distance!, forKey: "distance")
                            slist.updateValue(user_image!, forKey: "user_image")
                            


                            var people = element.objectForKey("people") as! NSArray
                            let PeopleArray = NSMutableArray()

                            for (peopleindex, peopleelement) in enumerate(people) {
                                var peopleslist =   [String:String]()

                                let fbid: String?  = peopleelement.objectForKey("fbid") as? String
                                let name: String? = peopleelement.objectForKey("name") as? String
                                   let user_image: String?  = peopleelement.objectForKey("user_image")as? String

                                peopleslist.updateValue(fbid!, forKey: "fbid")
                                peopleslist.updateValue(name!, forKey: "name")
                                 peopleslist.updateValue(user_image!, forKey: "user_image")
                                PeopleArray.addObject(peopleslist)
                            }
                            slist.updateValue(PeopleArray, forKey: "people")

                            self.ListArray.addObject(slist)


                        }


                        self.tvPlaces.reloadData()
                        self.refreshControl.endRefreshing()
                        // ActivityIndicatory(self.view ,false,false)
                    })
                }

            }
            task.resume()
            break;
        default: //following
            let url = NSURL(string:"http://api.underwhere.in/api/getuserlocation_following2")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "userid=\(userid)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in

                    var result = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as! NSDictionary
                //println(result)
                var data = result.objectForKey("result") as!  NSArray

                if(error == nil){
                    self.ListArray = NSMutableArray()
                    dispatch_async(dispatch_get_main_queue(), {
                        for (index, element) in enumerate(data) {
                            let place: NSDictionary! = element["place"] as! NSDictionary! // Place
                            let _lat:NSString? = place.objectForKey("lat") as! NSString?
                            let _lng:NSString? = place.objectForKey("lng")as! NSString?
                            let userlng:String! = place.objectForKey("userlng")as! String
                            let userlat:String! = place.objectForKey("userlat")as! String
                            let dlat:CLLocationDegrees  =  NSNumberFormatter().numberFromString(_lat! as String) as! CLLocationDegrees
                            let dlng:CLLocationDegrees  =  NSNumberFormatter().numberFromString(_lng as String!) as! CLLocationDegrees

                            let newannotation = MKPointAnnotation()
                            let center = CLLocationCoordinate2D(latitude: dlat, longitude: dlng)
                            newannotation.coordinate = center
//                            newannotation.title = place.objectForKey("locname") as? String
//                            newannotation.subtitle = place.objectForKey("sublocname")  as? String
                            newannotation.title = place.objectForKey("id") as! String
                            newannotation.subtitle = place.objectForKey("countfollowing") as! String

                            self.theMap.addAnnotation(newannotation)
                            let circle:MKOverlay = MKCircle(centerCoordinate: center, radius: self._radius)
                            self.theMap.addOverlay(circle)




                            var slist =   [String:AnyObject]()
                            let following_id: String?  = place.objectForKey("following_id") as? String
                            let id: String?  = place.objectForKey("id") as? String

                            let locname: String! = place.objectForKey("locname") as! String
                            let sublocname: String! = place.objectForKey("sublocname") as! String
                            let lati: String!  = place.objectForKey("lat")as! String
                            let lng: String!  = place.objectForKey("lng")as! String
                            let createdate: String!  = place.objectForKey("createdate")as! String
                            let fbid: String!  = place.objectForKey("fbid")as! String
                            let createby: String!  = place.objectForKey("name")as! String
                            let distance: String!  = place.objectForKey("distance")as! String
                            let user_image: String!  = place.objectForKey("user_image")as! String




                            slist.updateValue(userlat, forKey: "userlat")
                            slist.updateValue(userlng!, forKey: "userlng")
                            slist.updateValue(id!, forKey: "id")
                            slist.updateValue(following_id!, forKey: "following_id")
                            slist.updateValue(locname!, forKey: "locname")
                            slist.updateValue(sublocname!, forKey: "sublocname")
                            slist.updateValue(lati!, forKey: "lat")
                            slist.updateValue(lng!, forKey: "lng")
                            slist.updateValue(createdate!, forKey: "createdate")
                            slist.updateValue(fbid!, forKey: "fbid")
                            slist.updateValue(createby!, forKey: "createby")
                            slist.updateValue(distance!, forKey: "distance")
                              slist.updateValue(user_image!, forKey: "user_image")



                            let people:NSArray! = element.objectForKey("people") as! NSArray
                            let PeopleArray = NSMutableArray()

                            for (peopleindex, peopleelement) in enumerate(people) {
                                var peopleslist =   [String:String]()

                                let fbid: String?  = peopleelement.objectForKey("fbid") as? String
                                let name: String? = peopleelement.objectForKey("name") as? String
                                 let user_image: String?  = peopleelement.objectForKey("user_image")as? String

                                peopleslist.updateValue(fbid!, forKey: "fbid")
                                peopleslist.updateValue(name!, forKey: "name")
                                peopleslist.updateValue(user_image!, forKey: "user_image")
                                PeopleArray.addObject(peopleslist)
                            }
                            slist.updateValue(PeopleArray, forKey: "people")

                            self.ListArray.addObject(slist)

                        }


                        self.tvPlaces.reloadData()
                        self.refreshControl.endRefreshing()
                        //ActivityIndicatory(self.view ,false,false)
                    })
                }

            }
            task.resume()

            break;
        }
    }



    func getData(){

        // ActivityIndicatory(self.view ,true,false)
        let url = NSURL(string:"http://api.underwhere.in/api/getuser")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)



        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){


                dispatch_async(dispatch_get_main_queue(), {
                    self.ListArray = NSMutableArray()
                    let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    var data: AnyObject? = result?.objectForKey("result")
                                var slist =   [String:String]()

                    var fbid: String? = data?.objectForKey("fbid") as? String
                    var name: String?  = data?.objectForKey("name")as? String
                    var gender: String?  = data?.objectForKey("gender")as? String

                                    slist.updateValue(fbid!, forKey: "fbid")
                                    slist.updateValue(name!, forKey: "name")
                                    slist.updateValue(gender!, forKey: "geder")
                    
                    
                                    self.ListArray.addObject(slist)
                    self.pinUserFavoriteLoc()
                })

            }

        });
        task.resume()

    }




    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return ListArray.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let id: String = self.ListArray.objectAtIndex(indexPath.row)["id"] as! String
        let lat: String = self.ListArray.objectAtIndex(indexPath.row)["userlat"] as! String
        let lng: String = self.ListArray.objectAtIndex(indexPath.row)["userlng"] as! String
        let locname: String = self.ListArray.objectAtIndex(indexPath.row)["locname"] as! String
        let vc : FeedviewController! =  self.storyboard?.instantiateViewControllerWithIdentifier("Feedview") as! FeedviewController
        vc.locationid = id
        vc.lat = lat
        vc.lng = lng
        vc.locname = locname
        self.showViewController(vc as UIViewController, sender: vc)

    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{

        let cell:PlaceCell = tableView.dequeueReusableCellWithIdentifier(PlaceCell.reuseIdentifier) as! PlaceCell
        //cell.layoutMargins = UIEdgeInsets;
        //cell.preservesSuperviewLayoutMargins = false;


        let people:[NSDictionary]! = ListArray.objectAtIndex(indexPath.row)["people"] as! [NSDictionary]
        var locid: String = ListArray.objectAtIndex(indexPath.row)["id"] as! String
        let locname: String? = ListArray.objectAtIndex(indexPath.row)["locname"] as? String
        var sublocname: String?  = ListArray.objectAtIndex(indexPath.row)["sublocname"] as? String
        var lat: String?  = ListArray.objectAtIndex(indexPath.row)["lat"] as? String
        var lng: String?  = ListArray.objectAtIndex(indexPath.row)["lng"] as? String
        var createdate: String?  = ListArray.objectAtIndex(indexPath.row)["createdate"] as? String
        let fbid: String? = ListArray.objectAtIndex(indexPath.row)["fbid"] as? String
        let createby: String? = ListArray.objectAtIndex(indexPath.row)["createby"] as? String
        var distance: NSString! = ListArray.objectAtIndex(indexPath.row)["distance"] as! NSString
        let user_image: NSString! = ListArray.objectAtIndex(indexPath.row)["user_image"] as! NSString

        distance = String(format: "%.2f", distance!.doubleValue)

        cell.lblDistance.text = "\(distance)KM"

        cell.lblPlaceName.text = locname
        let imgprofile:NSURL!
//        if user_image == "" {
//            imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
//        }
//        else{
//            imgprofile = NSURL(string: "http://api.underwhere.in/public/uploads/user_img/\(user_image)");
//
//        }

        imgprofile =  NSURL(string: getPlaceLevel1(people.count))
        cell.imgcreateby.sd_setImageWithURL(imgprofile)
        cell.imgcreateby.clipsToBounds = true
        cell.imgcreateby.layer.cornerRadius =    cell.imgcreateby.frame.size.width / 2
        cell.imgcreateby.layer.borderWidth = 0
        cell.lblCreateby.text =  createby

        //cell.imgfollowing1.hidden = true
        //        cell.imgfollowing2.hidden = true
        //        cell.imgfollowing3.hidden = true
        //        cell.imgfollowing4.hidden = true
        //        cell.imgfollowing5.hidden = true

        cell.imgfollowing1.image = UIImage(named: "imgplace.png")
        cell.imgfollowing2.image = UIImage(named: "imgplace.png")
        cell.imgfollowing3.image = UIImage(named: "imgplace.png")
        cell.imgfollowing4.image = UIImage(named: "imgplace.png")
        cell.imgfollowing5.image = UIImage(named: "imgplace.png")
        cell.lblcntfollowing.text = "\(people.count)"



        for (index, element) in enumerate(people) {

            let fbid: String?  = element.objectForKey("fbid") as? String
            var name: String? = element.objectForKey("name") as? String
            let follower_image: String! = element.objectForKey("user_image") as! String


            var imgfollwer:NSURL!
             if follower_image == "" {
                imgfollwer = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
            }
            else{
                imgfollwer = NSURL(string: "http://api.underwhere.in/public/uploads/user_img/\(follower_image)");
            }

            if index == 0{
                cell.imgfollowing1.sd_setImageWithURL(imgfollwer)
                cell.imgfollowing1.clipsToBounds = true
                cell.imgfollowing1.layer.cornerRadius =  cell.imgfollowing1.frame.size.width / 2
                cell.imgfollowing1.hidden = false
            }
            if index == 1{
                cell.imgfollowing2.sd_setImageWithURL(imgfollwer)
                cell.imgfollowing2.clipsToBounds = true
                cell.imgfollowing2.layer.cornerRadius =   cell.imgfollowing2.frame.size.width / 2

                cell.imgfollowing2.hidden = false
            }
            if index == 2{
                cell.imgfollowing3.sd_setImageWithURL(imgfollwer)
                cell.imgfollowing3.clipsToBounds = true
                cell.imgfollowing3.layer.cornerRadius =   cell.imgfollowing3.frame.size.width / 2

                cell.imgfollowing3.hidden = false
            }
            if index == 3{
                cell.imgfollowing4.sd_setImageWithURL(imgfollwer)
                cell.imgfollowing4.clipsToBounds = true
                cell.imgfollowing4.layer.cornerRadius =   cell.imgfollowing4.frame.size.width / 2

                cell.imgfollowing4.hidden = false
            }
            if index == 4{
                cell.imgfollowing5.sd_setImageWithURL(imgfollwer)
                cell.imgfollowing5.clipsToBounds = true
                cell.imgfollowing5.layer.cornerRadius =   cell.imgfollowing5.frame.size.width / 2

                cell.imgfollowing5.hidden = false
            }


        }



        return cell;


    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {

        switch self.TAG
        {
        case "myplace":
            let btnremove = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                self.rmLoc(indexPath)
            }
            btnremove.backgroundColor = colorize(0xFE3B2F, alpha: 1)


            let btnedit = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit") { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                self.edLoc(indexPath)
            }
            btnedit.backgroundColor = colorize(0xC8C7CD, alpha: 1)

            return [btnremove,btnedit]; //array with all the buttons you want. 1,2,3, etc...
        default:
            let btnUnfollow = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Unfollow") { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                self.unFollow(indexPath)
            }
            btnUnfollow.backgroundColor = colorize(0xFE3B2F, alpha: 1)
            return [btnUnfollow]; //array with all the buttons you want. 1,2,3, etc...
        }

    }

    func edLoc(indexPath: NSIndexPath!) {
        var alert = UIAlertController(title: "Edit name", message: "Type a location name what you want", preferredStyle: UIAlertControllerStyle.Alert)
        //alert.view.tintColor = UIColor.grayColor()
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in

            let tf = alert.textFields?[0] as! UITextField

            var id: String = self.ListArray.objectAtIndex(indexPath.row)["id"] as! String


            let url = NSURL(string:"http://api.underwhere.in/api/updatelocation")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "id=\(id)&locname=\(tf.text)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in

                 let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                //print(result?.objectForKey("result"))

                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {
                        var removeAnotations : [AnyObject]! = self.theMap.annotations
                        var removeOverlays : [AnyObject]! = self.theMap.overlays
                        self.theMap.removeOverlays(removeOverlays)
                        self.theMap.removeAnnotations(removeAnotations)
                        self.ListArray = NSMutableArray()
                        self.pinUserFavoriteLoc()
                    })
                }

            }
            task.resume()



        }))
        alert.addAction(UIAlertAction(title: "Cancle", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            var locname: String? = self.ListArray.objectAtIndex(indexPath.row)["locname"] as? String
            textField.placeholder = "Edit name : "
            textField.text = locname
            textField.secureTextEntry = false
        })
        self.presentViewController(alert, animated: true, completion: nil)

    }



    func rmLoc(indexPath: NSIndexPath!) {

        var refreshAlert = UIAlertController(title: "Warning", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.view.tintColor = UIColor.grayColor()

        refreshAlert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action: UIAlertAction!) in
            var id: String = self.ListArray.objectAtIndex(indexPath.row)["id"] as! String
            let url = NSURL(string:"http://api.underwhere.in/api/removelocation")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "id=\(id)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in

                 let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {
                        var removeAnotations : [AnyObject]! = self.theMap.annotations
                        var removeOverlays : [AnyObject]! = self.theMap.overlays
                        self.theMap.removeOverlays(removeOverlays)
                        self.theMap.removeAnnotations(removeAnotations)
                        self.ListArray = NSMutableArray()
                        self.pinUserFavoriteLoc()
                    })
                }

            }
            task.resume()
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancle", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))

        presentViewController(refreshAlert, animated: true, completion: nil)

    }


    func unFollow(indexPath: NSIndexPath!) {

        var refreshAlert = UIAlertController(title: "Warning", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.view.tintColor = UIColor.grayColor()

        refreshAlert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action: UIAlertAction!) in
            var id: String = self.ListArray.objectAtIndex(indexPath.row)["following_id"] as! String
            print(id)
            let url = NSURL(string:"http://api.underwhere.in/api/unfollow")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "id=\(id)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in

                var result = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as! NSDictionary
                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {
                        var removeAnotations : [AnyObject]! = self.theMap.annotations
                        var removeOverlays : [AnyObject]! = self.theMap.overlays
                        self.theMap.removeOverlays(removeOverlays)
                        self.theMap.removeAnnotations(removeAnotations)
                        self.ListArray = NSMutableArray()
                        self.pinUserFavoriteLoc()
                    })
                }

            }
            task.resume()
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancle", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))

        presentViewController(refreshAlert, animated: true, completion: nil)

    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {


    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        /*var h  = theMap.frame.height
        var w = theMap.frame.width
        let offsetY:CGFloat = scrollView.contentOffset.y;
        let moveY:CGFloat = ((offsetY / 2) * -1) + h - (self.theMap.frame.origin.y / 2) - 465;
        self.theMap.center = CGPointMake(self.theMap.center.x,moveY)*/
    }






    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        //println("\(locations[0])")
        myLocations.append(locations[0]as! CLLocation)
        if(issetloc){
            let location = locations.last as! CLLocation

            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(spanX, spanY))
            theMap.setRegion(newRegion, animated: false)
            //var circle = MKCircle(centerCoordinate: self.myLocations.last!.coordinate, radius: 1000 as CLLocationDistance)
            //theMap.addOverlay(circle)
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
    
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {


        if !(annotation is MKPointAnnotation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }


        let reuseId = "pin"


        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)


            anView.canShowCallout = false
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView.annotation = annotation
        }

        var  img =  NSURL(string: getPlaceLevel2(annotation.subtitle!.toInt()!))
        var imgsrc:UIImageView! = UIImageView()
        imgsrc.sd_setImageWithURL(img)


        anView.image = imgsrc.image
        anView.frame = CGRectMake(0, 0, 30, 35)

        return anView

    }


    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        /*if overlay is MKPolyline {
        var polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blueColor()
        polylineRenderer.lineWidth = 4
        return polylineRenderer
        }*/
        
        //if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            //circle.strokeColor = uicolorFromHex(0x36A84B)
            circle.fillColor = helper.uicolorFromHex2(0x496AC9)
            circle.lineWidth = 0.5
            return circle
        //}

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

