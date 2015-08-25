//
//  Post.swift
//  Hood
//
//  Created by Abheyraj Singh on 25/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import CoreData

class Post: ParentObject {

    @NSManaged var message: String
    @NSManaged var comments_count: NSNumber
    @NSManaged var upvotes_count: NSNumber
    @NSManaged var timestamp: String
    @NSManaged var photo: String
    @NSManaged var video: String
    @NSManaged var is_upvoted: NSNumber
    @NSManaged var channel: Channel
    @NSManaged var author: User
    @NSManaged var comments: NSSet

}
