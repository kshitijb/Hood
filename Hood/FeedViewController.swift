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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataArray: JSON = JSON.nullJSON
    var dataObject: JSON = JSON.nullJSON
    var activityIndicator: UIActivityIndicatorView!
    
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
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier:String
        let dataObject = dataArray[indexPath.row]
        if let photo = dataObject["photo"].string{
            identifier = "CellWithImage"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! CellWithImage
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
            cell.setContents(dataArray[indexPath.row])
            return cell
        }else{
            identifier = "CellWithoutImage"
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! CellWithoutImage
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsetsZero
            cell.setContents(dataArray[indexPath.row])
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.new()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        getPosts()
    }
    
    override func viewWillAppear(animated: Bool) {
//        print("contentInset on will appear \(tableView.contentInset.top)")
//        println("Table View Frame on appear \(self.tableView.frame)")
//        tableView.reloadData()
//        tableView.contentInset = UIEdgeInsetsMake(24, 0, 0, 0)
    }
    
    override func viewDidLayoutSubviews() {
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
        let userInfo:Dictionary = ["post" : dataArray[indexPath.row].object , "postID" : dataArray[indexPath.row]["id"].intValue]
        NSNotificationCenter.defaultCenter().postNotificationName("commentsPressed", object: nil, userInfo: userInfo)
    }
    func getPosts(){
        if(self.dataArray.count == 0){
            showLoader()
        }
        let url = API().getAllPostsForChannel(self.dataObject["id"].stringValue)
        let manager = Alamofire.Manager.sharedInstance
        let headers = ["Authorization":"Bearer \(FBSDKAccessToken.currentAccessToken().tokenString)"]
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL,headers: headers).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, error) -> Void in
            self.hideLoader()
            if let e = error{
            }else{
                let responseJSON = JSON(data!)
                self.dataArray = responseJSON["results"]
                self.tableView.reloadData()
                self.tableView.setNeedsLayout()
                self.tableView.layoutIfNeeded()
                self.tableView.reloadData()
            }
        }
    }
    
    func showLoader(){
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        activityIndicator.center.y = activityIndicator.center.y + self.topLayoutGuide.length
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func hideLoader(){
        activityIndicator.stopAnimating()
    }

}
