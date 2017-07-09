//
//  NewsBody.swift
//  HLI
//
//  Created by Lena on 09.07.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation

struct NewsBody {
    enum DataType {
        case strong
        case image
        case link
        case video
        case unorderedList
        case orderedList
        case paragraph
        case blockquote
    }
    var type: DataType
    var data: Any
    var range: Range<String.Index>
    
    init(type: DataType, data: Any, range:  Range<String.Index>) {
        self.type = type
        self.data = data
        self.range = range
    }
}
