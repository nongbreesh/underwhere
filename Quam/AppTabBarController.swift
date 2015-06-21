//
//  AppTabBarControllerViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 1/9/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class AppTabBarController: UITabBarController,UITabBarDelegate,BadgeListener{
    @IBOutlet weak var btn_post: UIButton!
    @IBOutlet weak var btn_Openmap: UIButton!
    var userid = ""
    var name = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.hidden = false
        //        self.btn_Openmap.hidden = true
        //        self.btn_post.hidden = false
        self.navigationItem.title = "Happening"
        //        let logo = UIImage(named: "logo.png")
        //        let imageView = UIImageView(image:logo)
        //        self.navigationItem.titleView = imageView
        //self.navigationController?.navigationItem.titleView = imageView
        //navigationController?.navigationItem.title = "xxxx"
        self.tabBarController?.tabBar.delegate = self
        BadgeTransitionMediator.instance.setListener(self)


        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            self.userid = struserid
        }else{
            self.userid = ""
        }

        self.getData(self.userid)


        // Get tab bar and set base styles
//        let tabBar = self.tabBar;
//        tabBar.backgroundColor = UIColor.whiteColor()
//
//        // Without this, images can extend off top of tab bar
//        tabBar.clipsToBounds = true

        // For each tab item..
        //        for var i = 0; i < tabBar.items?.count; i++ {
        //            let tabBarItem = tabBar.items?[i] as! UITabBarItem
        //
        //            // Adjust tab images (Like mstysf says, these values will vary)
        ////            tabBarItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);
        ////            tabBarItem.title = ""
        //
        //
        //        }






    }


    func UpdateBadge(){
        self.getData(self.userid)
    }


    func activenotification (){
        let url = NSURL(string:"http://api.underwhere.in/api/activenotification")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary

                dispatch_async(dispatch_get_main_queue(), {
                    var tabArray = self.tabBar.items as NSArray!
                    var tabItem = tabArray.objectAtIndex(2) as! UITabBarItem
                    tabItem.badgeValue = nil
                })

            }

        });
        task.resume()
    }

    func getData(userid:String){

        let url = NSURL(string:"http://api.underwhere.in/api/getcountnotification")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(userid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary

                dispatch_async(dispatch_get_main_queue(), {

                    var data:String = result?.objectForKey("result") as! String

                    var tabArray = self.tabBar.items as NSArray!
                    var tabItem = tabArray.objectAtIndex(2) as! UITabBarItem
                    if data.toInt()! > 0{
                        tabItem.badgeValue =  data
                        UIApplication.sharedApplication().applicationIconBadgeNumber = data.toInt()!
                    }
                    else{
                        tabItem.badgeValue = nil
                        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                    }


                })

            }

        });
        task.resume()

    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }

    @IBAction func btn_Openmap(sender: AnyObject) {
        //println("map click")
        //
        //
        //        self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("mapview") as! MapViewController, animated: true)
    }


    @IBAction func btn_post(sender: AnyObject) {
        //        ActivityIndicatory(self.view ,true,false)
        //        PFUser.logOut()
        //        ActivityIndicatory(self.view ,false,false)
        //
        //        self.navigationController?.navigationBar.hidden = true
        //
        //
        //        let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("loginview")
        //        self.showViewController(vc as UIViewController, sender: vc)
    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem){
        let str:String = item.title as String!
        self.UpdateBadge()
        //println(str)
        switch str {
        case "Happening":
            self.navigationController?.navigationBarHidden = false
        case "Place":
            self.navigationController?.navigationBarHidden = false
        case "Suggest":
            self.navigationController?.navigationBarHidden = false
        case "Notification":
            self.navigationController?.navigationBarHidden = false
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            self.activenotification()
        case "Me":
            self.navigationController?.navigationBarHidden = true
        default:
            self.navigationController?.navigationBarHidden = false
        }

        
    }
    
    
    
    
    
    
}
