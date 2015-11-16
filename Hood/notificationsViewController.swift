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
//        let gr = UISwipeGestureRecognizer(target: self, action: Selector("dismiss:"))
//        gr.direction = UISwipeGestureRecognizerDirection.Left
//        view.addGestureRecognizer(gr)
        let rightButton = UIButton(frame: CGRectMake(0,0,24,24))
        rightButton.contentMode = .ScaleAspectFit
        rightButton.setImage(UIImage(named: "DownArrow"), forState: .Normal)
        rightButton.imageView?.contentMode = .ScaleAspectFit
        rightButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
    }
    
    func setUpOptionsButton(){
        let optionsButton = UIButton(frame: CGRectMake(0, 0, 25, 25))
        optionsButton.contentMode = UIViewContentMode.ScaleAspectFit
        optionsButton.setImage(UIImage(named: "Settings"), forState: .Normal)
        optionsButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        optionsButton.addTarget(self, action: "showDirectory", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionsButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchNotifications()
        clearAlerts()
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let commentVC:CommentsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Comments") as! CommentsViewController
        commentVC.postID = notifications![indexPath.row]["post"]["id"].int!
        
        self.navigationController?.pushViewController(commentVC, animated: true)
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
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL,headers: headers).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (_,_, result) -> Void in
            if(result.isSuccess){
                if let value = result.value{
                    let responseJSON = JSON(value)
                    self.notifications =  responseJSON["results"]
                    self.notificationTableView.reloadData()
                    self.notificationTableView.setNeedsLayout()
                    self.notificationTableView.layoutSubviews()
                    self.notificationTableView.reloadData()
                }
            }
            
        }
        
    }

    func markNotificationAsRead(notificationID: Int){
        
    }
    
    func clearAlerts(){
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.GET, API().clearAlerts(), parameters: nil, encoding: .URL, headers: headers).validate().responseJSON(options: .AllowFragments) { (request, response, result) -> Void in
            if(result.isSuccess){
                print(result.value!)
            }else{
                print(result.error)
            }
        }
    }
    
}
