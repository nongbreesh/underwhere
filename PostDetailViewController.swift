//
//  PostDetailViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 4/30/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate ,UIActionSheetDelegate{

    @IBOutlet var navitem: UINavigationItem!
    @IBOutlet var txtComment: UITextField!
    var userid:NSString = ""
    var postid:Int!
    var countpress = 0
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var hasFirstannotation:Bool = false
    let spanX = 0.1
    let spanY = 0.1
    var issetloc:Bool = true
    @IBOutlet var targetView: UIView!
    let  helper:Helper! = Helper()
    @IBOutlet weak var tb: UITableView!
    var ListArray = NSMutableArray()
    let _radius:CLLocationDistance = 500
    var refreshControl:UIRefreshControl!
    var TAG = "following"
    var kbHeight: CGFloat!
    var iskbshow = false
    var didScrollToBot = false
    var ownerid = ""
    var userloginid = ""
    var movement = 0
    var id:Int!
    var isscrollToBottom = false
    var didLike = [Int]()
    var didCountLike = [Int,Int]()
    var chkcell = [Int]()

    @IBOutlet var keyboardHeight: NSLayoutConstraint!
    @IBOutlet var btnMore: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            self.userid = struserid
        }else{
            self.userid = ""
        }

        self.getData()
        self.btn_send.enabled = false

        self.tb.delegate = self
        self.tb.dataSource = self
        self.txtComment.delegate = self
        self.view.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        self.tb.contentInset = UIEdgeInsetsMake(10,0, 10, 0)
        self.tb.separatorColor = colorize(0xDFE2E5, alpha: 1)
        self.tb.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        self.tb.separatorInset = UIEdgeInsetsZero
        self.tb.rowHeight = UITableViewAutomaticDimension
        self.tb.estimatedRowHeight = 102






        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tb.addSubview(refreshControl)

        self.tb.registerNib(UINib(nibName: "PostDetailCell", bundle: nil), forCellReuseIdentifier: "PostDetailCell")

        self.tb.registerNib(UINib(nibName: "ConversationCell_1", bundle: nil), forCellReuseIdentifier: "ConversationCell_1")

        self.tb.registerNib(UINib(nibName: "MapViewCell", bundle: nil), forCellReuseIdentifier: "MapViewCell")



        let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.view.addGestureRecognizer(recognizer)

        self.readnotification(self.postid)

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

    func handleTap(recognizer: UITapGestureRecognizer) {
        self.txtComment.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    func refresh(sender:AnyObject)
    {
        self.didLike = [Int]()
        self.didCountLike = [Int,Int]()
        self.chkcell = [Int]()
        self.isscrollToBottom = false
        self.getData()
    }



    @IBAction func btnMore(sender: AnyObject) {
        let actionSheet:UIActionSheet  = UIActionSheet()
        actionSheet.delegate = self

        if self.ownerid == self.userid{
            actionSheet.addButtonWithTitle("Delete Post")
        }
        else{
            actionSheet.addButtonWithTitle("Report")
        }


        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1


        actionSheet.showFromToolbar((self.navigationController?.toolbar)!)

    }

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        let buttonTitle:NSString =  actionSheet.buttonTitleAtIndex(buttonIndex)
        if buttonTitle.isEqual("Delete Post") {
            self.deletePost()

        } else if  buttonTitle.isEqual("Report"){
            self.reportPost()
        }
    }


    func deletePost(){

        var refreshAlert = UIAlertController(title: "Delete Post", message: "Your post will be delete", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.view.tintColor = UIColor.blackColor()

        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in

            ActivityIndicatory(self.view ,true,false)
            let url = NSURL(string:"http://api.underwhere.in/api/deletepost")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "postid=\(self.postid)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

            let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {

                        var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary
                        var data: AnyObject? = result?.objectForKey("result")
                        Modal_Profile_TransitionMediator.instance.sendPopoverDismissed(true)
                        ModalTransitionMediator.instance.sendPopoverDismissed(true)
                        ActivityIndicatory(self.view ,false,false)
                        self.navigationController?.popToRootViewControllerAnimated(true)


                    })

                }

            })
            task.resume()
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancle", style: .Cancel, handler: { (action: UIAlertAction!) in

        }))

        presentViewController(refreshAlert, animated: true, completion: nil)

    }

    func reportPost(){

        ActivityIndicatory(self.view ,true,false)
        let url = NSURL(string:"http://api.underwhere.in/api/reportpost")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "postid=\(self.postid)&createby=\(self.ownerid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {

                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary
                    var data: AnyObject? = result?.objectForKey("result")
                    ActivityIndicatory(self.view ,false,false)

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

    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.didLike = [Int]()
        self.didCountLike = [Int,Int]()
        self.chkcell = [Int]()
        _ = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

        navigationController?.hidesBarsOnSwipe = false

    }



    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        let val = textField.text
        if val != ""{
            self.btn_send.enabled = true
        }
        else{
            self.btn_send.enabled = false
        }

        return true
    }


    //    func scrollViewDidScroll(scrollView: UIScrollView){
    //        println(scrollView.layer.frame.origin.y)
    //    }



    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }



    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary =  notification.userInfo!
        let kbFrame:NSValue  = info.objectForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardFrame:CGRect  = kbFrame.CGRectValue()

        self.keyboardHeight.constant = keyboardFrame.size.height

        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
            self.scrolltoBottom()
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        //let info:NSDictionary =  notification.userInfo!
       // let kbFrame:NSValue  = info.objectForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
       //var keyboardFrame:CGRect  = kbFrame.CGRectValue()

        self.keyboardHeight.constant = 0

        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
        }

    }

    @IBOutlet var btn_send: UIBarButtonItem!



    func scrolltoBottom(){
        let offset = CGPoint(x: 0, y:self.tb.contentSize.height - self.tb.bounds.size.height)


        if offset.y > 0 {
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
                self.tb.setContentOffset(offset, animated: false)
                }) { (finished:Bool) -> Void in

            }
        }
    }

    @IBAction func btn(sender: AnyObject) {

        if(self.txtComment.text != ""){
            ActivityIndicatory(self.navigationController!.view,true,false)
            let url = NSURL(string:"http://api.underwhere.in/api/postcomment")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "postid=\(self.postid)&userid=\(self.userid)&message=\(self.txtComment.text)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

            let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                //                var returnData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
                //                var returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)
                //                println(returnString)
                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {
                        var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary
                        var data: AnyObject? = result?.objectForKey("result")
                        ActivityIndicatory(self.navigationController!.view ,false,false)
                        self.didScrollToBot = false
                        self.getData()
                        self.txtComment.text  = ""
                        self.txtComment.resignFirstResponder()

                        let delay = 0.3 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            self.scrolltoBottom()
                        }


                        return
                    })

                }

            });
            task.resume()
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView){
        // self.txtComment.resignFirstResponder()
    }


    func getData(){
        //ActivityIndicatory(self.view ,true,false)
        let url = NSURL(string:"http://api.underwhere.in/api/getpostdetail")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(self.userid)&postid=\(self.postid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {

                    self.ListArray = NSMutableArray()
                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary
                    var data: AnyObject? = result?.objectForKey("result")

                    if data != nil {
                        //                    println(data)
                        var slist =   [String:String]()

                        var id: String?  = data?.objectForKey("id") as? String

                        var locname: String? = data?.objectForKey("locname") as? String
                        var sublocname: String? = data?.objectForKey("sublocname") as? String
                        var lat: String?  = data?.objectForKey("alat")as? String
                        var lng: String?  = data?.objectForKey("alng")as? String
                        var createdate: String?  = data?.objectForKey("createdate")as? String
                        var fbid: String?  = data?.objectForKey("fbid")as? String
                        var createby: String?  = data?.objectForKey("name")as? String
                        var distance: String?  = data?.objectForKey("distance")as? String
                        var images: String?  = data?.objectForKey("images")as? String
                        var description: String?  = data?.objectForKey("description")as? String
                        var name: String?  = data?.objectForKey("name")as? String
                        var count_comment: String?  = data?.objectForKey("count_comment")as? String
                        var is_like: String!  = data?.objectForKey("is_like")as! String
                        var count_like: String!  = data?.objectForKey("count_like")as! String
                        var user_image: String!  = data?.objectForKey("user_image")as! String
                        var userlat: String!  = data?.objectForKey("userlat")as! String
                        var userlng: String!  = data?.objectForKey("userlng")as! String
                        self.ownerid = data?.objectForKey("ownerid")as! String

                        slist.updateValue(id!, forKey: "id")
                        slist.updateValue(count_comment!, forKey: "count_comment")
                        slist.updateValue(locname!, forKey: "locname")
                        slist.updateValue(sublocname!, forKey: "sublocname")
                        slist.updateValue(lat!, forKey: "lat")
                        slist.updateValue(lng!, forKey: "lng")
                        slist.updateValue(createdate!, forKey: "createdate")
                        slist.updateValue(fbid!, forKey: "fbid")
                        slist.updateValue(createby!, forKey: "createby")
                        slist.updateValue(is_like!, forKey: "is_like")
                        slist.updateValue(count_like!, forKey: "count_like")
                        if distance != nil { slist.updateValue(distance!, forKey: "distance") } else { slist.updateValue("0", forKey: "distance")   }
                        slist.updateValue(images!, forKey: "images")
                        slist.updateValue(description!, forKey: "description")
                        slist.updateValue(name!, forKey: "name")
                        slist.updateValue(user_image, forKey: "user_image")
                         slist.updateValue(userlat, forKey: "userlat")
                         slist.updateValue(userlng, forKey: "userlng")

                        self.title = name
                        self.ListArray.addObject(slist) // for header

                        self.ListArray.addObject(slist) // for mapview cell


                        var comments: [AnyObject]! = result?.objectForKey("comments") as! [AnyObject]!
                        for (index, element) in enumerate(comments) {
                            //println(element)
                            var slist =   [String:String]()
                            var id: String?  = element.objectForKey("id") as? String
                            var fbid: String? = element.objectForKey("fbid") as? String
                            var createby: String? = element.objectForKey("createby") as? String
                            var description: String?  = element.objectForKey("description")as? String
                            var name: String?  = element.objectForKey("name")as? String
                            var post_id: String?  = element.objectForKey("post_id")as? String
                            var createdate: String?  = element.objectForKey("createdate")as? String
                            var user_image: String?  = element.objectForKey("user_image")as? String
                            var userlat: String!  = element.objectForKey("userlat")as! String
                            var userlng: String!  = element.objectForKey("userlng")as! String





                            slist.updateValue(id!, forKey: "id")
                            slist.updateValue(fbid!, forKey: "fbid")
                            slist.updateValue(createby!, forKey: "createby")
                            slist.updateValue(description!, forKey: "description")
                            slist.updateValue(name!, forKey: "name")
                            slist.updateValue(post_id!, forKey: "post_id")
                            slist.updateValue(createdate!, forKey: "createdate")
                            slist.updateValue(user_image!, forKey: "user_image")
                             slist.updateValue(userlat!, forKey: "userlat")
                             slist.updateValue(userlng!, forKey: "userlng")

                            self.ListArray.addObject(slist)

                        }



                        self.refreshControl.endRefreshing()
                        //ActivityIndicatory(self.view ,false,false)
                        self.tb.reloadData()


                        let delay = 0.3 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            if self.isscrollToBottom{
                                self.scrolltoBottom()
                                self.isscrollToBottom = false
                            }
                        }


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

        if indexPath.row == 0{
            var id: String! = ListArray.objectAtIndex(indexPath.row)["id"] as! String
            var fbid: String? = ListArray.objectAtIndex(indexPath.row)["fbid"] as? String
            var name: String! = ListArray.objectAtIndex(indexPath.row)["name"] as! String
            var createdate: String? = ListArray.objectAtIndex(indexPath.row)["createdate"] as? String
            var description: String? = ListArray.objectAtIndex(indexPath.row)["description"] as? String
            var images: String! = ListArray.objectAtIndex(indexPath.row)["images"] as! String

            var locname: String! = ListArray.objectAtIndex(indexPath.row)["locname"] as! String
            var count_like: String! = ListArray.objectAtIndex(indexPath.row)["count_like"] as! String
            var is_like: String! = ListArray.objectAtIndex(indexPath.row)["is_like"] as! String
            var distance: NSString = ListArray.objectAtIndex(indexPath.row)["distance"] as! NSString
            var count_comment: String! = ListArray.objectAtIndex(indexPath.row)["count_comment"] as! String
            var user_image: String! = ListArray.objectAtIndex(indexPath.row)["user_image"] as! String

            var createby: String! = ListArray.objectAtIndex(indexPath.row)["createby"] as! String
            var userlat: String! = ListArray.objectAtIndex(indexPath.row)["userlat"] as! String
            var userlng: String! = ListArray.objectAtIndex(indexPath.row)["userlng"] as! String

            distance = String(format: "%.2f", distance.doubleValue)


            images = "http://api.underwhere.in/public/uploads/post_img/\(images)"
            //println(images)
            var cell:PostDetailCell = tableView.dequeueReusableCellWithIdentifier(PostDetailCell.reuseIdentifier) as! PostDetailCell
            cell.layoutMargins = UIEdgeInsetsZero;
            cell.preservesSuperviewLayoutMargins = false;
            let imgprofile:NSURL!
            if user_image == "" {
                imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
            }
            else{
                imgprofile = NSURL(string: "http://api.underwhere.in/public/uploads/user_img/\(user_image)");
            }
            cell.img_userpost.sd_setImageWithURL(imgprofile)
            cell.img_userpost.clipsToBounds = true
            cell.img_userpost.layer.cornerRadius = cell.img_userpost.frame.size.width / 2

            cell.parent = self.navigationController
            cell.lblcountcomment.text = count_comment

            cell.lat = userlat
              cell.lng = userlng

            cell.profileid = self.ownerid
       

            cell.lbl_createby.text = locname



            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let dateFromString = dateFormatter.dateFromString(createdate!)

            var myMutableString = NSMutableAttributedString()
            var titleString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: "\(timeAgoSinceDate(dateFromString!, false))", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!])

            titleString = NSMutableAttributedString(string: " by \(name)", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!,NSForegroundColorAttributeName: colorize(0xff6a6e, alpha: 1)])
            myMutableString.appendAttributedString(titleString)
            cell.lbl_createdate.attributedText = myMutableString



            //cell.lbl_createdate.text = timeAgoSinceDate(dateFromString!, false) + " by \(name)"
            cell.lbl_description.text = description

            let imgpost = NSURL(string: images!);
            //cell.img_post.layer.cornerRadius = 3
            cell.img_post.clipsToBounds = true
            cell.img_post.sd_setImageWithURL(imgpost)
            cell.lbl_range.text  = "\(distance)KM"


            cell.btnLove.tag =  id.toInt()!


            cell.btnLove.addTarget(self, action: "btnLoveClick:", forControlEvents: UIControlEvents.TouchUpInside)

            cell.btnLove.setBackgroundImage(UIImage(named: "ic_love.png"), forState: UIControlState.Normal)


            cell.lblcountLike.text  = "+\(count_like)"

            cell.postid = id.toInt()!
            cell.userid = self.userid as String


            if  !contains(self.chkcell,indexPath.row){
                if is_like.toInt()! > 0{
                    if !contains(self.didLike,  id.toInt()!){
                        self.didLike.append(id.toInt()!)
                    }
                }
                self.chkcell.append(indexPath.row)
            }



            if contains(self.didLike,  id.toInt()!){
                cell.btnLove.setBackgroundImage(UIImage(named: "ic_love_red.png"), forState: UIControlState.Normal)
            }
            else{
                cell.btnLove.setBackgroundImage(UIImage(named: "ic_love.png"), forState: UIControlState.Normal)
            }

            for (index, element) in enumerate(self.didCountLike) {
                if element.0 == id.toInt()!{
                    cell.lblcountLike.text  = "+\(element.1)"
                }
            }



            return cell;
        }
        else if indexPath.row == 1{

            var cell:MapViewCell = tableView.dequeueReusableCellWithIdentifier(MapViewCell.reuseIdentifier) as! MapViewCell
            cell.layoutMargins = UIEdgeInsetsZero;
            cell.preservesSuperviewLayoutMargins = false;

            var lat: NSString! = ListArray.objectAtIndex(indexPath.row)["lat"] as! NSString
            var lng: NSString! = ListArray.objectAtIndex(indexPath.row)["lng"] as! NSString
            var description: String! = ListArray.objectAtIndex(indexPath.row)["description"] as! String
            var distance: NSString = ListArray.objectAtIndex(indexPath.row)["distance"] as! NSString
            cell.lat = lat.doubleValue
            cell.lng = lng.doubleValue
            cell.title = description
            cell.distance = "\(distance)KM"
            cell.parent = self

            return cell;
        }
        else{

            var id: String! = ListArray.objectAtIndex(indexPath.row)["id"] as! String
            var fbid: String? = ListArray.objectAtIndex(indexPath.row)["fbid"] as? String
            var createby: String! = ListArray.objectAtIndex(indexPath.row)["createby"] as! String
            var description: String? = ListArray.objectAtIndex(indexPath.row)["description"] as? String
            var name: String? = ListArray.objectAtIndex(indexPath.row)["name"] as? String
            var post_id: String! = ListArray.objectAtIndex(indexPath.row)["post_id"] as! String
            var createdate: String! = ListArray.objectAtIndex(indexPath.row)["createdate"] as! String
            var user_image: String! = ListArray.objectAtIndex(indexPath.row)["user_image"] as! String
            var userlat: String! = ListArray.objectAtIndex(indexPath.row)["userlat"] as! String
            var userlng: String! = ListArray.objectAtIndex(indexPath.row)["userlng"] as! String





            var cell:ConversationCell_1 = tableView.dequeueReusableCellWithIdentifier(ConversationCell_1.reuseIdentifier) as! ConversationCell_1
            cell.parent = self
            cell.profileid = createby
            cell.lat = userlat
            cell.lng = userlng


            cell.layoutMargins = UIEdgeInsetsZero;
            cell.preservesSuperviewLayoutMargins = false;

            let imgprofile:NSURL!
            if user_image == "" {
                imgprofile = NSURL(string: "http://graph.facebook.com/\(String(fbid!))/picture?type=normal");
            }
            else{
                imgprofile = NSURL(string: "http://api.underwhere.in/public/uploads/user_img/\(user_image)");
            }
            cell.imgUser.sd_setImageWithURL(imgprofile)
            cell.imgUser.clipsToBounds = true
            cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.width / 2

            cell.lblUser.text = name
            cell.lblDescription.text = description

            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let dateFromString = dateFormatter.dateFromString(createdate!)

            cell.lblCreatedate.text = timeAgoSinceDate(dateFromString!, false)


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
                        var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary
                        var rs: Int! = result?.objectForKey("result") as! Int
                        var countlike: Int! = result?.objectForKey("countLike") as! Int
                        if rs == 1{
                            if !contains(self.didLike,  id){
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
                        self.didCountLike.append(Int(id),Int(countlike))
                        
                    })
                    
                }
                
            });
            task.resume()
            
        }
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
