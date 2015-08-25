//
//  Comment.swift
//  Hood
//
//  Created by Abheyraj Singh on 25/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation
import CoreData

class Comment: ParentObject {

    @NSManaged var timestamp: String
    @NSManaged var comment: String
    @NSManaged var post: Post
    @NSManaged var author: User

}
