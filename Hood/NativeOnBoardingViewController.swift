//
//  nativeOnBoardingViewController.swift
//  Pipal
//
//  Created by Robin Malhotra on 14/10/15.
//  Copyright © 2015 Housing Labs. All rights reserved.
//

import UIKit

class NativeOnBoardingViewController: UIViewController {
    var currentObjectsOnScreen:[AnyObject] = []
    let BURROW_WIDTH = CGFloat(743/2)
    let BURROW_HEIGHT = CGFloat(332)
    let BURROW_BUILDING_WIDTH = CGFloat(272/2)
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = GlobalColors.Green
        firstScreen()

        // Do any additional setup after loading the view.
    }
    
    func firstScreen()
    {
        let burrowImageView = UIImageView(image: UIImage(named: "burrow"))
        burrowImageView.frame = CGRectMake(0, view.frame.height - BURROW_HEIGHT, view.frame.width, BURROW_HEIGHT)
        burrowImageView.opaque = false
        view.addSubview(burrowImageView)
        
        let yellowArrow = UIButton()
        yellowArrow.setBackgroundImage(UIImage(named: "yellowArrow"), forState: UIControlState.Normal)
        yellowArrow.frame = CGRectMake(CGRectGetMidX(view.frame) - 22.5, CGRectGetMinY(burrowImageView.frame) - 77, 45, 45)
        yellowArrow.addTarget(self, action: "secondScreenTransition", forControlEvents: .TouchUpInside)
        view.addSubview(yellowArrow)
        
        let subtextLabel = UILabel(frame: CGRectMake(-view.frame.width, 158, view.frame.width, 72))
        subtextLabel.text = "Your neighborhood \n gathers here"
        subtextLabel.numberOfLines = 0
        subtextLabel.textAlignment = .Center
        subtextLabel.alpha = 0
        subtextLabel.opaque = false
        subtextLabel.font = UIFont(name: "Lato-light", size: 28)
        subtextLabel.textColor = UIColor.whiteColor()
        view.addSubview(subtextLabel)
        
        
        let titleLabel = UILabel(frame: CGRectMake( 0,80, view.frame.width, 50))
        titleLabel.font = UIFont(name: "Lato-Black", size: 42)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Pipal"
        titleLabel.textAlignment = .Center
        titleLabel.opaque = false
        view.addSubview(titleLabel)
        
        UIView.animateWithDuration(0.3) { () -> Void in
            subtextLabel.alpha = 1
            subtextLabel.transform = CGAffineTransformMakeTranslation(self.view.frame.width, 0)
        }
        currentObjectsOnScreen = [burrowImageView,yellowArrow,subtextLabel,titleLabel]
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func secondScreenTransition()
    {
        if let burrowImageView = currentObjectsOnScreen[0] as? UIImageView, yellowArrow = currentObjectsOnScreen[1] as? UIButton, subtextLabel = currentObjectsOnScreen[2] as? UILabel, titleLabel = currentObjectsOnScreen[3] as? UILabel
        {
            UIView.animateWithDuration(0.3, animations:
            { () -> Void in
                titleLabel.alpha = 0
                yellowArrow.alpha = 0
                burrowImageView.frame.origin.y = 204
                subtextLabel.alpha = 0
                subtextLabel.transform = CGAffineTransformMakeTranslation(-self.view.frame.width, 0)
            })
            
            UIView.animateWithDuration(0.73, animations: { () -> Void in
                burrowImageView.frame.origin.x = -self.BURROW_WIDTH/(2*self.BURROW_BUILDING_WIDTH)*self.view.frame.width
            })
            
            UIView.animateWithDuration(0.94, animations: { () -> Void in
                let aspectRatio = self.BURROW_WIDTH/self.BURROW_BUILDING_WIDTH
                burrowImageView.frame.size = CGSizeMake(aspectRatio*self.view.frame.width, aspectRatio*self.BURROW_HEIGHT )
                
                }, completion: { (completed) -> Void in
                    yellowArrow.removeFromSuperview()
                    titleLabel.removeFromSuperview()
                    subtextLabel.removeFromSuperview()
                    self.currentObjectsOnScreen = [burrowImageView]
                    self.secondScreenRender()
            })
        }
        
    }
    
    func secondScreenRender()
    {
        let subtext2 = UILabel(frame: CGRectMake(30, 56, 314, 108))
        subtext2.text = "Meet \nthe neighbours \n you don't know"
        subtext2.font = UIFont(name: "Lato-light", size: 28)
        subtext2.numberOfLines = 3
        subtext2.textColor = UIColor.whiteColor()
        subtext2.textAlignment = .Center
        view.addSubview(subtext2)
        
        let yellowArrow = UIButton()
        yellowArrow.setBackgroundImage(UIImage(named: "yellowArrow"), forState: UIControlState.Normal)
        yellowArrow.frame = CGRectMake(CGRectGetMidX(view.frame) - 22.5, CGRectGetMaxY(subtext2.frame) + 23, 45, 45)
        yellowArrow.addTarget(self, action: "thirdScreenTransition", forControlEvents: .TouchUpInside)
        view.addSubview(yellowArrow)
        
        currentObjectsOnScreen += [yellowArrow,subtext2]
        
        let numberInWords = ["one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"]

        for i in 0...2
        {
            for j in 0...4
            {
                
                if(j + i*5 < 15)
                {
                    print(j + i*5 )
                    let personView = UIImageView(image: UIImage(named: numberInWords[j+i*5]))
                    personView.frame = CGRectMake(30 + 123 * CGFloat(i), CGRectGetMaxY(yellowArrow.frame) + 20 + CGFloat(j) * 82 , 60, 60)
                    personView.opaque = false
                    view.addSubview(personView)
                    currentObjectsOnScreen.append(personView)
                    
                 }
            }
        }
    }
    
    func thirdScreenTransition()
    {
        if let burrowImageView = currentObjectsOnScreen[0] as? UIImageView, yellowArrow = currentObjectsOnScreen[1] as? UIButton, subtextLabel = currentObjectsOnScreen[2] as? UILabel
        {
            let personObjects = currentObjectsOnScreen[3...currentObjectsOnScreen.count-1]
            let fourRandomConversationalists = Array(personObjects).getFourRandomElements() as! [UIImageView]
            
            let subtextLabel2 = UILabel(frame: CGRectMake( view.frame.width, 56, view.frame.width, 108))
            subtextLabel2.text = "Discuss \n important issues \n without spam"
            subtextLabel2.textAlignment = .Center
            subtextLabel2.font = UIFont(name: "Lato-light", size: 28)
            subtextLabel2.textColor = UIColor.whiteColor()
            subtextLabel2.numberOfLines = 3
            subtextLabel2.opaque = false
            subtextLabel2.alpha = 0
            view.addSubview(subtextLabel2)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                subtextLabel2.transform = CGAffineTransformMakeTranslation(-self.view.frame.width, 0)
                subtextLabel2.alpha = 1
                burrowImageView.alpha = 0
                subtextLabel.transform = CGAffineTransformMakeTranslation(-self.view.frame.width, 0)
                for (index,personView) in fourRandomConversationalists.enumerate()
                {
                    personView.frame = CGRectMake(34, CGRectGetMaxY(yellowArrow.frame) + 75 + CGFloat(95*index), 45, 45)
                }
                let personArray = Array(personObjects) as! [UIImageView]
                for person in personArray
                {
                    if(!fourRandomConversationalists.contains(person))
                    {
                        person.alpha = 0
                        person.removeFromSuperview()
                    }
                }
                
                
                
            }, completion: { (completed) -> Void in
                burrowImageView.removeFromSuperview()
                subtextLabel.removeFromSuperview()
                self.currentObjectsOnScreen = [yellowArrow,subtextLabel2] + fourRandomConversationalists
                yellowArrow.removeTarget(self, action: Selector("thirdScreenTransition"), forControlEvents: .TouchUpInside)
                
                self.thirdScreenRender()
            })
        }
    }
    
    
    func thirdScreenRender()
    {
        if let yellowArrow = currentObjectsOnScreen[0] as? UIButton, let subtextLabel = currentObjectsOnScreen[1] as? UILabel
        {
            yellowArrow.addTarget(self, action: Selector("fourthScreenTransition"), forControlEvents: .TouchUpInside)
            let fourRandomConversationalists = Array(currentObjectsOnScreen[2...currentObjectsOnScreen.count-1])
            let heightsOfConversations = [65,30,49,30]
            let widthsOfConversations = [240, 263, 214,50]
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
               
                }, completion: { (completion) -> Void in
                    
            })
            
            var conversations = [UIImageView]()
            for (index,person) in fourRandomConversationalists.enumerate()
            {
                let conversation = UIImageView(image: UIImage(named: "bub"+String(index)))
                conversation.frame = CGRectMake(CGRectGetMaxX(person.frame), CGRectGetMaxY(person.frame) - CGFloat(heightsOfConversations[index]), CGFloat(widthsOfConversations[index]), CGFloat(heightsOfConversations[index]))
                conversation.opaque = false
                view.addSubview(conversation)
                conversations.append(conversation)
            }
            currentObjectsOnScreen = [yellowArrow,subtextLabel] + fourRandomConversationalists + conversations
            
        }
    }
    
    func fourthScreenTransition()
    {
        if let yellowArrow = currentObjectsOnScreen[0] as? UIButton, let subtextLabel = currentObjectsOnScreen[1] as? UILabel
        {
            let imageViews = Array(currentObjectsOnScreen[2...currentObjectsOnScreen.count-1]) as! [UIImageView]
            
            let subtextLabel2 = UILabel(frame: CGRectMake(view.frame.width, 56, view.frame.width, 72))
            subtextLabel2.text = "Find a local maid \n to cook and clean"
            subtextLabel2.opaque = false
            subtextLabel2.font = UIFont(name: "Lato-light", size: 28)
            subtextLabel2.alpha = 0
            subtextLabel2.textColor = UIColor.whiteColor()
            subtextLabel2.numberOfLines = 2
            subtextLabel2.textAlignment = .Center
            view.addSubview(subtextLabel2)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                subtextLabel.transform = CGAffineTransformMakeTranslation(-2*self.view.frame.width, 0)
                subtextLabel.alpha = 0
                
                subtextLabel2.transform = CGAffineTransformMakeTranslation(-self.view.frame.width, 0)
                subtextLabel2.alpha = 1
                for image in imageViews
                {
                    image.transform = CGAffineTransformMakeTranslation(-self.view.frame.width, 0)
                    image.alpha = 0
                }
            }, completion: { (completion) -> Void in
                yellowArrow.removeTarget(self, action: "fourthScreenTransition", forControlEvents: UIControlEvents.TouchUpInside)
                self.currentObjectsOnScreen = [yellowArrow,subtextLabel2]
                subtextLabel.removeFromSuperview()
                yellowArrow.addTarget(self, action: "fifthScreenTransition", forControlEvents: UIControlEvents.TouchUpInside)
            })
        }
    }
    
    func fifthScreenTransition()
    {
        if let yellowArrow = currentObjectsOnScreen[0] as? UIButton, let subtextLabel = currentObjectsOnScreen[1] as? UILabel
        {
            yellowArrow.addTarget(self, action: "fifthScreenTransition", forControlEvents: .TouchUpInside)
            let subtextLabel2 = UILabel(frame: CGRectMake(view.frame.width, 56, view.frame.width, 108))
            subtextLabel2.text = "Sell your \n unused refrigerator to a \ntrusty neighbour"
            subtextLabel2.opaque = false
            subtextLabel2.font = UIFont(name: "Lato-light", size: 28)
            subtextLabel2.alpha = 0
            subtextLabel2.textColor = UIColor.whiteColor()
            subtextLabel2.numberOfLines = 3
            subtextLabel2.textAlignment = .Center
            view.addSubview(subtextLabel2)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                subtextLabel.transform = CGAffineTransformMakeTranslation(-2*self.view.frame.width, 0)
                subtextLabel.alpha = 0
                
                subtextLabel2.transform = CGAffineTransformMakeTranslation(-self.view.frame.width, 0)
                subtextLabel2.alpha = 1
                
                }, completion: { (completion) -> Void in
                    subtextLabel.removeFromSuperview()
                    yellowArrow.removeTarget(self, action: "fifthScreenTransition", forControlEvents: UIControlEvents.TouchUpInside)
                    self.currentObjectsOnScreen = [yellowArrow,subtextLabel2]
                    yellowArrow.addTarget(self, action: "sixthScreenTransition", forControlEvents: UIControlEvents.TouchUpInside)
            })
            

        }
    }
    
    func sixthScreenTransition()
    {
        if let yellowArrow = currentObjectsOnScreen[0] as? UIButton, let subtextLabel = currentObjectsOnScreen[1] as? UILabel
        {
//            yellowArrow.addTarget(self, action: "fifthScreenTransition", forControlEvents: .TouchUpInside)
            let subtextLabel2 = UILabel(frame: CGRectMake(view.frame.width, 56, view.frame.width, 108))
            subtextLabel2.text = "Meet someone you can \n play badminton with"
            subtextLabel2.opaque = false
            subtextLabel2.font = UIFont(name: "Lato-light", size: 28)
            subtextLabel2.alpha = 0
            subtextLabel2.textColor = UIColor.whiteColor()
            subtextLabel2.numberOfLines = 2
            subtextLabel2.textAlignment = .Center
            view.addSubview(subtextLabel2)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                subtextLabel.transform = CGAffineTransformMakeTranslation(-2*self.view.frame.width, 0)
                subtextLabel.alpha = 0
                
                subtextLabel2.transform = CGAffineTransformMakeTranslation(-self.view.frame.width, 0)
                subtextLabel2.alpha = 1
                
                }, completion: { (completion) -> Void in
                    subtextLabel.removeFromSuperview()
                    yellowArrow.removeTarget(self, action: "fifthScreenTransition", forControlEvents: UIControlEvents.TouchUpInside)
                    self.currentObjectsOnScreen = [yellowArrow,subtextLabel2]
//                    yellowArrow.addTarget(self, action: "fifthScreenTransition", forControlEvents: UIControlEvents.TouchUpInside)
            })
            
            
        }

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
