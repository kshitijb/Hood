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
        static let portNumber = "80"
        static let channels = "channel"
        static let posts = "post"
        static let all = "all"
    }
    private var fullUrl:String{
        return Static.apiProtocol + Static.baseURL + ":" + Static.portNumber
    }
    
    private var allChannels:String{
        return fullUrl + "/" + Static.channels + "/" + Static.all + "/"
    }
    
    private var allPosts:String{
        return fullUrl + "/" + Static.posts + "/" + Static.all + "/"
    }
    
    func getFullUrl() -> String{
        return fullUrl
    }
    
    func getAllChannels() -> String{
        return allChannels
    }

    func getAllPosts() -> String{
        return allPosts
    }
//    let fullUrl = Static.apiProtocol + Static.baseURL + ":" + Static.portNumber
//    let allChannels = fullURLRef + "/"
    
}