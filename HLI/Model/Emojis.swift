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
        var image: UIImage
        var data: String
        
        init(name: String, image: UIImage, data: String) {
            self.name = name
            self.image = image
            self.data = data
        }
    }
    
    let emojiSize = CGRect(x: 0, y: 0, width: 30, height: 30)
    
    var emojis = [
        Emoji(name: "biggrin", image: #imageLiteral(resourceName: "screen"), data: ":-D"),
        Emoji(name: "laugh", image: #imageLiteral(resourceName: "screen"), data: "!-D"),
        Emoji(name: "surprise", image: #imageLiteral(resourceName: "screen"), data: "8-D"),
        Emoji(name: "smile", image: #imageLiteral(resourceName: "screen"), data: ":-)"),
        Emoji(name: "wink", image: #imageLiteral(resourceName: "screen"), data: ";-)"),
        Emoji(name: "cool", image: #imageLiteral(resourceName: "screen"), data: ":cool:"),
        Emoji(name: "playful", image: #imageLiteral(resourceName: "screen"), data: ":playful:"),
        Emoji(name: "tongue", image: #imageLiteral(resourceName: "screen"), data: ":-P"),
        Emoji(name: "angry", image: #imageLiteral(resourceName: "screen"), data: ":angry:"),
        Emoji(name: "arg", image: #imageLiteral(resourceName: "screen"), data: ":grrrr:"),
        Emoji(name: "dry", image: #imageLiteral(resourceName: "screen"), data: ":dry:"),
        Emoji(name: "blink", image: #imageLiteral(resourceName: "screen"), data: ":blink:"),
        Emoji(name: "blush", image: #imageLiteral(resourceName: "screen"), data: ":blush:"),
        Emoji(name: "cry", image: #imageLiteral(resourceName: "screen"), data: ":weep:"),
        Emoji(name: "huh", image: #imageLiteral(resourceName: "screen"), data: ":huh:"),
        Emoji(name: "ohmy", image: #imageLiteral(resourceName: "screen"), data: ":ohmy:"),
        Emoji(name: "sad", image: #imageLiteral(resourceName: "screen"), data: ":-("),
        Emoji(name: "sick", image: #imageLiteral(resourceName: "screen"), data: ":sick:"),
        Emoji(name: "unhappy", image: #imageLiteral(resourceName: "screen"), data: ":unhappy:"),
        Emoji(name: "unsure", image: #imageLiteral(resourceName: "screen"), data: ":unsure:")
    ]
    
    //    var emojisCollection = [
//        Emoji(name: "biggrin", image: #imageLiteral(resourceName: "emo_biggrin"), data: ":-D"),
//        Emoji(name: "laugh", image: #imageLiteral(resourceName: "emo_laugh"), data: "!-D"),
//        Emoji(name: "surprise", image: #imageLiteral(resourceName: "emo_surprise"), data: "8-D"),
//        Emoji(name: "smile", image: #imageLiteral(resourceName: "emo_smile"), data: ":-)"),
//        Emoji(name: "wink", image: #imageLiteral(resourceName: "emo_wink"), data: ";-)"),
//        Emoji(name: "cool", image: #imageLiteral(resourceName: "emo_cool"), data: ":cool:"),
//        Emoji(name: "playful", image: #imageLiteral(resourceName: "emo_playful"), data: ":playful:"),
//        Emoji(name: "tongue", image: #imageLiteral(resourceName: "emo_tongue"), data: ":-P"),
//        Emoji(name: "angry", image: #imageLiteral(resourceName: "emo_angry"), data: ":angry:"),
//        Emoji(name: "arg", image: #imageLiteral(resourceName: "emo_arg"), data: ":grrrr:"),
//        Emoji(name: "dry", image: #imageLiteral(resourceName: "emo_dry"), data: ":dry:"),
//        Emoji(name: "blink", image: #imageLiteral(resourceName: "emo_blink"), data: ":blink:"),
//        Emoji(name: "blush", image: #imageLiteral(resourceName: "emo_blush"), data: ":blush:"),
//        Emoji(name: "cry", image: #imageLiteral(resourceName: "emo_cry"), data: ":weep:"),
//        Emoji(name: "huh", image: #imageLiteral(resourceName: "emo_huh"), data: ":huh:"),
//        Emoji(name: "ohmy", image: #imageLiteral(resourceName: "emo_ohmy"), data: ":ohmy:"),
//        Emoji(name: "sad", image: #imageLiteral(resourceName: "emo_sad"), data: ":-("),
//        Emoji(name: "sick", image: #imageLiteral(resourceName: "emo_sick"), data: ":sick:"),
//        Emoji(name: "unhappy", image: #imageLiteral(resourceName: "emo_unhappy"), data: ":unhappy:"),
//        Emoji(name: "unsure", image: #imageLiteral(resourceName: "emo_unsure"), data: ":unsure:")
//    ]
    
    func getAttachment(emoji: Emoji, bounds: CGRect) -> NSTextAttachment {
        let attachment = NSTextAttachment()
        attachment.image = emoji.image
        attachment.bounds = bounds
        
        return attachment
    }
    
    func getEmoji(loc: String) -> NSTextAttachment {
        var attachment = NSTextAttachment()
        
        for emoji in emojis {
            if loc.contains(emoji.name) {
                print("It's \(emoji.name)")
                attachment = self.getAttachment(emoji: emoji, bounds: emojiSize)
            }
        }
        return attachment
    }
    
}
