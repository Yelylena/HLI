//
//  HLINews.swift
//  HLI
//
//  Created by Lena on 16.06.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation
import UIKit

class News {
    var newsURL:  URL
    var title:    String
    var date:     String
    var author:   String
    var tags:     [String]
    var tagsURL:  [URL]
    var comments: String
    var body:     [Body]
    
    init(newsURL: URL, title: String, date: String, author: String, tags: [String], tagsURL: [URL], comments: String, body: [Body]) {
        self.newsURL = newsURL
        self.title = title
        self.date = date
        self.author = author
        self.tags = tags
        self.tagsURL = tagsURL
        self.comments = comments
        self.body = body
    }
    
    func makeBobySubviews(body: [Body], cell: UITableViewCell) {
        
        var position = CGPoint(x: 0, y: 120)
        var tag = 1000
        
        for item in body {
            var bodySubviews = [UIView]()
            
            if item.type == Body.DataType.paragraph {
                let paragraphView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 120))
                paragraphView.text = item.data as? String
                paragraphView.numberOfLines = 1000
                cell.addSubview(paragraphView)
                bodySubviews.append(paragraphView)
                position.y += paragraphView.frame.height
            }
            
            if item.type == Body.DataType.unorderedList {
                let listView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 70))
                listView.numberOfLines = 1000
                listView.text = item.data as? String
                //                    listView.text?.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: bodyFont!)
                cell.addSubview(listView)
                bodySubviews.append(listView)
                position.y += listView.frame.height
            }
            
            if item.type == Body.DataType.image {
                let imageView = UIImageView(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 200))
                //                        imageView.center = cell.center
                
                imageView.sd_setImage(with: URL(string: item.data as! String))
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                cell.addSubview(imageView)
                bodySubviews.append(imageView)
                position.y += imageView.frame.height
            }
            
            if item.type == Body.DataType.strong {
                let strongView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 20))
                strongView.font = UIFont.boldSystemFont(ofSize: 17.0)
                strongView.text = item.data as? String
                strongView.numberOfLines = 1000
                cell.addSubview(strongView)
                bodySubviews.append(strongView)
                position.y += strongView.frame.height
            }
            
            for view in bodySubviews {
                view.tag = tag
                tag += 1
            }
        }
    }
    
    func removeBobySubviews(cell: UITableViewCell) {
        for subview in cell.subviews {
            if subview.tag >= 1000 {
                subview.removeFromSuperview()
                print("Removed subview with tag [\(subview.tag)]")
            }
        }
    }
}
