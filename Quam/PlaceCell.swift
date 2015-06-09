//
//  PlaceCell.swift
//  Quam
//
//  Created by Breeshy Sama on 1/7/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class PlaceCell: UITableViewCell {

    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var lblCreateby: UILabel!
    @IBOutlet weak var lblcntfollowing: UILabel!
     @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var imgcreateby: UIImageView!


     @IBOutlet weak var imgfollowing1: UIImageView!
     @IBOutlet weak var imgfollowing2: UIImageView!
     @IBOutlet weak var imgfollowing3: UIImageView!
     @IBOutlet weak var imgfollowing4: UIImageView!
     @IBOutlet weak var imgfollowing5: UIImageView!

    var ListArray = NSMutableArray()

    class var reuseIdentifier: String {
        get {
            return "PlaceCell"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.imgfollowing1.hidden = true
//        self.imgfollowing2.hidden = true
//        self.imgfollowing3.hidden = true
//        self.imgfollowing4.hidden = true
//        self.imgfollowing5.hidden = true
         self.lblPlaceName.textColor = colorize(0x2cc285, alpha: 1)
        self.lblCreateby.textColor = colorize(0xf96d6c, alpha: 1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    
}
