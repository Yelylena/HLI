//
//  NewsBody.swift
//  HLI
//
//  Created by Lena on 09.07.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation

struct NewsBody {
    var type: String
    var anyObject: Any
    var range: Range<String>
    
    init(type: String, anyObject: Any, range:  Range<String>) {
        self.type = type
        self.anyObject = anyObject
        self.range = range
    }
}
