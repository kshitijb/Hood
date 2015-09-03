//
//  PopButton.swift
//  Hood
//
//  Created by Abheyraj Singh on 10/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit

class PopButton: UIButton {
    
    func setSelectedWithAnimation(selectedValue: Bool){
        self.selected = selectedValue
        self.transform = CGAffineTransformMakeScale(0.7, 0.7)
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }) { (completed) -> Void in
        }
    }
}
