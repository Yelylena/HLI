//
//  NewsBody.swift
//  HLI
//
//  Created by Lena on 09.07.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation
import UIKit

class Body {
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
    //FIXME: Fix removing
    func removeBodySubviews(cell: UITableViewCell) {
        for subview in cell.subviews {
            if subview.tag >= 1000 {
                subview.removeFromSuperview()
            }
        }
    }
    //FIXME: Fix adding
    func makeBobySubviews(cell: UITableViewCell, item: Body, position: CGPoint) {
        var position = position
        if item.type == Body.DataType.unorderedList {
            let listView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 70))
            listView.numberOfLines = 1000
            listView.tag = 1000
            listView.text = item.data as? String
            //                    listView.text?.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: bodyFont!)
            cell.addSubview(listView)
            position.y += listView.frame.height
        }
        
        if item.type == Body.DataType.image {
            DispatchQueue.global(qos: .userInitiated).async {
                let imageView = UIImageView(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 200))
                imageView.tag = 1001
                //                        imageView.center = cell.center
                DispatchQueue.main.async {
                    imageView.sd_setImage(with: URL(string: item.data as! String))
                    imageView.contentMode = UIViewContentMode.scaleAspectFit
                    cell.addSubview(imageView)
                    position.y += imageView.frame.height
                }
            }
        }
        
        if item.type == Body.DataType.strong {
            let strongView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 20))
            strongView.tag = 1002
            strongView.font = UIFont.boldSystemFont(ofSize: 17.0)
            strongView.numberOfLines = 1000
            cell.addSubview(strongView)
            position.y += strongView.frame.height
        }
    }
}
