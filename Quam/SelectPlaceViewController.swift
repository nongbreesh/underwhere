//
//  SelectPlaceViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 5/18/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class SelectPlaceViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var navBar: UINavigationBar!
     var ListArray = NSMutableArray()
     var navigationBarAppearace = UINavigationBar.appearance()
    var userid = ""
    var rootView:PostViewController!

    @IBOutlet var ownView: UIView!
    @IBOutlet var tbPlace: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBar.tintColor = colorize(0xFFFFFF, alpha: 1)
        self.navBar.barTintColor = colorize(0x253044, alpha: 1)
        navigationBarAppearace.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.view.backgroundColor = colorize(0x253044, alpha: 1)
        navigationBarAppearace.translucent = false


        self.tbPlace.separatorColor = colorize(0xd3d6db, alpha: 1)
        self.tbPlace.backgroundColor = colorize(0xd3d6db, alpha: 1)
        self.tbPlace.separatorInset = UIEdgeInsetsZero
        self.tbPlace.rowHeight = UITableViewAutomaticDimension
        self.tbPlace.estimatedRowHeight = 102

        self.tbPlace.delegate = self
        self.tbPlace.dataSource = self

        self.tbPlace.registerNib(UINib(nibName: "NearByPlaceViewCell", bundle: nil), forCellReuseIdentifier: "NearByPlaceViewCell")


        

    }

    override func viewWillAppear(animated: Bool){
        self.getNearby()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }

    func getNearby(){
        ActivityIndicatory(self.ownView ,true,false)
        let url = NSURL(string:"http://api.underwhere.in/api/getfavlocationaround_byfollow")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)"
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
                        ActivityIndicatory(self.ownView ,false,false)

                    }

                    self.tbPlace.reloadData()

                })
            }
            
        }
        task.resume()
        
    }




    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return ListArray.count
    }



    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{


        let cell:NearByPlaceViewCell = tableView.dequeueReusableCellWithIdentifier(NearByPlaceViewCell.reuseIdentifier) as! NearByPlaceViewCell


        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        var id: String = ListArray.objectAtIndex(indexPath.row)["id"] as! String
        let locname: String? = ListArray.objectAtIndex(indexPath.row)["locname"] as? String
        var sublocname: String?  = ListArray.objectAtIndex(indexPath.row)["sublocname"] as? String
        var lat: String?  = ListArray.objectAtIndex(indexPath.row)["lat"] as? String
        var lng: String?  = ListArray.objectAtIndex(indexPath.row)["lng"] as? String
        var createdate: String?  = ListArray.objectAtIndex(indexPath.row)["createdate"] as? String
        let fbid: String? = ListArray.objectAtIndex(indexPath.row)["fbid"] as? String
        let name: String? = ListArray.objectAtIndex(indexPath.row)["name"] as? String
        let countfollowing: String! = ListArray.objectAtIndex(indexPath.row)["countfollowing"] as! String
        var distance: NSString = ListArray.objectAtIndex(indexPath.row)["distance"] as! NSString
        var isfollow: String = ListArray.objectAtIndex(indexPath.row)["isfollow"] as! String

        distance = String(format: "%.2f", distance.doubleValue)

        cell.Countfollowing.text = countfollowing
        cell.Distance.text = "\(distance)KM"
        cell.lblPlaceName.text = locname
        let imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal")
        cell.imgcreateby.sd_setImageWithURL(imgprofile)
        cell.imgcreateby.clipsToBounds = true
        cell.imgcreateby.layer.cornerRadius =   5 //cell.imgcreateby.frame.size.width / 2
        cell.imgcreateby.layer.borderWidth = 0
        cell.userid = self.userid as String
        cell.lblCreateby.text = name
        cell.cntfollowing  = countfollowing.toInt()!
        return cell;
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        self.tabBarController?.title = ""

        let id = ListArray.objectAtIndex(indexPath.row)["id"] as! String
        let locname = ListArray.objectAtIndex(indexPath.row)["locname"] as! String


        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string:locname, attributes: underlineAttribute)
        self.rootView.lblto.attributedText = underlineAttributedString
        self.rootView.locations_id = id


        self.dismissViewControllerAnimated(true, completion:nil)

    }


}
