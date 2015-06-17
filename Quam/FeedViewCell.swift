//
//  FeedViewCell.swift
//  Quam
//
//  Created by Breeshy Sama on 4/2/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class FeedViewCell: UITableViewCell,UIActionSheetDelegate{

    class var reuseIdentifier: String {
        get {
            return "FeedViewCell"
        }
    }

    @IBOutlet var Vetilcal_Space: NSLayoutConstraint!
    @IBOutlet var btnaddplace: UIButton!
    var parent:UIViewController!
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var bgview: UIView!
    @IBOutlet weak var botview: UIView!
    @IBOutlet weak var lbl_createby: UILabel!
    @IBOutlet weak var img_userpost: UIImageView!
    @IBOutlet weak var img_post: UIImageView!
    @IBOutlet weak var btn_love: UIButton!
    var locid:String!
    var locname:String!
    var lat:String!
    var lng:String!

    @IBOutlet weak var lblLove: UILabel!

    @IBOutlet weak var lblcountcomment: UILabel!
    @IBOutlet weak var lbl_description: UILabel!
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var lbl_createfrom: UILabel!
    var TRY_AN_ANIMATED_GIF = 0

    @IBOutlet var btnMore: UIButton!
    @IBOutlet weak var lbl_range: UILabel!
    var createby = ""
    var id:String = ""
    var postid:String = ""
    var cntfollowing:Int = 0
    var userid:String = ""
    var profileid:String!
    var createBy =  ""





    override func awakeFromNib() {
        super.awakeFromNib()

        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = false;

        self.contentview.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        self.botview.backgroundColor = colorize(0xFFFFFF, alpha: 1)
        self.lbl_createfrom.textColor = colorize(0xAAAAAA, alpha: 1)
        self.lbl_description.textColor = colorize(0x4C4C4C, alpha: 1)
        self.lbl_createby.textColor = colorize(0x2cc285, alpha: 1)

        self.bgview.backgroundColor = UIColor.whiteColor()
        self.bgview.layer.cornerRadius = 2.0
        self.bgview.layer.masksToBounds = false;


        // self.botview.layer.cornerRadius  = 5.0
        self.botview.layer.masksToBounds = true;
        self.botview.clipsToBounds = true;



        //        var aspectRatioMult:CGFloat = (self.img_post.image!.size.width / self.img_post.image!.size.height);
        //
        //        println(aspectRatioMult)
        //        // Constrain the desired aspect ratio
        //        self.img_post.addConstraint(NSLayoutConstraint(item: self.img_post, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.img_post, attribute: NSLayoutAttribute.Height, multiplier: aspectRatioMult, constant: 0))
        //
        //        // Constrain height
        //        self.img_post.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView(<=max)]", options: NSLayoutFormatOptions(0), metrics: ["max" : "1000"], views: ["imageView" : self.img_post]))
        //
        //
        //        // Constrain width
        //        self.img_post.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(<=max)]", options: NSLayoutFormatOptions(0), metrics: ["max" : "1000"], views: ["imageView" : self.img_post]))





        self.bgview.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.bgview.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.bgview.layer.shadowOpacity = 0.3
        self.bgview.layer.shadowRadius = 1
        self.bgview.layer.masksToBounds = false
        self.bgview.clipsToBounds = false

        //Add Gesture Recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("imageTapped:"))
        tapGesture.numberOfTapsRequired = 1
        img_post!.addGestureRecognizer(tapGesture)
        img_post!.userInteractionEnabled = true
        //
        //        self.img_post!.accessibilityLabel = "Photo of a cat wearing a Bane costume."

        //        var tapLoveGesture = UITapGestureRecognizer(target: self, action: Selector("imageLoveTapped:"))
        //        tapGesture.numberOfTapsRequired = 1
        //        img_love!.addGestureRecognizer(tapLoveGesture)
        //        img_love!.userInteractionEnabled = true


        self.btn_love.addTarget(self, action: "btnLoveClick:", forControlEvents: UIControlEvents.TouchUpInside)


        let tapPlace = UITapGestureRecognizer(target: self, action: Selector("openPlace:"))
        self.lbl_createby.addGestureRecognizer(tapPlace)
        self.lbl_createby.userInteractionEnabled = true

        let tapProfile = UITapGestureRecognizer(target: self, action: Selector("openProfile:"))
        self.lbl_createfrom.addGestureRecognizer(tapProfile)
        self.lbl_createfrom.userInteractionEnabled = true

        self.img_userpost.addGestureRecognizer(tapProfile)
          self.img_userpost.userInteractionEnabled = true
    }

    func btnLoveClick(sender:UIButton!){

        let delay = 0.3 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            if self.postid.toInt()! != 0{
                let url = NSURL(string:"http://api.underwhere.in/api/getLove")
                let request = NSMutableURLRequest(URL:url!)
                request.HTTPMethod = "POST"
                let postString = "userid=\(self.userid)&postid=\(self.postid)"
                request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

                let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                    if(error == nil){
                        dispatch_async(dispatch_get_main_queue(), {

                          let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary

                            let rs: Int! = result?.objectForKey("result") as! Int
                            if rs > 0{
                                self.lblLove.text = "+\(rs)"
                            }
                            else{
                                self.lblLove.text = "+\(rs)"
                            }

                        })

                    }

                })
                task.resume()

            }
        }



    }



    @IBAction func btnaddplace(sender: AnyObject) {
        if id != "0"{
            btnaddplace.enabled = false
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            let x:CGFloat = (self.btnaddplace.frame.width / 2) - 15
            let y:CGFloat = (self.btnaddplace.frame.height / 2) - 15
            activityIndicator.frame = CGRectMake(x, y, 30, 30)
            activityIndicator.startAnimating()



            self.btnaddplace.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Normal)
            self.btnaddplace.addSubview(activityIndicator)



            let url = NSURL(string:"http://api.underwhere.in/api/addfollow")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            //println(self.locations_id)
            let postString = "userid=\(self.userid)&locationid=\(self.id)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

            let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {

                        var result = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as! NSDictionary
                        let data: AnyObject? = result.objectForKey("result")
                        self.btnaddplace.setBackgroundImage(UIImage(named: "btn_addedplace.png"), forState: UIControlState.Normal)
                        activityIndicator.removeFromSuperview()

                    })

                }

            })
            task.resume()

        }

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }






    func openProfile(gesture:UIGestureRecognizer!){
        if self.profileid != nil {
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            //self.parent.navigationController?.navigationBarHidden = false
            let vc : ProfileViewController! =  self.parent.storyboard?.instantiateViewControllerWithIdentifier("profile") as! ProfileViewController
            vc.profileid = self.profileid
            vc.userlat = self.lat
            vc.userlng = self.lng
            vc.title = createBy
            self.parent.showViewController(vc as UIViewController, sender: vc)
        }
    }


    func openPlace(gesture:UIGestureRecognizer!){
        if self.locid != nil {
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            //self.parent.navigationController?.navigationBarHidden = false
            let vc : FeedviewController! =  self.parent.storyboard?.instantiateViewControllerWithIdentifier("Feedview") as! FeedviewController
            vc.locationid = self.locid
            vc.lat = self.lat
            vc.lng = self.lng
            vc.locname = self.locname
            self.parent.showViewController(vc as UIViewController, sender: vc)
        }
    }


    func imageTapped(gesture:UIGestureRecognizer!){
        let imageInfo:JTSImageInfo  = JTSImageInfo()

        if TRY_AN_ANIMATED_GIF == 1{
            imageInfo.imageURL =  NSURL(string:"http://media.giphy.com/media/O3QpFiN97YjJu/giphy.gif")
        }
        else{
            imageInfo.image = self.img_post.image
        }


        imageInfo.referenceRect = self.img_post.frame
        imageInfo.referenceView = self.img_post.superview
        imageInfo.referenceContentMode = self.img_post.contentMode
        imageInfo.referenceCornerRadius = self.img_post.layer.cornerRadius
        
        
        // Setup view controller
        let imageViewer:JTSImageViewController =  JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Scaled)
        
        
        // Present the view controller.
        imageViewer.showFromViewController(self.parent, transition: JTSImageViewControllerTransition._FromOriginalPosition)
        
    }
    
}
