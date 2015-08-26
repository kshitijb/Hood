//
//  PostController.swift
//  Hood
//
//  Created by Abheyraj Singh on 14/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

enum Vote: Int{
    case Upvote
    case Downvote
}

class PostController {
    static func VotePost(type: Vote, sender: AnyObject, post: JSON, success: (() -> Void)?, failure: (() -> Void)?) -> Void{
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("id") as? Int
        let params = ["post_id" : post["id"].int!, "user_id": userID!]
        
        var APIString:String
        switch type{
        case .Downvote: APIString = API().downvotePost()
        case .Upvote: APIString = API().upvotePost()
        }
        
        Alamofire.request(.POST, APIString, parameters: params, encoding: .JSON).response({ (request, response, data, error) -> Void in
            print(error)
            if (error != nil)
            {
                if let failureBlock = failure{
                    failureBlock()
                }
                let alert = UIAlertView(title: "no Interwebs", message: "Sorry,your message wasn't sent", delegate: self, cancelButtonTitle: "okay")
                alert.show()
            }else{
                if let successBlock = success{
                    successBlock()
                }
            }
            
        })
    }
    
    
    
}
