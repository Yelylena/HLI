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
        var name: String
        var url: String
        var data: String
        
        init(name: String, url: String, data: String) {
            self.name = name
            self.url = url
            self.data = data
        }
        
        init() {
            name = String()
            url = String()
            data = String()
        }
    }
    
    var emojis: [Emoji] = [
        Emoji(name: "biggrin", url: "https://www.hl-inside.ru/images/emoticons/emo_biggrin.gif", data: ":-D"),
        Emoji(name: "laugh", url: "http://www.hl-inside.ru/images/emoticons/emo_laugh.gif", data: "!-D"),
        Emoji(name: "surprise", url: "http://www.hl-inside.ru/images/emoticons/emo_surprise.gif", data: "8-D"),
        Emoji(name: "smile", url: "http://www.hl-inside.ru/images/emoticons/emo_smile.gif", data: ":-)"),
        Emoji(name: "wink", url: "http://www.hl-inside.ru/images/emoticons/emo_wink.gif", data: ";-)"),
        Emoji(name: "cool", url: "http://www.hl-inside.ru/images/emoticons/emo_cool.gif", data: ":cool:"),
        Emoji(name: "playful", url: "http://www.hl-inside.ru/images/emoticons/emo_playful.gif", data: ":playful:"),
        Emoji(name: "tongue", url: "http://www.hl-inside.ru/images/emoticons/emo_tongue.gif", data: ":-P"),
        Emoji(name: "angry", url: "http://www.hl-inside.ru/images/emoticons/emo_angry.gif", data: ":angry:"),
        Emoji(name: "arg", url: "http://www.hl-inside.ru/images/emoticons/emo_arg.gif", data: ":grrrr:"),
        Emoji(name: "dry", url: "http://www.hl-inside.ru/images/emoticons/emo_dry.gif", data: ":dry:"),
        Emoji(name: "blink", url: "http://www.hl-inside.ru/images/emoticons/emo_blink.gif", data: ":blink:"),
        Emoji(name: "blush", url: "http://www.hl-inside.ru/images/emoticons/emo_blush.gif", data: ":blush:"),
        Emoji(name: "cry", url: "http://www.hl-inside.ru/images/emoticons/emo_cry.gif", data: ":weep:"),
        Emoji(name: "huh", url: "http://www.hl-inside.ru/images/emoticons/emo_huh.gif", data: ":huh:"),
        Emoji(name: "ohmy", url: "http://www.hl-inside.ru/images/emoticons/emo_ohmy.gif", data: ":ohmy:"),
        Emoji(name: "sad", url: "http://www.hl-inside.ru/images/emoticons/emo_sad.gif", data: ":-("),
        Emoji(name: "sick", url: "http://www.hl-inside.ru/images/emoticons/emo_sick.gif", data: ":sick:"),
        Emoji(name: "unhappy", url: "http://www.hl-inside.ru/images/emoticons/emo_unhappy.gif", data: ":unhappy:"),
        Emoji(name: "unsure", url: "http://www.hl-inside.ru/images/emoticons/emo_unsure.gif", data: ":unsure:")
    ]
}
