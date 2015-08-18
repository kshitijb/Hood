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
    override func viewDidLoad() {
        super.viewDidLoad()
        addPhotoButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        postTextView.delegate = self
        postNowButton.layer.borderColor = UIColor(red: 243/255, green: 150/255, blue: 48/255, alpha: 1).CGColor
        postNowButton.layer.borderWidth = 2.5
        postNowButton.layer.cornerRadius = 25
        var viewBindingsDict: NSMutableDictionary = NSMutableDictionary()
        viewBindingsDict.setValue(addPhotoButton, forKey: "addPhotoButton")
        viewBindingsDict.setValue(postNowButton, forKey: "postNowButton")
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[addPhotoButton]-(>=10)-[postNowButton]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewBindingsDict as [NSObject : AnyObject]))
        addPhotoButton.addTarget(self, action: "addPhoto", forControlEvents: UIControlEvents.TouchUpInside)
        let aspectConstraint = NSLayoutConstraint(item: postImageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: postImageView, attribute: NSLayoutAttribute.Height, multiplier: 16/9, constant: 0)
        aspectConstraint.priority = 999
        postImageView.addConstraint(aspectConstraint)
    }
    
    @IBAction func postNow(sender: AnyObject)
    {
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("id") as? Int
        let params = [ "user_id": userID! ,"locality_id" : 1, "channel_id" : channelID!+1, "message" : postTextView.text] as [String:AnyObject!]
        print(params)
        Alamofire.request(.POST, API().addPost(), parameters: params,encoding: .JSON).response({ (request, response, data, error) -> Void in
            print(error)
            print(response)
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            self.navigationController?.popViewControllerAnimated(true)
        })

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
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
        postScrollView.contentSize = CGSizeMake(0, postImageView.frame.size.height + postImageView.frame.origin.y)
//        if(textView.contentSize.height > self.textViewHeightConstant.constant){
//            textViewHeightConstant.constant = textView.contentSize.height
//            self.view.layoutIfNeeded()
//        }
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
            UIView.animateWithDuration(duration!, delay: 0, options: nil, animations: { () -> Void in
                if(self.buttonBottomConstraint.constant < keyboardSize.height){
                    self.buttonBottomConstraint.constant += keyboardSize.height
                    self.postScrollView.layoutIfNeeded()
                }
            }, completion: { (completion) -> Void in
                
            })
        }
    }
    
    func keyboardWillHide(notification:NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            let curve: AnyObject? = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey]
            UIView.animateWithDuration(duration!, delay: 0, options: nil, animations: { () -> Void in
                self.buttonBottomConstraint.constant -= keyboardSize.height
                self.postScrollView.layoutIfNeeded()
                }, completion: { (completion) -> Void in
                    
            })
        }

    }

    func addPhoto(){
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let pickedImage = image
//        var attributedString:NSMutableAttributedString = NSMutableAttributedString(string: postTextView.text)
//        let textAttachment:NSTextAttachment = NSTextAttachment()
//        textAttachment.image = pickedImage
//        let scaleFactor:CGFloat = image.size.width/postTextView.frame.size.width-10
//        textAttachment.image = UIImage(CGImage: textAttachment.image?.CGImage, scale: scaleFactor, orientation: UIImageOrientation.Up)
//        let attributedStringWithImage = NSAttributedString(attachment: textAttachment)
//        attributedString.appendAttributedString(attributedStringWithImage)
//        postTextView.attributedText = attributedString
//        let imageView = UIImageView(image: pickedImage)
//        imageView.frame = CGRectMake(0, 0, postTextView.frame.size.width, postTextView.frame.size.width * 16/9)
//        postTextView.insertSubview(imageView, atIndex: 0)
        postImageView.image = pickedImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
}
