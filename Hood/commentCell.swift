//
//  commentCell.swift
//  Hood
//
//  Created by Robin Malhotra on 12/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {
    @IBOutlet weak var timestampLabel: UILabel!

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
