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

    @IBOutlet var flagButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    var postID: Int32?
    var post: Post?
    var upvotesCount = 0
    @IBOutlet weak var timestampLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.layer.masksToBounds = true
        self.profileImage.layer.shouldRasterize = true
        self.profileImage.layer.rasterizationScale = UIScreen.mainScreen().scale
        Utilities.setUpLineSpacingForLabel(content)
        //        content.updateConstraintsIfNeeded()
        commentsButton.addTarget(self, action: "commentsPressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.likesButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.likesButton.addTarget(self, action: "likePressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.flagButton.addTarget(self, action: "flagPost", forControlEvents: .TouchUpInside)
    }
    
    override func prepareForReuse() {
        likesButton.selected = false
    }
    
    func setContents(post: Post)
    {
        self.post = post
        postID = post.id.intValue
        upvotesCount = post.upvotes_count.integerValue
        let attributes = content.attributedText!.attributesAtIndex(0, effectiveRange: nil)
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
        if let profile_photo = post.author.profile_photo
        {
            profileImage.sd_setImageWithURL(NSURL(string:profile_photo), placeholderImage: UIImage(named: "Me.jpg"))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        self.updateConstraintsIfNeeded()
    }
    
    func commentsPressed(){
        let userInfo:Dictionary = ["post" : post! , "postID" : post!.id.integerValue]
        NSNotificationCenter.defaultCenter().postNotificationName("commentsPressed", object: nil, userInfo: userInfo)
    }
    
    func likePressed(){
        if self.likesButton.selected
        {
            upvotesCount--
            self.post?.upvotes_count = upvotesCount
            self.post?.is_upvoted = false
            likesButton.setTitle("\(upvotesCount) likes", forState: UIControlState.Normal)
            self.likesButton.selected = false
            PostController.VotePost(.Downvote, sender: likesButton, post: post!, success: nil, failure: { () -> Void in
                self.upvotesCount++
                self.likesButton.setTitle("\(self.upvotesCount) likes", forState: UIControlState.Normal)
                self.likesButton.selected = true
            })
        }
        else
        {
            upvotesCount++
            self.post?.upvotes_count = upvotesCount
            self.post?.is_upvoted = true
            likesButton.setTitle("\(upvotesCount) likes", forState: UIControlState.Normal)
            self.likesButton.selected = true
            PostController.VotePost(.Upvote, sender: likesButton, post: post!, success: nil, failure: { () -> Void in
                self.upvotesCount--
                self.likesButton.setTitle("\(self.upvotesCount) likes", forState: UIControlState.Normal)
                self.likesButton.selected = false
            })
        }
    }
    
    func flagPost(){
        PostController.FlagPost(post!, success: { () -> Void in
            UIAlertView(title: "Pipal", message: "This post has been reported. Thank you!", delegate: self, cancelButtonTitle: "Okay").show()
            }, failure: nil)
    }
    
}
