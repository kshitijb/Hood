//
//  RootViewController.swift
//  Hood
//
//  Created by Abheyraj Singh on 30/07/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.delegate = self
        self.pageViewController?.view.backgroundColor = UIColor.lightGrayColor()
//        let startingViewController: FeedViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
//        let viewControllers = [startingViewController]
//        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
        self.pageViewController!.dataSource = self.modelController
//        let firstDataObject: AnyObject? = self.modelController.pageData.firstObject
//        updateTitleForString(firstDataObject!.description!)
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        var pageViewRect = self.view.bounds
        self.pageViewController!.view.frame = pageViewRect
        self.pageViewController!.didMoveToParentViewController(self)
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showComments:", name: "commentsPressed", object: nil)
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        let currentViewController = self.pageViewController!.viewControllers[0] as! UIViewController
        let viewControllers = [currentViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })

        self.pageViewController!.doubleSided = false
        return .Min
    }

    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if completed{
            let dataViewController:FeedViewController = pageViewController.viewControllers.last as! FeedViewController
            updateTitleForString("\(dataViewController.dataObject!)")
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func updateTitleForString(title: String){
        self.title = "#\(title)"
    }
    
    func showComments(notification: NSNotification){
        let commentsView: UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Comments")! as! UIViewController
        self.navigationController?.pushViewController(commentsView, animated: true)
    }
    
    func getData(){
        SVProgressHUD.show()
        Alamofire.request(.GET, "http://128.199.179.151:8000/channel/all/", parameters: nil)
            .responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
                SVProgressHUD.dismiss()
                if let _error = error{
                    println(error)
                }else{
                    let responseDictionary = data as? NSDictionary
                    let responseArray = data?["results"] as? NSArray
//                    let swiftyJSONObject = JSON(data!)
//                    let array = NSMutableArray()
//                    for(index,subJSON) in swiftyJSONObject["results"]{
////                        array.addObject(sub)
//                    }
                }
        }
    }
    
}

