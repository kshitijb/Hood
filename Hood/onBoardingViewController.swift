//
//  onBoardingViewController.swift
//  Hood
//
//  Created by Robin Malhotra on 13/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit

class onBoardingViewController: UIViewController,UIScrollViewDelegate {
    let pages = 0...3
    var pageViews :[UIView] = []
    let pageControl = UIPageControl()

    @IBOutlet weak var scrollView: UIScrollView!
    let pageColors = [PipalGlobalColor,PipalGlobalPink, PipalGlobalPurple, PipalGlobalYellow]
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSizeMake(view.frame.width*4, 0)
//        pageControl.frame = CGRectMake(0, 0, 400, 100)

        scrollView.delegate = self
        
        for index in pages
        {
            let xOffset = CGFloat(index)*view.frame.width
            let page = UIView(frame: CGRectMake(xOffset, 0, view.frame.width, view.frame.height))
            var channelTitle = UILabel(frame: CGRectMake(xOffset, 35, view.frame.width, 37))
            channelTitle.center = CGPointMake(view.center.x, channelTitle.center.y)
            var channelDesc = UILabel(frame: CGRectMake(0, 85,  view.frame.width, 54))
            channelDesc.numberOfLines = 2
            channelTitle.center = CGPointMake(view.center.x, channelDesc.center.y)
            let clearView = UIView()
            page.addSubview(clearView)
//            clearView.backgroundColor = UIColor.redColor()
            
            channelTitle.font = UIFont(name: "Lato-Regular", size: 31)
            channelDesc.font = UIFont(name: "Lato-Regular", size: 18)
            channelDesc.alpha = 0.6
            channelTitle.textColor = UIColor.whiteColor()
            channelTitle.textAlignment = NSTextAlignment.Center
            channelDesc.textAlignment = NSTextAlignment.Center
            channelDesc.textColor = UIColor.whiteColor()
            let iPhoneImage = UIImageView(image: UIImage(named: "iPhone"))
            iPhoneImage.frame = CGRectMake(0,100,100,100)
            var channelImageScrollView = UIScrollView(frame: CGRectMake(0,0,100,100))
            channelTitle.setTranslatesAutoresizingMaskIntoConstraints(false)
            channelDesc.setTranslatesAutoresizingMaskIntoConstraints(false)
            iPhoneImage.setTranslatesAutoresizingMaskIntoConstraints(false)
            channelImageScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
            clearView.setTranslatesAutoresizingMaskIntoConstraints(false)
            page.addSubview(channelTitle)
            page.addSubview(channelDesc)
            page.addSubview(iPhoneImage)
            iPhoneImage.addSubview(channelImageScrollView)
            let channelImage = UIImageView()

            let views = Dictionary(dictionaryLiteral: ("channelTitle",channelTitle),("channelDesc",channelDesc),("channelImageScrollView",channelImageScrollView),("iPhoneImage",iPhoneImage),("pageControl",pageControl),("channelImage",channelImage),("clearView",clearView))
            page.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[channelTitle]|", options: nil, metrics: nil, views: views))
            page.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[channelDesc]|", options: nil, metrics: nil, views: views))
            page.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[clearView]|", options: nil, metrics: nil, views: views))
            page.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(30)-[channelTitle]-(15)-[channelDesc]-(25)-[clearView(>=9)]-(25)-[iPhoneImage]|", options: nil, metrics: nil, views: views))
            page.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[iPhoneImage]-20-|", options: nil, metrics: nil, views: views))
            page.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(22)-[channelImageScrollView]-(22)-|", options: nil, metrics: nil, views: views))
            page.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(80)-[channelImageScrollView]|", options: nil, metrics: nil, views: views))
            scrollView.addSubview(page)
            switch index
            {
            case 0:
                channelTitle.text = "#home"
                channelDesc.text = "Chat with your neighbours. \n Post news and get important alerts"
                page.backgroundColor = GlobalColors.Green
            case 1:
                channelTitle.text = "#buy/sell"
                channelDesc.text = "Buy and Sell to people you trust. \n Hassle free local classifieds"
                page.backgroundColor = GlobalColors.Pink
            case 2:
                channelTitle.text = "help"
                channelDesc.text = "Ask for help and share resources. \n We’re all in this together."
                page.backgroundColor = GlobalColors.Purple
            case 3:
                channelTitle.text = "#meetups"
                channelDesc.text = "Buy and Sell to people you trust. \n Hassle free local classifieds"
                page.backgroundColor = GlobalColors.Yellow
            default:
                print("sdaklfjnsal")
            }
            view.layoutIfNeeded()

            if index == 0
            {
                print(clearView.frame)
                pageControl.frame = clearView.frame
            }
            pageViews.append(page)
        }
        pageViews[0].backgroundColor = PipalGlobalColor
        self.view.bringSubviewToFront(pageControl)
        view.addSubview(pageControl)
        pageControl.numberOfPages = 4
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped")
        view.addGestureRecognizer(tapGesture)
//        pageControl.frame = CGRectMake(0.0, 55.0, view.frame.width, 54.0)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x/view.frame.width)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func viewTapped(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        
        let index = Int(scrollView.contentOffset.x / view.frame.width)
        pageViews[0].backgroundColor = UIColor.clearColor()
        let perc = (scrollView.contentOffset.x - CGFloat(index) * view.frame.width)/view.frame.width
        if (scrollView.contentOffset.x > 0.0) && (scrollView.contentOffset.x < CGFloat(pages.endIndex)*view.frame.width) && index < pageColors.count - 1
        {
                view.backgroundColor = Utilities.colorBetweenColors(pageColors[index], lastColor: pageColors[index+1], offsetAsFraction: perc)
        }
    }
    
}
