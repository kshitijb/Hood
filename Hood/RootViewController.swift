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
    let titleScrollViewWidth = CGFloat(160)
    var pageViewController: UIPageViewController?
    var titleScrollView: UIScrollView?
    let channelPicker:ChannelPickerView = ChannelPickerView()
    let pageColors: NSMutableArray = NSMutableArray()
    
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
        self.pageIndicatorContainer.backgroundColor = GlobalColors.Green.colorWithAlphaComponent(0.9)
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
            let titleString = (dataViewController.dataObject as! Channel).name
            let count = self.modelController.indexOfViewController(dataViewController)
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
        commentsView.post = info["post"] as? Post
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
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    print(swiftyJSONObject)
                    var channels:NSMutableArray = NSMutableArray()
                    for (key, channel) in swiftyJSONObject["results"]{
                        let channelObject = Channel.generateObjectFromJSON(channel, context: appDelegate.managedObjectContext!)
                        channels.addObject(channelObject)
                    }
                    appDelegate.saveContext()
                    self.modelController.pageData = channels
//                    self.modelController.pageData = swiftyJSONObject["results"]
                    self.pageControl.numberOfPages = self.modelController.pageData.count
                    print(self.modelController.pageData)
                    if(self.pageViewController!.viewControllers.count == 0){
                        let startingViewController: FeedViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
                        let viewControllers = [startingViewController]
                        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
                        self.pageControl.currentPage = 0
                        self.showPageControl()
                    }
                    

                    self.updateTitleView()
                    self.pageViewController?.view.userInteractionEnabled = true
                }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addPost"
        {
            let currentChannel = self.modelController.pageData.objectAtIndex(self.pageControl.currentPage) as! Channel
            (segue.destinationViewController as? AddPostViewController)?.channelID = currentChannel.id.integerValue
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
        self.channelPicker.setUpForView(self.navigationController!.view)
        self.titleScrollView = UIScrollView(frame: CGRectMake(0, 0, 160, 40))
        self.titleScrollView?.pagingEnabled = true
        self.titleScrollView?.scrollEnabled = false
        let tapGesture = UITapGestureRecognizer(target: self, action: "titleViewTapped")
        self.titleScrollView?.addGestureRecognizer(tapGesture)
        var startingX:CGFloat = 0
        let pageSize:CGFloat = 160
        for item in self.modelController.pageData {
            let channel = item as! Channel
            let titleLabel:UILabel = UILabel()
//            if let color = channel.color{
                pageColors.addObject(UIColor(hexString: "#" + channel.color))
//            }else{
                pageColors.addObject(GlobalColors.Green)
//            }
            titleLabel.text = "#" + channel.name
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
//        self.updateTitleViewForPageNumber(pageControl.currentPage, animated: false)
    }
    
    func updateTitleViewForPageNumber(page: Int, animated: Bool){
        var frame = titleScrollView!.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        
        frame.origin.y = 0;
        self.titleScrollView?.setContentOffset(CGPointMake(CGFloat(pageControl.currentPage) * titleScrollViewWidth, frame.origin.y), animated: animated)
    }

    
//    MARK: ScrollView Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageViewOffset = scrollView.contentOffset.x - self.pageViewController!.view.frame.size.width
        let titleViewOffset = CGFloat(pageControl.currentPage) * titleScrollViewWidth + (pageViewOffset/self.pageViewController!.view.frame.size.width) * 160
        self.titleScrollView!.contentOffset = CGPointMake(titleViewOffset, 0)
        let perc = scrollView.contentOffset.x/self.view.frame.width - 1

        if scrollView.contentOffset.x - view.frame.width < 0 && pageControl.currentPage == 0
        {
            //too much to the left
        }
        else if scrollView.contentOffset.x - view.frame.width > 0 && pageControl.currentPage == pageControl.numberOfPages - 1
        {
            //too much to the right
        }
        else
        {

            var colorToSet:UIColor
            
            //can find direction of scroll from currentPage and contentOffset
            if (scrollView.contentOffset.x > 0) && (pageControl.currentPage != pageControl.numberOfPages - 1)
            {
                colorToSet = Utilities.colorBetweenColors(pageColors[pageControl.currentPage] as! UIColor, lastColor: pageColors[pageControl.currentPage + 1] as! UIColor, offsetAsFraction: perc)
                
            }
            else
            {
                colorToSet = Utilities.colorBetweenColors(pageColors[pageControl.currentPage] as! UIColor, lastColor: pageColors[pageControl.currentPage - 1] as! UIColor, offsetAsFraction: -perc)
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
                let img = getImageWithColor(colorToSet, CGSizeMake(1, 64))
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.navigationBar.setBackgroundImage(img,forBarMetrics: .Default)
                    self.pageIndicatorContainer.backgroundColor = colorToSet
                    
                })
                
            })
            
        }


//        Utilities.colorBetweenColors(UIColor.redColor(), lastColor: UIColor.greenColor(), offsetAsFraction: scrollView.contentOffset.x/view.frame.width)
    }
    
    func titleViewTapped(){
        channelPicker.showInView(self.navigationController!.view)
    }
    
    func jumpToPageForIndex(index: Int){
        let viewController = self.modelController.viewControllerAtIndex(index, storyboard: self.storyboard!)
        pageViewController!.setViewControllers([viewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: { (completed:Bool) -> Void in
            pageViewController?.setViewControllers([viewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        })
    }
    
}
    
    


