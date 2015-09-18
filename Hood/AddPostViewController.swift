//
//  AddPostViewController.swift
//  Hood
//
//  Created by Robin Malhotra on 05/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import Alamofire

class AddPostViewController: UIViewController,UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var postScrollView: UIScrollView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    var channelID: Int?
    @IBOutlet weak var postNowButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var textViewHeightConstant: NSLayoutConstraint!
    var pickedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesBarsOnSwipe = false
        addPhotoButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        postTextView.delegate = self
        postNowButton.layer.borderColor = GlobalColors.Green.CGColor
        postNowButton.layer.borderWidth = 2.5
        postNowButton.layer.cornerRadius = 25
        var viewBindingsDict: NSMutableDictionary = NSMutableDictionary()
        viewBindingsDict.setValue(addPhotoButton, forKey: "addPhotoButton")
        viewBindingsDict.setValue(postNowButton, forKey: "postNowButton")
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[addPhotoButton]-(==10)-[postNowButton]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewBindingsDict as [NSObject : AnyObject]))
        addPhotoButton.addTarget(self, action: "addPhoto", forControlEvents: UIControlEvents.TouchUpInside)
        let aspectConstraint = NSLayoutConstraint(item: postImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: postImageView, attribute: NSLayoutAttribute.Height, multiplier: 16/9, constant: 0)
        aspectConstraint.priority = 999
        postImageView.addConstraint(aspectConstraint)
    }
    
    @IBAction func postNow(sender: AnyObject)
    {
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("id") as? Int
        var params = [ "user_id": userID! ,"locality_id" : API.Static.currentNeighbourhoodID, "channel_id" : channelID!, "message" : postTextView.text] as [String:AnyObject!]
        if let pickedImage = pickedImage{
            let imageData = UIImagePNGRepresentation(pickedImage)
            let base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
            params["file"] = base64String
        }
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        self.title = "Posting"
        self.postNowButton.enabled = false
        self.navigationController?.popViewControllerAnimated(true)
        let userInfo:Dictionary = ["channelID":self.channelID!]
        NSNotificationCenter.defaultCenter().postNotificationName(AddingPostNotificationName, object: nil, userInfo: userInfo)
        Alamofire.request(.POST, API().addPost(), parameters: params,encoding: .JSON, headers: headers).response({ (request, response, data, error) -> Void in
            print(error)
            if error != nil
            {
            }
            else
            {
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                NSNotificationCenter.defaultCenter().postNotificationName(AddedPostNotificationName, object: nil, userInfo: userInfo)
                self.postNowButton.enabled = true
                self.title = ""
            }
        })

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        postTextView.becomeFirstResponder()
        //Todo: Use UIKeyboardWillChangeFrameNotification here
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if textView.text == "What's on your mind?"
        {
            textView.text = nil
            textView.textColor = UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
            
        }
    }

    func textViewDidChange(textView: UITextView) {
        updateScrollViewContentSize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

//  MARK: - animate Add photo button with Keyboard

    
    func keyboardWillShow(notification:NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            let curve: AnyObject? = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey]
            if(self.buttonBottomConstraint.constant < keyboardSize.height){
                self.buttonBottomConstraint.constant += keyboardSize.height
                UIView.animateWithDuration(duration!, delay: 0, options: nil, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    }, completion: { (completion) -> Void in
                        
                })
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            let curve: AnyObject? = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey]
            self.buttonBottomConstraint.constant -= keyboardSize.height
            UIView.animateWithDuration(duration!, delay: 0, options: nil, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (completion) -> Void in
                    
            })
        }

    }

    func addPhoto(){
        let cameraViewController = ALCameraViewController(croppingEnabled: true) { (image) -> Void in
            if(image?.size.width > 2*self.view.frame.width)
            {
                self.pickedImage = self.resizeImage(image!)
            }
            else
            {
                self.pickedImage = image
            }
                        
            self.postImageView.image = self.pickedImage
            self.updateScrollViewContentSize()
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            
        }
        presentViewController(cameraViewController, animated: true) { () -> Void in
            
        }
    }
    
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    func updateScrollViewContentSize(){
        postScrollView.contentSize = CGSizeMake(0, postImageView.frame.size.height + postImageView.frame.origin.y)
    }
    
    func resizeImage(image: UIImage) -> UIImage{
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let targetWidth = UIScreen.mainScreen().bounds.width
        let targetHeight = (originalHeight/originalWidth)*targetWidth
        let targetSize = CGSizeMake(targetWidth, targetHeight)
        UIGraphicsBeginImageContext(targetSize)
        let targetRect = CGRectMake(0, 0, targetSize.width, targetSize.height)
        image.drawInRect(targetRect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        return resizedImage
        
    }
    
    

    
}
