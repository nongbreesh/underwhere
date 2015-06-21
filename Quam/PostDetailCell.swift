//
//  FeedViewCell.swift
//  Quam
//
//  Created by Breeshy Sama on 4/2/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class PostDetailCell: UITableViewCell{

    class var reuseIdentifier: String {
        get {
            return "PostDetailCell"
        }
    }

    var postid:Int!
    var userid:String!
    @IBOutlet var lblcountLike: UILabel!
    @IBOutlet weak var lblcomment: UILabel!
    var parent:UIViewController!
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var bgview: UIView!
    @IBOutlet weak var botview: UIView!
    @IBOutlet weak var lbl_createby: UILabel!
    @IBOutlet weak var img_userpost: UIImageView!
    @IBOutlet weak var img_post: UIImageView!
    var lat:String!
    var lng:String!

    @IBOutlet var btnLove: UIButton!
    @IBOutlet weak var lblcountcomment: UILabel!
    @IBOutlet weak var lbl_description: UILabel!
    @IBOutlet weak var lbl_createdate: UILabel!
    var TRY_AN_ANIMATED_GIF = 0
    var profileid:String!
    var createBy = ""

       @IBOutlet weak var img_user_like1: UIImageView!
       @IBOutlet weak var img_user_like2: UIImageView!
       @IBOutlet weak var img_user_like3: UIImageView!
       @IBOutlet weak var img_user_like4: UIImageView!
       @IBOutlet weak var img_user_like5: UIImageView!

    @IBOutlet weak var lbl_range: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()

        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = false;
        self.contentview.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        self.botview.backgroundColor = colorize(0xF3F3F5, alpha: 1)
        self.lbl_createby.textColor = colorize(0x2cc285, alpha: 1)
        self.lbl_createdate.textColor = colorize(0xAAAAAA, alpha: 1)
        self.lbl_description.textColor = colorize(0x4C4C4C, alpha: 1)

//        self.bgview.backgroundColor = UIColor.whiteColor()
        self.bgview.layer.cornerRadius = 3.0
//        self.bgview.layer.masksToBounds = false;

        

        self.bgview.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.bgview.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.bgview.layer.shadowOpacity = 0.3
        self.bgview.layer.shadowRadius = 1
        self.bgview.layer.masksToBounds = false
        self.bgview.clipsToBounds = false


        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("imageTapped:"))
        tapGesture.numberOfTapsRequired = 1
        img_post!.addGestureRecognizer(tapGesture)
        img_post!.userInteractionEnabled = true
        img_post!.accessibilityLabel = "Photo of a cat wearing a Bane costume"

        let tapProfile = UITapGestureRecognizer(target: self, action: Selector("openProfile:"))
        self.lbl_createdate.addGestureRecognizer(tapProfile)
        self.lbl_createdate.userInteractionEnabled = true

        self.img_userpost.addGestureRecognizer(tapProfile)
        self.img_userpost.userInteractionEnabled = true


    }


    @IBAction func btnLove(sender: AnyObject) {
        let delay = 0.3 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            if self.postid != 0{
                let url = NSURL(string:"http://api.underwhere.in/api/getLove")
                let request = NSMutableURLRequest(URL:url!)
                request.HTTPMethod = "POST"
                let postString = "userid=\(self.userid)&postid=\(self.postid)"
                request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

                let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                    if(error == nil){
                        dispatch_async(dispatch_get_main_queue(), {
                            var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary

                            var rs: Int! = result?.objectForKey("result") as! Int
                            if rs > 0{
                                self.lblcountLike.text = "\(rs) likes"
                            }
                            else{
                                self.lblcountLike.text = "\(rs) likes"
                            }
                        })

                    }

                })
                task.resume()
                
            }
        }
        

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

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

    func openProfile(gesture:UIGestureRecognizer!){
        if self.profileid != nil {
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            self.parent.navigationController?.navigationBarHidden = false
            let vc : ProfileViewController! =  self.parent.storyboard?.instantiateViewControllerWithIdentifier("profile") as! ProfileViewController
            vc.profileid = self.profileid
            vc.userlat = self.lat
            vc.userlng = self.lng
            vc.title = createBy
            self.parent.showViewController(vc as UIViewController, sender: vc)
        }
    }

}

