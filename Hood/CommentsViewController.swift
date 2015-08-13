//
//  CommentsViewController.swift
//  Hood
//
//  Created by Abheyraj Singh on 04/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class CommentsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var postUserImage: UIImageView!
    @IBOutlet weak var postUserName: UILabel!
    @IBOutlet weak var postTimeStamp: UILabel!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentsTextView: UITextView!
    var postID = 0
    @IBOutlet weak var commentConstraint: NSLayoutConstraint!
    var comments = JSON.nullJSON
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 138
        tableView.rowHeight = UITableViewAutomaticDimension
        setupUI()
        
        
        print(API().getCommentsForPost("\(postID)"))
        Alamofire.request(.GET, API().getCommentsForPost("\(postID)"), parameters: nil,encoding: .JSON).response({ (request, response, data, error) -> Void in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            self.comments = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupUI(){
        postUserImage.layer.cornerRadius = postUserImage.frame.size.width/2
        postUserImage.layer.masksToBounds = true
        commentsTextView.layoutManager.ensureLayoutForTextContainer(commentsTextView.textContainer)
        commentsTextView.text = "Add a comment"
    
    }
    
    @IBAction func sendComment(sender: AnyObject)
    {
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("id") as? Int
        let params = [ "user_id": userID! ,"post_id" : postID, "comment":commentsTextView.text] as [String:AnyObject!]
        print(params)
        Alamofire.request(.POST, API().addComment(), parameters: params,encoding: .JSON).response({ (request, response, data, error) -> Void in
            print(error)
            print(response)
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))

        })
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier:String
        if(indexPath.section == 0)
        {
            var cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as? CommentsHeaderCell
            if(cell == nil)
            {
                cell = CommentsHeaderCell()
            }
            
            cell!.preservesSuperviewLayoutMargins = false
            cell!.layoutMargins = UIEdgeInsetsZero
            return cell!
        }
        else
        {
            identifier = "Comment"
            var cell = tableView.dequeueReusableCellWithIdentifier("Comment") as? commentCell
            if(cell == nil)
            {
                cell = commentCell()
            }
            if comments["results"].array?.count>0
            {
                print(comments["results"].array!.count)
                cell?.authorLabel.text = comments["results"][indexPath.row]["author"]["firstname"].string! + " " + String(Array(comments["results"][indexPath.row]["author"]["lastname"].string!)[0])
                
                cell?.commentLabel.text = comments["results"][indexPath.row]["comment"].string
                cell?.timestampLabel.text = Utilities.timeStampFromDate(comments["results"][indexPath.row]["timestamp"].string!)
            }
            cell!.preservesSuperviewLayoutMargins = false
            cell!.layoutMargins = UIEdgeInsetsZero
            return cell!
        }


       
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }else{
            if let x = comments["results"].array?.count
            {
                return x
            }
            else
            {
                return 0
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if(section != 0){
            return UIView.new()
        }else{
            return nil
        }
    }
    func keyboardWillShow(notification:NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            let curve: AnyObject? = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey]
            UIView.animateWithDuration(duration!, delay: 0, options: nil, animations: { () -> Void in
                self.commentConstraint.constant += keyboardSize.height
                }, completion: { (completion) -> Void in
                    
            })
        }
    }
    func keyboardWillHide(notification:NSNotification)
    {
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardDidHideNotification, object: nil)
    }
    override func viewDidLayoutSubviews() {
        self.tableView.reloadData()
    }
}
