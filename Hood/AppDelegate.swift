//
//  AppDelegate.swift
//  Hood
//
//  Created by Abheyraj Singh on 30/07/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = PipalGlobalColor
        UINavigationBar.appearance().setBackgroundImage(getImageWithColor(PipalGlobalColor, CGSizeMake(1, 64)), forBarMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage.new()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        let fontNames = UIFont.fontNamesForFamilyName("Lato")
        let font = UIFont(name: "Lato-Regular", size: 26)
        if let font = font{
            let titleDict: NSDictionary = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
            UINavigationBar.appearance().titleTextAttributes = titleDict as [NSObject : AnyObject]
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }


    
}

