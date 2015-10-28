//
//  nativeOnBoardingViewController.swift
//  Pipal
//
//  Created by Robin Malhotra on 14/10/15.
//  Copyright © 2015 Housing Labs. All rights reserved.
//

import UIKit

class NativeOnBoardingViewController: UIViewController
{
    var currentObjectsOnScreen:[AnyObject] = []

    var BURROW_WIDTH = CGFloat(743/2)
    var BURROW_HEIGHT = CGFloat(331.5)
    var BURROW_BUILDING_WIDTH = CGFloat(136)
    var LEFT_BUILDING_OFFSET = CGFloat(124)
    var scale = CGFloat(1)

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = GlobalColors.Green
        scale = self.view.frame.width/BURROW_WIDTH
        BURROW_HEIGHT = BURROW_HEIGHT * scale
        BURROW_WIDTH = BURROW_WIDTH * scale
        BURROW_BUILDING_WIDTH = BURROW_BUILDING_WIDTH * scale
        LEFT_BUILDING_OFFSET = LEFT_BUILDING_OFFSET * scale
        firstScreen()

        // Do any additional setup after loading the view.
    }
    
    func firstScreen()
    {
        
        let titleLabel = UILabel(frame: CGRectMake( 0, 0.12 * view.frame.height, view.frame.width, 50))
        titleLabel.font = UIFont(name: "Lato-Black", size: 42)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Pipal"
        titleLabel.textAlignment = .Center
        titleLabel.opaque = false
        view.addSubview(titleLabel)
        
        let subtextLabel = UILabel(frame: CGRectMake(-view.frame.width, CGRectGetMaxY(titleLabel.frame) + 28, view.frame.width, 72))
        subtextLabel.text = "Your neighborhood \n gathers here"
        subtextLabel.numberOfLines = 0
        subtextLabel.textAlignment = .Center
        subtextLabel.alpha = 0
        subtextLabel.opaque = false
        subtextLabel.font = UIFont(name: "Lato-light", size: 28)
        subtextLabel.textColor = UIColor.whiteColor()
        view.addSubview(subtextLabel)
        
        let yellowArrow = UIButton()
        yellowArrow.setBackgroundImage(UIImage(named: "yellowArrow"), forState: UIControlState.Normal)
        yellowArrow.frame = CGRectMake(CGRectGetMidX(view.frame) - 22.5, CGRectGetMaxY(subtextLabel.frame) + 28, 45, 45)
        yellowArrow.addTarget(self, action: "secondScreenTransition", forControlEvents: .TouchUpInside)
        view.addSubview(yellowArrow)
        
        
        let burrowImageView = UIImageView(image: UIImage(named: "burrow"))
        burrowImageView.frame = CGRectMake(0, CGRectGetMaxY(yellowArrow.frame) + 32 , view.frame.width, BURROW_HEIGHT)
        burrowImageView.opaque = false
        view.addSubview(burrowImageView)
        for i in 0...2
        {
            for j in 0...7
            {
                print(i*8+j)
                let personView = UIImageView(image: UIImage(named: "Oval"))
                personView.frame = CGRectMake( 138.5*scale + 85/2*scale*CGFloat(i), CGRectGetMinY(burrowImageView.frame) + 15*scale + CGFloat(j) * 58/2 * scale , 41/2, 41/2)
                personView.opaque = false
                view.addSubview(personView)
                currentObjectsOnScreen.append(personView)
                
            }
        }


        
        UIView.animateWithDuration(0.3) { () -> Void in
            subtextLabel.alpha = 1
            subtextLabel.transform = CGAffineTransformMakeTranslation(self.view.frame.width, 0)
        }
        currentObjectsOnScreen = [burrowImageView,yellowArrow,subtextLabel,titleLabel] + currentObjectsOnScreen
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func secondScreenTransition()
    {
        if let burrowImageView = currentObjectsOnScreen[0] as? UIImageView, yellowArrow = currentObjectsOnScreen[1] as? UIButton, subtextLabel = currentObjectsOnScreen[2] as? UILabel, titleLabel = currentObjectsOnScreen[3] as? UILabel
        {
            let windows = Array(currentObjectsOnScreen[4...currentObjectsOnScreen.count - 1]) as! [UIImageView]
            let oneThird = view.frame.width/3
            


            UIView.animateWithDuration(0.3, animations:
            { () -> Void in
                titleLabel.alpha = 0
                yellowArrow.alpha = 0
                burrowImageView.frame.origin.y = burrowImageView.frame.origin.y + 100
                for window in windows
                {
                    window.frame.origin.y = window.frame.origin.y + 100
                }
                subtextLabel.alpha = 0
                subtextLabel.transform = CGAffineTransformMakeTranslation(-self.view.frame.width, 0)
            })
            
            UIView.animateWithDuration(0.73, animations: { () -> Void in
                burrowImageView.frame.origin.y = 204


            })
            
            UIView.animateWithDuration(0.94, animations: { () -> Void in
                let scale = self.view.frame.width/self.BURROW_BUILDING_WIDTH
                burrowImageView.frame.size = CGSizeMake(self.view.frame.width*scale, self.BURROW_HEIGHT*scale)
                burrowImageView.frame.origin.x = -self.LEFT_BUILDING_OFFSET * self.view.frame.width/self.BURROW_BUILDING_WIDTH
                for i in 0...2
                {
                    for j in 0...7
                    {
                        windows[i*8+j].frame = CGRectMake(30 + 123 * CGFloat(i), 207 + 45 + CGFloat(j) * 82 , 60, 60)
                        windows[i*8+j].center.x = CGFloat(CGFloat(i)+CGFloat(0.5))*oneThird
                    }
                }
                subtextLabel.alpha = 0
                subtextLabel.frame.origin.x = -143
            }, completion: { (completed) -> Void in
                    yellowArrow.removeFromSuperview()
                    titleLabel.removeFromSuperview()
                    subtextLabel.removeFromSuperview()
                    self.currentObjectsOnScreen = [burrowImageView] + windows
                    self.secondScreenRender()
                
            })
        }
        
    }
    
    func secondScreenRender()
    {
        let subtext2 = UILabel(frame: CGRectMake(0, 56, view.frame.width, 108))
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
        let windows = Array(currentObjectsOnScreen[1...currentObjectsOnScreen.count-1])
        let delay = 1.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            for win in windows
            {
                win.removeFromSuperview()
            }
        }
        
        let numberInWords = ["one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen"]
        
        let oneThird = view.frame.width/3
        currentObjectsOnScreen = [currentObjectsOnScreen[0]]+[yellowArrow,subtext2]
        
        for (counter,shuffledIndex) in [7, 5, 0, 14, 1, 10, 15, 2, 11, 9, 3, 4, 12, 8, 13, 6].enumerate()
        {
            let i = shuffledIndex/5
            let j = shuffledIndex%5
            if(j + i*5 < 15)
            {
                let personView = UIImageView(image: UIImage(named: numberInWords[j+i*5]))
                print((i,j))
                personView.frame = CGRectMake(30 + 123 * CGFloat(i), CGRectGetMaxY(yellowArrow.frame) + 20 + CGFloat(j) * 82 , 60, 60)
                personView.transform = CGAffineTransformMakeScale(0, 0)
                
                UIView.animateWithDuration(NSTimeInterval(0.3), delay: NSTimeInterval(0.04*Double(counter)), options: [], animations: { () -> Void in
                        personView.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: { (completion) -> Void in
                        
                })
                
                
                personView.center.x = CGFloat(CGFloat(i)+CGFloat(0.5))*oneThird
                personView.opaque = false
                view.addSubview(personView)
                
                currentObjectsOnScreen.append(personView)
                
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
                subtextLabel.transform = CGAffineTransformMakeTranslation(-2*self.view.frame.width, 0)
                subtextLabel2.transform = CGAffineTransformMakeTranslation(-self.view.frame.width, 0)
                subtextLabel2.alpha = 1
                burrowImageView.alpha = 0
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
                let personObjects = self.currentObjectsOnScreen[3...self.currentObjectsOnScreen.count-1]

                self.currentObjectsOnScreen = [yellowArrow,subtextLabel2] + fourRandomConversationalists
                yellowArrow.removeTarget(self, action: Selector("thirdScreenTransition"), forControlEvents: .TouchUpInside)
                
                self.thirdScreenRender()
            })
        }
    }
    
    
    func thirdScreenRender()
    {
        
        if let yellowArrow = currentObjectsOnScreen[0] as? UIButton,subtextLabel = currentObjectsOnScreen[1] as? UILabel
        {
            yellowArrow.addTarget(self, action: Selector("fourthScreenTransition"), forControlEvents: .TouchUpInside)
            let fourRandomConversationalists = Array(currentObjectsOnScreen[2...currentObjectsOnScreen.count-1])
            let heightsOfConversations = [65,30,49,30]
            let widthsOfConversations = [240, 263, 214,50]
            
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
            print(subtextLabel.text)
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
                    yellowArrow.addTarget(self, action: "dismissOnboarding", forControlEvents: UIControlEvents.TouchUpInside)
            })
            
            
        }
    }
    
    func dismissOnboarding()
    {
        self.performSegueWithIdentifier("dismissOnboarding", sender: self)
    }    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
