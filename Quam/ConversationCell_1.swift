//
//  ConversationCell_1.swift
//  Quam
//
//  Created by Breeshy Sama on 1/30/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class ConversationCell_1: UITableViewCell {

    @IBOutlet var lblCreatedate: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var lblUser: UILabel!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet weak var contentview: UIView!
    var profileid:String!
    var lat:String!
    var lng:String!
       var parent:UIViewController!

       @IBOutlet weak var bgview: UIView!
    class var reuseIdentifier: String {
        get {
            return "ConversationCell_1"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.lblUser.textColor = colorize(0x2cc285, alpha: 1)
        self.lblDescription.textColor = colorize(0x4C4C4C, alpha: 1)
        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = false;
        self.contentview.backgroundColor = colorize(0xDFE2E5, alpha: 1)
        self.bgview.backgroundColor = UIColor.whiteColor()
        //self.bgview.layer.cornerRadius = 2.0
        self.bgview.layer.masksToBounds = false;

        let tapProfile = UITapGestureRecognizer(target: self, action: Selector("openProfile:"))
        self.lblUser.addGestureRecognizer(tapProfile)
        self.lblUser.userInteractionEnabled = true

        self.imgUser.addGestureRecognizer(tapProfile)
        self.imgUser.userInteractionEnabled = true

    }

    func openProfile(gesture:UIGestureRecognizer!){
        if self.profileid != nil {
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            self.parent.navigationController?.navigationBarHidden = false
            let vc : ProfileViewController! =  self.parent.storyboard?.instantiateViewControllerWithIdentifier("profile") as! ProfileViewController
            vc.profileid = self.profileid
            vc.userlat = self.lat
            vc.userlng = self.lng
            self.parent.showViewController(vc as UIViewController, sender: vc)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
