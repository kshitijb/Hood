//
//  ParentObject.swift
//  Hood
//
//  Created by Abheyraj Singh on 25/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class ParentObject: NSManagedObject {

    @NSManaged var id: NSNumber
    
    static func createOrUpateObjectFromJSON(json: JSON, context: NSManagedObjectContext, entityName: String) -> NSManagedObject{
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.fetchLimit = 1
        let id = NSNumber(longLong: json["id"].int64!)
        fetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [id])
        var entity:NSManagedObject
//        if(context.countForFetchRequest(fetchRequest, error: &error) > 0){
//            entity = context.executeFetchRequest(fetchRequest, error: &error)!.last as! NSManagedObject
//        }
//        else{
//            entity = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as! NSManagedObject
//        }
        do
        {
            let results = try context.executeFetchRequest(fetchRequest)
            if(results.count > 0){
                entity = results.last as! NSManagedObject
            }else{
                entity = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
            }
        }
        catch _ as NSError
        {
            entity = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
        }
        
        return entity
    }
    
}
