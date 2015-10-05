//
//  ChannelPickerView.swift
//  Hood
//
//  Created by Abheyraj Singh on 20/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

class ChannelPickerView: UIView {
    
    let statusBarHeight = 20
    let buttonHeight = 75
    var channels:[Channel] = []
    var buttonsArray: NSMutableArray = NSMutableArray()
    var blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    var inView = UIView()
    
    func setUpWithChannels(inView:UIView)
    {

        self.inView = inView
        performFetchFromCoreData()
    }
    
    func createSubViews()
    {
        frame = inView.frame
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = frame
        addSubview(blurView)
        var startingY = 0
        for (key,channel) in channels.enumerate() {
            let buttonHeightToUse:CGFloat
            if(key == 0){
                buttonHeightToUse = CGFloat(statusBarHeight) + CGFloat(buttonHeight)
            }else{
                buttonHeightToUse = CGFloat(buttonHeight)
            }
            let button: UIButton = UIButton(frame: CGRectMake(CGFloat(0), CGFloat(startingY), frame.size.width, buttonHeightToUse))
            button.setTitle("#" + channel.name, forState: UIControlState.Normal)
            if let colorString = channel.color{
                button.backgroundColor = UIColor(hexString: "#" + colorString)
            }
            button.titleLabel?.font = UIFont(name: "Lato-Regular", size: 28)
            button.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            blurView.contentView.addSubview(button)
            startingY += Int(buttonHeightToUse)
        }

    }
    
    func performFetchFromCoreData()
    {
        let request = NSFetchRequest(entityName: "Channel")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { (result) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.channels = result.finalResult as! [Channel]
                print(result.finalResult!.count)
                self.createSubViews()
                
            })
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.managedObjectContext?.performBlock({ () -> Void in
            do
            {
                try appDelegate.managedObjectContext?.executeRequest(asyncRequest)
            }
            catch
            {
                print("Unable to execute asynchronous fetch result.");
                print(error)
            }
        })
    }

    
    func setUpForView(view: UIView){
        frame = view.frame
        blurView.removeFromSuperview()
        buttonsArray.removeAllObjects()
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = frame
        addSubview(blurView)
        self.setUpWithChannels(view)
    }
    
    func addButtonForObject(object: JSON, action: (() -> Void)?){
        let y:CGFloat
        let height:CGFloat
        if(self.buttonsArray.count == 0){
            y = 0
            height = CGFloat(buttonHeight + statusBarHeight)
        }else{
            y = CGFloat(buttonHeight * buttonsArray.count + statusBarHeight)
            height = CGFloat(buttonHeight)
        }
        let button: ChannelPickerButton = ChannelPickerButton(frame: CGRectMake(0, y, frame.size.width, height))
        button.setTitle("#" + object["name"].string!, forState: UIControlState.Normal)
        if let colorString = object["color"].string{
            button.backgroundColor = UIColor(hexString: "#" + colorString)
        }
        button.titleLabel?.font = UIFont(name: "Lato-Regular", size: 28)
        button.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        if action != nil
        {
            button.action = action
        }
        buttonsArray.addObject(button)
        blurView.contentView.addSubview(button)
    }
    
    func showInView(view:UIView){
        layer.opacity = 0
        view.addSubview(self)
//        let finalFrame = frame
//        let initialFrame = CGRectMake(0, -frame.size.height, frame.size.width, frame.size.height)
//        frame = initialFrame
        self.transform = CGAffineTransformMakeScale(0.9, 0.9)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
//            self.frame = finalFrame
            self.transform = CGAffineTransformMakeScale(1, 1)
            self.layer.opacity = 1
            }) { (completed:Bool) -> Void in
            
        }
    }
    
    func dismissView(){
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
            self.layer.opacity = 0
            }) { (completed:Bool) -> Void in
            self.removeFromSuperview()
        }
    }

    func buttonTapped(sender: ChannelPickerButton){
        if let senderAction = sender.action{
            senderAction()
        }
        dismissView()
        
    }
    
    class ChannelPickerButton: UIButton {
        var action: (() -> Void)?
    }
    
}
