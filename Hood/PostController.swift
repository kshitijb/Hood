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
    static func VotePost(type: Vote, sender: AnyObject, post: Post, success: (() -> Void)?, failure: (() -> Void)?) -> Void{
        let params = ["post_id" : post.id.integerValue]
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        var APIString:String
        switch type{
        case .Downvote: APIString = API().downvotePost()
        case .Upvote: APIString = API().upvotePost()
        }
        
        Alamofire.request(.POST, APIString, parameters: params,encoding: .JSON,headers:headers)
            .response { request, response, data, error in
                print(request)
                print(response)
                print(error)
                if error != nil
                {
                    if let failureBlock = failure{
                        failureBlock()
                    }
//                    let alert = UIAlertView(title: "Error", message: "Sorry,your message wasn't sent", delegate: self, cancelButtonTitle: "okay")
//                    alert.show()
                }
                else
                {
                    Utilities.appDelegate.saveContext()
                    if let successBlock = success{
                        successBlock()
                    }

                }
        }
    
    }
    
    
    
}
