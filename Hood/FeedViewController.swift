//
//  FeedViewController.swift
//  Hood
//
//  Created by Abheyraj Singh on 31/07/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import FBSDKCoreKit
import CoreData

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    var dataArray: NSMutableArray = NSMutableArray()
    var dataObject: AnyObject?
    var activityIndicator: UIActivityIndicatorView?
    var context = Utilities.appDelegate.privateContext()
    var shouldHideHeader: Bool = false
    
    @IBOutlet var addPostHeaderTopConstraint: NSLayoutConstraint!
    @IBOutlet var addingPostHeaderView: UIView!
    @IBOutlet var addingPostLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 138
//        tableView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length + 30, 0, 0, 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        self.automaticallyAdjustsScrollViewInsets = true
        self.addingPostHeaderView.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addingPost:", name: "AddingPost", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addedPost:", name: "AddedPost", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let numberOfSections = fetchedResultsController.sections?.count{
            return numberOfSections
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier:String
        let dataObject: AnyObject = fetchedResultsController.objectAtIndexPath(indexPath)
        let post = dataObject as! Post
        if let photo = post.photo{
            identifier = "CellWithImage"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! CellWithImage
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
            cell.setContents(post)
            return cell
        }else{
            identifier = "CellWithoutImage"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! CellWithoutImage
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
            cell.setContents(post)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultsController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.new()
    }
    
    override func viewDidAppear(animated: Bool) {
        getPosts()
    }
    
    override func viewWillAppear(animated: Bool) {
//        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
//            let mainContext: NSManagedObjectContext = notification.object as! NSManagedObjectContext
//            if(mainContext.isEqual(self.context) == false){
//                self.context.performBlock({ () -> Void in
//                    self.context.mergeChangesFromContextDidSaveNotification(notification)
//                })
//            }
//        }
        
//        self.tableView.reloadData()
//        self.tableView.setNeedsLayout()
//        self.tableView.layoutIfNeeded()
//        self.tableView.reloadData()
//        print("contentInset on will appear \(tableView.contentInset.top)")
//        println("Table View Frame on appear \(self.tableView.frame)")
//        tableView.reloadData()
//        tableView.contentInset = UIEdgeInsetsMake(24, 0, 0, 0)
    }
    
    override func viewWillLayoutSubviews() {
        print("Top layout guide is \(self.topLayoutGuide.length)" )
//        println("Table View Frame on layout \(self.tableView.frame)")
        let frame:CGRect = self.tableView.frame;
        if(frame.size.width > self.view.frame.size.width) {
            self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, frame.size.height)
        }
        if(topLayoutGuide.length == 0){
            tableView.contentInset = UIEdgeInsetsMake(64 + (self.parentViewController?.parentViewController as! RootViewController).pageIndicatorContainer.frame.height, 0, 0, 0)
        }else{
            tableView.contentInset = UIEdgeInsetsMake(64 + (self.parentViewController?.parentViewController as! RootViewController).pageIndicatorContainer.frame.height, 0, 0, 0)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let selectedPost: Post = fetchedResultsController.objectAtIndexPath(indexPath) as! Post
        let userInfo:Dictionary = ["post" : selectedPost , "postID" : selectedPost.id.integerValue]
        NSNotificationCenter.defaultCenter().postNotificationName("commentsPressed", object: nil, userInfo: userInfo)
    }
    
    func getPosts(){
        if let count = self.fetchedResultsController.sections?.count{
            if (count == 0){
                showLoader()
            }
        }else{
            showLoader()
        }
        
        let channel = self.dataObject as! Channel
        let url = API().getAllPostsForChannel("\(channel.id.intValue)")
        let manager = Alamofire.Manager.sharedInstance
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL,headers: headers).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, error) -> Void in
            self.hideLoader()
            if let e = error{
            }else{
                let responseJSON = JSON(data!)
//                print(responseJSON)
                self.dataArray = NSMutableArray()
                let fetchRequest = NSFetchRequest(entityName: "Post")
                fetchRequest.predicate = NSPredicate(format: "channel == %@", argumentArray: [self.dataObject as! Channel])
                let appDelegate = Utilities.appDelegate
                for (key, post) in responseJSON["results"]{
                    let postObject = Post.generateObjectFromJSON(post, context: appDelegate.managedObjectContext!)
                    postObject.channel = self.dataObject as! Channel
                    self.dataArray.addObject(postObject)
                }
                let results = appDelegate.managedObjectContext?.executeFetchRequest(fetchRequest, error: nil)
                if(results?.count > 0){
                    let objectsToDelete = NSMutableSet(array: results!)
                    objectsToDelete.minusSet(NSSet(array: self.dataArray as [AnyObject]) as Set<NSObject>)
                    let objectsToDeleteArray = objectsToDelete.allObjects
                    if objectsToDeleteArray.count > 0{
                        for index in 0...objectsToDeleteArray.count-1{
                            appDelegate.managedObjectContext?.deleteObject(objectsToDeleteArray[index] as! NSManagedObject)
                        }
                    }
                }
                appDelegate.saveContext()
            }
        }
    }
    
    func showLoader(){
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.center = view.center
        activityIndicator!.center.y = activityIndicator!.center.y + self.topLayoutGuide.length
        view.addSubview(activityIndicator!)
        activityIndicator?.startAnimating()
    }
    
    func hideLoader(){
        activityIndicator?.stopAnimating()
    }

    //Mark: Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let postFetchRequest = NSFetchRequest(entityName: "Post")
        postFetchRequest.predicate = NSPredicate(format: "channel == %@", argumentArray: [(self.dataObject as! Channel)])
        postFetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: postFetchRequest,
            managedObjectContext: Utilities.appDelegate.managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: "\((self.dataObject as! Channel).id)")
        
        frc.delegate = self
        
        return frc
    }()
    
    /* called first
    begins update to `UITableView`
    ensures all updates are animated simultaneously */
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        self.tableView.reloadData()
//        self.tableView.setNeedsLayout()
//        self.tableView.layoutIfNeeded()
//        self.tableView.reloadData()
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.None)
//        case .Move:
//            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func fetchData(){
        fetchedResultsController.managedObjectContext.performBlock { () -> Void in
            self.fetchedResultsController.performFetch(nil)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.tableView.reloadData()
                self.tableView.setNeedsLayout()
                self.tableView.layoutIfNeeded()
                self.tableView.reloadData()
                
            })
        }
    }
    
    //Mark: managing table header view
    
    func addingPost(notification: NSNotification){
        if let userInfo = notification.userInfo{
            let channelID:Int = userInfo["channelID"] as! Int
            let channel = self.dataObject as! Channel
            if(channelID == channel.id.integerValue){
                self.addingPostLabel.text = "Adding post to #\(channel.name)"
                if let color = channel.color{
                    self.addingPostLabel.textColor = UIColor(hexString: "#" + color)
                }
                self.showAddPostHeader()
            }
        }
    }
    
    func addedPost(notification: NSNotification){
        if let userInfo = notification.userInfo{
            let channelID:Int = userInfo["channelID"] as! Int
            let channel = self.dataObject as! Channel
            if(channelID == channel.id.integerValue){
                self.hideAddPostHeader()
                self.getPosts()
            }
        }
    }
    
    func hideAddPostHeader(){
        tableView.contentInset = UIEdgeInsetsMake(64 + (self.parentViewController?.parentViewController as! RootViewController).pageIndicatorContainer.frame.height, 0, 0, 0)
        addingPostHeaderView.layer.opacity = 1
        addingPostHeaderView.hidden = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.addingPostHeaderView.layer.opacity = 0
            }) { (completed: Bool) -> Void in
            self.addingPostHeaderView.hidden = true
        }
    }
    
    func showAddPostHeader(){
        addPostHeaderTopConstraint.constant = 89
        tableView.contentInset = UIEdgeInsetsMake(64 + (self.parentViewController?.parentViewController as! RootViewController).pageIndicatorContainer.frame.height + 50, 0, 0, 0)
        addingPostHeaderView.layer.opacity = 0
        addingPostHeaderView.hidden = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.addingPostHeaderView.layer.opacity = 1
            self.view.layoutSubviews()
        })
    }
    
}

