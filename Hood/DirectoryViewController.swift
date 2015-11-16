//
//  DirectoryViewController.swift
//  Pipal
//
//  Created by Abheyraj Singh on 10/11/15.
//  Copyright © 2015 Housing Labs. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class DirectoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var directoryItems: Array<JSON> = []
    @IBOutlet var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setUpBackButton()
        getDirectory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpBackButton(){
//        let rightButton = UIButton(frame: CGRectMake(0,0,24,24))
//        rightButton.contentMode = .ScaleAspectFit
//        rightButton.setImage(UIImage(named: "ForwardArrow"), forState: .Normal)
//        rightButton.imageView?.contentMode = .ScaleAspectFit
//        rightButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: rightButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "dismiss:")
    }
    
    func dismiss(sender: AnyObject){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:DirectoryCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! DirectoryCell
        let currentObject = directoryItems[indexPath.row]
        let firstName = currentObject["firstname"].string!
        let lastName = currentObject["lastname"].string!
        cell.userName.text = "\(firstName.uppercaseString) \(lastName.uppercaseString)"
        cell.profileImage.sd_setImageWithURL(NSURL(string: currentObject["profile_photo"].stringValue))
        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let directoryItems = self.directoryItems{
            return directoryItems.count
//        }else{
//            return 0
//        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.frame.width/2
        let height = width
        return CGSizeMake(width, height)
    }
    
    func getDirectory(){
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.GET, API().getAllMembers(), parameters: nil, encoding: .URL, headers: headers).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, result) -> Void in
            if(result.isSuccess){
                let responseJSON = JSON(result.value!)
                self.directoryItems = responseJSON["results"].array!
                self.title = "\(self.directoryItems.count) neighbours"
                self.collectionView.reloadData()
            }
        }
    }

}
