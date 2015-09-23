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
    var postID :Int32?
    var post:Post?
    var upvotesCount = 0
    var placeholderImage: UIImage?
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

    override func prepareForReuse() {
        likesButton.selected = false
    }
    
    func setContents(post:Post)
    {
        self.post = post
        postID = post.id.intValue
        print(post.id.intValue)
        upvotesCount = post.upvotes_count.integerValue
        var attributes = content.attributedText!.attributesAtIndex(0, effectiveRange: nil)
        let attributedString = NSAttributedString(string: post.message, attributes: attributes)
        content.attributedText = attributedString
        contentView.layoutIfNeeded()
        commentsButton.setTitle("\(post.comments_count.integerValue) Comments", forState: UIControlState.Normal)
        likesButton.setTitle("\(post.upvotes_count.integerValue) Likes", forState: UIControlState.Normal)
        if post.is_upvoted.boolValue{
            likesButton.selected = true
        }
        timestampLabel.text = Utilities.timeStampFromDate(post.timestamp!)
        let lastName = post.author.lastname
        userName.text = post.author.firstname + " " + lastName
        
        if let placeholderImage = placeholderImage{
            
        }else{
            placeholderImage = getImageWithColor(UIColor.lightGrayColor(), size: profileImage.frame.size)
        }
        
        if let profile_photo = post.author.profile_photo
        {
            profileImage.sd_setImageWithURL(NSURL(string:profile_photo), placeholderImage: placeholderImage)
        }
        if let imageURL = post.photo{
            postImage.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: placeholderImage)
        }
        
    }

    func commentsPressed(){
//        print(post)
        let userInfo:Dictionary = ["post" : post! , "postID" : post!.id.integerValue]
        NSNotificationCenter.defaultCenter().postNotificationName("commentsPressed", object: nil, userInfo: userInfo)
    }
    
    func likePressed(){
        if self.likesButton.selected
        {
            upvotesCount--
            likesButton.setTitle("\(upvotesCount) likes", forState: UIControlState.Normal)
            let userID = NSUserDefaults.standardUserDefaults().valueForKey("id") as? Int

            (self.likesButton as! PopButton).setSelectedWithAnimation(false)
            PostController.VotePost(.Downvote, sender: likesButton, post: post!, success: nil, failure: { () -> Void in
                self.upvotesCount++
                self.likesButton.setTitle("\(self.upvotesCount) likes", forState: UIControlState.Normal)
                self.likesButton.selected = true
            })
        }
        else
        {
            upvotesCount++
            likesButton.setTitle("\(upvotesCount) likes", forState: UIControlState.Normal)
            (self.likesButton as! PopButton).setSelectedWithAnimation(true)
            PostController.VotePost(.Upvote, sender: likesButton, post: post!, success: nil, failure: { () -> Void in
                self.upvotesCount--
                self.likesButton.setTitle("\(self.upvotesCount) likes", forState: UIControlState.Normal)
                self.likesButton.selected = false
            })
        }
    }

    
}
