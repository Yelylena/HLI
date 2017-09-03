//
//  Comment.swift
//  HLI
//
//  Created by Lena on 22.06.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import UIKit

struct Comment {
    var name: String
    var date: String
    var body: [Body]
    var image: String?
//    var commentQuoteAuthor: String?
    
    init(name: String, date: String, body: [Body], image: String?) {
        self.name = name
        self.date = date
        self.body = body
        self.image = image
    }
}
