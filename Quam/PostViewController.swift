//
//  PostViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 4/25/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PostViewController: UIViewController,UITextViewDelegate , CLLocationManagerDelegate , UIActionSheetDelegate, PECropViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet var btnsavesuggest: UIButton!

    @IBOutlet var lblsetLoc: UILabel!
    @IBOutlet var uiviewprogess: UIView!
    @IBOutlet var uploadProgess: UIProgressView!
    @IBOutlet var uiviewsuggest: UIView!
    @IBOutlet var tbsuggest: UITableView!
    @IBOutlet var btn_edit: UIButton!
    @IBOutlet var btn_setLoc: UIButton!

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var theMap: MKMapView!
    @IBOutlet weak var btn_camera: UIBarButtonItem!
    @IBOutlet weak var lblPlace: UILabel!
    @IBOutlet weak var lblto: UILabel!
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var btndone: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!

    var ListArray = NSMutableArray()
    var kbHeight: CGFloat!
    var iskbhide = true
    var didScrollToBot = false

    var popover:UIPopoverController!
    var fqlocname : String!

    var _IMGSIZE:CGFloat! = 640

    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var userid:String!
    var is_posttowall:String!
    var navigationBarAppearace = UINavigationBar.appearance()
    let spanX = 0.01
    let spanY = 0.01
    var lat = "" as NSString!
    var lng = "" as NSString!
    var locations_id = ""
    var LOC_FLAG = 0

    let _radius:CLLocationDistance = 500
    var issetloc:Bool = true
    var didAddbtn = [Int]()
    var chkcell = [Int]()
    var isarraynerby = [Int]()

    @IBAction func btnsavesuggest(sender: AnyObject) {
        self.getLocNearby()
        var timer = NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
    }

    func handleTap(recognizer: UITapGestureRecognizer) {
        self.textInput.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    override func viewWillAppear(animated: Bool){
        self.updateEditButtonEnabled()
        self.uiviewprogess.hidden = true
        self.uploadProgess.setProgress(0, animated: true)
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

        // self.getNearby()
    }

    func selectPlace(sender:UITapGestureRecognizer) {
        let vc :SelectPlaceViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("selectPlace") as! SelectPlaceViewController
        vc.userid = self.userid as String
        vc.rootView = self
        self.showViewController(vc, sender: vc)
    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    func keyboardWillShow(notification: NSNotification) {

        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
                self.scrolltoBottom()
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }

    func scrolltoBottom(){
        // let offset = CGPoint(x: 0, y:self.view.frame.size.height)
        //   self.view.setContentOffset(offset, animated: false)
    }


    func animateTextField(up: Bool) {
        self.scrolltoBottom()
        let movement = (up ? -kbHeight : kbHeight)

        //        self.tb.frame.size.height  = CGRect(x: self.tb.frame.origin.x, y: self.tb.frame.origin.y, width: self.tb.frame.width, height: (self.tb.frame.width - movement))
        //
        //        println(self.tb.frame.height)

        if movement != nil{
            UIView.animateWithDuration(0.3, animations: {
                //self.view.frame = CGRectOffset(self.view.frame, 0, movement)

                self.view.frame.size.height = self.view.frame.size.height + movement
            })
        }
    }

    @IBAction func btn_setLoc(sender: AnyObject) {
        self.btn_setLoc.enabled = false

        self.addLoc(self.fqlocname,sublocname: "",lat: self.lat.doubleValue,lng: self.lng.doubleValue)
    }

    func getNearby(){
        self.uiviewsuggest.hidden = false

        let url = NSURL(string:"http://api.underwhere.in/api/getfavlocationaround")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    self.ListArray = NSMutableArray()

                       var result = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as! NSDictionary
                    var data: [NSDictionary]! = result.objectForKey("result") as! [NSDictionary]

                    for (index, element) in enumerate(data) {

                        var slist =   [String:String]()
                        var id: String?  = element.objectForKey("id") as? String
                        var locname: String? = element.objectForKey("locname") as? String
                        var sublocname: String? = element.objectForKey("sublocname") as? String
                        var lati: String?  = element.objectForKey("lat")as? String
                        var lng: String?  = element.objectForKey("lng")as? String
                        var createdate: String?  = element.objectForKey("createdate")as? String
                        var fbid: String?  = element.objectForKey("fbid")as? String
                        var name: String?  = element.objectForKey("name")as? String
                        var countfollowing: String?  = element.objectForKey("countfollowing")as? String
                        var isfollow: String?  = element.objectForKey("isfollow")as? String
                        var distance: String?  = element.objectForKey("distance")as? String

                        if isfollow != "0"{
                            self.btnsavesuggest.enabled = true
                        }


                        slist.updateValue(id!, forKey: "id")
                        slist.updateValue(locname!, forKey: "locname")
                        slist.updateValue(sublocname!, forKey: "sublocname")
                        slist.updateValue(lati!, forKey: "lat")
                        slist.updateValue(lng!, forKey: "lng")
                        slist.updateValue(createdate!, forKey: "createdate")
                        slist.updateValue(fbid!, forKey: "fbid")
                        slist.updateValue(name!, forKey: "name")
                        slist.updateValue(countfollowing!, forKey: "countfollowing")
                        slist.updateValue(distance!, forKey: "distance")
                        slist.updateValue(isfollow!, forKey: "isfollow")


                        self.ListArray.addObject(slist)

                    }

                    if data.count > 0 {
                        self.btn_setLoc.hidden = true
                        self.lblsetLoc.hidden = true
                        self.tbsuggest.reloadData()
                        self.tbsuggest.hidden = false
                        self.uiviewsuggest.alpha = 1.0
                        ActivityIndicatory(self.view ,false,false)
                    }
                    else{
                        self.lblsetLoc.text = "\"\(self.fqlocname)\" is near you?"
                        self.lblsetLoc.hidden = false
                        self.btn_setLoc.hidden = false
                        self.tbsuggest.hidden = true
                        ActivityIndicatory(self.view ,false,false)
                    }
                })
            }

        }
        task.resume()

    }



    func addLoc(locname:String,sublocname:String,lat:Double,lng:Double){

        let url = NSURL(string:"http://api.underwhere.in/api/adduserlocation")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)&locname=\(locname)&sublocname=\(sublocname)&lat=\(lat)&lng=\(lng)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
            var data:NSString! = result?.objectForKey("result") as! NSString!
            var locid:Int! = result?.objectForKey("id") as! Int
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    if data == "success" {
                        self.btn_setLoc.enabled = true
                        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
                        let underlineAttributedString = NSAttributedString(string:locname, attributes: underlineAttribute)
                        self.lblto.attributedText = underlineAttributedString
                        self.locations_id =   "\(locid)"
                        var timer = NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
                    }

                })
            }

        }
        task.resume()
    }




    func update() {
        //  PopUpView.hidden = true
        UIView.animateWithDuration(0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.uiviewsuggest.alpha = 0.0
            }, completion: nil)

    }


    override func viewDidLoad() {
        super.viewDidLoad()
        ActivityIndicatory(self.view ,true,false)

        self.tbsuggest.delegate = self
        self.tbsuggest.dataSource = self

        self.btnsavesuggest.enabled = false

        self.uiviewsuggest.hidden = true
        self.uiviewsuggest.layer.cornerRadius = 15
        self.uiviewsuggest.layer.masksToBounds = true
        self.uiviewsuggest.layer.borderColor = colorize(0xdddddd, alpha: 0.7).CGColor
        self.uiviewsuggest.layer.borderWidth = 3

        self.tbsuggest.separatorColor = colorize(0xEEF2F5, alpha: 1)
        self.tbsuggest.backgroundColor = colorize(0xEEF2F5, alpha: 1)
        self.tbsuggest.separatorInset = UIEdgeInsetsZero
        self.tbsuggest.rowHeight = UITableViewAutomaticDimension
        self.tbsuggest.estimatedRowHeight = 102

        self.btn_setLoc.layer.cornerRadius = 5
        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            self.userid = struserid
            self.is_posttowall = NSUserDefaults.standardUserDefaults().objectForKey("is_posttowall") as? String

        }else{
            self.is_posttowall = "1"
            self.userid = ""
        }


        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()

        //self.btn_photo.enabled = false
        //self.theMap.delegate = self
        self.theMap.mapType = MKMapType.Standard
        self.theMap.showsUserLocation = false
        self.theMap.zoomEnabled = false



        navBar.tintColor = colorize(0xFFFFFF, alpha: 1)
        navBar.barTintColor = colorize(0x253044, alpha: 1)
        navigationBarAppearace.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.view.backgroundColor = colorize(0x253044, alpha: 1)
        navigationBarAppearace.translucent = false
        self.btndone.enabled = false
        self.textInput.delegate = self
        //self.textInput.becomeFirstResponder()
        //        self.textInput.text = "Type what happening around here..."
        //        self.textInput.textColor = colorize(0xC8C8C8, alpha: 1)

        self.textInput.text = "บอกกับทุกคน ว่าเกิดอะไรขึ้นที่นี่..."
        self.textInput.textColor = UIColor.lightGrayColor()
        self.textInput.scrollEnabled = true


        let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.view.addGestureRecognizer(recognizer)


        self.tbsuggest.registerNib(UINib(nibName: "SuggestPlaceViewCell", bundle: nil), forCellReuseIdentifier: "SuggestPlaceViewCell")


        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("selectPlace:"))
        self.lblto.addGestureRecognizer(tapGesture)

    }


    func textViewDidBeginEditing(textView: UITextView){
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            self.textInput.text = "Type what happening around here..."
            self.textInput.textColor = UIColor.lightGrayColor()
        }
    }



    func textViewDidChange(textView: UITextView){
        let val = textView.text
        if val != ""{
            //self.textInput.textColor = colorize(0x000000, alpha: 1)
            if self.LOC_FLAG == 1{
                self.btndone.enabled = true
            }
        }
        else{
            self.btndone.enabled = false
        }

    }

    func getFQloc(){
        let fqurl = NSURL(string:"https://api.foursquare.com/v2/venues/search?ll=\(self.lat),\(self.lng)&oauth_token=RNECEIHZPPNZAXNR2EGXZCI55UDDKCM3HU1E42XNYVIDFMMK&v=20150401")
        let fqrequest = NSMutableURLRequest(URL:fqurl!)
        fqrequest.HTTPMethod = "GET"
        let fqtask = NSURLSession.sharedSession().dataTaskWithRequest(fqrequest) {
            data, response, error in
             let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
            // println(result)
            if result?["response"]?.objectForKey("venues")?.count == 0{
                var fqlocname = " Unknow "
                self.LOC_FLAG  = 1
                self.fqlocname =  fqlocname
                self.updateLastLocation()
            }
            else{
                dispatch_async(dispatch_get_main_queue(), {
                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    var fqlocname = " Unknow "
                    if result?["response"]?.objectForKey("venues")?.count > 0 {
                        fqlocname = result!["response"]!.objectForKey("venues")![0]["name"]! as! String
                        self.LOC_FLAG  = 1
                        self.fqlocname =  fqlocname
                        self.updateLastLocation()
                    }
                })
            }

        }
        fqtask.resume()
    }

    func updateLastLocation(){
        let url = NSURL(string:"http://api.underwhere.in/api/updatelastlocation")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)&lat=\(self.lat)&lng=\(self.lng)&locname=\(self.fqlocname)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                 let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary

                dispatch_async(dispatch_get_main_queue(), {
                    self.getLocNearby()
                    self.getData()
                })
            }

        });
        task.resume()

    }



    func getData(){

        let url = NSURL(string:"http://api.underwhere.in/api/getuser")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                var result = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary

                dispatch_async(dispatch_get_main_queue(), {

                    var data: AnyObject? = result?.objectForKey("result")
                    var slist =   [String:String]()

                    var fbid: String? = data?.objectForKey("fbid") as? String
                    var name: String?  = data?.objectForKey("name")as? String
                    var gender: String?  = data?.objectForKey("gender")as? String
                    var lat: String  = data?.objectForKey("lat")as! String
                    var lng: String  = data?.objectForKey("lng")as! String
                    var locname: String  = data?.objectForKey("locname")as! String

                    //self.lblto.text = "My Location near \(locname)"
                    let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
                    let underlineAttributedString = NSAttributedString(string:locname, attributes: underlineAttribute)
                    self.lblPlace.attributedText = underlineAttributedString

                })

            }

        });
        task.resume()

    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnback(sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Delete Post", message: "Your draft won't be saved. Do you want to delete it anyway?", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.view.tintColor = UIColor.blackColor()

        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in

            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
//            self.navigationBarAppearace.setBackgroundImage(UIImage(named: "navbg"), forBarMetrics: UIBarMetrics.Default)
                self.navigationBarAppearace.translucent = true
//            self.navigationBarAppearace.shadowImage = UIImage()
               self.navigationBarAppearace.barTintColor = colorize(0x2cc285, alpha: 1)

            self.dismissViewControllerAnimated(true, completion:nil)

        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancle", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))

        presentViewController(refreshAlert, animated: true, completion: nil)
    }

    func postToFacebook(message : String,link : String,picture : String,placeto : String) {

        let postParams = ["message":"\(message)"
            ,"link":"\(link)"
            ,"picture":"\(picture)"
            ,"caption":"post near : \(placeto)" ];

        var fbRequest = FBSDKGraphRequest(graphPath:"me/feed", parameters: postParams, HTTPMethod: "POST").startWithCompletionHandler { (conn:FBSDKGraphRequestConnection!, id:AnyObject!,error: NSError!) -> Void in
            if error != nil {
                print("\(error.description)")
            } else {
                print("posted to facebook with id : \(id)")
            }
        }
    }

    @IBAction func btndone(sender: AnyObject) {
        self.btndone.enabled = false
        //println(self.userid)
        //ActivityIndicatory(self.view ,true,false)
        self.uiviewprogess.hidden = false
        self.uploadProgess.setProgress(10, animated: true)

        requestSnapshotData(self.theMap) {
            data, error in

            if error != nil {
                print("requestSnapshotData error: \(error)")
                return
            }

            //self.imgmap.image =  UIImage(data: data!)
            var imageData = data
            if self.btn_edit.enabled {
                imageData = UIImagePNGRepresentation(self.imageView.image)
            }

            self.uploadProgess.setProgress(30, animated: true)

            let url = "http://api.underwhere.in/api/upload_images"
            if imageData != nil{
                var request = NSMutableURLRequest(URL: NSURL(string:url)!)
                var session = NSURLSession.sharedSession()

                request.HTTPMethod = "POST"

                var boundary = NSString(format: "---------------------------14737809831466499882746641449")
                var contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
                // println("Content Type \(contentType)")
                request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")

                var body = NSMutableData.alloc()

                // Title
                body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData(NSString(format:"Content-Disposition: form-data; name=\"title\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData("Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)

                // Image
                body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData(NSString(format:"Content-Disposition: form-data; name=\"fileUpload\"; filename=\"img.png\"\\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData(imageData)
                body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)



                request.HTTPBody = body



                // var returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)

                dispatch_async(dispatch_get_main_queue(), {
                    var returnData: NSData?

                        returnData = NSURLConnection.sendSynchronousRequest(request, returningResponse: AutoreleasingUnsafeMutablePointer<NSURLResponse?>(), error: NSErrorPointer())


                     let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(returnData!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary

                    // println(returnString)

                    var statusid = result?.objectForKey("StatusID") as! String
                    var FileName = result?.objectForKey("FileName") as! String
                    if(statusid == "1"){

                        var data: NSData = self.textInput.text.dataUsingEncoding(NSUTF32LittleEndianStringEncoding, allowLossyConversion: false)!
                        self.uploadProgess.setProgress(60, animated: true)

                        let url = NSURL(string:"http://api.underwhere.in/api/postmessage")
                        let request = NSMutableURLRequest(URL:url!)
                        request.HTTPMethod = "POST"


                        let postString = "userid=\(self.userid)&message=\(self.textInput.text)&lat=\(self.lat)&lng=\(self.lng)&image=\(FileName)&locations_id=\(self.locations_id)"
                        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)


                        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                            if(error == nil){
                                dispatch_async(dispatch_get_main_queue(), {
                                    var postresult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as! NSDictionary
                                    //iprintln(postresult)
                                    var postid = postresult.objectForKey("result")  as! Int


                                    let delay = 1 * Double(NSEC_PER_SEC)
                                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                    dispatch_after(time, dispatch_get_main_queue()) {

                                        var placeto:String!  =  self.lblto.text
                                        if self.is_posttowall == "1" {
                                            var place:String! = self.lblPlace.text
                                            self.postToFacebook("\(self.textInput.text)",link: "http://underwhere.in/post/index/\(postid)",picture: "http://api.underwhere.in/public/uploads/post_img/\(FileName)",placeto: "\(placeto)");
                                        }


                                        //ActivityIndicatory(self.view ,false,false)
//                                        self.navigationBarAppearace.setBackgroundImage(UIImage(named: "navbg"), forBarMetrics: UIBarMetrics.Default)
                                        self.navigationBarAppearace.translucent = true
//                                        self.navigationBarAppearace.shadowImage = UIImage()
                                         self.navigationBarAppearace.barTintColor = colorize(0x2cc285, alpha: 1)
                                        self.uploadProgess.setProgress(100, animated: true)
                                        ModalTransitionMediator.instance.sendPopoverDismissed(true)
                                        Modal_Profile_TransitionMediator.instance.sendPopoverDismissed(true)
                                    }






                                })

                            }

                        });
                        task.resume()



                    }
                    else{
                        self.btndone.enabled = true
                        //ActivityIndicatory(self.navigationController!.view ,false,false)
                    }

                })
            }

        }


    }

    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        myLocations.append(locations[0] as! CLLocation)
        if(issetloc){
            let location = locations.last as! CLLocation

            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.lat = "\(location.coordinate.latitude)"
            self.lng = "\(location.coordinate.longitude)"
            let newRegion = MKCoordinateRegion(center: center, span:  MKCoordinateSpanMake(spanX, spanY))
            theMap.setRegion(newRegion, animated: false)
            let circle = MKCircle(centerCoordinate: self.myLocations.last!.coordinate, radius: _radius)
            theMap.addOverlay(circle)
            issetloc = false


            let newannotation = MKPointAnnotation()
            newannotation.coordinate = center
            self.theMap.addAnnotation(newannotation)

            self.getFQloc()

        }
    }


    func getLocNearby(){

        let url = NSURL(string:"http://api.underwhere.in/api/getfavlocationnearby")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    var data: [AnyObject]! = result?.objectForKey("result") as! [AnyObject]!

                    // if nill redirect here
                    if (data.count == 0){
                        //ActivityIndicatory(self.view ,false,false)
                        self.getNearby()
                    }
                    else{
                        var allloc = ""
                        var alllocid = ""

                        if data != nil {
                            for (index, element) in enumerate(data) {

                                var locname:NSString! = element.objectForKey("locname") as! NSString
                                var id:NSString! = element.objectForKey("id")as! NSString
                                allloc += "\(locname),"
                                alllocid += "\(id),"
                            }

                            let stringLength = count(allloc) // Since swift1.2 `countElements` became `count`
                            let substringIndex = stringLength - 1
                            allloc =   allloc.substringToIndex(advance(allloc.startIndex, substringIndex))

                            let stringLength2 = count(alllocid) // Since swift1.2 `countElements` became `count`
                            let substringIndex2 = stringLength2 - 1
                            alllocid =   alllocid.substringToIndex(advance(alllocid.startIndex, substringIndex2))

                        }

                        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
                        let underlineAttributedString = NSAttributedString(string:allloc, attributes: underlineAttribute)
                        self.lblto.attributedText = underlineAttributedString
                        self.locations_id =   alllocid
                        ActivityIndicatory(self.view ,false,false)
                    }

                })

            }

        }
        task.resume()

    }

    func requestSnapshotData(mapView: MKMapView, completion: (data: NSData!, error: NSError!) -> ()) {
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.size = mapView.frame.size
        options.scale = UIScreen.mainScreen().scale

        let coordinate:CLLocationCoordinate2D = self.manager.location.coordinate


        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.startWithCompletionHandler() {
            snapshot, error in

            if error != nil {
                completion(data: nil, error: error)
                return
            }


            var image = snapshot.image


            let finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height)
            let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: "")
            let pinImage = pin.image
            //let pinImage = UIImage(named:"pinonmap")

            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale);
            image.drawAtPoint(CGPointMake(0, 0))

            var point:CGPoint = snapshot.pointForCoordinate(coordinate)
            if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
            {
                var pinCenterOffset:CGPoint = pin.centerOffset;
                point.x -= pin.bounds.size.width / 2.0;
                point.y -= pin.bounds.size.height / 2.0;
                point.x += pinCenterOffset.x;
                point.y += pinCenterOffset.y;

                pinImage!.drawAtPoint(point)
            }


            let finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();




            let data = UIImagePNGRepresentation(finalImage)
            completion(data: data, error: nil)
        }
    }

    // MARK: - PECropViewControllerDelegate methods

    func cropViewController(controller:PECropViewController ,didFinishCroppingImage croppedImage:UIImage,transform:CGAffineTransform,cropRect:CGRect)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)


        if croppedImage.size.width > _IMGSIZE{
            self.imageView.image =   RBResizeImage(croppedImage, CGSize(width: _IMGSIZE,height: _IMGSIZE))
        }
        else{
            self.imageView.image =   croppedImage
        }




        //        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
        //            self.updateEditButtonEnabled()
        //        }

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }

    func cropViewControllerDidCancel(controller:PECropViewController)
    {
        self.imageView.image = nil
        //        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
        //            self.updateEditButtonEnabled()
        //        }
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        controller.dismissViewControllerAnimated(true, completion: nil)

    }


    @IBAction func btn_camera(sender: AnyObject) {
        var actionSheet:UIActionSheet  = UIActionSheet()
        actionSheet.delegate = self

        actionSheet.addButtonWithTitle("Photo Album")
        if  UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            actionSheet.addButtonWithTitle("Camera")
        }
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1


        actionSheet.showFromToolbar(self.navigationController?.toolbar)
    }

    // MARK:  - UIActionSheetDelegate methods

    /*
    Open camera or photo album.
    */

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        let buttonTitle:NSString =  actionSheet.buttonTitleAtIndex(buttonIndex)
        if buttonTitle.isEqual("Photo Album") {
            self.openPhotoAlbum()
        } else if  buttonTitle.isEqual("Camera"){
            self.showCamera()
        }
    }


    // MARK: -  - Private methods

    func showCamera()
    {
        let controller:UIImagePickerController  = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = UIImagePickerControllerSourceType.Camera


        self.presentViewController(controller, animated: true, completion: nil)
    }

    func openPhotoAlbum()
    {

        let controller:UIImagePickerController  = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary

        self.presentViewController(controller, animated: true, completion: nil)

    }

    func updateEditButtonEnabled()
    {
        if (self.imageView.image != nil) {
            self.btn_edit.enabled = true
            self.imageView.hidden = false
            self.theMap.hidden = true
        }
        else{
            self.btn_edit.enabled = false
            self.imageView.hidden = true
            self.theMap.hidden = false
        }
    }



    // MARK:  -  UIImagePickerControllerDelegate methods

    /*
    Open PECropViewController automattically when image selected.
    */
     func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {

        let img:UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage!
        let image:UIImage = img
        self.imageView.image   = image;
        self.imageView.hidden = true

        //        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
        //            if (self.popover.popoverVisible) {
        //                self.popover.dismissPopoverAnimated(false)
        //            }
        //
        //            self.updateEditButtonEnabled()
        //
        //            self.openEditor(self)
        //        } else {
        //            picker.dismissViewControllerAnimated(true, completion: { () -> Void in
        //                self.openEditor(self)
        //            })
        //        }

        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.openEditor(self)
        })
    }


    @IBAction func openEditor(sender: AnyObject) {
        let controller:PECropViewController  = PECropViewController()
        controller.delegate = self;
        controller.image = self.imageView.image;
        controller.toolbarHidden = true


        let image:UIImage = self.imageView.image!
        let width:CGFloat = image.size.width
        let height:CGFloat = image.size.height
        let length:CGFloat = min(width, height)
        controller.imageCropRect = CGRectMake((width - length) / 2,
            (height - length) / 2,
            length,
            length);

        let navigationController:UINavigationController =  UINavigationController(rootViewController: controller)

        //        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
        //            navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        //        }
        self.presentViewController(navigationController, animated: true, completion: nil)
    }



    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{

        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }



    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return ListArray.count
    }



    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{


        let cell:SuggestPlaceViewCell = tableView.dequeueReusableCellWithIdentifier(SuggestPlaceViewCell.reuseIdentifier) as! SuggestPlaceViewCell


        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        let id: String = ListArray.objectAtIndex(indexPath.row)["id"] as! String
        let locname: String? = ListArray.objectAtIndex(indexPath.row)["locname"] as? String
        var sublocname: String?  = ListArray.objectAtIndex(indexPath.row)["sublocname"] as? String
        var lat: String?  = ListArray.objectAtIndex(indexPath.row)["lat"] as? String
        var lng: String?  = ListArray.objectAtIndex(indexPath.row)["lng"] as? String
        var createdate: String?  = ListArray.objectAtIndex(indexPath.row)["createdate"] as? String
        let fbid: String? = ListArray.objectAtIndex(indexPath.row)["fbid"] as? String
        let name: String? = ListArray.objectAtIndex(indexPath.row)["name"] as? String
        let countfollowing: String! = ListArray.objectAtIndex(indexPath.row)["countfollowing"] as! String
        var distance: NSString = ListArray.objectAtIndex(indexPath.row)["distance"] as! NSString
        let isfollow: String = ListArray.objectAtIndex(indexPath.row)["isfollow"] as! String
        
        distance = String(format: "%.2f", distance.doubleValue)
        
        cell.Countfollowing.text = countfollowing
        cell.Distance.text = "\(distance)KM"
        cell.lblPlaceName.text = locname
        let imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal")
        cell.imgcreateby.sd_setImageWithURL(imgprofile)
        cell.imgcreateby.clipsToBounds = true
        cell.imgcreateby.layer.cornerRadius =  5 // cell.imgcreateby.frame.size.width / 2
        cell.imgcreateby.layer.borderWidth = 0
        cell.userid = self.userid as String
        cell.lblCreateby.text = name
        cell.btn_add.tag =  id.toInt()!
        cell.cntfollowing  = countfollowing!.toInt()!
        
        if isfollow != "0"{
            cell.id = "0"
            cell.btn_add.enabled = false
            self.didAddbtn.append(id.toInt()!)
            cell.btn_add.setBackgroundImage(UIImage(named: "btn_addedplace.png"), forState: UIControlState.Normal)
            self.isarraynerby.append(id.toInt()!)
        }
        else{
            
            cell.id = id
            cell.btn_add.enabled = true
            cell.btn_add.setBackgroundImage(UIImage(named: "btn_addplace.png"), forState: UIControlState.Normal)
            cell.btn_add.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        if !contains(self.didAddbtn,id.toInt()!){
            cell.btn_add.enabled = true
            cell.btn_add.setBackgroundImage(UIImage(named: "btn_addplace.png"), forState: UIControlState.Normal)
        }
        else{
            cell.btn_add.enabled = false
            cell.btn_add.setBackgroundImage(UIImage(named: "btn_addedplace.png"), forState: UIControlState.Normal)
        }
        
        
        return cell;
    }
    
    func btnClick(sender:UIButton!){
        self.didAddbtn.append(sender.tag)
        self.isarraynerby.append(sender.tag)
        sender.enabled = false
        if self.isarraynerby.count > 0{
            self.btnsavesuggest.enabled = true
        }
    }
    
    
}

extension UIImage {
    public func resize(size:CGSize, completionHandler:(resizedImage:UIImage, data:NSData)->()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            let newSize:CGSize = size
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImageJPEGRepresentation(newImage, 0.5)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: newImage, data:imageData)
            })
        })
    }
}
