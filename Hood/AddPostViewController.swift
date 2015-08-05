//
//  AddPostViewController.swift
//  Hood
//
//  Created by Robin Malhotra on 05/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController {
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var textviewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var addPhotoButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        postTextView.becomeFirstResponder()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardDidShowNotification, object: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//  MARK: - animate Add photo button with Keyboard
    
    func keyboardWillShow(notification:NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                let textViewOrigin = self.postTextView.frame.origin
//                self.postTextView.frame = CGRectMake(textViewOrigin.x, textViewOrigin.y, self.postTextView.frame.width, self.postTextView.frame.height - keyboardSize.height)
                self.textviewBottomConstraint.constant = keyboardSize.height + 20
                self.postTextView.layoutIfNeeded()
                }, completion: { (completed) -> Void in
                
            })
            
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            print(duration)
        }
    }
    func keyboardWillHide(notification:NSNotification)
    {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
