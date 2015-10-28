
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
import Sheriff
import CoreData
class RootViewController: UIViewController, UIPageViewControllerDelegate, UIScrollViewDelegate,UIViewControllerTransitioningDelegate {

    @IBOutlet weak var notificationBarButton: UIBarButtonItem!
    let titleScrollViewWidth = CGFloat(160)
    var pageViewController: UIPageViewController?
    var titleScrollView: UIScrollView?
    let pageColors: NSMutableArray = NSMutableArray()
    let shouldHideStatusBar: Bool = false
    var statusBarBackgroundView: UIView?
    
    @IBOutlet weak var pageIndicatorContainer: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    let badge = GIBadgeView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            performSegueWithIdentifier("showLogin", sender: self)
        }
        else
        {
            getData()
            fetchNotificationsCount()
        }
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageControl.hidden = true
        self.pageIndicatorContainer.backgroundColor = GlobalColors.Green
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
        setUpNotificationButton()
    }
    
    func setUpNotificationButton(){
        let notifButton = UIButton(frame: CGRectMake(0, 0, 25, 25))
        notifButton.contentMode = UIViewContentMode.ScaleAspectFit
        notifButton.addSubview(badge)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: notifButton)
        badge.increment()
        
        notifButton.setImage(UIImage(named: "Profile"), forState: UIControlState.Normal)
        notifButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        notifButton.addTarget(self, action:Selector("showNotifs") , forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func showNotifs(){
        self.performSegueWithIdentifier("showNotifications", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.barHideOnSwipeGestureRecognizer.addTarget(self, action: "handleSwipeForNavigationBar:")
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if(self.navigationController?.navigationBarHidden == true){
           self.navigationController?.navigationBarHidden = false
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
        
        if let currentViewController = self.pageViewController!.viewControllers?[0]
        {
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })

            self.pageViewController!.doubleSided = false
        }
        return .Min
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            let dataViewController:FeedViewController = pageViewController.viewControllers!.last as! FeedViewController
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
        let commentsView: CommentsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Comments") as! CommentsViewController
        var info = notification.userInfo!
        commentsView.postID = info["postID"] as! Int
        commentsView.post = info["post"] as? Post
        self.navigationController?.pushViewController(commentsView, animated: true)
    }
    
    func getData(){
        if(self.modelController.pageData.count == 0){
            SVProgressHUD.showWithStatus("Loading")
        }
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.GET, API().getAllChannelsForNeighbourhood() + "/", headers:headers).validate()
            .responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, _, result) -> Void in
                SVProgressHUD.dismiss()
                if(result.isSuccess){
                    let swiftyJSONObject = JSON(result.value!)
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    print(swiftyJSONObject)
                    let channels:NSMutableArray = NSMutableArray()
                    for (key, channel) in swiftyJSONObject["channels"]{
                        let channelObject = Channel.generateObjectFromJSON(channel, context: appDelegate.managedObjectContext!)
                        channels.addObject(channelObject)
                    }
                    appDelegate.saveContext()
                    self.fetchChannels()
                }else{
                    print(result.error)
                }
            }
        }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addPost"
        {
            let currentChannel = self.modelController.pageData.objectAtIndex(self.pageControl.currentPage) as! Channel
            (segue.destinationViewController as? AddPostViewController)?.channelID = currentChannel.id.integerValue
        }
        else if segue.identifier == "showNotifications"
        {
            let toViewController = segue.destinationViewController 
            toViewController.transitioningDelegate = self
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let show = leftToRightNavController()
        show.isDismissing = false
        return show
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismiss = leftToRightNavController()
        dismiss.isDismissing = true
        return dismiss
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
        self.titleScrollView?.scrollEnabled = false
        var startingX:CGFloat = 0
        let pageSize:CGFloat = 160
        for item in self.modelController.pageData {
            let channel = item as! Channel
            let titleLabel:UILabel = UILabel()
            if let color = channel.color{
                pageColors.addObject(UIColor(hexString: "#" + color))
            }else{
                pageColors.addObject(GlobalColors.Green)
            }
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
            if (scrollView.contentOffset.x > self.view.frame.width) && (pageControl.currentPage != pageControl.numberOfPages - 1)
            {
                colorToSet = Utilities.colorBetweenColors(pageColors[pageControl.currentPage] as! UIColor, lastColor: pageColors[pageControl.currentPage + 1] as! UIColor, offsetAsFraction: perc)
            }
            else
            {
                if pageControl.currentPage == 0
                {
                    colorToSet = pageColors[0] as! UIColor
                    return
                }
                colorToSet = Utilities.colorBetweenColors(pageColors[pageControl.currentPage] as! UIColor, lastColor: pageColors[pageControl.currentPage - 1] as! UIColor, offsetAsFraction: -perc)
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
                let img = getImageWithColor(colorToSet, size: CGSizeMake(1, 64))
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.navigationBar.setBackgroundImage(img,forBarMetrics: .Default)
                    self.pageIndicatorContainer.backgroundColor = colorToSet
                    if let statusBarBackground = self.statusBarBackgroundView{
                        statusBarBackground.backgroundColor = colorToSet
                    }
                })
                
            })
            
        }


//        Utilities.colorBetweenColors(UIColor.redColor(), lastColor: UIColor.greenColor(), offsetAsFraction: scrollView.contentOffset.x/view.frame.width)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {

    }
    
    
    func jumpToPageForIndex(index: Int){
        let viewController = self.modelController.viewControllerAtIndex(index, storyboard: self.storyboard!)
        pageViewController!.setViewControllers([viewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: { (completed:Bool) -> Void in
            self.pageViewController?.setViewControllers([viewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        })
    }
    
    func handleSwipeForNavigationBar(gestureRecognizer: UISwipeGestureRecognizer){
        if(self.navigationController?.navigationBar.frame.origin.y<0){
            if self.statusBarBackgroundView == nil{
                self.statusBarBackgroundView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 20))
                var colorToSet: UIColor
                if(self.modelController.pageData.count>0){
                    let channel = self.modelController.pageData.objectAtIndex(self.pageControl.currentPage) as! Channel
                    colorToSet = UIColor(hexString: "#" + channel.color!)
                }else{
                    colorToSet = GlobalColors.Green
                }
                self.statusBarBackgroundView?.backgroundColor = colorToSet
                self.view.addSubview(self.statusBarBackgroundView!)
            }
        }else{
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.statusBarBackgroundView?.layer.opacity = 0
                    }, completion: { (completed: Bool) -> Void in
                        self.statusBarBackgroundView?.removeFromSuperview()
                        self.statusBarBackgroundView = nil
                })
        }
    }
    
    
    func fetchNotificationsCount(){
        let url = API().getNotificationsForUser()
        print(url)
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.GET, url, parameters: nil, encoding: ParameterEncoding.URL,headers: headers).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request, _, result) -> Void in
            
                let responseJSON = JSON(result.value!)
                self.badge.badgeValue = responseJSON["count"].int!
        }
    }
    
    func fetchChannels(){
        let fetchRequest = NSFetchRequest(entityName: "Channel")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let context = Utilities.appDelegate.managedObjectContext
        do
        {
            var results = try context?.executeFetchRequest(fetchRequest)
            if results?.count > 0{
                var mutableArray = NSMutableArray(array: results!)
                self.modelController.pageData = mutableArray
                self.populateData()
            }else{
                getData()
            }
        }
        catch
        {
            
        }
    }
    
    func populateData(){
        self.pageControl.numberOfPages = self.modelController.pageData.count
        if(self.pageViewController!.viewControllers!.count == 0){
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



