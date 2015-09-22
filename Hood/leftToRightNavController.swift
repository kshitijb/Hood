//
//  leftToRightNavController.swift
//  Pipal
//
//  Created by Robin Malhotra on 17/09/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit

class leftToRightNavController: NSObject, UIViewControllerAnimatedTransitioning
{
    var isDismissing:Bool = true
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let finalFrameForVC = transitionContext.finalFrameForViewController(toViewController)
        let containerView = transitionContext.containerView()
        let bounds = UIScreen.mainScreen().bounds
        if(isDismissing == true)
        {
            toViewController.view.frame = CGRectOffset(finalFrameForVC, bounds.size.width, 0)
        }
        else
        {
            toViewController.view.frame = CGRectOffset(finalFrameForVC, -bounds.size.width, 0)
        }
            containerView!.addSubview(toViewController.view)
//        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
//            fromViewController.view.alpha = 0.5
//            toViewController.view.frame = finalFrameForVC
//            }, completion: {
//                finished in
//                transitionContext.completeTransition(true)
//                fromViewController.view.alpha = 1.0
//        })
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
            if(self.isDismissing==true)
            {
                fromViewController.view.frame = CGRectMake(-bounds.width, 0, bounds.width, bounds.height)
            }
            else
            {
                fromViewController.view.frame = CGRectMake(bounds.width, 0, bounds.width, bounds.height)
            }
            toViewController.view.frame = bounds
        }) { (finished) -> Void in
            transitionContext.completeTransition(true)
        }
    }
    
}
