//
//  ProfileViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 1/29/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController , UITableViewDelegate
,UITableViewDataSource,Modal_Profile_TransitionListener,UIActionSheetDelegate,UITabBarControllerDelegate,UIScrollViewDelegate{
    var profileid:String!
    var ListArray = NSMutableArray()
    var refreshControl:UIRefreshControl!
    var parent:UIViewController!
    var userid:NSString = ""
    var nextpage = 0
    var offset = 0
    var limit = 20
    var chkcell = [Int]()
    var didAddbtn = [Int]()
    var didLike = [Int]()
    var didCountLike = [Int,Int]()
    var locManager = CLLocationManager()
    var cnttabbed:Int = 0
    var userlat = ""
    var userlng = ""
    @IBOutlet var statusbarbg: UIView!
    var preventAnimation = Set<NSIndexPath>()
    var setBG = Set<NSIndexPath>()
    @IBOutlet weak var tb_profile: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()



        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            if self.profileid == nil{
                self.userid = struserid
            }
            else{
                self.userid = self.profileid
            }
        }else{
            self.userid = ""
        }

        self.statusbarbg.backgroundColor = colorize(0x2cc285, alpha: 0)


        Modal_Profile_TransitionMediator.instance.setListener(self)
        self.parent = self

        self.refreshControl = UIRefreshControl()
        //self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tb_profile.addSubview(refreshControl)


        self.tb_profile.delegate = self
        self.tb_profile.dataSource = self


        self.view.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        if self.profileid != nil {
            self.tb_profile.contentInset = UIEdgeInsetsMake(-45,0, 0, 0)
        }
        else{
            self.tb_profile.contentInset = UIEdgeInsetsMake(-20,0, 0, 0)
        }
        self.tb_profile.separatorColor = colorize(0xDFE2E5, alpha: 1)
        self.tb_profile.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        self.tb_profile.separatorInset = UIEdgeInsetsZero
        self.tb_profile.rowHeight = UITableViewAutomaticDimension
        self.tb_profile.estimatedRowHeight = 102





        self.tb_profile.registerNib(UINib(nibName: "ProfileHeaderCell", bundle: nil), forCellReuseIdentifier: "ProfileHeaderCell")

        self.tb_profile.registerNib(UINib(nibName: "FeedViewCell", bundle: nil), forCellReuseIdentifier: "FeedViewCell")

        self.tb_profile.registerNib(UINib(nibName: "FeedViewCell_no_Image", bundle: nil), forCellReuseIdentifier: "FeedViewCell_no_Image")


        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRectMake(0,0, 50, 50)
        activityIndicator.startAnimating()
        self.tb_profile.tableFooterView = activityIndicator
        self.reload()


    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
        if viewController == tabBarController.selectedViewController {
            if self.cnttabbed > 0 {
                self.tb_profile.setContentOffset(CGPointZero, animated: true)
            }
            self.cnttabbed++
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView){
        if scrollView.contentOffset.y > 100 {
            let change_opacity = scrollView.contentOffset.y / 300.0
            if change_opacity <= 1.0 && change_opacity >= 0.0 {
                self.statusbarbg.backgroundColor = colorize(0x2cc285, alpha: Double(change_opacity))
            }
        }
        else{
            self.statusbarbg.backgroundColor = colorize(0x2cc285, alpha:0.0)
        }
    }



    func refresh(sender:AnyObject)
    {
        self.offset = 0
        self.limit = 20
        self.preventAnimation = Set<NSIndexPath>()
        self.nextpage  = 0
        self.tb_profile.tableFooterView?.hidden = false
        self.didAddbtn = [Int]()
        self.didLike = [Int]()
        self.didCountLike = [Int,Int]()
        self.chkcell = [Int]()
        self.getData()
    }


    func popoverDismissed() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        self.getData()
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.hidesBarsOnSwipe = false
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillAppear(animated: Bool){
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.navigationBarHidden = true
        self.cnttabbed = 0
        self.didAddbtn = [Int]()
        self.didLike = [Int]()
        self.didCountLike = [Int,Int]()
        self.chkcell = [Int]()
        self.tabBarController?.delegate = self
        self.tabBarController?.title = "ข้อมูลส่วนตัว"

        if self.profileid != nil {
            self.navigationController?.navigationBarHidden = false
        }
        else{
            self.navigationController?.navigationBarHidden = true
        }

    }


    func reload(){
        self.offset = 0
        self.limit = 20
        self.nextpage  = 0
        self.tb_profile.tableFooterView?.hidden = false
        self.getData()
        self.tabBarController?.title = "Profile"
    }


    func getData(){
        self.refreshControl.beginRefreshing()
        //        ActivityIndicatory(self.view ,true,false)
        let url = NSURL(string:"http://api.underwhere.in/api/getuser")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(self.userid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    self.ListArray = NSMutableArray()
                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary


                    var data: AnyObject? = result?.objectForKey("result")
                    var slist =   [String:String]()

                    var fbid: String? = data?.objectForKey("fbid") as? String
                    var name: String?  = data?.objectForKey("name")as? String
                    var gender: String?  = data?.objectForKey("gender")as? String
                    var lat: String  = data?.objectForKey("lat")as! String
                    var lng: String  = data?.objectForKey("lng")as! String
                    var locname: String  = data?.objectForKey("locname")as! String
                    var count_post: String  = data?.objectForKey("count_post")as! String
                    var count_location: String  = data?.objectForKey("count_location")as! String
                    var user_image: String  = data?.objectForKey("user_image")as! String




                    slist.updateValue(locname, forKey: "locname")
                    slist.updateValue(lat, forKey: "lat")
                    slist.updateValue(lng, forKey: "lng")
                    slist.updateValue(fbid!, forKey: "fbid")
                    slist.updateValue(name!, forKey: "name")
                    slist.updateValue(gender!, forKey: "geder")
                    slist.updateValue(count_post, forKey: "count_post")
                    slist.updateValue(count_location, forKey: "count_location")
                    slist.updateValue(user_image, forKey: "user_image")



                    self.ListArray.addObject(slist)
                    self.getPostData(self.offset,nexPage: self.limit)


                })

            }

        });
        task.resume()

    }


    func getPostData(currentPage:Int,nexPage:Int){
        var strownerid = "0"
        if let ownerid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            strownerid  = ownerid
        }

        let url = NSURL(string:"http://api.underwhere.in/api/getmypost")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)&lat=\(self.userlat)&lng=\(self.userlng)&currentPage=\(currentPage)&nextPage=\(nexPage)&profileid=\(strownerid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    var data: [AnyObject]! = result?.objectForKey("result") as! [AnyObject]!
                    if data.count > 0{
                        for (index, element) in enumerate(data) {
                            //println(element)
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
                            var createby: String?  = element.objectForKey("userid")as? String
                            var myloc: String?  = element.objectForKey("myloc")as? String
                            var locid: String?  = element.objectForKey("locid")as? String
                            var is_like: String?  = element.objectForKey("is_like")as? String
                            var count_like: String?  = element.objectForKey("count_like")as? String
                            var user_image: String?  = element.objectForKey("user_image")as? String




                            slist.updateValue(id!, forKey: "id")
                            slist.updateValue(createby!, forKey: "createby")
                            slist.updateValue(description!, forKey: "description")
                            slist.updateValue(images!, forKey: "images")
                            slist.updateValue(lat!, forKey: "lat")
                            slist.updateValue(lng!, forKey: "lng")
                            slist.updateValue(createdate!, forKey: "createdate")
                            slist.updateValue(updatedate!, forKey: "updatedate")
                            slist.updateValue(fbid!, forKey: "fbid")
                            slist.updateValue(name!, forKey: "name")
                            slist.updateValue(locname!, forKey: "locname")
                            if distance != nil { slist.updateValue(distance!, forKey: "distance") } else { slist.updateValue("0", forKey: "distance") }
                            slist.updateValue(count_comment!, forKey: "count_comment")
                            slist.updateValue(myloc!, forKey: "myloc")
                            slist.updateValue(locid!, forKey: "locid")
                            slist.updateValue(is_like!, forKey: "is_like")
                            slist.updateValue(count_like!, forKey: "count_like")
                            slist.updateValue(user_image!, forKey: "user_image")

                            self.ListArray.addObject(slist)

                        }
                        if  (self.limit - 1) - 20 <= data.count{
                            self.tb_profile.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                        else{
                            self.refreshControl.endRefreshing()
                            self.tb_profile.tableFooterView?.hidden = true
                        }
                    }
                    else{
                        self.refreshControl.endRefreshing()
                        self.tb_profile.reloadData()
                        self.tb_profile.tableFooterView?.hidden = true
                    }
                    return

                })
            }
        });
        task.resume()

    }



    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        return self.ListArray.count
    }

    /* func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row == 0{
    return 200
    }
    else{
    var cell = self.tb_profile.rectForRowAtIndexPath(indexPath)
    //return  cell!.frame.height
    return 150
    }
    }*/

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{

        if indexPath.row == 0{
            var cell:ProfileHeaderCell = tableView.dequeueReusableCellWithIdentifier(ProfileHeaderCell.reuseIdentifier) as! ProfileHeaderCell
            // cell.userInteractionEnabled = false // ปิดไม่ให้ select
            cell.layoutMargins = UIEdgeInsetsZero;
            cell.preservesSuperviewLayoutMargins = false;

            var fbid: String? = ListArray.objectAtIndex(indexPath.row)["fbid"] as? String
            var user_image: String! = ListArray.objectAtIndex(indexPath.row)["user_image"] as! String
            var name: String!  = ListArray.objectAtIndex(indexPath.row)["name"] as! String
            var gender: String?  = ListArray.objectAtIndex(indexPath.row)["gender"] as? String
            var lat: String  = ListArray.objectAtIndex(indexPath.row)["lat"] as! String
            var lng: String  = ListArray.objectAtIndex(indexPath.row)["lng"] as! String
            var locname: String!  = ListArray.objectAtIndex(indexPath.row)["locname"] as! String
            var count_post: String  = ListArray.objectAtIndex(indexPath.row)["count_post"] as! String
            var count_location: String  = ListArray.objectAtIndex(indexPath.row)["count_location"] as! String

            //var locationame: String?  = ListArray.objectAtIndex(indexPath.row)["locationame"] as? String


            cell.lblPost.text = count_post
            cell.lblLocation.text = count_location
            cell.lblLoc.text = "@ \(locname)"
            cell.lblFullname.text = name
            cell.parent = self
            cell.userid = self.userid as String
            if self.profileid != nil {
                cell.btn_setting.hidden = true
                self.navigationController?.navigationBarHidden = false
            }
            else{
                self.navigationController?.navigationBarHidden = true
                cell.btn_setting.hidden = false

            }

            let imgprofile:NSURL!
            if user_image == "" {
                imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
            }
            else{
                imgprofile = NSURL(string: "http://api.underwhere.in/public/uploads/user_img/\(user_image)");
            }
            cell.imgProfile.sd_setImageWithURL(imgprofile)
            cell.imgProfile.layer.cornerRadius =   cell.imgProfile.frame.size.width / 2
            cell.imgProfile.clipsToBounds = true
            cell.imgProfile.layer.borderWidth = 2
            cell.imgProfile.layer.borderColor = colorize(0xFFFFFF, alpha: 1).CGColor
            cell.btn_setting.addTarget(self, action: "btnSetting:", forControlEvents: UIControlEvents.TouchUpInside)


            if !self.setBG.contains(indexPath) {
                self.setBG.insert(indexPath)
                cell.bgProfile.clipsToBounds = true
                cell.bgProfile.sd_setImageWithURL(imgprofile)

                var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView

                visualEffectView.frame =  CGRect(x: 0, y: 0, width: cell.bgProfile.frame.width + 20, height: cell.bgProfile.frame.height)

                cell.bgProfile.addSubview(visualEffectView)

            }



            return cell;

        }
        else{

            var id: String! = ListArray.objectAtIndex(indexPath.row)["id"] as! String
            var fbid: String? = ListArray.objectAtIndex(indexPath.row)["fbid"] as? String
            var name: String! = ListArray.objectAtIndex(indexPath.row)["name"] as! String
            var createdate: String? = ListArray.objectAtIndex(indexPath.row)["createdate"] as? String
            var description: String? = ListArray.objectAtIndex(indexPath.row)["description"] as? String
            var images: String! = ListArray.objectAtIndex(indexPath.row)["images"] as! String

            var locname: String! = ListArray.objectAtIndex(indexPath.row)["locname"] as! String
            var distance: NSString = ListArray.objectAtIndex(indexPath.row)["distance"] as! NSString
            var count_comment: String! = ListArray.objectAtIndex(indexPath.row)["count_comment"] as! String
            var myloc: String! = ListArray.objectAtIndex(indexPath.row)["myloc"] as! String
            var locid: String! = ListArray.objectAtIndex(indexPath.row)["locid"] as! String
            var count_like: String! = ListArray.objectAtIndex(indexPath.row)["count_like"] as! String
            var is_like: String! = ListArray.objectAtIndex(indexPath.row)["is_like"] as! String
            var user_image: String! = ListArray.objectAtIndex(indexPath.row)["user_image"] as! String


            distance = String(format: "%.2f", distance.doubleValue)
            if(images != ""){
                images = "http://api.underwhere.in/public/uploads/post_img/\(images)"
                //println(images)
                var cell:FeedViewCell = tableView.dequeueReusableCellWithIdentifier(FeedViewCell.reuseIdentifier) as! FeedViewCell
                //cell.selectionStyle = UITableViewCellSelectionStyle.None

                cell.locid = locid
                cell.locname = locname
                cell.lat = "\(0)"
                cell.lng = "\(0)"



                let imgprofile:NSURL!
                if user_image == "" {
                    imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
                }
                else{
                    imgprofile = NSURL(string: "http://api.underwhere.in/public/uploads/user_img/\(user_image)");
                }




                cell.img_userpost.sd_setImageWithURL(imgprofile)
                cell.img_userpost.layer.cornerRadius =   cell.img_userpost.frame.size.width / 2
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
                //                cell.lbl_createfrom.text = timeAgoSinceDate(dateFromString!, false) + " by \(name)"
                cell.lbl_description.text = description

                let imgpost = NSURL(string: images!);
                cell.img_post.clipsToBounds = true
                cell.img_post.sd_setImageWithURL(imgpost)
                cell.lbl_range.text  = "\(distance)KM"
                cell.lblcountcomment.text = count_comment
                cell.parent =  parent
                cell.btnMore.tag = indexPath.row
                cell.btnMore.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.lblcountcomment.text = count_comment

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



                cell.btn_love.tag = id.toInt()!

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
                //cell.selectionStyle = UITableViewCellSelectionStyle.None

                let imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
                cell.img_userpost.sd_setImageWithURL(imgprofile)
                cell.img_userpost.layer.cornerRadius =  cell.img_userpost.frame.size.width / 2
                cell.img_userpost.clipsToBounds = true
                cell.img_userpost.layer.borderWidth = 0

                cell.lbl_createby.text = name


                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                let dateFromString = dateFormatter.dateFromString(createdate!)

                cell.lbl_createdate.text = timeAgoSinceDate(dateFromString!, false) + " near \(locname)"
                cell.lbl_description.text = description

                let imgpost = NSURL(string: images!);
                cell.lbl_range.text  = "\(distance)KM"
                cell.lblcountcomment.text = count_comment
                return cell

            }
        }


    }

    func btnLoveClick(sender:UIButton!){

        var id = sender.tag

        var strownerid = "0"
        if let ownerid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            strownerid  = ownerid
        }

        if id != 0{
            let url = NSURL(string:"http://api.underwhere.in/api/addLove")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "userid=\(strownerid)&postid=\(id)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

            let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {
                        var result = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
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

    func btnSetting(sender:UIButton!){
        self.tabBarController?.title = ""
        let vc : SettingViewController! =  self.storyboard?.instantiateViewControllerWithIdentifier("setting") as! SettingViewController
        vc.userloginid = self.userid as String

        self.showViewController(vc, sender: vc)
    }

    func btnClick(sender:UIButton!){
        var id = ListArray.objectAtIndex(sender.tag)["id"] as! String
        var createby = ListArray.objectAtIndex(sender.tag)["createby"] as! String


        var actionSheet:UIActionSheet  = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.tag = sender.tag
        if createby == self.userid{
            if self.profileid == nil{
                actionSheet.addButtonWithTitle("Delete Post")
            }
            else{
                actionSheet.addButtonWithTitle("Report")
            }
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

        var strownerid = "0"
        if let ownerid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            strownerid  = ownerid
        }


        if buttonTitle.isEqual("Delete Post") {
            self.deletePost(id,createby: strownerid)

        } else if  buttonTitle.isEqual("Report"){
            self.reportPost(id,createby: strownerid)
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

                        self.getData()
                        ModalTransitionMediator.instance.sendPopoverDismissed(true)

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
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.row != 0{
            self.tabBarController?.title = ""
            let id = ListArray.objectAtIndex(indexPath.row)["id"] as! String
            let vc : PostDetailViewController! =  self.storyboard?.instantiateViewControllerWithIdentifier("postdetail") as! PostDetailViewController
            vc.postid = id.toInt()!
            vc.userid = self.userid
            vc.userloginid = self.userid as String
            
            self.showViewController(vc, sender: vc)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !preventAnimation.contains(indexPath) {
            preventAnimation.insert(indexPath)
            TipInCellAnimator.animate(cell)
        }
        if self.tb_profile.tableFooterView?.hidden == false{
            self.nextpage = ListArray.count - 1
            
            if indexPath.row == nextpage {
                self.limit += 20
                self.getPostData(self.offset,nexPage: self.limit)
                
            }
        }
    }
    
    
    
}
