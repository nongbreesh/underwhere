//
//  FeedViewCell.swift
//  Quam
//
//  Created by Breeshy Sama on 4/2/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class FeedViewCell_no_Image: UITableViewCell {

    class var reuseIdentifier: String {
        get {
            return "FeedViewCell_no_Image"
        }
    }
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var bgview: UIView!
    @IBOutlet weak var botview: UIView!
    @IBOutlet weak var lbl_createby: UILabel!
    @IBOutlet weak var img_userpost: UIImageView!

    @IBOutlet weak var lbl_description: UILabel!
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var lbl_createdate: UILabel!

    @IBOutlet weak var lblcountcomment: UILabel!

    @IBOutlet weak var lbl_range: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = false;
        self.contentview.backgroundColor = colorize(0xE0E0E0, alpha: 1)
        self.botview.backgroundColor = colorize(0xF8F8F8, alpha: 1)
        self.lbl_createby.textColor = colorize(0x161616, alpha: 1)
        self.lbl_createdate.textColor = colorize(0xAAAAAA, alpha: 1)
        self.lbl_description.textColor = colorize(0x363636, alpha: 1)
        self.line.backgroundColor = colorize(0xE2E2E2, alpha: 1)

        self.bgview.backgroundColor = UIColor.whiteColor()
        self.bgview.layer.cornerRadius = 5.0
        self.bgview.layer.masksToBounds = false;


        self.botview.layer.cornerRadius  = 5.0
        self.botview.layer.masksToBounds = true;
        self.botview.clipsToBounds = true;


        //self.bgview.layer.borderColor = colorize(0xE2E2E2, alpha: 1).CGColor
        //self.bgview.layer.borderWidth = 1.0;



        self.bgview.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.bgview.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        self.bgview.layer.shadowOpacity = 0.2
        self.bgview.layer.shadowRadius = 0.5
        self.bgview.layer.masksToBounds = true
        self.bgview.clipsToBounds = false

    }



    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

