//
//  Constants.swift
//  KickSearch
//
//  Created by Saruhan Kole on 28.06.2019.
//  Copyright © 2019 Peartree Developers. All rights reserved.
//

import Foundation

struct Constant {
    
    var backers: String
    var title: String
    var no: String
    var pledged: String
    var blurb: String
    var by: String
    var location: String
    var percentageFunded: String
    var state: String
    var type: String
    var url: String
    
    init(_ dictionary: [String: Any]) {
        self.backers = dictionary["num.backers"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.no = dictionary["s.no"] as? String ?? ""
        self.pledged = dictionary["amt.pledged"] as? String ?? ""
        self.blurb = dictionary["blurb"] as? String ?? ""
        self.by = dictionary["by"] as? String ?? ""
        self.location = dictionary["location"] as? String ?? ""
        self.percentageFunded = dictionary["percentageFunded"] as? String ?? ""
        self.state = dictionary["state"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
        self.url = dictionary["url"] as? String ?? ""
    }
}


