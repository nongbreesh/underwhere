//
//  SuggestPlaceViewCell.swift
//  Quam
//
//  Created by Breeshy Sama on 4/17/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class SuggestPlaceViewCell: UITableViewCell {

    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var lblCreateby: UILabel!
    @IBOutlet weak var imgcreateby: UIImageView!
    @IBOutlet weak var Countfollowing: UILabel!
    @IBOutlet weak var Distance: UILabel!
    var id:String = ""
    var cntfollowing:Int = 0
    var userid:String = ""
    class var reuseIdentifier: String {
        get {
            return "SuggestPlaceViewCell"
        }
    }

    @IBOutlet var btn_add: UIButton!

    @IBAction func btn_add(sender: AnyObject) {

        if id != "0"{
            btn_add.enabled = false
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            let x:CGFloat = (self.btn_add.frame.width / 2) - 15
            let y:CGFloat = (self.btn_add.frame.height / 2) - 15
            activityIndicator.frame = CGRectMake(x, y, 30, 30)
            activityIndicator.startAnimating()



            self.btn_add.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Normal)
            self.btn_add.addSubview(activityIndicator)
            //        println(id)


            let url = NSURL(string:"http://api.underwhere.in/api/addfollow")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            //println(self.locations_id)
            let postString = "userid=\(self.userid)&locationid=\(self.id)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

            let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {
                        var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                        var data: AnyObject? = result?.objectForKey("result")
                        self.btn_add.setBackgroundImage(UIImage(named: "btn_addedplace.png"), forState: UIControlState.Normal)
                        activityIndicator.removeFromSuperview()
                        self.Countfollowing.text = "\(self.cntfollowing + 1)"
                    })

                }

            });
            task.resume()

        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblPlaceName.textColor = colorize(0x3B4048, alpha: 1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
