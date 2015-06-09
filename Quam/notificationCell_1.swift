//
//  ConversationCell_2.swift
//  Quam
//
//  Created by Breeshy Sama on 1/30/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class notificationCell_1: UITableViewCell {


    @IBOutlet var bg: UIView!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblDetail: UILabel!
    @IBOutlet var lblDate: UILabel!




    class var reuseIdentifier: String {
        get {
            return "notificationCell_1"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // self.lblDetail.textColor = colorize(0x2cc285, alpha: 1)
        self.lblDetail.textColor = colorize(0x4C4C4C, alpha: 1)


    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
