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
    var commentsJSON = JSON.nullJSON
    var comments = [NSManagedObject]()
    @IBOutlet weak var sendCommentButton: UIView!
    let commentsActivityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
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
        Alamofire.request(.GET, API().getCommentsForPost("\(postID)"), parameters: nil,encoding: .JSON).response({ (request, response, data, error) -> Void in

            self.commentsJSON = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            for (key, comment) in self.commentsJSON["results"]{
//                let request = NSFetchRequest(entityName: "Comment")
//                request.predicate = NSPredicate(format: "id == %@", argumentArray: [NSNumber(longLong:comment["id"].int64!)])
//                if appDelegate.managedObjectContext?.countForFetchRequest(request, error: nil) == 0
//                {
                    let commentObject = Comment.generateObjectFromJSON(comment, context: appDelegate.managedObjectContext!)
                    commentObject.post = self.post!
//                }
                
            }
            appDelegate.saveContext()
            self.performFetchFromCoreData()

        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func performFetchFromCoreData()
    {
        let request = NSFetchRequest(entityName: "Comment")
        request.predicate = NSPredicate(format: "post == %@", argumentArray: [self.post!])
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { (result) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.processAsyncResults(result)
            })
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.managedObjectContext?.performBlock({ () -> Void in
            let error = NSErrorPointer()
            let asyncResult = appDelegate.managedObjectContext?.executeRequest(asyncRequest, error: error)
            if error != nil
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
        let tapGesture = UITapGestureRecognizer(target: self, action: "sendComment:")
        sendCommentButton.addGestureRecognizer(tapGesture)
    }
    
    //MARK: TextView delegate methods
    
    func textViewDidBeginEditing(textView: UITextView) {
        commentsTextView.text = ""
    }
    
    func textViewDidChange(textView: UITextView) {
        
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
                self.commentsJSON = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
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
            let record = comments[indexPath.row] as! Comment
            identifier = "Comment"
            let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as! commentCell
            cell.authorLabel.text = record.author.firstname + " " + record.author.lastname

            cell.commentLabel.text = record.comment
            cell.timestampLabel.text = Utilities.timeStampFromDate(record.timestamp)
            Utilities.setUpLineSpacingForLabel(cell.commentLabel)
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }


       
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }else{
            return comments.count
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
    
    func processAsyncResults(result:NSAsynchronousFetchResult)
    {
        if let finalResult = result.finalResult as? [(NSManagedObject)]
        {
            self.comments = finalResult
            self.tableView.reloadData()
        }
    }
}
