
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

let HasSwiped = "HasSwiped"

class RootViewController: UIViewController, UIPageViewControllerDelegate, UIScrollViewDelegate,UIViewControllerTransitioningDelegate {

    @IBOutlet weak var notificationBarButton: UIBarButtonItem!
    let titleScrollViewWidth = CGFloat(160)
    var pageViewController: UIPageViewController?
    var titleScrollView: UIScrollView?
    let pageColors: NSMutableArray = NSMutableArray()
    let shouldHideStatusBar: Bool = false
    var statusBarBackgroundView: UIView?
    var shouldScrollCommentsToBottom = false
    var swipeCoach: UIView?
    @IBOutlet var addButton: UIButton!
    
    @IBOutlet weak var pageIndicatorContainer: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    let badge = GIBadgeView()
    var resetViewControllers: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageControl.hidden = true
        addButton.hidden = true
        addButton.layer.shadowOffset = CGSizeMake(2, 2)
        addButton.layer.shadowColor = UIColor.grayColor().CGColor
        addButton.layer.shadowOpacity = 0.8
        self.pageIndicatorContainer.backgroundColor = GlobalColors.Green
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        if let _ = self.pageViewController{
            
        }else{
            initializePageViewController()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showComments:", name: "commentsPressed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "jumpToChannel:", name: JumpToChannelNotificationName, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAddButton", name: "ShowAddButton", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideAddButton", name: "HideAddButton", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBell:", name: UpdateBell, object: nil)
        setUpNotificationButton()
        setUpOptionsButton()
        if (AppDelegate.owner == nil)
        {
            performSegueWithIdentifier("showLogin", sender: self)
        }
        else
        {
            fetchChannels()
            getData()
            fetchNotificationsCount()
        }
        
//        updateBell()

    }
    
    func updateBell()
    {
//        badge.increment()
        let keyFrameAnimation=CAKeyframeAnimation(keyPath: "position.x")
        keyFrameAnimation.additive = true
        keyFrameAnimation.values=[0,1,-1,1,-1,0]
        keyFrameAnimation.keyTimes=[0,0.25,0.5,0.75,0.9,0]
        keyFrameAnimation.duration=0.5
        keyFrameAnimation.repeatCount = 4
        badge.layer.addAnimation(keyFrameAnimation, forKey: "sdkfjnaskdf")
        
    }
    
    func setUpNotificationButton(){
        let notifButton = UIButton(frame: CGRectMake(0, 0, 25, 25))
        notifButton.contentMode = UIViewContentMode.ScaleAspectFit
        notifButton.addSubview(badge)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: notifButton)
        badge.backgroundColor = UIColor.whiteColor()
        badge.textColor = GlobalColors.Green
//        badge.increment()
        
        notifButton.setImage(UIImage(named: "bell"), forState: UIControlState.Normal)
        notifButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        notifButton.addTarget(self, action:Selector("showNotifs") , forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func showNotifs(){
        self.performSegueWithIdentifier("showNotifications", sender: self)
    }
    
    func setUpOptionsButton(){
        let optionsButton = UIButton(frame: CGRectMake(0, 0, 25, 25))
        optionsButton.contentMode = UIViewContentMode.ScaleAspectFit
        optionsButton.setImage(UIImage(named: "Profile"), forState: .Normal)
        optionsButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        optionsButton.addTarget(self, action: "showDirectory", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionsButton)
    }
    
    func showDirectory(){
        performSegueWithIdentifier("showDirectory", sender: self)
    }
    
    func optionsPressed(){
        let actionSheet = UIAlertController(title: "Options", message: "", preferredStyle: .ActionSheet)
        
        let shareApp = UIAlertAction(title: "Share App", style: .Default) { (action) -> Void in
            let activityViewController = UIActivityViewController(activityItems: ["Check out Pipal on the App Store!"], applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        actionSheet.addAction(shareApp)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .Destructive) { (action) -> Void in
            Utilities.appDelegate.logoutUserAndDeleteData()
            self._modelController = nil
            self.resetViewControllers = true
            self.performSegueWithIdentifier("showLogin", sender: self)
        }
        actionSheet.addAction(logoutAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.barHideOnSwipeGestureRecognizer.addTarget(self, action: "handleSwipeForNavigationBar:")
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let profile: AnyObject = userDefaults.valueForKey("fbProfilePhoto")
        {
            print(profile)
        }
        if (AppDelegate.owner == nil)
        {
            performSegueWithIdentifier("showLogin", sender: self)
        }
        else
        {
            getData()
            if(!NSUserDefaults.standardUserDefaults().boolForKey(HasSwiped)){
                let swipeCoach = UIImageView(image: UIImage(named: "swipecoach"))
                swipeCoach.contentMode = UIViewContentMode.ScaleAspectFit
                swipeCoach.frame = CGRectMake(0, 0, self.view.frame.width, 135)
                self.swipeCoach = swipeCoach
                self.view.addSubview(self.swipeCoach!)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        if let _ = self.titleScrollView{
            updateTitleBarColor(pageColors[pageControl.currentPage] as! UIColor)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if(self.navigationController?.navigationBarHidden == true){
           self.navigationController?.navigationBarHidden = false
        }
    }
    
    func initializePageViewController(){
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
        let pageViewRect = self.view.bounds
        self.pageViewController!.view.frame = pageViewRect
        self.pageViewController!.didMoveToParentViewController(self)
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
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
            let count = self.modelController.indexOfViewController(dataViewController)
            self.pageControl.currentPage = count
            if(!NSUserDefaults.standardUserDefaults().boolForKey(HasSwiped)){
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: HasSwiped)
                NSUserDefaults.standardUserDefaults().synchronize()
                if let swipeCoach = self.swipeCoach{
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        swipeCoach.layer.opacity = 0
                        }, completion: { (completed) -> Void in
                        swipeCoach.removeFromSuperview()
                        self.swipeCoach = nil
                    })
                }
            }
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
    
    func showCommentsWithPostID(id: Int, shouldScroll:Bool){
        let commentsView: CommentsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Comments") as! CommentsViewController
        commentsView.postID = id
        commentsView.shouldScrollToBottom = shouldScroll
        self.navigationController?.pushViewController(commentsView, animated: true)
    }
    
    func getData(){
        if(self.modelController.pageData.count == 0){
            SVProgressHUD.showWithStatus("Loading")
        }
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.GET, API().getAllChannelsForNeighbourhood("\(AppDelegate.owner!.neighbourhood.id.intValue)") + "/", headers:headers).validate()
            .responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, _, result) -> Void in
                SVProgressHUD.dismiss()
                if(result.isSuccess){
                    let swiftyJSONObject = JSON(result.value!)
                    let appDelegate = Utilities.appDelegate
                    print(swiftyJSONObject)
                    let channels:NSMutableArray = NSMutableArray()
                    for (key, channel) in swiftyJSONObject["channels"]{
                        let channelObject = Channel.generateObjectFromJSON(channel, context: appDelegate.managedObjectContext!)
                        channels.addObject(channelObject)
                    }
                    let fetchRequest = NSFetchRequest(entityName: "Channel")
                    do{
                        if let results = try appDelegate.managedObjectContext?.executeFetchRequest(fetchRequest){
                            let oldSet = NSMutableSet(array: results)
                            let newSet = NSMutableSet(array: channels as [AnyObject])
                            newSet.minusSet(oldSet as Set<NSObject>)
                            let objectsToDeleteArray = newSet.allObjects
                            if objectsToDeleteArray.count > 0{
                                for index in 0...objectsToDeleteArray.count-1{
                                    appDelegate.managedObjectContext?.deleteObject(objectsToDeleteArray[index] as! NSManagedObject)
                                }
                            }
                        }
                    }
                    catch {
                        
                    }
                    
                    appDelegate.saveContext()
                    if(self.modelController.pageData.count == 0){
                        self.fetchChannels()
                    }
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
//            let toViewController = segue.destinationViewController 
//            toViewController.transitioningDelegate = self
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
        self.updateTitleViewForPageNumber(pageControl.currentPage, animated: false)
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
//            self.performSegueWithIdentifier("showNotifications", sender: self)
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
            updateTitleBarColor(colorToSet)
        }


//        Utilities.colorBetweenColors(UIColor.redColor(), lastColor: UIColor.greenColor(), offsetAsFraction: scrollView.contentOffset.x/view.frame.width)
    }
    
    func updateTitleBarColor(colorToSet: UIColor){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
            let img = getImageWithColor(colorToSet, size: CGSizeMake(1, 64))
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.navigationController?.navigationBar.setBackgroundImage(img,forBarMetrics: .Default)
                self.pageIndicatorContainer.backgroundColor = colorToSet
                if let statusBarBackground = self.statusBarBackgroundView{
                    statusBarBackground.backgroundColor = colorToSet
                }
                self.addButton.backgroundColor = colorToSet
                self.badge.textColor = colorToSet
            })
            
        })
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {

    }
    
    func jumpToChannel(notification: NSNotification){
        if let userInfo = notification.userInfo{
            if let index = userInfo["channelID"] as? Int{
                jumpToPageForIndex(modelController.indexOfChannelId(index))
            }
        }
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
                self.addButton.backgroundColor = colorToSet
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
            if(result.isSuccess){
                let responseJSON = JSON(result.value!)
                if let unread_count = responseJSON["unread_count"].int{
                    if(unread_count>0){
                        self.badge.badgeValue = unread_count
                        self.badge.hidden = false
                        self.updateBell()
                    }else{
                        self.badge.hidden = true
                    }
                }
            }else{
                self.badge.hidden = true
            }
        }
    }
    
    func fetchChannels(){
        let fetchRequest = NSFetchRequest(entityName: "Channel")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let context = Utilities.appDelegate.managedObjectContext
        do
        {
            let results = try context?.executeFetchRequest(fetchRequest)
            if results?.count > 0{
                let mutableArray = NSMutableArray(array: results!)
                self.modelController.pageData = mutableArray
                self.populateData()
            }
        }
        catch
        {
            
        }
    }
    
    func populateData(){
        self.pageControl.numberOfPages = self.modelController.pageData.count
        if let _ = self.pageViewController{
            
        }else{
            initializePageViewController()
        }
        if(self.pageViewController!.viewControllers!.count == 0 || resetViewControllers){
            let startingViewController: FeedViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
            let viewControllers = [startingViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
            self.pageControl.currentPage = 0
            self.showPageControl()
            self.showAddButton()
            resetViewControllers = false
        }
        
        
        self.updateTitleView()
        self.pageViewController?.view.userInteractionEnabled = true
    }
    
    func showAddButton(){
        if(addButton.hidden){
            addButton.layer.opacity = 0.5
            addButton.transform = CGAffineTransformMakeScale(0.5, 0.5)
            addButton.hidden = false
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
                self.addButton.layer.opacity = 1
                self.addButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }) { (completed: Bool) -> Void in
                    
            }
        }
    }

    func hideAddButton(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.addButton.layer.opacity = 0
            }) { (completed) -> Void in
                self.addButton.hidden = true
                self.addButton.layer.opacity = 1
        }
    }
    
}



