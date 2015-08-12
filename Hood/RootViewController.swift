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
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
class RootViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?

    @IBOutlet weak var pageIndicatorContainer: UIView!
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            performSegueWithIdentifier("showLogin", sender: self)
        }
        else
        {
            getData()
        }
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageControl.hidden = true
        self.pageIndicatorContainer.backgroundColor = PipalGlobalColor.colorWithAlphaComponent(0.9)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.delegate = self
        self.pageViewController?.view.backgroundColor = UIColor.whiteColor()
        self.pageViewController?.view.userInteractionEnabled = false
        self.pageViewController!.dataSource = self.modelController
        self.addChildViewController(self.pageViewController!)
        self.view.insertSubview(self.pageViewController!.view, belowSubview: self.pageIndicatorContainer)
        var pageViewRect = self.view.bounds
        self.pageViewController!.view.frame = pageViewRect
        self.pageViewController!.didMoveToParentViewController(self)
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showComments:", name: "commentsPressed", object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let profile: AnyObject = userDefaults.valueForKey("fbProfilePhoto")
        {
            print(profile)
        }
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            performSegueWithIdentifier("showLogin", sender: self)
        }
        else
        {
            getData()
        }
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
            let titleString = dataViewController.dataObject["name"]
            updateTitleForString("\(titleString)")
            self.pageControl.currentPage = self.modelController.indexOfViewController(dataViewController)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func updateTitleForString(title: String){
        self.title = "#\(title)"
    }
    
    func showComments(notification: NSNotification){
        let commentsView: CommentsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Comments")! as! CommentsViewController
        var info = notification.userInfo!
        commentsView.postID = info["postID"] as! Int
        self.navigationController?.pushViewController(commentsView, animated: true)
    }
    
    func getData(){
        SVProgressHUD.showWithStatus("Loading")
        Alamofire.request(.GET, API().getAllChannels(), parameters: nil)
            .responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
                SVProgressHUD.dismiss()
                if let _error = error{
                    println(error)
                }else{
                    let swiftyJSONObject = JSON(data!)
                    print(swiftyJSONObject)
                    self.modelController.pageData = swiftyJSONObject["results"]
                    self.pageControl.numberOfPages = self.modelController.pageData.count
                    self.pageControl.currentPage = 0
                    print(self.modelController.pageData)
                    let startingViewController: FeedViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
                    let viewControllers = [startingViewController]
                    self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
                    
                    //Update First title
                    self.updateTitleForString(self.modelController.pageData[0]["name"].string!)
                    self.pageViewController?.view.userInteractionEnabled = true
                    self.showPageControl()
                }
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addPost"
        {
            (segue.destinationViewController as? AddPostViewController)?.channelID = pageControl.currentPage
        }
    }
    func showPageControl(){
        self.pageControl.hidden = false
        self.pageControl.transform = CGAffineTransformMakeScale(0.6, 0.6)
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
            self.pageControl.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }) { (completed) -> Void in
            
        }
    }
    
    
    
}

