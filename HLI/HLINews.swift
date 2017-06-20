//
//  HLINews.swift
//  HLI
//
//  Created by Lena on 16.06.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation

struct HLINews {
    var newsURL: URL
    var title: String
    var date: String
    var author: String
    var tags: [String]
    var tagsURL: [URL]
    var comments: String
    var body: String
    
    init(newsURL: URL, title: String, date: String, author: String, tags: [String], tagsURL: [URL], comments: String, body: String) {
        self.newsURL = newsURL
        self.title = title
        self.date = date
        self.author = author
        self.tags = tags
        self.tagsURL = tagsURL
        self.comments = comments
        self.body = body
    }
}
