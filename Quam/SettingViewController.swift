//
//  SettingViewController.swift
//  Quam
//
//  Created by Breeshy Sama on 5/4/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController,UITableViewDelegate {
    var userloginid = ""
    @IBOutlet var tb: UITableView!
    @IBOutlet var settingview: UITableViewCell!
    @IBOutlet var switch_pushnoti: UISwitch!
    @IBOutlet var switch_posttowall: UISwitch!
    let fbloginmrg = FBSDKLoginManager()
    @IBOutlet var lbl_isfbconnected: UILabel!
    @IBOutlet var btnlogout: UIButton!
    @IBOutlet var cell_fb_connect: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingview.backgroundColor = UIColor.clearColor()
        self.btnlogout.layer.cornerRadius = 5
        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            self.userloginid = struserid
        }


    }

    func fbConect(recognizer: UITapGestureRecognizer) {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRectMake(250,0, 50, 50)
        activityIndicator.startAnimating()
        self.cell_fb_connect.addSubview(activityIndicator)
        self.lbl_isfbconnected.hidden = true
        //email มันยังไม่ให้
        self.fbloginmrg.logInWithReadPermissions( ["public_profile", "user_friends","email"], handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in

            if error != nil{
                var alert = UIAlertController(title: "Login error!", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else if result.isCancelled {
                print(result)
            }
            else{
                var fbRequest = FBSDKGraphRequest(graphPath:"me", parameters: nil);
                fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in

                    if error == nil {
                        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
                        var session = NSURLSession(configuration: configuration)

                        var fbid: String! = result.objectForKey("id") as! String
                        var gender: String! = result.objectForKey("gender") as! String
                        if result.objectForKey("email") != nil{
                            var email: String! = result.objectForKey("email") as! String
                        }
                        else{
                            var email:String! =  ""
                        }

                        var first_name:String! = result.objectForKey("first_name") as! String
                        var last_name:String! = result.objectForKey("last_name") as! String
                        var name:String!  = result.objectForKey("name") as! String

                        let url = NSURL(string:"http://api.underwhere.in/api/fb_connect")
                        let request = NSMutableURLRequest(URL:url!)
                        request.HTTPMethod = "POST"
                        let postString = "userid=\(self.userloginid)&fbid=\(fbid)&firstname=\(first_name)&last_name=\(last_name)&gender=\(gender)"
                        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                            data, response, error in

                            if error != nil {
                                print("error=\(error)")
                                return
                            }

                            dispatch_async(dispatch_get_main_queue(), {
                                var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as! NSDictionary
                                var data = result.objectForKey("result") as? String
                                if(data == "success"){

                                    let delay = 3 * Double(NSEC_PER_SEC)
                                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                    dispatch_after(time, dispatch_get_main_queue()) {
                                        self.lbl_isfbconnected.text = "connected"
                                        self.lbl_isfbconnected.hidden = false
                                        activityIndicator.removeFromSuperview()
                                    }


                                }
                                else{
                                    let alertController = UIAlertController(title: "Connect Error", message:
                                        "This Facebook ID has been connected with another UnderWhere account", preferredStyle: UIAlertControllerStyle.Alert)
                                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

                                    self.presentViewController(alertController, animated: true, completion: nil)
                                    self.lbl_isfbconnected.hidden = false
                                    activityIndicator.removeFromSuperview()
                                }

                                self.lbl_isfbconnected.hidden = false
                                return

                            })
                        }
                        task.resume()

                    } else {

                        self.lbl_isfbconnected.hidden = false

                        print("Error Getting Info \(error)");

                    }
                }
            }
        })
    }


    override func viewWillAppear(animated: Bool){
        self.tabBarController?.title = "Setting"
          self.navigationController?.navigationBarHidden = false
        self.getData()
    }

    func getData(){
        let url = NSURL(string:"http://api.underwhere.in/api/getuser")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(self.userloginid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary


                    var data: AnyObject? = result?.objectForKey("result")
                    var slist =   [String:String]()

                    var fbid: String! = data?.objectForKey("fbid") as! String
                    var name: String?  = data?.objectForKey("name")as? String
                    var gender: String?  = data?.objectForKey("gender")as? String
                    var lat: String  = data?.objectForKey("lat")as! String
                    var lng: String  = data?.objectForKey("lng")as! String
                    var locname: String  = data?.objectForKey("locname")as! String
                    var count_post: String  = data?.objectForKey("count_post")as! String
                    var count_location: String  = data?.objectForKey("count_location")as! String
                    var is_push: NSString  = data?.objectForKey("is_push")as! NSString
                    var is_posttowall: NSString  = data?.objectForKey("is_posttowall")as! NSString

                    if is_push.intValue == 1 {
                        self.switch_pushnoti.setOn(true, animated:true)
                    } else {
                        self.switch_pushnoti.setOn(false, animated:true)
                    }



                    if is_posttowall.intValue == 1 {
                        self.switch_posttowall.setOn(true, animated:true)
                    } else {
                        self.switch_posttowall.setOn(false, animated:true)
                    }

                    if fbid == "0"{

                        let recognizer = UITapGestureRecognizer(target: self, action: Selector("fbConect:"))
                        self.cell_fb_connect.addGestureRecognizer(recognizer)
                        self.lbl_isfbconnected.text = "not connect"
                        self.switch_posttowall.setOn(false, animated:false)
                        self.switch_posttowall.enabled = false
                    }
                    else{
                        self.lbl_isfbconnected.text = "connected"
                        self.switch_posttowall.enabled = true
                    }



                })

            }

        });
        task.resume()

    }


    @IBAction func btn_done(sender: AnyObject) {
        var isnoti = "0"
        var is_posttowall = "0"
        if self.switch_pushnoti.on{
            isnoti = "1"
        }
        else{
            isnoti = "0"
        }


        if self.switch_posttowall.on{
            is_posttowall = "1"
        }
        else{
            is_posttowall = "0"
        }

        NSUserDefaults.standardUserDefaults().setObject(is_posttowall, forKey: "is_posttowall")


        // println(self.userloginid)

        let url = NSURL(string:"http://api.underwhere.in/api/usersetting")
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "userid=\(self.userloginid)&isnoti=\(isnoti)&is_posttowall=\(is_posttowall)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

            if(error == nil){
                dispatch_async(dispatch_get_main_queue(), {
                    var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary
                    var data: AnyObject? = result?.objectForKey("result")

//                    self.navigationController?.popToRootViewControllerAnimated(true)
                      self.navigationController?.popViewControllerAnimated(true)

                })

            }

        });
        task.resume()


    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let vc : WebViewController! =  self.storyboard?.instantiateViewControllerWithIdentifier("webview") as! WebViewController
        let celltitle = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text as String!
        if celltitle != nil{
            switch celltitle{
            case "About" :
                vc.pagetitle = "About"
                vc.url = "http://api.underwhere.in/api/about"

                self.showViewController(vc, sender: vc)
                break;
            case "Feedback" :
                vc.pagetitle = "Feedback"
                vc.url = "http://api.underwhere.in/api/feedback"

                self.showViewController(vc, sender: vc)
                break;
            default :
                break;
            }
        }
    }


    @IBAction func btn_logout(sender: AnyObject) {


        let refreshAlert = UIAlertController(title: "Warning", message: "Do you want to Logout?", preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.view.tintColor = UIColor.grayColor()

        refreshAlert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action: UIAlertAction!) in


            NSUserDefaults.standardUserDefaults().setObject("", forKey: "userid")
            let fbloginmrg = FBSDKLoginManager()
            FBSession.activeSession().closeAndClearTokenInformation()
            fbloginmrg.logOut()

            let vc : RegisterViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("registerview") as! RegisterViewController
            vc.islogout = true
            self.showViewController(vc, sender: vc)
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancle", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
        

    }
}
