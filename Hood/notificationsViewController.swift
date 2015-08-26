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
        let url = API().getNotificationsForUser()
        print(url)
//        let headers = ["Authorization":"Bearer \(FBSDKAccessToken.currentAccessToken().tokenString)"]
//        print(headers)
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL,headers: nil).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, error) -> Void in
            if let e = error{
                print(error)
            }else{
                let responseJSON = JSON(data!)
                self.notifications =  responseJSON["results"]
                self.notificationTableView.reloadData()
                
            }
        }
        
        // Do any additional setup after loading the view.
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
