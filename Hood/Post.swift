//
//  Post.swift
//  Hood
//
//  Created by Abheyraj Singh on 25/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Post: ParentObject {

    @NSManaged var message: String
    @NSManaged var comments_count: NSNumber
    @NSManaged var upvotes_count: NSNumber
    @NSManaged var timestamp: NSDate?
    @NSManaged var photo: String?
    @NSManaged var video: String?
    @NSManaged var is_upvoted: NSNumber
    @NSManaged var channel: Channel
    @NSManaged var author: User
    @NSManaged var comments: NSSet

    static func generateObjectFromJSON(json: JSON, context: NSManagedObjectContext) -> Post{
        
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Post")
        fetchRequest.fetchLimit = 1
        let id = NSNumber(longLong: json["id"].int64!)
        fetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [id])
        var error: NSError?
        var entity:ParentObject
        if(context.countForFetchRequest(fetchRequest, error: &error) > 0){
            entity = context.executeFetchRequest(fetchRequest, error: &error)!.last as! ParentObject
        }
        else{
            entity = NSEntityDescription.insertNewObjectForEntityForName("Post", inManagedObjectContext: context) as! ParentObject
        }
        
        if let id = json["id"].int64{
            entity.id = NSNumber(longLong: id)
        }

        
        let post:Post = entity as! Post
        if let message = json["message"].string{
            post.message = message
        }
        if let comments_count = json["comments_count"].int64{
            post.comments_count = NSNumber(longLong: comments_count)
        }
        if let upvotes_count = json["upvotes_count"].int64{
            post.upvotes_count = NSNumber(longLong: upvotes_count)
        }
        if let timestamp = json["timestamp"].string{
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            post.timestamp = dateFormatter.dateFromString(timestamp)
        }
        
        if let photo = json["photo"].string{
            post.photo = photo
        }
        
        if let video = json["video"].string{
            post.video = video
        }
        
        post.author = User.generateObjectFromJSON(json["author"], context: context)
        
        return post
    }

    
}
