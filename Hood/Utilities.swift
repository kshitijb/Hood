//
//  Utilities.swift
//  Hood
//
//  Created by Robin Malhotra on 07/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import UIKit

let AddedPostNotificationName = "AddedPost"
let AddingPostNotificationName = "AddingPost"
let JumpToChannelNotificationName = "JumpToChannel"
let UpdateBell = "updateBell"

struct GlobalColors{
    static let Green:UIColor = UIColor(hexString: "#1FC055")
    static let Purple: UIColor = UIColor(hexString: "#7323DC")
    static let Pink: UIColor = UIColor(hexString: "#E62878")
    static let Yellow: UIColor = UIColor(hexString: "#FCB100")
}

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

func linearTransition(x:CGFloat,y:CGFloat,offset:CGFloat)->CGFloat
{
    return x * (1.0 - offset) + offset * y
}


struct Utilities
{
    static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    static func timeStampFromDate(date:NSDate) -> String
    {
            let now = NSDate()
            let timeInterval = now.timeIntervalSinceDate(date)
            let dateFormatter = NSDateFormatter()
            switch(timeInterval)
            {
                case _ where timeInterval < 3600:
                    return "Just now"
                case _ where timeInterval > 3600 && timeInterval < 24 * 3600 :
                    return "\(Int(timeInterval/3600)) hours ago"
                case _ where timeInterval > 86400 && timeInterval < 7*86400 :
                    let calendar = NSCalendar.currentCalendar()
                    let dateComponents = calendar.components([.Day,.Weekday], fromDate: date)
                    return "\(calendar.shortWeekdaySymbols[dateComponents.weekday - 1])"
                case _ where timeInterval > 7 * 86400 :
                    dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                    dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
                    return "\(dateFormatter.stringFromDate(date))"
                default :
                    // change to a readable time format and change to local time zone
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.timeZone = NSTimeZone(name: "IST")
                    let timeStamp = dateFormatter.stringFromDate(date) 
                    return timeStamp
            }
    }
    
    static func timeStampFromDateString(str:String) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        if let date = dateFormatter.dateFromString(str)
        {
            let now = NSDate()
            let timeInterval = now.timeIntervalSinceDate(date)
            
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
                return timeStamp
            }
            
        }
        else
        {
            return "unknown time"
        }
        
    }
    
    static func setUpLineSpacingForLabel(label:UILabel, font: UIFont){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attrString = NSMutableAttributedString(string: label.text!)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: font, range:NSMakeRange(0, attrString.length))
        label.attributedText = attrString
    }
    
    static func setUpLineSpacingForLabel(label:UILabel){
        setUpLineSpacingForLabel(label, font: UIFont(name: "Lato-Regular", size: 18)!)
    }
    
    static func colorBetweenColors(firstColor:UIColor , lastColor:UIColor, offsetAsFraction:CGFloat)->UIColor
    {
        let c1Comp = CGColorGetComponents(firstColor.CGColor)
        let c2Comp = CGColorGetComponents(lastColor.CGColor)

        let colorComponents = [
            c1Comp[0], c1Comp[1], c1Comp[2], c1Comp[3],
            c2Comp[0], c2Comp[1], c2Comp[2], c2Comp[3]
        ]
        
        let red  = linearTransition(c1Comp[0], y: c2Comp[0], offset: offsetAsFraction)
        let green = linearTransition(c1Comp[1], y: c2Comp[1], offset: offsetAsFraction)
        let blue = linearTransition(c1Comp[2], y: c2Comp[2], offset: offsetAsFraction)
        
        return UIColor(red: red , green: green, blue: blue, alpha: 1.0)
    }
    
    
}