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
import Alamofire
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
//        if(context.countForFetchRequest(fetchRequest, error: &error) > 0)
//        {
//            do
//            {
//                entity = try context.executeFetchRequest(fetchRequest).last as! ParentObject
//            }
//            catch
//            {
//                //Honestly, if we're here, we're fucked anyway.
//            }
//        }
//        else{
//            entity = NSEntityDescription.insertNewObjectForEntityForName("Post", inManagedObjectContext: context) as! ParentObject
//        }

        do
        {
            let results = try context.executeFetchRequest(fetchRequest)
            if(results.count > 0){
                entity = results.last as! ParentObject
            }else{
                entity = NSEntityDescription.insertNewObjectForEntityForName("Post", inManagedObjectContext: context) as! ParentObject
            }
        }
        catch
        {
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
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            post.timestamp = dateFormatter.dateFromString(timestamp)
        }
        
        if let is_upvoted = json["is_upvoted"].bool{
            post.is_upvoted = is_upvoted
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
    
    
    
    static func getPosts(channel: Channel, pageSize: Int, page: Int, completion: ((responseData: AnyObject?, error: ErrorType?) -> Void)?){
        let url = API().getAllPostsForChannel("\(channel.id.intValue)")
        let headers = ["Authorization":"Bearer \(AppDelegate.owner!.uuid)"]
        let parameters = ["page":page, "page_size": pageSize]
        
        Alamofire.request(.GET, url, parameters: parameters,encoding: .URL,headers:headers).responseData { (request, response, result) -> Void in
            if let completion = completion{
                completion(responseData: result.value, error: result.error);
            }
            
            if(result.isSuccess){
                let responseJSON = JSON(data: result.value!, options: NSJSONReadingOptions.AllowFragments, error: nil)
//                print(String(data: data!, encoding: NSUTF8StringEncoding))
                let dataArray = NSMutableArray()
                let fetchRequest = NSFetchRequest(entityName: "Post")
                fetchRequest.predicate = NSPredicate(format: "channel == %@", argumentArray: [channel])
                fetchRequest.fetchBatchSize = pageSize
                fetchRequest.fetchOffset = pageSize * page
                let appDelegate = Utilities.appDelegate
                for (_, post) in responseJSON["results"]{
                    let postObject = Post.generateObjectFromJSON(post, context: appDelegate.managedObjectContext!)
                    postObject.channel = channel
                    dataArray.addObject(postObject)
                }
                do
                {
                    let results = try appDelegate.managedObjectContext?.executeFetchRequest(fetchRequest)
                    if(results?.count > 0){
                        let objectsToDelete = NSMutableSet(array: results!)
                        objectsToDelete.minusSet(NSSet(array: dataArray as [AnyObject]) as Set<NSObject>)
                        let objectsToDeleteArray = objectsToDelete.allObjects
                        if objectsToDeleteArray.count > 0{
                            for index in 0...objectsToDeleteArray.count-1{
                                appDelegate.managedObjectContext?.deleteObject(objectsToDeleteArray[index] as! NSManagedObject)
                            }
                        }
                    }
                    appDelegate.saveContext()
                }
                catch
                {
                    
                }

            }
            
        }
        
    }
    
    
    

    
}
