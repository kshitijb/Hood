//
//  Utilities.swift
//  Hood
//
//  Created by Robin Malhotra on 07/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import UIKit

let PipalGlobalColor:UIColor = UIColor(red: 97/255, green: 199/255, blue: 144/255, alpha: 1)

func getImageWithColor(color: UIColor, size: CGSize) -> UIImage
{
    let rect = CGRectMake(0, 0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}


struct Utilities
{
    static func timeStampFromDate(str:String) -> String
    {
        print(str)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        if let date = dateFormatter.dateFromString(str)
        {
            let now = NSDate()
            let timeInterval = now.timeIntervalSinceDate(date)
            println(timeInterval)
            
            switch(timeInterval)
            {
                case _ where timeInterval < 3600:
                    return "Just now"
                case _ where timeInterval > 3600 && timeInterval < 24 * 3600 :
                    return "\(Int(timeInterval/3600)) hours ago"
                default :
                    // change to a readable time format and change to local time zone
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.timeZone = NSTimeZone(name: "IST")
                    let timeStamp = dateFormatter.stringFromDate(date)
                    print(timeStamp)
                    return timeStamp
            }
           
        }
        else
        {
            return "unknown time"
        }
        
    }
    
    static func setUpLineSpacingForLabel(label:UILabel){
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        var attrString = NSMutableAttributedString(string: label.text!)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "Lato-Regular", size: 18)!, range:NSMakeRange(0, attrString.length))
        label.attributedText = attrString
    }
}