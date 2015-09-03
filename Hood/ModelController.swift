//
//  ModelController.swift
//  Hood
//
//  Created by Abheyraj Singh on 30/07/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import SwiftyJSON
/*

 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageData:NSMutableArray = NSMutableArray()
    var pagesCache: NSMutableArray = NSMutableArray()
    var storyboard: UIStoryboard?
    
    override init() {
        super.init()
        // Create the data model.
//        pageData = NSArray(array: ["Home","News","Buy/Sell","SOS","Sharing"])
//                pageData = NSArray(array: ["Home"])
    }

    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> FeedViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }
        self.storyboard = storyboard
        // Create a new view controller and pass suitable data.
        if(self.pagesCache.count<=index){
            let dataViewController = storyboard.instantiateViewControllerWithIdentifier("FeedViewController") as! FeedViewController
            println(dataViewController.view.frame)
            dataViewController.dataObject = self.pageData[index]
            dataViewController.fetchData()
            self.pagesCache.addObject(dataViewController)
            return dataViewController
        }else{
            return self.pagesCache[index] as? FeedViewController
        }
    }

    func indexOfViewController(viewController: FeedViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        let dataObject: Channel = viewController.dataObject as! Channel
//            let dataArray  = pageData
//            return dataArray.indexOfObject(dataObject)
        for index in 0...self.pageData.count{
            let currentObject = self.pageData[index] as! Channel
            if currentObject.id == dataObject.id{
                return index
            }
        }
        
//            return dataArray.indexOfObject(dataJSON)
//        } else {
            return NSNotFound
//        }
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! FeedViewController)
        if (index == 0) {
//  TODO: Show notifications view controller from the side
//
//            if let viewController: UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NotificationsViewController") as? UIViewController{
//            return viewController
//            }else {
             return nil
//            }
        }else if(index == NSNotFound){
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! FeedViewController)
        if index == NSNotFound {
            return nil
        }
        
        index++
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

}

