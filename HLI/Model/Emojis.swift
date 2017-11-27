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
    
    let emojiSize = CGRect(x: 0, y: -5, width: 23, height: 20)
    
    var emojis = [
        Emoji(name: "biggrin", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_biggrin.gif")!))!, data: ":-D"),
        Emoji(name: "laugh", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_laugh.gif")!))!, data: "!-D"),
        Emoji(name: "surprise", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_surprise.gif")!))!, data: "8-D"),
        Emoji(name: "smile", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_smile.gif")!))!, data: ":-)"),
        Emoji(name: "wink", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_wink.gif")!))!, data: ";-)"),
        Emoji(name: "cool", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_cool.gif")!))!, data: ":cool:"),
        Emoji(name: "playful", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_playful.gif")!))!, data: ":playful:"),
        Emoji(name: "tongue", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_tongue.gif")!))!, data: ":-P"),
        Emoji(name: "angry", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_angry.gif")!))!, data: ":angry:"),
        Emoji(name: "arg", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_arg.gif")!))!, data: ":grrrr:"),
        Emoji(name: "dry", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_dry.gif")!))!, data: ":dry:"),
        Emoji(name: "blink", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_blink.gif")!))!, data: ":blink:"),
        Emoji(name: "blush", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_blush.gif")!))!, data: ":blush:"),
        Emoji(name: "cry", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_cry.gif")!))!, data: ":weep:"),
        Emoji(name: "huh", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_huh.gif")!))!, data: ":huh:"),
        Emoji(name: "ohmy", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_ohmy.gif")!))!, data: ":ohmy:"),
        Emoji(name: "sad", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_sad.gif")!))!, data: ":-("),
        Emoji(name: "sick", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_sick.gif")!))!, data: ":sick:"),
        Emoji(name: "unhappy", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_unhappy.gif")!))!, data: ":unhappy:"),
        Emoji(name: "unsure", image: UIImage.sd_animatedGIF(with: try! Data(contentsOf: URL(string: "http://is.hl-inside.ru/emoticons/emo_unsure.gif")!))!, data: ":unsure:")
    ]
    
    func getEmoji(loc: String) -> NSTextAttachment {
        
        let attachment = NSTextAttachment()
        
        for emoji in emojis {
            if loc.contains(emoji.name) {
                attachment.image = emoji.image
                attachment.bounds = emojiSize
            }
        }
        return attachment
    }
    
}
