//
//  Constants.swift
//  Hood
//
//  Created by Abheyraj Singh on 06/08/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation

struct API {
    struct Static {
        static let apiProtocol = "http://"
        static let baseURL = "128.199.179.151"
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
        static let currentNeighbourhoodID = "3"
     }
    private var fullUrl:String{
        return Static.apiProtocol + Static.baseURL + ":" + Static.portNumber
    }
    
    private var allChannels:String{
        return "/".join([fullUrl, Static.channels, Static.all])
    }
    
    private var allPosts:String{
        return "/".join([fullUrl, Static.posts, Static.all])
    }
    
    func getFullUrl() -> String{
        return fullUrl
    }
    
    func getAllChannels() -> String{
        return allChannels
    }

    func getAllChannelsForNeighbourhood() -> String{
        return "/".join([fullUrl,Static.neighbourhoods,Static.all,Static.currentNeighbourhoodID])
    }
    
    func getAllPosts() -> String{
        return allPosts
    }
    
    func getAllPostsForChannel(channel: String) -> String{
        return "/".join([fullUrl,Static.posts,Static.filter,Static.currentNeighbourhoodID,channel])
    }
    
    func upvotePost()->String{
        return "/".join([fullUrl,Static.upvote,Static.add])
    }
    func downvotePost()->String{
        return "/".join([fullUrl,Static.upvote,Static.delete])
    }
    
    func addPost() -> String
    {
        return "/".join([fullUrl,Static.posts,Static.add])
    }
    
    func addComment() -> String
    {
        return "/".join([fullUrl,Static.comment,Static.add])
    }
    
    func getCommentsForPost(postID:String) -> String
    {
        return "/".join([fullUrl,Static.posts,Static.comments,postID])
    }
    
    func getNotificationsForUser() -> String
    {
        return "/".join([fullUrl, Static.notifications,Static.show])
    }
}