//
//  NearByPlaceViewCell.swift
//  Quam
//
//  Created by Breeshy Sama on 5/18/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class NearByPlaceViewCell: UITableViewCell {


    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var lblCreateby: UILabel!
    @IBOutlet weak var imgcreateby: UIImageView!
    @IBOutlet weak var Countfollowing: UILabel!
    @IBOutlet weak var Distance: UILabel!
    var id:String = ""
    var cntfollowing:Int = 0
    var userid:String = ""
    class var reuseIdentifier: String {
        get {
            return "NearByPlaceViewCell"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblPlaceName.textColor = colorize(0x3B4048, alpha: 1)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
}
