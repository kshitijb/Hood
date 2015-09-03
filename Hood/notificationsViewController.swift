//
//  notificationsViewController.swift
//  Hood
//
//  Created by Robin Malhotra on 21/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKCoreKit
import SwiftyJSON
class notificationsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var notificationTableView: UITableView!
    var notifications :JSON?
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        notificationTableView.estimatedRowHeight = 2
        notificationTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchNotifications()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let count = notifications?.count
        {
            print(count)
            return count
        }
        else
        {
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as! NotificationCell
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        let notificationCell = cell as! NotificationCell
        if let notifications = notifications?.array
        {
            notificationCell.setContents(notifications[indexPath.row])
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    @IBAction func dismiss(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    func fetchNotifications(){
        let url = API().getNotificationsForUser()
        print(url)
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL,headers: headers).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, error) -> Void in
            if let e = error{
                print(error)
            }else{
                let responseJSON = JSON(data!)
                self.notifications =  responseJSON["results"]
                self.notificationTableView.reloadData()
                self.notificationTableView.setNeedsLayout()
                self.notificationTableView.layoutSubviews()
                self.notificationTableView.reloadData()
            }
        }
        
    }

}
