//
//  NotificationViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 5/9/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate,UITableViewDataSource ,UITabBarControllerDelegate,NotificationListener{

    var userid:NSString = ""
    var locationid : String?
    var fqlocname : String!

    @IBOutlet var lblwelcome: UILabel!
    @IBOutlet var lblwelcomedetail: UILabel!

    @IBOutlet var tb: UITableView!
    var refreshControl:UIRefreshControl!
    var parent:UIViewController!

    var nextpage = 0
    var offset = 0
    var limit = 20
    var cnttabbed:Int = 0

    var chkcell = [Int]()

    var ListArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            self.userid = struserid
        }else{
            self.userid = ""
        }



        NotificationTransitionMediator.instance.setListener(self)
        self.reload()


        self.tb.delegate = self
        self.tb.dataSource = self
        self.tb.contentInset = UIEdgeInsetsMake(0,0, 0, 0)
        self.parent = self
        self.view.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        self.tb.separatorColor = colorize(0xDFE2E5, alpha: 1)
        self.lblwelcome.textColor =  colorize(0x2cc285, alpha: 1)
        //self.statusbarbg.backgroundColor =  colorize(0x9068AB, alpha:  1)
        self.tb.backgroundColor = UIColor.clearColor()
        self.tb.separatorInset = UIEdgeInsetsZero
        self.tb.rowHeight = UITableViewAutomaticDimension
        self.tb.estimatedRowHeight = 102


        self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tb.addSubview(refreshControl)


        self.tb.registerNib(UINib(nibName: "notificationCell_1", bundle: nil), forCellReuseIdentifier: "notificationCell_1")
        self.tb.registerNib(UINib(nibName: "notificationCell_2", bundle: nil), forCellReuseIdentifier: "notificationCell_2")



        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRectMake(0,0, 50, 50)
        activityIndicator.startAnimating()
        self.tb.tableFooterView = activityIndicator
    }

    func UpdateNotificationData(){
        self.reload()
    }


    override func viewWillAppear(animated: Bool) {
        var chkcell = [Int]()
        self.cnttabbed = 0

        self.tabBarController?.delegate = self
    }


    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.title = "Notification"
        super.viewDidAppear(animated)

        navigationController?.hidesBarsOnSwipe = false
    }

    func reload() {
        self.chkcell = [Int]()
        self.offset = 0
        self.limit = 20
        self.nextpage  = 0
        BadgeTransitionMediator.instance.sendUpdateBadge(true)
        self.tb.tableFooterView?.hidden = false
        //        self.didAddbtn = [Int]()
        self.getData(self.offset,nexPage:self.limit)
        //        self.statusbarbg.hidden = true
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
        var chkcell = [Int]()
        self.offset = 0
        self.limit = 20
        self.nextpage  = 0
        self.tb.tableFooterView?.hidden = false
        //        self.isrefresh = true
        //        self.didAddbtn = [Int]()
        self.getData(self.offset,nexPage:self.limit)
    }



    func getData(currentPage:Int,nexPage:Int){
        let url = NSURL(string:"http://api.underwhere.in/api/getnotification")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)&currentPage=\(currentPage)&nextPage=\(nexPage)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    self.ListArray = NSMutableArray()

                    var returnData: NSData?

                        returnData =  NSURLConnection.sendSynchronousRequest(request, returningResponse: AutoreleasingUnsafeMutablePointer<NSURLResponse?>(), error: NSErrorPointer())
                

                    var returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)
                    // println(returnString)
                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary

                    var data:[NSDictionary]! = result?.objectForKey("result") as! [NSDictionary]

                    if data.count > 0{

                        for (index, element) in enumerate(data) {
                            //println(element)
                            var slist =   [String:String]()
                            var id: String!  = element.objectForKey("id") as! String
                            var title: String!  = element.objectForKey("title") as! String
                            var type: String! = element.objectForKey("type") as! String
                            var status: String! = element.objectForKey("status") as! String
                            var createby: String!  = element.objectForKey("createby")as! String
                            var createto: String!  = element.objectForKey("createto")as! String
                            var refid: String!  = element.objectForKey("refid")as! String
                            var createdate: String!  = element.objectForKey("createdate")as! String
                            var name: String!  = element.objectForKey("name")as! String
                            var fbid: String!  = element.objectForKey("fbid")as! String
                              var user_image: String!  = element.objectForKey("user_image")as! String



                            slist.updateValue(id, forKey: "id")
                            slist.updateValue(title, forKey: "title")
                            slist.updateValue(type, forKey: "type")
                            slist.updateValue(status, forKey: "status")
                            slist.updateValue(createby, forKey: "createby")
                            slist.updateValue(createto, forKey: "createto")
                            slist.updateValue(refid, forKey: "refid")
                            slist.updateValue(createdate, forKey: "createdate")
                            slist.updateValue(name, forKey: "name")
                            slist.updateValue(fbid, forKey: "fbid")
                            slist.updateValue(user_image, forKey: "user_image")

                            self.ListArray.addObject(slist)

                        }

                        // println(self.ListArray.addObject)

                        if  self.limit - 20 <= data.count{

                            self.refreshControl.endRefreshing()
                            self.tb.reloadData()
                        }
                        else{
                            self.refreshControl.endRefreshing()
                            self.tb.tableFooterView?.removeFromSuperview()
                        }

                        self.tb.hidden = false
                        self.lblwelcome.hidden = true
                        self.lblwelcomedetail.hidden = true

                    }

                    else{
                        self.refreshControl.endRefreshing()
                        self.tb.tableFooterView?.removeFromSuperview()
                        self.tb.reloadData()
                        self.tb.hidden = true
                        self.lblwelcome.hidden = false
                        self.lblwelcomedetail.hidden = false
                    }



                    return

                })
            }
        });
        task.resume()

    }




    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return ListArray.count
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{

        var id: String! = ListArray.objectAtIndex(indexPath.row)["id"] as! String
        var type: String! = ListArray.objectAtIndex(indexPath.row)["type"] as! String
        let status: String! = ListArray.objectAtIndex(indexPath.row)["status"] as! String
        let title: String! = ListArray.objectAtIndex(indexPath.row)["title"] as! String
        let name: String! = ListArray.objectAtIndex(indexPath.row)["name"] as! String
        let fbid: String! = ListArray.objectAtIndex(indexPath.row)["fbid"] as! String
        let createdate: String! = ListArray.objectAtIndex(indexPath.row)["createdate"] as! String
        let user_image: String! = ListArray.objectAtIndex(indexPath.row)["user_image"] as! String



        let cell:notificationCell_1 = tableView.dequeueReusableCellWithIdentifier(notificationCell_1.reuseIdentifier) as! notificationCell_1
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        var myMutableString = NSMutableAttributedString()
        var titleString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: "\(name)", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 12.0)!,NSForegroundColorAttributeName: colorize(0xff6a6e, alpha: 1)])

        titleString = NSMutableAttributedString(string: " \(title)", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!])
        myMutableString.appendAttributedString(titleString)


        let imgprofile:NSURL!
        if user_image == "" {
            imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
        }
        else{
            imgprofile = NSURL(string: "http://api.underwhere.in/public/uploads/user_img/\(user_image)");
        }
        cell.imgUser.sd_setImageWithURL(imgprofile)
        cell.imgUser.layer.cornerRadius =  cell.imgUser.frame.size.width / 2
        cell.imgUser.clipsToBounds = true
        cell.imgUser.layer.borderWidth = 0

        if status.toInt()! == 3{
            cell.bg.backgroundColor = colorize(0xFFFFFF, alpha: 1)
        }
        else{
            //             if status.toInt()! == 2{
            //            if type == "FOLLOW" {
            //                cell.bg.backgroundColor = colorize(0xFFFFFF, alpha: 1)
            //            }
            //             }
            //            else{
            //            cell.bg.backgroundColor = colorize(0xDDE1E3, alpha: 0.8)
            //            }
            cell.bg.backgroundColor = colorize(0xDDE1E3, alpha: 0.8)
        }

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let dateFromString = dateFormatter.dateFromString(createdate)

        cell.lblDate.text = timeAgoSinceDate(dateFromString!, false)


        cell.lblDetail.attributedText = myMutableString


        //println(self.chkcell)
        if contains(self.chkcell,indexPath.row){
            cell.bg.backgroundColor = UIColor.whiteColor()
        }



        return cell



    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if self.tb.tableFooterView?.hidden == false{
            self.nextpage = ListArray.count - 1

            if indexPath.row == nextpage {
                self.limit += 20
                self.getData(self.offset,nexPage: self.limit)

            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){

        let type = ListArray.objectAtIndex(indexPath.row)["type"] as! String
        let cell:notificationCell_1 = self.tb.cellForRowAtIndexPath(indexPath) as! notificationCell_1
        cell.bg.backgroundColor = UIColor.whiteColor()
        let refid = ListArray.objectAtIndex(indexPath.row)["refid"] as! String
        var id = ListArray.objectAtIndex(indexPath.row)["id"] as! String


        if !contains(self.chkcell,indexPath.row){
            self.chkcell.append(indexPath.row)
        }


        if type == "COMMENT" {
            self.tabBarController?.title = ""
            let vc : PostDetailViewController! =  self.storyboard?.instantiateViewControllerWithIdentifier("postdetail") as! PostDetailViewController
            vc.postid = refid.toInt()!
            vc.userid = self.userid
            vc.userloginid = self.userid as String
            vc.isscrollToBottom  = true
            self.showViewController(vc, sender: vc)

        }
        else if type == "POST" {
            self.tabBarController?.title = ""
            var id = ListArray.objectAtIndex(indexPath.row)["id"] as! String
            let vc : PostDetailViewController! =  self.storyboard?.instantiateViewControllerWithIdentifier("postdetail") as! PostDetailViewController
            vc.postid = refid.toInt()!
            vc.userid = self.userid
            vc.userloginid = self.userid as String
            self.showViewController(vc, sender: vc)
        }
        else if type == "LIKE" {
            self.tabBarController?.title = ""
            var id = ListArray.objectAtIndex(indexPath.row)["id"] as! String
            let vc : PostDetailViewController! =  self.storyboard?.instantiateViewControllerWithIdentifier("postdetail") as! PostDetailViewController
            vc.postid = refid.toInt()!
            vc.userid = self.userid
            vc.userloginid = self.userid as String
            self.showViewController(vc, sender: vc)
        }
        else{
            self.readnotification(refid.toInt()!)
        }
    }
    
    
    func readnotification(postid:Int){
        let url = NSURL(string:"http://api.underwhere.in/api/read_post_notification")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "postid=\(postid)&userid=\(self.userid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    return
                    
                })
            }
        });
        task.resume()
        
        
    }
    
    
}

