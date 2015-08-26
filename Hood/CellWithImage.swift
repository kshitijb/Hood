//
//  CellWithImage.swift
//  Hood
//
//  Created by Abheyraj Singh on 04/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebImage

class CellWithImage: UITableViewCell {
    var postID :Int?
    var post = JSON.nullJSON
    var upvotesCount = 0
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!

    @IBOutlet weak var postImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.layer.masksToBounds = true
        self.profileImage.layer.shouldRasterize = true
        self.profileImage.layer.rasterizationScale = UIScreen.mainScreen().scale
        Utilities.setUpLineSpacingForLabel(content)
        let aspectConstraint = NSLayoutConstraint(item: postImage, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: postImage, attribute: NSLayoutAttribute.Height, multiplier: 16/9, constant: 0)
        aspectConstraint.priority = 999
        postImage.addConstraint(aspectConstraint)
        commentsButton.addTarget(self, action: "commentsPressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.likesButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.likesButton.addTarget(self, action: "likePressed", forControlEvents: UIControlEvents.TouchUpInside)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setContents(jsonObject:JSON)
    {
        post = jsonObject
        postID = jsonObject["id"].int
        upvotesCount = jsonObject["upvotes_count"].int!
        var attributes = content.attributedText.attributesAtIndex(0, effectiveRange: nil)
        let attributedString = NSAttributedString(string: jsonObject["message"].string!, attributes: attributes)
        content.attributedText = attributedString
        contentView.layoutIfNeeded()
        if let noOfComments = jsonObject["comments_count"].number{
            commentsButton.setTitle("\(noOfComments) Comments", forState: UIControlState.Normal)
        }
        if let noOfLikes = jsonObject["upvotes_count"].number{
            likesButton.setTitle("\(noOfLikes) Likes", forState: UIControlState.Normal)
        }
        if let isLiked = jsonObject["is_upvoted"].bool{
            if isLiked{
                likesButton.selected = true
            }
        }
        timestampLabel.text = Utilities.timeStampFromDate(jsonObject["timestamp"].string!)
        let lastName = jsonObject["author"]["lastname"].string
        userName.text = jsonObject["author"]["firstname"].string! + " " + lastName!
        if let profileURL = jsonObject["author"]["profile_photo"].string
        {
            profileImage.sd_setImageWithURL(NSURL(string:profileURL), placeholderImage: UIImage(named: "Me.jpg"))
        }
        if let imageURL = jsonObject["photo"].string{
            postImage.sd_setImageWithURL(NSURL(string: imageURL))
        }
        
    }

    func commentsPressed(){

        let userInfo:Dictionary = ["post" : post.object , "postID" : postID!]
        NSNotificationCenter.defaultCenter().postNotificationName("commentsPressed", object: nil, userInfo: userInfo)
    }
    
    func likePressed(){
        if self.likesButton.selected
        {
            upvotesCount--
            likesButton.setTitle("\(upvotesCount) likes", forState: UIControlState.Normal)
            let userID = NSUserDefaults.standardUserDefaults().valueForKey("id") as? Int

            self.likesButton.selected = false
            PostController.VotePost(.Downvote, sender: likesButton, post: post, success: nil, failure: { () -> Void in
                self.upvotesCount++
                self.likesButton.setTitle("\(self.upvotesCount) likes", forState: UIControlState.Normal)
                self.likesButton.selected = true
            })
        }
        else
        {
            upvotesCount++
            likesButton.setTitle("\(upvotesCount) likes", forState: UIControlState.Normal)
            self.likesButton.selected = true
            PostController.VotePost(.Upvote, sender: likesButton, post: post, success: nil, failure: { () -> Void in
                self.upvotesCount--
                self.likesButton.setTitle("\(self.upvotesCount) likes", forState: UIControlState.Normal)
                self.likesButton.selected = false
            })
        }
    }

    
}
