//
//  UserHeaderCell.swift
//  Quam
//
//  Created by Breeshy Sama on 1/8/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class UserHeaderCell: UITableViewCell {

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTokenPoint: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!

    class var reuseIdentifier: String {
        get {
            return "UserHeaderCell"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    


}
