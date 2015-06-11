

import UIKit


class RegisterViewController: UIViewController ,UIGestureRecognizerDelegate{


    @IBOutlet var targetView: UIView!
    let spanX = 0.1
    let spanY = 0.1
    var islogout = false
    var issetloc:Bool = true
    let fbloginmrg = FBSDKLoginManager()
    var email:AnyObject!
    var fbid:AnyObject!
    var gender:AnyObject!
    var name:AnyObject!
    var first_name:AnyObject!
    var last_name:AnyObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            self.fbloginmrg.logOut()
        }
    }

    override func viewWillAppear(animated: Bool){
        self.navigationController?.interactivePopGestureRecognizer.delegate = self
    }


    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if islogout {
            return false;
        }
        else{
            return true;
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btn_fblogin(sender: AnyObject) {


        ActivityIndicatory(self.view ,true,false)
        // Whenever a person opens app, check for a cached session

        //email มันยังไม่ให้
        self.fbloginmrg.logInWithReadPermissions( ["public_profile", "user_friends","email"], handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in

            if error != nil{
                var alert = UIAlertController(title: "Login error!", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else if result.isCancelled {
               // println(result)
                 ActivityIndicatory(self.view,false,false)
            }
            else{
                var fbRequest = FBSDKGraphRequest(graphPath:"me", parameters: nil);
                fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in

                    if error == nil {
                        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
                        var session = NSURLSession(configuration: configuration)

                        self.fbid = result.objectForKey("id")
                        self.gender = result.objectForKey("gender")
                        if result.objectForKey("email") != nil{
                            self.email = result.objectForKey("email")
                        }
                        else{
                            self.email =  ""
                        }

                        self.first_name = result.objectForKey("first_name")
                        self.last_name = result.objectForKey("last_name")
                        self.name = result.objectForKey("name")

                        let url = NSURL(string:"http://api.underwhere.in/api/check_register")
                        let request = NSMutableURLRequest(URL:url!)
                        request.HTTPMethod = "POST"
                        let postString = "fbid=\(self.fbid)&name=\(self.name)&firstname=\(self.first_name)&last_name=\(self.last_name)&gender=\(self.gender)&email=\(self.email)"
                        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                            data, response, error in

                            if error != nil {
                                print("error=\(error)")
                                return
                            }

                            dispatch_async(dispatch_get_main_queue(), {
                                var result = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as! NSDictionary
                                ActivityIndicatory(self.view,false,false)

                                var data = result.objectForKey("result") as? String
                                var userid = result.objectForKey("userid") as? String
                                var is_posttowall = result.objectForKey("is_posttowall") as? String

                                if(data == "1"){

                                    FBSession.openActiveSessionWithPermissions(["publish_actions"], allowLoginUI: true) { (session:FBSession!, state:FBSessionState, error:NSError!) -> Void in
                                    }

                                    var types: UIUserNotificationType = UIUserNotificationType.Badge |
                                        UIUserNotificationType.Alert |
                                        UIUserNotificationType.Sound

                                    var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )

                                    self.navigationController!.interactivePopGestureRecognizer.enabled = false

                                    self.islogout = true
                                    let vc : RegisterFillViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("register_fill") as! RegisterFillViewController
                                    vc.fbid = self.fbid
                                    vc.gender = self.gender
                                    vc.first_name = self.first_name
                                    vc.last_name   =  self.last_name
                                    vc.name = self.name as! String
                                    vc.email = self.email as! String
                                    self.showViewController(vc, sender: vc)



                                    return
                                }
                                else{

                                    FBSession.openActiveSessionWithPermissions(["publish_actions"], allowLoginUI: true) { (session:FBSession!, state:FBSessionState, error:NSError!) -> Void in
                                    }

                                    var types: UIUserNotificationType = UIUserNotificationType.Badge |
                                        UIUserNotificationType.Alert |
                                        UIUserNotificationType.Sound

                                    var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )

                                    self.islogout = false

                                    UIApplication.sharedApplication().registerUserNotificationSettings( settings )
                                    UIApplication.sharedApplication().registerForRemoteNotifications()

                                    NSUserDefaults.standardUserDefaults().setObject(userid, forKey: "userid")
                                    NSUserDefaults.standardUserDefaults().setObject(is_posttowall, forKey: "is_posttowall")
                                     self.navigationController!.interactivePopGestureRecognizer!.enabled = false
                                    let vc : AnyObject! =  self.storyboard?.instantiateViewControllerWithIdentifier("tabview")
                                    self.showViewController(vc as! UIViewController, sender: vc)
                                    
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
