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
import CoreData
class CommentsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource ,UITextViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentsTextView: UITextView!
    var postID = 0
    var post: Post?
    @IBOutlet weak var commentConstraint: NSLayoutConstraint!
    var commentsJSON = JSON.null
    var comments = [NSManagedObject]()
    @IBOutlet weak var sendCommentButton: UIView!
    let commentsActivityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    var tapGesture :UITapGestureRecognizer?
    @IBOutlet var checkmark: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 138
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        setupUI()

        performFetchFromCoreData()

        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.networkRequestForComments()
        self.navigationController?.hidesBarsOnSwipe = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pushNotificationReceived:"), name: "PushNotification", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        self.tableView.reloadData()
    }
    
    func networkRequestForComments()
    {
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.GET,API().getCommentsForPost("\(postID)"), parameters: nil, encoding: .URL, headers: headers).responseData{_, _, result in
            
            self.commentsJSON = JSON(data: result.value!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            for (_, comment) in self.commentsJSON["results"]{
                
                let commentObject = Comment.generateObjectFromJSON(comment, context: appDelegate.managedObjectContext!)
                commentObject.post = self.post!
                
            }
            appDelegate.saveContext()
            self.getCommentsFromCoreData()
        }

    }
    
    func networkRequestForPost()
    {
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.GET, API().getPostWithID("\(postID)") + "/", parameters: nil, encoding: .URL, headers: headers).validate().responseData{request, _, result in
            if(result.isSuccess){
                let resultJSON = JSON(data: result.value!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                print(resultJSON)
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                _ = Post.generateObjectFromJSON(resultJSON, context: appDelegate.managedObjectContext!)
                appDelegate.saveContext()
                self.performFetchFromCoreData()
            }else{
                UIAlertView(title: "Pipal", message: "Could not load your post at this time, Please try again", delegate: self, cancelButtonTitle: "Ok").show()
            }
        }
    }
    
    func processAsyncResults(result:NSAsynchronousFetchResult)
    {
        if result.finalResult?.count == 0
        {
            networkRequestForComments()
        }
        else if let finalResult = result.finalResult as? [(NSManagedObject)]
        {
            if(comments.count>0){
            let originalCommentsSet = Set(self.comments)
            let resultsSet = Set(finalResult)
            let intersection = resultsSet.subtract(originalCommentsSet)
            if(intersection.count>0){
                comments.insertContentsOf(intersection, at: 0)
                var indexPaths = Array<NSIndexPath>()
                for(var i = 0; i<intersection.count;i++){
                    indexPaths.append(NSIndexPath(forRow: i, inSection: 1))
                }
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Left)
                tableView.endUpdates()
            }
            }else{
                comments = finalResult
                tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            }
        }
    }
    
    func setPostFromCoreData(result:NSAsynchronousFetchResult)
    {
        if result.finalResult?.count == 0
        {
            networkRequestForPost()
        }
        
        else if let finalResult = result.finalResult as? [(NSManagedObject)]
        {
            self.post = finalResult[0] as? Post
            self.getCommentsFromCoreData()
            self.tableView.reloadData()
        }
    }
    
    func performFetchFromCoreData()
    {
        let request = NSFetchRequest(entityName: "Post")
        request.predicate = NSPredicate(format: "id == %@", argumentArray: [self.postID])
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { (result) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.setPostFromCoreData(result)
                
            })
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.managedObjectContext?.performBlock({ () -> Void in
            do
            {
                try appDelegate.managedObjectContext?.executeRequest(asyncRequest)
            }
            catch
            {
                print("Unable to execute asynchronous fetch result.");
                print(error)
            }
        })
    }
    
    func getCommentsFromCoreData()
    {
        if let count = commentsJSON["count"].int64{
            if count == 0{
                return
            }
        }
        
        let commentRequest = NSFetchRequest(entityName: "Comment")
        commentRequest.predicate = NSPredicate(format: "post.id == %@", argumentArray: [self.postID])
        commentRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let commentAsyncRequest = NSAsynchronousFetchRequest(fetchRequest: commentRequest) { (result) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.processAsyncResults(result)
            })
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.managedObjectContext?.performBlock({ () -> Void in
            do
            {
                try appDelegate.managedObjectContext?.executeRequest(commentAsyncRequest)
            }
            catch
            {
                print("Unable to execute asynchronous fetch result.");
                print(error)
            }
        })
    }
    
    func setupUI(){
        commentsTextView.layoutManager.ensureLayoutForTextContainer(commentsTextView.textContainer)
        commentsTextView.text = "Add a comment"
        commentsTextView.delegate = self
        commentsTextView.layer.cornerRadius = 4
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
        checkmark.hidden = true
        let activityIndicator = UIActivityIndicatorView(frame: checkmark.frame)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        checkmark.superview?.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("id") as? Int
        let params = ["post_id" : post!.id.integerValue, "comment":commentsTextView.text] as [String:AnyObject!]
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        print(params)
        
        Utilities.appDelegate.showNotificationsAlert()
        
        Alamofire.request(.POST, API().addComment(), parameters: params, encoding: .JSON,headers:headers).responseData{_, _, result in
            
            
            activityIndicator.removeFromSuperview()
            self.checkmark.hidden = false
            self.commentsTextView.resignFirstResponder()
            self.commentsTextView.text = ""
            self.networkRequestForComments()
            self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)

        }

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
                cell.commentsButton.hidden = true
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCellWithIdentifier("CellWithoutImage") as! CellWithoutImage
                cell.setContents(post!)
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
                cell.commentsButton.hidden = true
                return cell
            }
        }
        else
        {
            let record = comments[indexPath.row] as! Comment
            identifier = "Comment"
            let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as! commentCell
            cell.authorLabel.text = record.author.firstname + " " + record.author.lastname

            cell.commentLabel.text = record.comment
            cell.timestampLabel.text = Utilities.timeStampFromDate(record.timestamp)
            Utilities.setUpLineSpacingForLabel(cell.commentLabel, font: UIFont(name: "Lato-Regular", size: 16)!)
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }


       
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            if post != nil
            {
                return 1
            }
            else
            {
                return 0
            }
        }else{
            return comments.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func keyboardWillChangeFrame(notification: NSNotification){
        var userInfo = notification.userInfo!
        let frameEnd = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        let convertedFrameEnd = self.view.convertRect(frameEnd, fromView: nil)
        let heightOffset = self.view.bounds.size.height - convertedFrameEnd.origin.y
        self.commentConstraint.constant = heightOffset
        
        UIView.animateWithDuration(
            userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue,
            delay: 0,
            options: .TransitionNone,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    func pushNotificationReceived(notification: NSNotification){
        let userInfo = notification.userInfo!
        if let id = userInfo["NOTIFICATION_POST_ID"]{
            if(id.integerValue == self.postID){
                self.networkRequestForComments()
            }
        }
    }

}
