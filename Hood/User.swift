//
//  User.swift
//  Hood
//
//  Created by Abheyraj Singh on 25/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class User: ParentObject {

    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var profile_photo: String?
    @NSManaged var email: String
    @NSManaged var registration_time: String
    @NSManaged var access_token: String
    @NSManaged var fb_id: String
    @NSManaged var is_owner: NSNumber
    @NSManaged var neighbourhood: Neighbourhood
    @NSManaged var posts: NSSet
    @NSManaged var uuid: String

    static func generateObjectFromJSON(json: JSON, context: NSManagedObjectContext) -> User{
        
        let user:User = ParentObject.createOrUpateObjectFromJSON(json, context: context, entityName: "User") as! User
        
        if let id = json["id"].int64{
            user.id = NSNumber(longLong: id)
        }
        
        if let firstname = json["firstname"].string{
            user.firstname = firstname
        }
        if let lastname = json["lastname"].string{
            user.lastname = lastname
        }
        if let profile_photo = json["profile_photo"].string{
            user.profile_photo = profile_photo
        }
        if let email = json["email"].string{
            user.email = email
        }
        if let fb_id = json["fb_id"].string{
            user.fb_id = fb_id
        }
        if let uuid = json["uuid"].string{
            user.uuid = uuid
        }
        return user
    }
    
}
