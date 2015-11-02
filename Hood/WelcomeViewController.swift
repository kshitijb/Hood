//
//  WelcomeViewController.swift
//  Pipal
//
//  Created by Abheyraj Singh on 07/10/15.
//  Copyright © 2015 Housing Labs. All rights reserved.
//

import UIKit


class WelcomeViewController: UIViewController {

    @IBOutlet var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        meetNeighboursButton.layer.cornerRadius = 20
//        meetNeighboursButton.addTarget(self, action: "showOnboarding", forControlEvents: .TouchUpInside)
        welcomeLabel.text = "Welcome to \(AppDelegate.owner!.neighbourhood.name)"
        let delayInSeconds = 1.4;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
        self.dismissViewControllerAnimated(true, completion: nil)

        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showOnboarding(){
//        let onboarding:UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("onboarding"))!
//        self.navigationController?.pushViewController(onboarding, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
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
