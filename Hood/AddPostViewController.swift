//
//  AddPostViewController.swift
//  Hood
//
//  Created by Robin Malhotra on 05/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController,UITextViewDelegate
{
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var textviewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var addPhotoButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        addPhotoButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        postTextView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if textView.text == "What's on your mind?"
        {
            textView.text = nil
            textView.textColor = UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
            
        }
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
                self.textviewBottomConstraint.constant = keyboardSize.height + 20
                self.postTextView.layoutIfNeeded()
            }, completion: { (completion) -> Void in
                
            })
        }
    }
    func keyboardWillHide(notification:NSNotification)
    {
        
    }

}
