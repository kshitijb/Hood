//
//  Channel.swift
//  Hood
//
//  Created by Abheyraj Singh on 25/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Channel: ParentObject {

    @NSManaged var color: String?
    @NSManaged var name: String
    @NSManaged var info: String
    @NSManaged var posts: NSSet

    static func generateObjectFromJSON(json: JSON, context: NSManagedObjectContext) -> Channel{
        
        let channel:Channel = ParentObject.createOrUpateObjectFromJSON(json, context: context, entityName: "Channel") as! Channel
        
        if let id = json["id"].int64{
            channel.id = NSNumber(longLong: id)
        }
        
        if let name = json["name"].string{
            channel.name = name
        }
        if let color = json["color"].string{
            channel.color = color
        }
        if let info = json["purpose"].string{
            channel.info = info
        }
        return channel
    }
    
}
