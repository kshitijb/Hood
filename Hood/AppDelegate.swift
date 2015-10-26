//
//  AppDelegate.swift
//  Hood
//
//  Created by Abheyraj Singh on 30/07/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Fabric
import Crashlytics
import CoreData
import Alamofire
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, UIAlertViewDelegate {
    var window: UIWindow?
    static var owner:User?
    var gcmSenderID: String?
    var registrationToken: String?
    let registrationKey = "onRegistrationCompleted"
    var registrationOptions = [String: AnyObject]()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = GlobalColors.Green
        UINavigationBar.appearance().setBackgroundImage(getImageWithColor(GlobalColors.Green, size: CGSizeMake(1, 64)), forBarMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        let font = UIFont(name: "Lato-Regular", size: 26)
        if let font = font{
            let titleDict: NSDictionary = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
            UINavigationBar.appearance().titleTextAttributes = titleDict as? [String : AnyObject]
        }
        Fabric.with([Crashlytics()])
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedObjectContext!)
        fetchRequest.predicate = NSPredicate(format: "is_owner == %@", argumentArray: [NSNumber(bool: true)])
        fetchRequest.fetchLimit = 1
        if(managedObjectContext!.countForFetchRequest(fetchRequest, error: nil) > 0){
            
        do
        {
            AppDelegate.owner = try self.managedObjectContext!.executeFetchRequest(fetchRequest).last as? User
        }
        catch
        {
        
        }
            
        }
//        Lookback.setupWithAppToken("3kok372o2DpYeWKFF")
//        Lookback.sharedLookback().feedbackBubbleInitialPosition = CGPointMake(-20, -20)
//        Lookback.sharedLookback().shakeToRecord = true
//        Lookback.sharedLookback().feedbackBubbleVisible = true
        
//        if let options = launchOptions{
//            if let notification = options[UIApplicationLaunchOptionsRemoteNotificationKey]{
//                processPushNotification(notification)
//            }
//        }
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
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        if(deviceToken.length == 0){
            print("deviceToken is empty")
        }
        print("Device token is \(tokenString)")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notificationsEnabled")
        NSUserDefaults.standardUserDefaults().synchronize()
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
            kGGLInstanceIDAPNSServerTypeSandboxOption:false]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
        
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
            print("Registration for remote notification failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                registrationKey, object: nil, userInfo: userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        print("notification received with completion handler \(userInfo)")
        if(UIApplication.sharedApplication().applicationState != UIApplicationState.Active){
            processPushNotification(userInfo)
        }else if(UIApplication.sharedApplication().applicationState == UIApplicationState.Active){
            NSNotificationCenter.defaultCenter().postNotificationName("PushNotification", object: nil, userInfo: userInfo)
        }
        
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        print("handle pressed")
    }
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            if(AppDelegate.owner != nil){
                sendTokenToServer(registrationToken)
            }
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
        }
    }
    
    func sendTokenToServer(token: String){
        let parameters = ["device_id": token]
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        Alamofire.request(.POST, API().registerDevice(), parameters: parameters, encoding: .JSON, headers: headers).responseData { (request, response, result) -> Void in
            if(result.isSuccess){
                print("Token sent successfully")
            }else{
                print("Error sending token \(result.error)")
            }
        }
    }
    
    func onTokenRefresh() {
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "housing.core_data" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Model.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do
        {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        }
        catch
        {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            dict[NSUnderlyingErrorKey] = error
//            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            // Replace this with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog("Unresolved error \(error), \(error!.userInfo)")
            
            print("Shit happened, and I∫m in no mood to fix it")
            abort()
            

        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    func privateContext () -> NSManagedObjectContext{
        let privateContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        privateContext.parentContext = managedObjectContext
        return privateContext
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            let _ : NSError? = nil
            do
            {
                try moc.save()
            }
            catch
            {
                
            }
            
//            if moc.hasChanges && !moc.save() {
//                // Replace this implementation with code to handle the error appropriately.
//                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                NSLog("Unresolved error \(error), \(error!.userInfo)")
//                abort()
//            }
        }
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(
            app,
            openURL: url,
            sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as! String,
            annotation: nil)
    }

    // MARK: Notifications
    
    func processPushNotification(notification: AnyObject){
        if((notification["NOTIFICATION_POST_ID"]) != nil){
            if let id = notification["NOTIFICATION_POST_ID"]{
                if let rootViewController = (window?.rootViewController as? UINavigationController)?.viewControllers.first as? RootViewController{
                    rootViewController.showCommentsWithPostID(id.integerValue)
                }
            }
        }
    }
    
    func askForNotifications(){
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func showNotificationsAlert(){
        if(!NSUserDefaults.standardUserDefaults().boolForKey("notificationsEnabled")){
            UIAlertView(title: "Enable Notifications", message: "Hi! Congratulations on making your first post. To stay up to date on what's going on around you, we recommend that you enable notifications", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Enable").show()
        }
    }
    
    // MARK: UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == 1){
            askForNotifications()
        }
    }
    
}

