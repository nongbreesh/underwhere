//
//  FeedviewController.swift
//  Quam
//
//  Created by Breeshy Sama on 4/2/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import Foundation
import UIKit

class FeedviewController: UIViewController , UITableViewDelegate
,UITableViewDataSource,UIActionSheetDelegate,UIScrollViewDelegate,UITabBarControllerDelegate,MMHorizontalListViewDataSource,MMHorizontalListViewDelegate{
    var userid = ""
    var locationid : String!
    var lat : String!
    var lng : String!
    var locname : String!
    var nextpage = 0
    var offset = 0
    var limit = 20
    var chkcell = [Int]()
    var didAddbtn = [Int]()
    var didLike = [Int]()
    var didCountLike = [Int,Int]()
    var cnttabbed:Int = 0
    var ListArray = NSMutableArray()
    var preventAnimation = Set<NSIndexPath>()

    @IBOutlet var lblNoData: UILabel!
    @IBOutlet var holizonbg: UIView!
    @IBOutlet var horizontalView: MMHorizontalListView!

    //@IBOutlet var statusbarbg: UIView!
    var refreshControl:UIRefreshControl!



    var ListUserArray = NSMutableArray()


    @IBOutlet weak var tb: UITableView!




    override func viewDidLoad() {
        super.viewDidLoad()


        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            self.userid = struserid
        }else{
            self.userid = ""
        }


        self.horizontalView.scrollEnabled = true
        self.horizontalView.delegate = self
        self.horizontalView.dataSource = self
        self.horizontalView.cellSpacing = 7

        self.holizonbg.backgroundColor = colorize(0x000000, alpha: 0.5)

        self.getUserByLoc()



        self.tabBarController?.delegate = self

        self.title = locname
        self.tb.delegate = self
        self.tb.dataSource = self
        //self.statusbarbg.backgroundColor =  colorize(0x9068AB, alpha:  1)
        self.tb.contentInset = UIEdgeInsetsMake(0,0, 0, 0)
        self.view.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        self.tb.separatorColor = colorize(0xDFE2E5, alpha: 1)
        self.tb.backgroundColor = UIColor.clearColor()
        self.tb.separatorInset = UIEdgeInsetsZero
        self.tb.rowHeight = UITableViewAutomaticDimension
        self.tb.estimatedRowHeight = 102


        self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tb.addSubview(refreshControl)


        self.tb.registerNib(UINib(nibName: "FeedViewCell", bundle: nil), forCellReuseIdentifier: "FeedViewCell")
        self.tb.registerNib(UINib(nibName: "FeedViewCell_no_Image", bundle: nil), forCellReuseIdentifier: "FeedViewCell_no_Image")


    }

    func MMHorizontalListViewNumberOfCells(horizontalListView:MMHorizontalListView!) -> NSInteger{

        return  self.ListUserArray.count
    }

    func  _MMHorizontalListView(horizontalListView:MMHorizontalListView, widthForCellAtIndex index:NSInteger) -> CGFloat {

        return 30

    }


    func  _MMHorizontalListView(horizontalListView:MMHorizontalListView , cellAtIndex index:NSInteger) -> MMHorizontalListViewCell {
        var cell  = horizontalListView.dequeueCellWithReusableIdentifier("UserViewCell")

        if cell == nil {
            let fbid: String! = self.ListUserArray.objectAtIndex(index)["fbid"] as! String
            var user_id: String! = self.ListUserArray.objectAtIndex(index)["user_id"] as! String

            cell = MMHorizontalListViewCell(frame: CGRectMake(0, 0, 30, 30))
            cell.reusableIdentifier = "UserViewCell"
            let img = UIImageView()
            //            let label = UILabel()
            //            label.frame = CGRectMake(5,5,50,20);
            //            label.text = "xxxxx"



            img.frame = CGRectMake(2,0, 27,27);

            let imgprofile = NSURL(string: "http://graph.facebook.com/\(fbid)/picture?type=normal")

            img.sd_setImageWithURL(imgprofile)
            img.layer.cornerRadius =  img.frame.size.width / 2
            img.clipsToBounds = true
            img.layer.borderWidth = 0

            cell.addSubview(img)

        }


        return cell;
    }
    //
    //   override func MMHorizontalListView(horizontalListView:MMHorizontalListView!  ,didSelectCellAtIndex index:NSInteger) {
    //
    //    }
    //
    //   override  func MMHorizontalListView(horizontalListView:MMHorizontalListView!  ,didDeselectCellAtIndex index:NSInteger) {
    //
    //
    //    }


    func getUserByLoc(){
        let url = NSURL(string:"http://api.underwhere.in/api/get_user_following_location")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "locid=\(locationid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if(error == nil){
                var FollowingListArray = NSMutableArray()
                dispatch_async(dispatch_get_main_queue(), {
                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    var data: [AnyObject]! = result?.objectForKey("result") as! [AnyObject]!



                    for (index, element) in enumerate(data) {

                        var slist =   [String:String]()
                        var fbid: String!  = element.objectForKey("fbid") as! String
                        var user_id: String!  = element.objectForKey("user_id") as! String



                        slist.updateValue(fbid, forKey: "fbid")
                        slist.updateValue(user_id, forKey: "user_id")
                        self.ListUserArray.addObject(slist)

                    }

                    if data.count > 0 {
                        self.holizonbg.hidden = true
                    }
                    else{
                        self.holizonbg.hidden = true
                    }

                    self.horizontalView.reloadData()
                })
            }

        }
        task.resume()

    }


    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
        if viewController == tabBarController.selectedViewController {
            if self.cnttabbed > 0 {
                self.tb.setContentOffset(CGPointZero, animated: true)
            }
            self.cnttabbed++
        }
    }


    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.navigationController?.navigationBar.hidden == true {
            UIApplication.sharedApplication().statusBarHidden = true
            //self.statusbarbg.hidden = false
        }
        else{
            UIApplication.sharedApplication().statusBarHidden = false
            // self.statusbarbg.hidden = true
        }

    }


    override func viewWillAppear(animated: Bool) {
        self.lblNoData.hidden = true
        self.offset = 0
        self.limit = 20
        self.nextpage  = 0
        self.cnttabbed = 0
        self.didAddbtn = [Int]()
        self.didLike = [Int]()
        self.didCountLike = [Int,Int]()
        self.chkcell = [Int]()
        self.tb.tableFooterView?.hidden = false
        //        self.statusbarbg.hidden = true
        UIApplication.sharedApplication().statusBarHidden = false
        self.getData(locationid!,lat: self.lat!,lng: self.lng!,currentPage: self.offset,nexPage: self.limit)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return ListArray.count
    }


    func refresh(sender:AnyObject)
    {
        self.offset = 0
        self.limit = 20
        self.preventAnimation = Set<NSIndexPath>()
        self.nextpage  = 0
        self.tb.tableFooterView?.hidden = false
        self.didAddbtn = [Int]()
        self.didLike = [Int]()
        self.didCountLike = [Int,Int]()
        self.chkcell = [Int]()
        // Code to refresh table view
        self.getData(locationid!,lat: lat!,lng: lng!,currentPage: self.offset,nexPage: self.limit)

    }


    func getData(locationid:String,lat:String,lng:String,currentPage:Int,nexPage:Int){
        self.refreshControl.beginRefreshing()
        self.ListArray = NSMutableArray()
        //        ActivityIndicatory(self.view ,true,false)
        let url = NSURL(string:"http://api.underwhere.in/api/getpost")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(self.userid)&id=\(locationid)&lat=\(lat)&lng=\(lng)&currentPage=\(currentPage)&nextPage=\(nexPage)"

        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary

                dispatch_async(dispatch_get_main_queue(), {
                    var data: [AnyObject]! = result?.objectForKey("result") as! [AnyObject]!
                    if data.count > 0{
                        self.lblNoData.hidden = true
                        for (index, element) in enumerate(data) {

                            var slist =   [String:String]()
                            var id: String?  = element.objectForKey("id") as? String
                            var description: String? = element.objectForKey("description") as? String
                            var images: String? = element.objectForKey("images") as? String
                            var createdate: String?  = element.objectForKey("acreatedate")as? String
                            var updatedate: String?  = element.objectForKey("aupdatedate")as? String
                            var fbid: String?  = element.objectForKey("fbid")as? String
                            var name: String?  = element.objectForKey("name")as? String
                            var lat: String?  = element.objectForKey("lat")as? String
                            var lng: String?  = element.objectForKey("lng")as? String
                            var locname: String?  = element.objectForKey("locname")as? String
                            var distance: String?  = element.objectForKey("distance")as? String
                            var count_comment: String?  = element.objectForKey("count_comment")as? String
                            var createby: String?  = element.objectForKey("userid") as? String
                            var myloc: String?  = element.objectForKey("myloc")as? String
                            var locid  = element.objectForKey("location_id")as! String
                            var is_like: String?  = element.objectForKey("is_like")as? String
                            var count_like: String?  = element.objectForKey("count_like")as? String
                            var user_image: String!  = element.objectForKey("user_image")as! String





                            slist.updateValue(id!, forKey: "id")
                            slist.updateValue(description!, forKey: "description")
                            slist.updateValue(images!, forKey: "images")
                            slist.updateValue(lat!, forKey: "lat")
                            slist.updateValue(lng!, forKey: "lng")
                            slist.updateValue(createdate!, forKey: "createdate")
                            slist.updateValue(updatedate!, forKey: "updatedate")
                            slist.updateValue(fbid!, forKey: "fbid")
                            slist.updateValue(name!, forKey: "name")
                            slist.updateValue(locname!, forKey: "locname")
                            slist.updateValue(distance!, forKey: "distance")
                            slist.updateValue(count_comment!, forKey: "count_comment")
                            slist.updateValue(createby!, forKey: "createby")
                            slist.updateValue(myloc!, forKey: "myloc")
                            slist.updateValue(locid, forKey: "locid")
                            slist.updateValue(is_like!, forKey: "is_like")
                            slist.updateValue(count_like!, forKey: "count_like")
                             slist.updateValue(user_image, forKey: "user_image")



                            self.ListArray.addObject(slist)

                        }
                        if  self.limit - 20 <= data.count{

                            self.refreshControl.endRefreshing()
                            self.tb.reloadData()
                        }
                        else{
                            self.refreshControl.endRefreshing()
                            self.tb.tableFooterView?.hidden = true
                        }
                    }
                    else{
                        self.lblNoData.hidden = false
                        self.refreshControl.endRefreshing()
                        self.tb.tableFooterView?.hidden = true
                        self.tb.reloadData()

                    }
                })

            }

        });
        task.resume()

    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !preventAnimation.contains(indexPath) {
            preventAnimation.insert(indexPath)
            TipInCellAnimator.animate(cell)
        }
        if self.tb.tableFooterView?.hidden == false{
            self.nextpage = ListArray.count - 1

            if indexPath.row == nextpage {
                self.limit += 20
                self.getData(locationid!,lat: lat!,lng: lng!,currentPage: self.offset,nexPage: self.limit)

            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let id = ListArray.objectAtIndex(indexPath.row)["id"] as! String
        let vc : PostDetailViewController! =  self.storyboard?.instantiateViewControllerWithIdentifier("postdetail") as! PostDetailViewController
        vc.postid = id.toInt()!
        vc.userid = self.userid
        self.showViewController(vc, sender: vc)
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var id: String! = ListArray.objectAtIndex(indexPath.row)["id"] as! String
        var fbid: String? = ListArray.objectAtIndex(indexPath.row)["fbid"] as? String
        var name: String! = ListArray.objectAtIndex(indexPath.row)["name"] as! String
        var createdate: String? = ListArray.objectAtIndex(indexPath.row)["createdate"] as? String
        var description: String? = ListArray.objectAtIndex(indexPath.row)["description"] as? String
        var images: String! = ListArray.objectAtIndex(indexPath.row)["images"] as! String

        var locname: NSString = ListArray.objectAtIndex(indexPath.row)["locname"] as! NSString
        var distance: NSString = ListArray.objectAtIndex(indexPath.row)["distance"] as! NSString
        var count_comment: String! = ListArray.objectAtIndex(indexPath.row)["count_comment"] as! String
        var myloc: String! = ListArray.objectAtIndex(indexPath.row)["myloc"] as! String
        var locid: String! = ListArray.objectAtIndex(indexPath.row)["locid"] as! String
        var count_like: String! = ListArray.objectAtIndex(indexPath.row)["count_like"] as! String
        var is_like: String! = ListArray.objectAtIndex(indexPath.row)["is_like"] as! String
 var user_image: String! = ListArray.objectAtIndex(indexPath.row)["user_image"] as! String
 var createby: String! = ListArray.objectAtIndex(indexPath.row)["createby"] as! String
        distance = String(format: "%.2f", distance.doubleValue)

        if(images != ""){
            images = "http://api.underwhere.in/public/uploads/post_img/\(images)"

            var cell:FeedViewCell = tableView.dequeueReusableCellWithIdentifier(FeedViewCell.reuseIdentifier) as! FeedViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None

            cell.profileid = createby
            cell.lat = self.lat
               cell.lng = self.lng

            let imgprofile:NSURL!
             if user_image == "" {
                imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
            }
            else{
                imgprofile = NSURL(string: "http://api.underwhere.in/public/uploads/user_img/\(user_image)");
            }

            cell.img_userpost.sd_setImageWithURL(imgprofile)
            cell.img_userpost.layer.cornerRadius =    cell.img_userpost.frame.size.width / 2
            cell.img_userpost.clipsToBounds = true
            cell.img_userpost.layer.borderWidth = 0

            cell.lbl_createby.text = locname as String


            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let dateFromString = dateFormatter.dateFromString(createdate!)

            var myMutableString = NSMutableAttributedString()
            var titleString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: "\(timeAgoSinceDate(dateFromString!, false))", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!])

            titleString = NSMutableAttributedString(string: " by \(name)", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!,NSForegroundColorAttributeName: colorize(0xff6a6e, alpha: 1)])
            myMutableString.appendAttributedString(titleString)
            cell.lbl_createfrom.attributedText = myMutableString


            cell.lbl_description.text = description

            let imgpost = NSURL(string: images!);
            cell.img_post.clipsToBounds = true
            cell.img_post.sd_setImageWithURL(imgpost)
            cell.lbl_range.text  = "\(distance)KM"
            cell.lblcountcomment.text = count_comment
            cell.btnMore.tag = indexPath.row
            cell.btnMore.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.parent = self
            cell.btnaddplace.tag =  locid.toInt()!

            if myloc.toInt()! > 0{
                cell.id = "0"
                cell.btnaddplace.hidden = true
            }
            else{
                cell.btnaddplace.hidden = false
                cell.id = locid
                cell.btnaddplace.enabled = true
                cell.btnaddplace.setBackgroundImage(UIImage(named: "btn_addplace.png"), forState: UIControlState.Normal)
                cell.btnaddplace.addTarget(self, action: "btnFollowClick:", forControlEvents: UIControlEvents.TouchUpInside)
            }

            if !contains(self.didAddbtn,locid.toInt()!){
                cell.btnaddplace.enabled = true
                cell.btnaddplace.setBackgroundImage(UIImage(named: "btn_addplace.png"), forState: UIControlState.Normal)
            }
            else{
                cell.btnaddplace.enabled = false
                cell.btnaddplace.setBackgroundImage(UIImage(named: "btn_addedplace.png"), forState: UIControlState.Normal)
            }

            cell.btn_love.tag =  id.toInt()!

            cell.btn_love.addTarget(self, action: "btnLoveClick:", forControlEvents: UIControlEvents.TouchUpInside)

            cell.btn_love.setBackgroundImage(UIImage(named: "ic_love.png"), forState: UIControlState.Normal)

            cell.lblLove.text  = "+\(count_like)"

            cell.postid = id


            if !contains(self.chkcell,indexPath.row){
                if is_like.toInt()! > 0{
                    if !contains(self.didLike,id.toInt()!){
                        self.didLike.append(id.toInt()!)
                    }
                }
                self.chkcell.append(indexPath.row)
            }



            if contains(self.didLike,id.toInt()!){
                cell.btn_love.setBackgroundImage(UIImage(named: "ic_love_red.png"), forState: UIControlState.Normal)
            }
            else{
                cell.btn_love.setBackgroundImage(UIImage(named: "ic_love.png"), forState: UIControlState.Normal)
            }

            for (index, element) in enumerate(self.didCountLike) {
                if element.0 == id.toInt()!{
                    cell.lblLove.text  = "+\(element.1)"
                }
            }

            return cell;

        }
        else{
            var cell:FeedViewCell_no_Image = tableView.dequeueReusableCellWithIdentifier(FeedViewCell_no_Image.reuseIdentifier)as! FeedViewCell_no_Image
            cell.selectionStyle = UITableViewCellSelectionStyle.None

            let imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
            cell.img_userpost.sd_setImageWithURL(imgprofile)
            cell.img_userpost.layer.cornerRadius =  cell.img_userpost.frame.size.width / 2
            cell.img_userpost.clipsToBounds = true
            cell.img_userpost.layer.borderWidth = 0

            cell.lbl_createby.text = name


            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let dateFromString = dateFormatter.dateFromString(createdate!)

            cell.lbl_createdate.text = timeAgoSinceDate(dateFromString!, false) + " via \(locname)"
            cell.lbl_description.text = description

            let imgpost = NSURL(string: images!);
            cell.lbl_range.text  = "\(distance)KM"
            cell.lblcountcomment.text = count_comment
            return cell;

        }
    }

    func btnLoveClick(sender:UIButton!){

        var id = sender.tag

        if id != 0{
            let url = NSURL(string:"http://api.underwhere.in/api/addLove")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "userid=\(self.userid)&postid=\(id)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

            let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {
                        var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                        var rs: Int! = result?.objectForKey("result") as! Int
                        var countlike: Int! = result?.objectForKey("countLike") as! Int
                        if rs == 1{
                            if !contains(self.didLike,id){
                                self.didLike.append(id)
                                sender.setBackgroundImage(UIImage(named: "ic_love_red.png"), forState: UIControlState.Normal)
                            }

                        }
                        else{
                            for (index, element) in enumerate(self.didLike) {
                                if element == id {
                                    if self.didLike.count > 0{
                                        self.didLike.removeAtIndex(index)
                                        sender.setBackgroundImage(UIImage(named: "ic_love.png"), forState: UIControlState.Normal)
                                    }
                                }
                            }

                        }
                        self.didCountLike.append(id as Int,countlike as Int)

                    })

                }

            });
            task.resume()

        }



    }

    func btnFollowClick(sender:UIButton!){
        self.didAddbtn.append(sender.tag)
        sender.enabled = false
    }



    func btnClick(sender:UIButton!){
        var id = ListArray.objectAtIndex(sender.tag)["id"] as! String
        var createby = ListArray.objectAtIndex(sender.tag)["createby"] as! String


        var actionSheet:UIActionSheet  = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.tag = sender.tag
        if createby == self.userid{
            actionSheet.addButtonWithTitle("Delete Post")
        }
        else{
            actionSheet.addButtonWithTitle("Report")
        }



        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1


        actionSheet.showFromToolbar(self.navigationController?.toolbar)
    }



    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        let buttonTitle:NSString =  actionSheet.buttonTitleAtIndex(buttonIndex)
        let id = ListArray.objectAtIndex(actionSheet.tag)["id"] as! String
        let createby = ListArray.objectAtIndex(actionSheet.tag)["createby"] as! String

        if buttonTitle.isEqual("Delete Post") {
            self.deletePost(id,createby: createby)

        } else if  buttonTitle.isEqual("Report"){
            self.reportPost(id,createby: createby)
        }
    }

    func deletePost(postid:String,createby:String){
        var refreshAlert = UIAlertController(title: "Delete Post", message: "Your post will be delete", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.view.tintColor = UIColor.blackColor()

        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in

            let url = NSURL(string:"http://api.underwhere.in/api/deletepost")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "postid=\(postid)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

            let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {
                        var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                        var data: AnyObject? = result?.objectForKey("result")

                        self.navigationController?.popToRootViewControllerAnimated(true)

                    })

                }

            });
            task.resume()
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancle", style: .Cancel, handler: { (action: UIAlertAction!) in
            
        }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func reportPost(postid:String,createby:String){
        
      
        let url = NSURL(string:"http://api.underwhere.in/api/reportpost")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "postid=\(postid)&createby=\(createby)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            
            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    var data: AnyObject? = result?.objectForKey("result")

                    let alertController = UIAlertController(title: "Message", message:
                        "This post has been reported to us", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.view.tintColor = UIColor.blueColor()
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                })
                
            }
            
        });
        task.resume()
    }
    
    
    
    
    
}
