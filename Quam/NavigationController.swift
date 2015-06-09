//
//  NavigationController.swift
//  Quam
//
//  Created by Breeshy Sama on 3/23/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    var userid:String!
    override func viewDidLoad() {
        super.viewDidLoad()

        let fbloginmrg = FBSDKLoginManager()

        if let struserid = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String{
            userid = struserid
        }else{
            userid = ""
        }

        if userid == "" {
            let vc : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("registerview")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
        else{
            let vc : AnyObject! =  self.storyboard?.instantiateViewControllerWithIdentifier("tabview")
            self.showViewController(vc as! UIViewController, sender: vc)
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
