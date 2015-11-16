//
//  DirectoryCell.swift
//  Pipal
//
//  Created by Abheyraj Singh on 10/11/15.
//  Copyright © 2015 Housing Labs. All rights reserved.
//

import UIKit

class DirectoryCell: UICollectionViewCell {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userName: UILabel!
    
    override func awakeFromNib() {
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.layer.masksToBounds = true
        self.profileImage.layer.shouldRasterize = true
        self.profileImage.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
}
