//
//  loginViewController.swift
//  Hood
//
//  Created by Robin Malhotra on 11/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import SVProgressHUD
import Alamofire
import SwiftyJSON

class loginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.navigationItem.leftBarButtonItem=nil
        self.navigationItem.hidesBackButton=true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginWithFB(sender: AnyObject)
    {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["email","user_about_me"], handler: { (result, error) -> Void in
            
            if error != nil
            {
                print("error")
            }
            else if result.isCancelled
            {
                print("cancelled")
            }
            else
            {
                
                SVProgressHUD.showWithStatus("Logging in")
                var fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,first_name,last_name"])
                fbRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    print(result)
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue(result["first_name"], forKey: "first_name")
                    userDefaults.setValue(result["last_name"], forKey: "last_name")
                    let id = result["id"]
                    
                    let email = result["email"]
                    userDefaults.setValue("https://graph.facebook.com/\(id!)/picture?type=normal", forKey: "fbProfilePhoto")
                    userDefaults.setValue(id, forKey: "fb_id")
                    userDefaults.synchronize()
                    var firstName: String = result["first_name"] as! String
                    var lastName: String = result["last_name"] as! String
                    let parameters = [
                        "firstname":firstName,
                        "lastname" : lastName,
                        "locality_id" : 1,
                        "access_token" : FBSDKAccessToken.currentAccessToken().tokenString,
                        "fb_id" : result["id"],
                        "about" : "",
                        "email": email,
                        "profile_photo" : "https://graph.facebook.com/\(id!)/picture?type=normal"
                    ]
                    
                    Alamofire.request(.POST, "http://128.199.179.151/user/register/", parameters: parameters as? [String : AnyObject], encoding: .JSON) .response { request, response, data, error in
                        if let responseDict = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary
                        {
                            let userDefaults = NSUserDefaults.standardUserDefaults()
                            userDefaults.setValue(responseDict["id"], forKey: "id")
                            userDefaults.setValue(responseDict["access_token"], forKey: "accessToken")
                            userDefaults.synchronize()
                            let responseJSON = JSON(data: data!, options: .AllowFragments, error: nil)
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            let user:User = User.generateObjectFromJSON(responseJSON, context: appDelegate.managedObjectContext!)
                            user.is_owner = NSNumber(bool: true)
                            AppDelegate.owner = user
                            appDelegate.saveContext()
                        }
                    }

                    SVProgressHUD.dismiss()
                    let onboarding:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("onboarding") as! UIViewController
                    self.navigationController?.pushViewController(onboarding, animated: true)
                })
                
                
            }
        })
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
