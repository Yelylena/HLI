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
    var text: String
    var image: String?
    var commentQuote: String?
//    var commentQuoteAuthor: String?
    
    init(name: String, date: String, text: String, image: String?, commentQuote: String?) {
        self.name = name
        self.date = date
        self.text = text
        self.image = image
        self.commentQuote = commentQuote
    }
}
