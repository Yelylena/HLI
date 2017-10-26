//
//  Emojis.swift
//  HLI
//
//  Created by Lena on 24.10.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation
import UIKit

class Emojis {
    struct Emoji {
        var url: String
        var data: String
        
        init(url: String, data: String) {
            self.url = url
            self.data = data
        }
        
        init() {
            url = String()
            data = String()
        }
    }
    
    var emojis: [Emoji] = [
        Emoji(url: "https://www.hl-inside.ru/images/emoticons/emo_biggrin.gif", data: ":-D"),
        Emoji(url: "http://www.hl-inside.ru/images/emoticons/emo_laugh.gif", data: "!-D"),
        Emoji(url: "http://www.hl-inside.ru/images/emoticons/emo_surprise.gif", data: "8-D"),
        Emoji(url: "http://www.hl-inside.ru/images/emoticons/emo_smile.gif", data: ":-)"),
        Emoji(url: "http://www.hl-inside.ru/images/emoticons/emo_wink.gif", data: ";-)"),
        Emoji(url: "http://www.hl-inside.ru/images/emoticons/emo_cool.gif", data: ":cool:"),
        Emoji(url: "http://www.hl-inside.ru/images/emoticons/emo_playful.gif", data: ":playful:")
    ]
}
