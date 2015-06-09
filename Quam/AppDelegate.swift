//
//  AppDelegate.swift
//  Quam
//
//  Created by Breeshy Sama on 11/9/2557 BE.
//  Copyright (c) 2557 Breeshy Sama. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?

    //var locationManager = CLLocationManager()
    var timer:NSTimer!
    var Activenotitimer:NSTimer!
    var notitimer:NSTimer!
    var userid:NSString = ""
    var navController:NavigationController!
    var type = ""
    var postid = ""

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {


        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            self.userid = struserid
        }else{
            self.userid = ""
        }



        //timer = NSTimer.scheduledTimerWithTimeInterval(60 * 5, target: self, selector: Selector("handleTimer:"), userInfo: nil, repeats: true) // update location  ทุกๆ 5 นาที



        //        self.timer.invalidate()
        //        self.timer = nil


        let tabbar  = UITabBar.appearance()
        let navigationBarAppearace = UINavigationBar.appearance()

        //self.window?.backgroundColor = uicolorFromHex(0x773c9f)
//        self.window?.tintColor = uicolorFromHex(0xad82c7)
        navigationBarAppearace.tintColor = uicolorFromHex(0xFFFFFF)
        navigationBarAppearace.barTintColor = uicolorFromHex(0x2cc285)
       // navigationBarAppearace.layer.borderWidth = 0


//        navigationBarAppearace.shadowImage = UIImage()
       navigationBarAppearace.translucent = true
//        navigationBarAppearace.setBackgroundImage(UIImage(named: "navbg"), forBarMetrics: UIBarMetrics.Default)




        // change navigation item title color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: uicolorFromHex(0x2cc285)], forState:.Selected)


//                tabbar.shadowImage = UIImage()
//                tabbar.translucent = false
//        tabbar.backgroundImage = UIImage(named: "tabbarbg")
        tabbar.tintColor = colorize(0x2cc285, alpha: 1)

        self.navController  = self.window!.rootViewController as! NavigationController


        let delay = 1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            if self.postid != "" {
                ControllerTransitionMediator.instance.sendFromDelegate(true)
            }
        }



        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }


    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject?) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }



    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0

        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }



    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {
//        Activenotitimer = NSTimer.scheduledTimerWithTimeInterval(60 * 1, target: self, selector: Selector("ActiveNotihandleTimer:"), userInfo: nil, repeats: true)
        self.postid = ""
        self.type = ""
    }

    func ActiveNotihandleTimer(timer: NSTimer){
        //println(timer)
        BadgeTransitionMediator.instance.sendUpdateBadge(true)
        NotificationTransitionMediator.instance.sendUpdateNotificationData(true)
    }



    //    func handleTimer(timer: NSTimer) {
    //        println(timer)
    //        self.locationManager.delegate = self
    //        self.locationManager.startUpdatingLocation()
    //    }
    //
    //
    //    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
    //        self.sendBackgroundLocationToServer(newLocation);
    //    }
    //
    //    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    //        println(manager)
    //    }



    //    func getFQloc(lat:Double!,lng:Double!){
    //        let fqurl = NSURL(string:"https://api.foursquare.com/v2/venues/search?ll=\(lat),\(lng)&oauth_token=RNECEIHZPPNZAXNR2EGXZCI55UDDKCM3HU1E42XNYVIDFMMK&v=20150401")
    //        let fqrequest = NSMutableURLRequest(URL:fqurl!)
    //        fqrequest.HTTPMethod = "GET"
    //        let fqtask = NSURLSession.sharedSession().dataTaskWithRequest(fqrequest) {
    //            data, response, error in
    //
    //            dispatch_async(dispatch_get_main_queue(), {
    //                var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary
    //                var fqlocname = " Unknow "
    //                if result?["response"]?.objectForKey("venues")?.count > 0 {
    //                    fqlocname = result!["response"]!.objectForKey("venues")![0]["name"]! as! String
    //                    self.updateLastLocation(lat,lng: lng,fqlocname: fqlocname)
    //                }
    //            })
    //
    //        }
    //        fqtask.resume()
    //    }

    //    func updateLastLocation(lat:Double!,lng:Double!,fqlocname:String){
    //        let url = NSURL(string:"http://api.underwhere.in/api/updatelastlocation")
    //        let request = NSMutableURLRequest(URL:url!)
    //        request.HTTPMethod = "POST"
    //        let postString = "userid=\(userid)&lat=\(lat)&lng=\(lng)&locname=\(fqlocname)"
    //        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
    //
    //        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in
    //
    //            if(error == nil){
    //                var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary
    //
    //                dispatch_async(dispatch_get_main_queue(), {
    //                })
    //            }
    //
    //        });
    //        task.resume()
    //
    //    }

    //    func sendBackgroundLocationToServer(location: CLLocation) {
    //        var bgTask = UIBackgroundTaskIdentifier()
    //        bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
    //            UIApplication.sharedApplication().endBackgroundTask(bgTask)
    //        }
    //
    //        self.getFQloc(location.coordinate.latitude,lng: location.coordinate.longitude)
    //
    //        if (bgTask != UIBackgroundTaskInvalid)
    //        {
    //            UIApplication.sharedApplication().endBackgroundTask(bgTask);
    //            bgTask = UIBackgroundTaskInvalid;
    //        }
    //    }

    func applicationWillEnterForeground(application: UIApplication) {
//        self.Activenotitimer.invalidate()
//        self.Activenotitimer = nil

        let delay = 1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            if self.postid != "" {
                ControllerTransitionMediator.instance.sendFromDelegate(true)
            }
        }


        application.beginBackgroundTaskWithExpirationHandler{}
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        application.beginBackgroundTaskWithExpirationHandler{}
    }

    func applicationWillTerminate(application: UIApplication) {
        application.beginBackgroundTaskWithExpirationHandler{}
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""

        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }

        self.registerDeviceToken(tokenString)

    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {

        print(error)

    }

    func registerDeviceToken(deviceToken:String){
        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            self.userid = struserid
        }else{
            self.userid = ""
        }

        let url = NSURL(string:"http://api.underwhere.in/api/registerDeviceToken")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(self.userid)&devicetoken=\(deviceToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)


        var returnData: NSData?
       
            returnData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: NSErrorPointer())


        var returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)
        print(returnString)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                dispatch_async(dispatch_get_main_queue(), {
                })

            }

        });
        task.resume()
    }


    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        if userInfo["aps"] != nil {
            self.type  = userInfo["aps"]?.objectForKey("type") as! String
            self.postid  = userInfo["aps"]?.objectForKey("id") as! String
            NSUserDefaults.standardUserDefaults().setObject(postid, forKey: "postid")
            NSUserDefaults.standardUserDefaults().setObject(type, forKey: "type")

            //ControllerTransitionMediator.instance.sendFromDelegate(true)
            BadgeTransitionMediator.instance.sendUpdateBadge(true)
            NotificationTransitionMediator.instance.sendUpdateNotificationData(true)
            
        }
        else{
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "postid")
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "type")
        }
        
    }
    
    
}




