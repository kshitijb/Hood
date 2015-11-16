//
//  Constants.swift
//  Hood
//
//  Created by Abheyraj Singh on 06/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation

let APIPageSize = 20
let botChannelId = 14

struct API {
    struct Static {
        static let apiProtocol = "http://"
        static let baseURL = "188.166.254.150"
//        static let baseURL = "169.254.223.134"
        static let portNumber = "80"
        static let channels = "channel"
        static let posts = "post"
        static let all = "all"
        static let filter = "filter"
        static let upvote = "upvote"
        static let add = "add"
        static let delete = "delete"
        static let comment = "comment"
        static let comments = "comments"
        static let notifications = "alert"
        static let show = "show"
        static let neighbourhoods = "neighbourhood"
        static var currentNeighbourhoodID = "1"
        static let register = "register"
        static let user = "user"
        static let update = "update"
        static let locality = "locality"
        static let device = "device"
        static let clear = "clear"
        static let members = "members"
    }
    
    private var fullUrl:String{
        return Static.apiProtocol + Static.baseURL + ":" + Static.portNumber
    }
    
    private var allChannels:String{
        return ([fullUrl, Static.channels, Static.all]).joinWithSeparator("/")
        
    }
    
    private var allPosts:String{
        return ([fullUrl, Static.posts, Static.all]).joinWithSeparator("/")
    }
    
    func getFullUrl() -> String{
        return fullUrl
    }
    
    func getAllChannels() -> String{
        return allChannels
    }

    func getAllChannelsForNeighbourhood(neighbourhood:String) -> String{
        return ([fullUrl,Static.neighbourhoods,Static.all,neighbourhood]).joinWithSeparator("/")
    }
    
    func getAllPosts() -> String{
        return allPosts
    }
    
    func getAllPostsForChannel(channel: String, neighbourhood: String) -> String{
        return ([fullUrl,Static.posts,Static.filter,neighbourhood,channel]).joinWithSeparator("/")
    }
    
    func getPostWithID(postID:String)->String
    {
        return ([fullUrl,Static.posts,Static.all,postID]).joinWithSeparator("/")
    }
    
    func upvotePost()->String{
        return ([fullUrl,Static.upvote,Static.add]).joinWithSeparator("/")
    }
    func downvotePost()->String{
        return ([fullUrl,Static.upvote,Static.delete]).joinWithSeparator("/")
    }
    
    func addPost() -> String
    {
        return ([fullUrl,Static.posts,Static.add]).joinWithSeparator("/")
    }
    
    func addComment() -> String
    {
        return ([fullUrl,Static.comment,Static.add]).joinWithSeparator("/")
    }
    
    func getCommentsForPost(postID:String) -> String
    {
        return ([fullUrl,Static.posts,Static.comments,postID]).joinWithSeparator("/")
    }
    
    func getNotificationsForUser() -> String
    {
        return ([fullUrl, Static.notifications,Static.show]).joinWithSeparator("/")
    }
    
    func registerUser() -> String{
        return ([fullUrl, Static.user, Static.register]).joinWithSeparator("/")
    }
    
    func updateUserLocality() -> String{
        return ([fullUrl, Static.user, Static.update, Static.locality]).joinWithSeparator("/")
    }
    
    func registerDevice() -> String{
        return ([registerUser(), Static.device]).joinWithSeparator("/")
    }
    
    func clearAlerts() -> String{
        return ([fullUrl, Static.notifications, Static.clear]).joinWithSeparator("/")
    }
    
    func getAllMembers() -> String{
        return ([fullUrl, Static.neighbourhoods, Static.members].joinWithSeparator("/"))
    }
}