//
//  SelectNeighbourhoodViewController.swift
//  Pipal
//
//  Created by Abheyraj Singh on 17/11/15.
//  Copyright © 2015 Housing Labs. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class SelectNeighbourhoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var neighbourhoods: Array<JSON>?
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getNeighbourhoods()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let neighbourhoods = self.neighbourhoods{
            return neighbourhoods.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! NeighbourhoodCell
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
        cell.selectedBackgroundView = selectedBackgroundView
        let currentObject = neighbourhoods![indexPath.row]
        cell.name.text = currentObject["name"].string
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentObject = neighbourhoods![indexPath.row]
        setNeighbourhood(currentObject)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func getNeighbourhoods(){
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.GET, API().getAllNeighbourhoods() + "/", parameters: nil, encoding: .URL, headers: headers).responseJSON(options: .MutableContainers) { (request, response, result) -> Void in
            if result.isSuccess{
                let responseJSON = JSON(result.value!)
                self.neighbourhoods = responseJSON["results"].array
                self.tableView.reloadData()
            }
        }
    }
    
    func setNeighbourhood(neighbourhood: JSON){
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        SVProgressHUD.showWithStatus("Setting up Neighbourhood")
        Alamofire.request(.POST, API().updateUserLocality(), parameters: ["id":neighbourhood["id"].int!], encoding: .JSON, headers: headers).responseJSON(options: .MutableContainers) { (request, response, result) -> Void in
            if result.isSuccess{
                SVProgressHUD.dismiss()
                let neighbourhood = Neighbourhood.generateObjectFromJSON(neighbourhood, context: Utilities.appDelegate.managedObjectContext!)
                AppDelegate.owner?.neighbourhood = neighbourhood
                Utilities.appDelegate.saveContext()
                self.performSegueWithIdentifier("welcome", sender: nil)
            }else{
                UIAlertView(title: "Pipal", message: "Could not select a neighbourhood at this time. Please try again", delegate: self, cancelButtonTitle: "Okay").show()
            }
        }
    }
}
