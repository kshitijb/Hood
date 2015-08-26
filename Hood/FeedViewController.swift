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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 138
//        tableView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length + 30, 0, 0, 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        self.automaticallyAdjustsScrollViewInsets = true
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
        fetchedResultsController.performFetch(nil)
        self.tableView.reloadData()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
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
                print(responseJSON)
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                for (key, post) in responseJSON["results"]{
                    let postObject = Post.generateObjectFromJSON(post, context: appDelegate.managedObjectContext!)
                    postObject.channel = self.dataObject as! Channel
                    self.dataArray.addObject(postObject)
                }
                appDelegate.saveContext()
//                self.dataArray = responseJSON["results"]
//                self.tableView.reloadData()
//                self.tableView.setNeedsLayout()
//                self.tableView.layoutIfNeeded()
//                self.tableView.reloadData()
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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let frc = NSFetchedResultsController(
            fetchRequest: postFetchRequest,
            managedObjectContext: appDelegate.managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
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
//        case .Update:
//            let cell = self.tableView.cellForRowAtIndexPath(indexPath!)
//            
//            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        case .Move:
//            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
//        case .Delete:
//            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
}

