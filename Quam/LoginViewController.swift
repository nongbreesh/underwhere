//
//  LoginViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 1/15/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class LoginViewController: UIViewController{

    @IBOutlet var targetView: UIView!
    let spanX = 0.1
    let spanY = 0.1
    var islogout = false
    var issetloc:Bool = true
    var email:String!
    let fbloginmrg = FBSDKLoginManager()
    @IBOutlet weak var themap: MKMapView!
    //@IBOutlet var fbLoginView : FBLoginView!
    @IBOutlet var tf_email: UITextField!
    @IBOutlet var tf_password: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true


        //self.fbLoginView.delegate = self

        // self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]

        if (FBSDKAccessToken.currentAccessToken() != nil) {
            self.fbloginmrg.logOut()
        }

        let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.view.addGestureRecognizer(recognizer)


    }

    func handleTap(recognizer: UITapGestureRecognizer) {
        self.tf_email.resignFirstResponder()
        self.tf_password.resignFirstResponder()
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }



    @IBAction func btn_back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }



    @IBAction func btn_login(sender: AnyObject) {
        if tf_email.text == "" {
            let alertController = UIAlertController(title: "Login Error", message:
                "Email is required", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

            self.presentViewController(alertController, animated: true, completion: nil)

        }
        else if !isValidEmail(tf_email.text!) {
            let alertController = UIAlertController(title: "Register Error", message:
                "Email is wrong format", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if self.tf_password.text == ""{
            let alertController = UIAlertController(title: "Login Error", message:
                "Password is required", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

            self.presentViewController(alertController, animated: true, completion: nil)
        }else{
            ActivityIndicatory(self.view ,true,false)
            //        ActivityIndicatory(self.view ,true,false)
            let url = NSURL(string:"http://api.underwhere.in/api/user_login")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "email=\(tf_email.text)&password=\(tf_password.text)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

            let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                if(error == nil){
                    dispatch_async(dispatch_get_main_queue(), {


                        let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer())

                        var _result = result!.objectForKey("result") as? String
                         let fbid = result!.objectForKey("fbid") as? String
                        let userid = result!.objectForKey("userid") as? String
                        let is_posttowall = result!.objectForKey("is_posttowall") as? String


                        if userid != "0" {
                            NSUserDefaults.standardUserDefaults().setObject(userid, forKey: "userid")
                            NSUserDefaults.standardUserDefaults().setObject(is_posttowall, forKey: "is_posttowall")


                            self.navigationController!.interactivePopGestureRecognizer!.enabled = false

                            self.islogout = false

                            if fbid != "0" {
                            self.fbloginmrg.logInWithReadPermissions( ["public_profile", "user_friends","email"], handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                                if error == nil {
//                                    FBSession.openActiveSessionWithPermissions(["publish_actions"], allowLoginUI: true) { (session:FBSession!, state:FBSessionState, error:NSError!) -> Void in
//                                    }

                                }
                                })


                                }

                            ActivityIndicatory(self.view ,false,false)
                            let vc : AnyObject! =  self.storyboard?.instantiateViewControllerWithIdentifier("tabview")
                            self.showViewController(vc as! UIViewController, sender: vc)
                        }
                        else{
                            ActivityIndicatory(self.view ,false,false)
                            let alertController = UIAlertController(title: "Login Error", message:
                                "Email or Password is wrong!", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    })

                }

            })
            task.resume()
        }
    }





    @IBAction func btn_fblogin(sender: AnyObject) {


        ActivityIndicatory(self.view ,true,false)
        // Whenever a person opens app, check for a cached session

        self.fbloginmrg.logInWithReadPermissions( ["public_profile", "user_friends","email"], handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in

            if error != nil{
                let alert = UIAlertController(title: "Login error!", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else if result.isCancelled {
                print(result)
            }
            else{
                let fbRequest = FBSDKGraphRequest(graphPath:"me", parameters: nil);
                fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in

                    if error == nil {
                        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
                        let session = NSURLSession(configuration: configuration)

                        let fbid: AnyObject! = result.objectForKey("id")
                        let gender: AnyObject! = result.objectForKey("gender")
                        if  result.objectForKey("email") != nil {
                            self.email = result.objectForKey("email") as! String
                        }
                        else{
                            self.email = ""
                        }
                        let first_name: AnyObject! = result.objectForKey("first_name")
                        let last_name: AnyObject! = result.objectForKey("last_name")
                        let name: AnyObject! = result.objectForKey("name")

                        let url = NSURL(string:"http://api.underwhere.in/api/check_register")
                        let request = NSMutableURLRequest(URL:url!)
                        request.HTTPMethod = "POST"
                        let postString = "fbid=\(fbid)&name=\(name)&firstname=\(first_name)&last_name=\(last_name)&gender=\(gender)&email=\(self.email)"
                        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                            data, response, error in

                            if error != nil {
                                ActivityIndicatory(self.view,false,false)
                                print("error=\(error)")
                                return
                            }

                            dispatch_async(dispatch_get_main_queue(), {

                              let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer())
                                ActivityIndicatory(self.view,false,false)

                                let data = result!.objectForKey("result") as? String
                                let userid = result!.objectForKey("userid") as? String
                                let is_posttowall = result!.objectForKey("is_posttowall") as? String

                                if(data == "0"){

                                    FBSession.openActiveSessionWithPermissions(["publish_actions"], allowLoginUI: true) { (session:FBSession!, state:FBSessionState, error:NSError!) -> Void in
                                    }

                                    var types: UIUserNotificationType = UIUserNotificationType.Badge |
                                        UIUserNotificationType.Alert |
                                        UIUserNotificationType.Sound

                                    let settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )

                                    UIApplication.sharedApplication().registerUserNotificationSettings( settings )
                                    UIApplication.sharedApplication().registerForRemoteNotifications()

                                    //
                                    //                                    var type = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
                                    //                                    var setting = UIUserNotificationSettings(forTypes: type, categories: nil)
                                    //                                    UIApplication.sharedApplication().registerUserNotificationSettings(setting)
                                    //                                    UIApplication.sharedApplication().registerForRemoteNotifications()


                                    NSUserDefaults.standardUserDefaults().setObject(userid, forKey: "userid")
                                    NSUserDefaults.standardUserDefaults().setObject(is_posttowall, forKey: "is_posttowall")
                                     self.navigationController!.interactivePopGestureRecognizer!.enabled = false
                                    self.islogout = false
                                    let vc : AppTabBarController! =  self.storyboard?.instantiateViewControllerWithIdentifier("tabview") as! AppTabBarController
                                    self.showViewController(vc, sender: vc)

                                    return
                                }
                            })
                        }
                      task.resume()
                        
                    } else {
                        
                        ActivityIndicatory(self.view,false,false)
                        
                        print("Error Getting Info \(error)");
                        
                    }
                }
            }
        })
    }
    
    
    
}
