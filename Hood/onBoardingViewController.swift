//
//  onBoardingViewController.swift
//  Hood
//
//  Created by Robin Malhotra on 13/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit

class onBoardingViewController: UIViewController {
    let pages = 0...3
    var views :[UIView] = []
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSizeMake(view.frame.width*4, view.frame.height)
        
        for index in pages
        {
            let xOffset = CGFloat(index)*view.frame.width
            let page = UIView(frame: CGRectMake(xOffset, 0, view.frame.width, view.frame.height))
            var channelTitle = UILabel(frame: CGRectMake(xOffset, 35, view.frame.width, 37))
            channelTitle.center = CGPointMake(view.center.x, channelTitle.center.y)
            var channelDesc = UILabel(frame: CGRectMake(30, 85,  view.frame.width, 54))
            channelTitle.numberOfLines = 2
            channelTitle.center = CGPointMake(view.center.x, channelDesc.center.y)
            
            let iPhoneImage = UIImageView(image: UIImage(named: "iPhone"))
            iPhoneImage.frame = CGRectMake(0,0,0,0)
            var channelImageScrollView = UIScrollView(frame: CGRectMake(0,0,0,0))
            page.addSubview(channelTitle)
            page.addSubview(channelDesc)
            page.addSubview(iPhoneImage)
            page.addSubview(channelImageScrollView)
            scrollView.addSubview(page)
            switch index
            {
            case 1:
                channelTitle.text = "#home"
                channelDesc.text = "Chat with your neighbours. \\n Post news and get important alerts"
                page.backgroundColor = 
                
            
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
