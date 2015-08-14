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
class RootViewController: UIViewController, UIPageViewControllerDelegate, UIScrollViewDelegate {

    var pageViewController: UIPageViewController?
    var titleScrollView: UIScrollView?
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
        for view in self.pageViewController!.view.subviews{
            if(view.isKindOfClass(UIScrollView)){
                (view as! UIScrollView).delegate = self
            }
        }
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
            let count = self.modelController.indexOfViewController(dataViewController)
            updateTitleViewForPageNumber(count, animated: true)
//            self.titleScrollView?.contentOffset = CGPointMake(pageOffset, 0)
//            updateTitleForString("\(titleString)")
            self.pageControl.currentPage = count
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
        commentsView.post = JSON(info["post"]!)
        self.navigationController?.pushViewController(commentsView, animated: true)
    }
    
    func getData(){
        if(self.modelController.pageData.count == 0){
            SVProgressHUD.showWithStatus("Loading")
        }
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
                    print(self.modelController.pageData)
                    if(self.pageViewController!.viewControllers.count == 0){
                        let startingViewController: FeedViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
                        let viewControllers = [startingViewController]
                        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
                        self.pageControl.currentPage = 0
                        self.showPageControl()
                    }
                    
                    //Update First title
//                    self.updateTitleForString(self.modelController.pageData[0]["name"].string!)
                    self.updateTitleView()
                    self.pageViewController?.view.userInteractionEnabled = true
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
    
    func updateTitleView(){
        self.titleScrollView = UIScrollView(frame: CGRectMake(0, 0, 160, 40))
        self.titleScrollView?.pagingEnabled = true
        self.titleScrollView?.userInteractionEnabled = false
        var startingX:CGFloat = 0
        let pageSize:CGFloat = 160
        for (key, channel) in self.modelController.pageData {
            let titleLabel:UILabel = UILabel()
            titleLabel.text = "#" + channel["name"].string!
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.font = UIFont(name: "Lato-Regular", size: 26)
            titleLabel.textColor = UIColor.whiteColor()
            let x:CGFloat = startingX * pageSize
            titleLabel.frame = CGRectMake(x, 0, pageSize, 40)
            self.titleScrollView?.addSubview(titleLabel)
            startingX = startingX + 1
        }
        self.titleScrollView?.contentSize = CGSizeMake(startingX * pageSize, 0)
        self.navigationItem.titleView = self.titleScrollView
        self.updateTitleViewForPageNumber(pageControl.currentPage, animated: false)
    }
    
    func updateTitleViewForPageNumber(page: Int, animated: Bool){
        var frame = titleScrollView!.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0;
        self.titleScrollView?.setContentOffset(CGPointMake(frame.origin.x, frame.origin.y), animated: animated)
    }
    
    
    //MARK: ScrollView Delegate
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        println("Scrollview offset is \(scrollView.contentOffset.x)")
//        let pageViewOffset = scrollView.contentOffset.x - self.pageViewController!.view.frame.size.width
//        let titleViewOffset = (pageViewOffset/self.pageViewController!.view.frame.size.width) * 160
//        self.titleScrollView!.contentOffset = CGPointMake(self.titleScrollView!.contentOffset.x + titleViewOffset, 0)
//    }
    
}

