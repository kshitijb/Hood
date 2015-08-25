//
//  Neighbourhood.swift
//  Hood
//
//  Created by Abheyraj Singh on 25/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Neighbourhood: ParentObject {

    @NSManaged var name: String
    @NSManaged var google_id: String
    @NSManaged var channels: NSSet
    static func generateObjectFromJSON(json: JSON, context: NSManagedObjectContext) -> Neighbourhood{
        let entity = NSEntityDescription.entityForName("Neighbourhood", inManagedObjectContext: context)
        let neighbourhood:Neighbourhood = Neighbourhood(entity: entity!, insertIntoManagedObjectContext: context)
        if let id = json["id"].int64{
            neighbourhood.id = NSNumber(longLong: id)
        }
        if let name = json["name"].string{
            neighbourhood.name = name
        }
        return neighbourhood
    }
}
