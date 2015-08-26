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
        let neighbourhood:Neighbourhood = ParentObject.createOrUpateObjectFromJSON(json, context: context, entityName: "Neightbourhood") as! Neighbourhood
        if let name = json["name"].string{
            neighbourhood.name = name
        }
        return neighbourhood
    }
}
