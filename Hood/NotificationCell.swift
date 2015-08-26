//
//  notificationCell.swift
//  Hood
//
//  Created by Robin Malhotra on 21/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import SwiftyJSON
class NotificationCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    var json = JSON.nullJSON
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setContents(jsonObject:JSON)
    {
        json = jsonObject
        profileImage.sd_setImageWithURL(NSURL(string: jsonObject["actor"]["profile_photo"].string!), placeholderImage: UIImage(named: "Me.jpg"))
        fullNameLabel.text = jsonObject["actor"]["firstname"].string! + " " + jsonObject["actor"]["lastname"].string!
        timestampLabel.text = Utilities.timeStampFromDate(jsonObject["timestamp"].string!)
        commentLabel.text = jsonObject["action"].string
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
