//
//  RegisterFillViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 6/5/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class RegisterFillViewController: UIViewController ,UITextFieldDelegate{

    @IBOutlet var targetView: UIView!
    let spanX = 0.1
    let spanY = 0.1
    var islogout = false
    var issetloc:Bool = true
    var email:String!
    var fbid: AnyObject!
    var gender: AnyObject!
    var first_name: AnyObject!
    var last_name: AnyObject!
    var name: String!
    var password:String!

    let fbloginmrg = FBSDKLoginManager()

    @IBOutlet var tf_name: UITextField!

    @IBOutlet var tf_email: UITextField!

    @IBOutlet var tf_password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true

        self.tf_email.text = email
        self.tf_name.text = name
        self.tf_name.delegate = self

        let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.view.addGestureRecognizer(recognizer)

    }



    @IBAction func btn_back(sender: AnyObject) {
         self.navigationController?.popViewControllerAnimated(true)
    }


    func handleTap(recognizer: UITapGestureRecognizer) {
        self.tf_email.resignFirstResponder()
        self.tf_name.resignFirstResponder()
        self.tf_password.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func btn_register(sender: AnyObject) {
        if tf_name.text == "" {
            let alertController = UIAlertController(title: "Regiter Error", message:
                "Name is required", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        else if tf_email.text == "" {
            let alertController = UIAlertController(title: "Register Error", message:
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
            let alertController = UIAlertController(title: "Register Error", message:
                "Password is required", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

            self.presentViewController(alertController, animated: true, completion: nil)
        }else{
            ActivityIndicatory(self.view ,true,false)
            var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            var session = NSURLSession(configuration: configuration)
            self.email = self.tf_email.text
            self.password = self.tf_password.text
            self.name = self.tf_name.text
            if self.fbid == nil {
                self.fbid = "0"
            }
            let url = NSURL(string:"http://api.underwhere.in/api/user_register")
            let request = NSMutableURLRequest(URL:url!)
            request.HTTPMethod = "POST"
            let postString = "fbid=\(self.fbid)&name=\(self.name)&firstname=\(self.first_name)&last_name=\(self.last_name)&gender=\(self.gender)&email=\(self.email)&password=\(self.password)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
//
//            var returnData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
//
//            var returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)
//            println(returnString)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in

                if error != nil {
                    print("error=\(error)")
                    return
                }

                dispatch_async(dispatch_get_main_queue(), {
                    let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    ActivityIndicatory(self.view,false,false)

                    var data = result!.objectForKey("result") as? String

                    if(data == "success"){

                        var userid = result!.objectForKey("userid") as! String
                        var is_posttowall = result!.objectForKey("is_posttowall") as! String

                        var types: UIUserNotificationType = UIUserNotificationType.Badge |
                            UIUserNotificationType.Alert |
                            UIUserNotificationType.Sound

                        var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )

                        UIApplication.sharedApplication().registerUserNotificationSettings( settings )
                        UIApplication.sharedApplication().registerForRemoteNotifications()

                        NSUserDefaults.standardUserDefaults().setObject(userid, forKey: "userid")
                        NSUserDefaults.standardUserDefaults().setObject(is_posttowall, forKey: "is_posttowall")
                        
                        self.navigationController!.interactivePopGestureRecognizer!.enabled = true
                        
                        let vc : AnyObject! =  self.storyboard?.instantiateViewControllerWithIdentifier("tabview")
                        self.showViewController(vc as! UIViewController, sender: vc)
                        
                        return
                    }
                    else{
                         ActivityIndicatory(self.view,false,false)
                        let alertController = UIAlertController(title: "Register Error", message:
                            "This email address is already in use by another UnderWhere account", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                })
            }
            task.resume()
        }
    }
    
}
