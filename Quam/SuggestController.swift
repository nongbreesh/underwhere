//
//  SuggestController.swift
//  Quam
//
//  Created by Breeshy Sama on 4/17/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class SuggestController: UIViewController , UITableViewDelegate,CLLocationManagerDelegate
,UITableViewDataSource,UITabBarControllerDelegate{

    @IBOutlet var lblwelcome: UILabel!
    @IBOutlet var lblwelcomedetail: UILabel!
    @IBOutlet var btn_setnewLoc: UIButton!

    @IBOutlet var suggestbg: UIView!

    var userid:NSString = ""
    var locationid : String?
    var locname : String?

    var refreshControl:UIRefreshControl!
    var parent:UIViewController!

    var currentPage = 0
    var nextpage = 0
    var lat : Double!
    var long : Double!

    var didAddbtn = [Int]()
    var ListArray = NSMutableArray()
    var chkcell = [Int]()

    var locManager = CLLocationManager()
    var cnttabbed:Int = 0

    var is_frommap = false
    var maplat:Double! = 0
    var maplng:Double! = 0
    var maptitle:String!

    var root:MapViewController!

    @IBOutlet weak var tb: UITableView!

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func indexChanged(sender: AnyObject) {
        self.didAddbtn = [Int]()
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            //Nearby
            self.getNearby()
        case 1:
            //Popular
            self.getPopular()
        case 2:
            //Newest
            self.getNewest()
        default:
            break;
        }
    }

    @IBAction func btn_setnewLoc(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
        self.root.DoSetLocation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            self.userid = struserid
        }else{
            self.userid = ""
        }

        //self.thiscontrol = self
        self.locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()

        self.title = locname
        self.tb.delegate = self
        self.tb.dataSource = self

        self.parent = self
        self.view.backgroundColor = colorize(0xFFFFFF, alpha: 1)
        self.tb.separatorColor = colorize(0xEEF2F5, alpha: 1)
        self.tb.backgroundColor = colorize(0xEEF2F5, alpha: 1)
        self.suggestbg.backgroundColor = colorize(0x2cc285, alpha: 0.85)
        self.btn_setnewLoc.layer.cornerRadius = 5
        self.btn_setnewLoc.backgroundColor = colorize(0xf96d6c, alpha: 1)
        self.lblwelcome.textColor = colorize(0x2cc285, alpha: 1)
        self.tb.separatorInset = UIEdgeInsetsZero
        self.tb.rowHeight = UITableViewAutomaticDimension
        self.tb.estimatedRowHeight = 102

        self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tb.addSubview(refreshControl)

        self.tb.registerNib(UINib(nibName: "SuggestPlaceViewCell", bundle: nil), forCellReuseIdentifier: "SuggestPlaceViewCell")
        //        var nib = UINib(nibName: "SuggestPlaceViewCell", bundle: nil)
        //        self.tb.registerNib(nib, forCellReuseIdentifier: "SuggestPlaceViewCell")


        self.getNearby()


    }

    override func viewWillAppear(animated: Bool){
        self.cnttabbed = 0
        self.tb.hidden = false
        lblwelcome.hidden = false
        lblwelcomedetail.hidden = false
        self.tabBarController?.delegate = self

        if is_frommap {
            self.title = "Neaby \(maptitle)"
            self.lblwelcome.text = "อุปส์!"
            self.lblwelcomedetail.text = "ดูเหมือนว่าจะไม่มีสถานที่รอบๆ \"\(self.maptitle)\" เลยนะ"
        }
        else{
            self.title = "มีอะไรใหม่"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return ListArray.count
    }


    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
        if viewController == tabBarController.selectedViewController {
            if self.cnttabbed > 0 {
                self.tb.setContentOffset(CGPointZero, animated: true)
            }
            self.cnttabbed++

        }
    }



    func refresh(sender:AnyObject)
    {
        self.didAddbtn = [Int]()
        locManager.startUpdatingLocation()

        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            //Nearby
            self.getNearby()
        case 1:
            //Popular
            self.getPopular()
        case 2:
            //Newest
            self.getNewest()
        default:
            break;
        }

    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }



    func updateLastLocation(){
        let url = NSURL(string:"http://api.underwhere.in/api/updatelastlocation")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)&lat=\(self.lat)&lng=\(self.long)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary

                dispatch_async(dispatch_get_main_queue(), {
                    self.getNearby()
                })
            }

        });
        task.resume()

    }

    func getNearby(){
        self.refreshControl.beginRefreshing()

        ActivityIndicatory(self.view ,true,false)
        let url = NSURL(string:"http://api.underwhere.in/api/getfavlocationaround")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)&lat=\(self.maplat)&lng=\(self.maplng)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    self.ListArray = NSMutableArray()

                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    var data: [AnyObject]! = result?.objectForKey("result") as! [AnyObject]!
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
                        var user_image: String?  = element.objectForKey("user_image")as? String


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
                        slist.updateValue(user_image!, forKey: "user_image")


                        self.ListArray.addObject(slist)

                    }

                    if data.count > 0 {
                        self.tb.reloadData()
                        self.refreshControl.endRefreshing()
                        self.tb.hidden = false
                        self.lblwelcome.hidden = true
                        self.lblwelcomedetail.hidden = true
                        self.btn_setnewLoc.hidden = true

                    }
                    else{
                        self.tb.hidden = true
                        self.lblwelcome.hidden = false
                        self.lblwelcomedetail.hidden = false
                        self.btn_setnewLoc.hidden = false
                    }
                    ActivityIndicatory(self.view ,false,false)
                })
            }

        }
        task.resume()

    }



    func getPopular(){
        self.refreshControl.beginRefreshing()
        ActivityIndicatory(self.view ,true,false)
        let url = NSURL(string:"http://api.underwhere.in/api/getpopularlocation")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)&lat=\(self.maplat)&lng=\(self.maplng)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    self.ListArray = NSMutableArray()

                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    var data: [AnyObject]! = result?.objectForKey("result") as! [AnyObject]!
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
                        var user_image: String?  = element.objectForKey("user_image")as? String


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
                        slist.updateValue(user_image!, forKey: "user_image")

                        self.ListArray.addObject(slist)

                    }
                    if data.count > 0 {
                        self.tb.reloadData()
                        self.refreshControl.endRefreshing()
                        self.tb.hidden = false
                        self.lblwelcome.hidden = true
                        self.lblwelcomedetail.hidden = true
                         self.btn_setnewLoc.hidden = true
                    }
                    else{

                        self.tb.hidden = true
                        self.lblwelcome.hidden = false
                        self.lblwelcomedetail.hidden = false
                         self.btn_setnewLoc.hidden = false
                    }
                     ActivityIndicatory(self.view ,false,false)
                })
            }

        }
        task.resume()

    }


    func getNewest(){
        self.refreshControl.beginRefreshing()
        ActivityIndicatory(self.view ,true,false)
        let url = NSURL(string:"http://api.underwhere.in/api/getnewestlocation")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)&lat=\(self.maplat)&lng=\(self.maplng)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    self.ListArray = NSMutableArray()

                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    var data: [AnyObject]! = result?.objectForKey("result") as! [AnyObject]!
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
var user_image: String?  = element.objectForKey("user_image")as? String

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
                        slist.updateValue(user_image!, forKey: "user_image")

                        self.ListArray.addObject(slist)

                    }
                    if data.count > 0 {
                        self.tb.reloadData()
                        self.refreshControl.endRefreshing()
                        self.tb.hidden = false
                        self.lblwelcome.hidden = true
                        self.lblwelcomedetail.hidden = true
                        self.btn_setnewLoc.hidden = true
                    }
                    else{

                        self.tb.hidden = true
                        self.lblwelcome.hidden = false
                        self.lblwelcomedetail.hidden = false
                        self.btn_setnewLoc.hidden = false
                    }
                     ActivityIndicatory(self.view ,false,false)
                })
            }
            
        }
        task.resume()
        
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{


        let cell:SuggestPlaceViewCell = tableView.dequeueReusableCellWithIdentifier(SuggestPlaceViewCell.reuseIdentifier) as! SuggestPlaceViewCell


        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        let id: String = ListArray.objectAtIndex(indexPath.row)["id"] as! String
        let locname: String! = ListArray.objectAtIndex(indexPath.row)["locname"] as! String
        var sublocname: String?  = ListArray.objectAtIndex(indexPath.row)["sublocname"] as? String
        var lat: String?  = ListArray.objectAtIndex(indexPath.row)["lat"] as? String
        var lng: String?  = ListArray.objectAtIndex(indexPath.row)["lng"] as? String
        var createdate: String?  = ListArray.objectAtIndex(indexPath.row)["createdate"] as? String
        let fbid: String? = ListArray.objectAtIndex(indexPath.row)["fbid"] as? String
        let name: String! = ListArray.objectAtIndex(indexPath.row)["name"] as! String
        let countfollowing: String! = ListArray.objectAtIndex(indexPath.row)["countfollowing"] as! String
        var distance: NSString = ListArray.objectAtIndex(indexPath.row)["distance"] as! NSString
        let isfollow: String = ListArray.objectAtIndex(indexPath.row)["isfollow"] as! String
         let user_image: String = ListArray.objectAtIndex(indexPath.row)["user_image"] as! String

        distance = String(format: "%.2f", distance.doubleValue)

        cell.Countfollowing.text = countfollowing
        cell.Distance.text = "\(distance)KM"
        cell.lblPlaceName.text = "@\(locname)"
        let imgprofile:NSURL!
         if user_image == "" {
            imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
        }
        else{
            imgprofile = NSURL(string: "http://api.underwhere.in/public/uploads/user_img/\(user_image)");
        }
        cell.imgcreateby.sd_setImageWithURL(imgprofile)
        cell.imgcreateby.clipsToBounds = true
        cell.imgcreateby.layer.cornerRadius =   5 //cell.imgcreateby.frame.size.width / 2
        cell.imgcreateby.layer.borderWidth = 0
        cell.userid = self.userid as String
        cell.lblCreateby.text = "by \(name)"
        cell.btn_add.tag =  id.toInt()!
        cell.cntfollowing  = countfollowing.toInt()!

        if isfollow != "0"{
            cell.id = "0"
            cell.btn_add.enabled = false
            self.didAddbtn.append(id.toInt()!)
            cell.btn_add.setBackgroundImage(UIImage(named: "btn_addedplace.png"), forState: UIControlState.Normal)
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
        sender.enabled = false
    }
    
    
    
    
    
}
