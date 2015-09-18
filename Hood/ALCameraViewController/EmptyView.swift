//
//  emptyView.swift
//  Pipal
//
//  Created by Robin Malhotra on 09/09/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit

class EmptyView: UIView {

    @IBOutlet weak var youLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var shareFirstPostLabel: UILabel!
    @IBOutlet weak var imageToTint: UIImageView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    func initWithFrameAndColor(frame:CGRect,color:UIColor)
    {
        self.frame = frame
        let tintView = UIView(frame: imageToTint.frame)
        tintView.backgroundColor = color
        tintView.alpha = 0.1
        self.addSubview(tintView)

//        imageToTint.tintColor = color
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
