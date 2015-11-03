//
//  LockViewController.swift
//  Pipal
//
//  Created by Abheyraj Singh on 06/10/15.
//  Copyright © 2015 Housing Labs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LockViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var lockTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lockTextField.delegate = self
        lockTextField.keyboardType = UIKeyboardType.PhonePad
        submitButton.addTarget(self, action: "submit", forControlEvents: .TouchUpInside)
        submitButton.hidden = true
        submitButton.frame.size = CGSizeMake(35,35)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        lockTextField.becomeFirstResponder()
    }
    
    func submit(){
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.frame = self.submitButton.frame
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        submitButton.hidden = true
        Alamofire.request(.POST, API().updateUserLocality(), parameters: ["locality_code":lockTextField.text!], encoding: .JSON, headers: headers).responseJSON { (request, response, result) -> Void in
            if(result.isSuccess){
                if let _ = result.value?.valueForKey("error"){
                    UIAlertView(title: "Error", message: "Seems like the code you have entered is incorrect. Please try again", delegate: self, cancelButtonTitle: "Ok").show()
                }else{
                    let responseJSON = JSON(result.value!)
                    let neighbourhood = Neighbourhood.generateObjectFromJSON(responseJSON, context: Utilities.appDelegate.managedObjectContext!)
                    AppDelegate.owner?.neighbourhood = neighbourhood
                    Utilities.appDelegate.saveContext()
                    self.performSegueWithIdentifier("welcomeSegue", sender: nil)
                }
            }else{
                print(result.error)
            }
            self.activityIndicator.removeFromSuperview()
            self.submitButton.hidden = false
        }
    }
    
    //Mark: UITextField Delegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > textField.text?.characters.count )
        {
            return false;
        }
        
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        if(newLength == 4){
            submitButton.hidden = false
        }else if(newLength < 4){
            submitButton.hidden = true
        }
        return newLength <= 4
    }

}
