//
//  ImageWithSize.swift
//  HLI
//
//  Created by Lena on 04.10.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation
import UIKit

struct ImageWithSize {
    var url: String
    var width: Int
    var height: Int
    
    init(url: String, width: Int, height: Int) {
        self.url = url
        self.width = width
        self.height = height
    }
    init() {
        url = String()
        width = 0
        height = 0
    }
}
