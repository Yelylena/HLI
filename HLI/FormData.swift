//
//  FormData.swift
//  HLI
//
//  Created by Lena on 20.10.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation
import UIKit

struct FormData {
    var date: String
    var wallace: String
    var breen: String
    
    init(date: String, wallace: String, breen: String) {
        self.date = date
        self.wallace = wallace
        self.breen = breen
    }
    init() {
        date = String()
        wallace = String()
        breen = String()
    }
}
