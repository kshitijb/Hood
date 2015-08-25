//
//  User.swift
//  Hood
//
//  Created by Abheyraj Singh on 25/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var firstname: String
    @NSManaged var lastname: String
    @NSManaged var profile_photo: String
    @NSManaged var email: String
    @NSManaged var registration_time: String
    @NSManaged var access_token: String
    @NSManaged var fb_id: String
    @NSManaged var is_owner: NSNumber
    @NSManaged var neighbourhood: NSManagedObject
    @NSManaged var posts: NSSet

}
