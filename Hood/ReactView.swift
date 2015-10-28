//
//  ReactView.swift
//  Pipal
//
//  Created by Robin Malhotra on 13/10/15.
//  Copyright © 2015 Housing Labs. All rights reserved.
//

import UIKit
import React
class ReactView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    let jsCodeLocation = NSURL(string: "http://localhost:8081/ReactComponent/index.ios.bundle?platform=ios&dev=true")
    // For production use, this `NSURL` could instead point to a pre-bundled file on disk:
    //
    //   NSURL *jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
    //
    // To generate that file, run the curl command and add the output to your main Xcode build target:
    //
    //   curl http://localhost:8081/index.ios.bundle -o main.jsbundle

   
    
    func initialise()
    {
         let rootView = RCTRootView(bundleURL:jsCodeLocation, moduleName: "SimpleApp", initialProperties: nil, launchOptions: nil)
        self.addSubview(rootView)
        rootView.frame = self.bounds
    }
}
