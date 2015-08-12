//
//  CellWithoutImage.swift
//  Hood
//
//  Created by Abheyraj Singh on 31/07/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebImage
import Alamofire
class CellWithoutImage: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    var postID :Int?
    @IBOutlet weak var timestampLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.layer.masksToBounds = true
        self.profileImage.layer.shouldRasterize = true
        self.profileImage.layer.rasterizationScale = UIScreen.mainScreen().scale
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        var attrString = NSMutableAttributedString(string: content.text!)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "Lato-Regular", size: 18)!, range:NSMakeRange(0, attrString.length))
        content.attributedText = attrString
        content.updateConstraintsIfNeeded()
        commentsButton.addTarget(self, action: "commentsPressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.likesButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.likesButton.addTarget(self, action: "likePressed", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func setContents(jsonObject:JSON)
    {
        print(jsonObject)
        postID = jsonObject["id"].int
        var attributes = content.attributedText.attributesAtIndex(0, effectiveRange: nil)
        let attributedString = NSAttributedString(string: jsonObject["message"].string!, attributes: attributes)
        content.attributedText = attributedString
        content.updateConstraintsIfNeeded()
        if let noOfComments = jsonObject["comments_count"].number{
            commentsButton.setTitle("\(noOfComments) Comments", forState: UIControlState.Normal)
        }
        if let noOfLikes = jsonObject["upvotes_count"].number{
            likesButton.setTitle("\(noOfLikes) Likes", forState: UIControlState.Normal)
        }
        timestampLabel.text = Utilities.timeStampFromDate(jsonObject["timestamp"].string!)
        let lastName = jsonObject["author"]["lastname"].string
        var firstChar = Array(lastName!)[0]
        userName.text = jsonObject["author"]["firstname"].string! + " " + String(firstChar)
        if let profileURL = jsonObject["author"]["profile_photo"].string
        {
            let otherURL = "https://pbs.twimg.com/profile_images/2499605683/bf8yn88rwt3jklyajuax.jpeg"
            profileImage.sd_setImageWithURL(NSURL(string:otherURL), placeholderImage: UIImage(named: "Me.jpg"))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        self.updateConstraintsIfNeeded()
    }
    
    func commentsPressed(){
        NSNotificationCenter.defaultCenter().postNotificationName("commentsPressed", object: nil, userInfo: nil)
    }
    
    func likePressed(){
        if self.likesButton.selected
        {
            self.likesButton.selected = false
            
        }
        else
        {
            let userID = NSUserDefaults.standardUserDefaults().valueForKey("fb_id") as! String
            let userIDno = userID.toInt()
            println(postID)
            let params = ["post_id" : postID!, "user_id": 1]
            Alamofire.request(.POST, "http://128.199.179.151/upvote/add/", parameters: params,encoding: .JSON).response({ (request, response, data, error) -> Void in
                print(error)
                print(response)
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                print(request)
            })
            self.likesButton.selected = true
        }
    }
    
    
}
