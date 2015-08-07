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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataArray: JSON = JSON.nullJSON
    var dataObject: JSON = JSON.nullJSON
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 138
        tableView.contentInset = UIEdgeInsetsMake(34, 0, 0, 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        self.automaticallyAdjustsScrollViewInsets = true
        getPosts()
//        dataArray = NSMutableArray(array: [1,2,3,4,5,6,7,8,9])
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier:String
//        if(indexPath.row == 1){
//            identifier = "CellWithImage"
//        }else{
            identifier = "CellWithoutImage"
//        }
        let cell:CellWithoutImage = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! CellWithoutImage
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        cell.content.text = self.dataArray[indexPath.row]["message"].stringValue
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.new()
    }
    
    override func viewDidAppear(animated: Bool) {
        print("Did appear")
//        self.tableView.reloadData()
//                tableView.contentInset = UIEdgeInsetsMake(24, 0, 0, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
//        print("contentInset on will appear \(tableView.contentInset.top)")
//        println("Table View Frame on appear \(self.tableView.frame)")
//        tableView.reloadData()
//        tableView.contentInset = UIEdgeInsetsMake(24, 0, 0, 0)
    }
    
    override func viewWillLayoutSubviews() {
        print("Current inset is \(self.tableView.contentInset.top)" )
//        println("Table View Frame on layout \(self.tableView.frame)")
        let frame:CGRect = self.tableView.frame;
        if(frame.size.width > self.view.frame.size.width) {
            self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, frame.size.height)
        }
        if(tableView.contentInset.top != 34){
            tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        }
    }
    
    func getPosts(){
        Alamofire.request(.GET, API().getAllPosts(), parameters: nil).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, response, data, error) -> Void in
            if let e = error{
                print(error)
            }else{
                let responseJSON = JSON(data!)
                self.dataArray = responseJSON["results"]
                self.tableView.reloadData()
            }
        }
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
