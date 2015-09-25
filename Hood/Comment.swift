//
//  Comment.swift
//  Hood
//
//  Created by Abheyraj Singh on 25/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
class Comment: ParentObject {

    @NSManaged var timestamp: NSDate
    @NSManaged var comment: String
    @NSManaged var post: Post
    @NSManaged var author: User

    static func generateObjectFromJSON(json: JSON, context: NSManagedObjectContext) -> Comment{
        
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Comment")
        fetchRequest.fetchLimit = 1
        let id = NSNumber(longLong: json["id"].int64!)
        fetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [id])
        var entity:ParentObject
//        if(context.countForFetchRequest(fetchRequest, error: &error) > 0){
//            entity = context.executeFetchRequest(fetchRequest).last as! ParentObject
//        }
//        else{
//            entity = NSEntityDescription.insertNewObjectForEntityForName("Comment", inManagedObjectContext: context) as! ParentObject
//        }
        
        do
        {
            let results = try context.executeFetchRequest(fetchRequest)
            if(results.count > 0){
                entity = results.last as! ParentObject
            }else{
                entity = NSEntityDescription.insertNewObjectForEntityForName("Comment", inManagedObjectContext: context) as! ParentObject
            }
        }
        catch
        {
            entity = NSEntityDescription.insertNewObjectForEntityForName("Comment", inManagedObjectContext: context) as! ParentObject
        }
        
        if let id = json["id"].int64{
            entity.id = NSNumber(longLong: id)
        }
        
        let comment:Comment = entity as! Comment
        
        if let commentString = json["comment"].string{
            comment.comment = commentString
        }
        if let timestamp = json["timestamp"].string{
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            comment.timestamp = dateFormatter.dateFromString(timestamp)!
        }
        
        comment.author = User.generateObjectFromJSON(json["author"], context: context)
        return comment
    }
    
    
}
