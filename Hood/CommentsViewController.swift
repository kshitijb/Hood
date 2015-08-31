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
import WebImage
import FBSDKCoreKit

class CommentsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource ,UITextViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentsTextView: UITextView!
    var postID = 0
    var post: Post?
    @IBOutlet weak var commentConstraint: NSLayoutConstraint!
    var comments = JSON.nullJSON
    @IBOutlet weak var sendCommentButton: UIView!
    let commentsActivityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    var tapGesture :UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 138
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        setupUI()
        
        

        Alamofire.request(.GET, API().getCommentsForPost("\(postID)"), parameters: nil,encoding: .JSON).response({ (request, response, data, error) -> Void in

            self.comments = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupUI(){
        commentsTextView.layoutManager.ensureLayoutForTextContainer(commentsTextView.textContainer)
        commentsTextView.text = "Add a comment"
        commentsTextView.delegate = self
        tapGesture = UITapGestureRecognizer(target: self, action: "sendComment:")
        sendCommentButton.addGestureRecognizer(tapGesture!)
        tapGesture?.enabled = false
    }
    
    //MARK: TextView delegate methods
    
    func textViewDidBeginEditing(textView: UITextView) {
        commentsTextView.text = ""
    }
    
    func textViewDidChange(textView: UITextView) {
        if(textView.text != ""){
            tapGesture?.enabled = true
        }
    }
    
    // MARK: Other
    
    @IBAction func sendComment(sender: AnyObject)
    {
        
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("id") as? Int
        let params = ["post_id" : post!.id.integerValue, "comment":commentsTextView.text] as [String:AnyObject!]
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        print(params)
        Alamofire.request(.POST, API().addComment(), parameters: params,encoding: .JSON, headers: headers).response({ (request, response, data, error) -> Void in
            print(error)
            print(response)
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            self.commentsTextView.resignFirstResponder()
            self.commentsTextView.text = ""
            Alamofire.request(.GET, API().getCommentsForPost("\(self.postID)"), parameters: nil,encoding: .JSON).response({ (request, response, data, error) -> Void in
                self.comments = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
            })
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier:String
        if(indexPath.section == 0)
        {
            if let photo = post!.photo{
                let cell = tableView.dequeueReusableCellWithIdentifier("CellWithImage") as! CellWithImage
                cell.setContents(post!)
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCellWithIdentifier("CellWithoutImage") as! CellWithoutImage
                cell.setContents(post!)
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
                return cell
            }
        }
        else
        {
            identifier = "Comment"
            let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as! commentCell
            if comments["results"].array?.count>0
            {
                cell.authorLabel.text = comments["results"][indexPath.row]["author"]["firstname"].string! + " " + comments["results"][indexPath.row]["author"]["lastname"].string!
                
                cell.commentLabel.text = comments["results"][indexPath.row]["comment"].string
//                cell.timestampLabel.text = Utilities.timeStampFromDate(comments["results"][indexPath.row]["timestamp"].string!)
                Utilities.setUpLineSpacingForLabel(cell.commentLabel)
            }
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }


       
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }else{
            if let commentsCount = comments["results"].array?.count
            {
                return commentsCount
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
    
    func keyboardWillShow(notification:NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            let curve: AnyObject? = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey]
            if(self.commentConstraint.constant < keyboardSize.height){
                self.commentConstraint.constant += keyboardSize.height
                UIView.animateWithDuration(duration!, delay: 0, options: nil, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    }, completion: { (completion) -> Void in
                        
                })
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            let curve: AnyObject? = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey]
            self.commentConstraint.constant -= keyboardSize.height
            UIView.animateWithDuration(duration!, delay: 0, options: nil, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (completion) -> Void in
                    
            })
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        self.tableView.reloadData()
    }
}
