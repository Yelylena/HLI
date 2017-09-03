//
//  BodyHelper.swift
//  HLI
//
//  Created by Lena on 27.08.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation
import UIKit
import YouTubePlayer
import SDWebImage

var bodyHeight: CGFloat = 0

func getBobySubviews(body: [Body], cell: UITableViewCell) {
    
    var position = CGPoint(x: 0, y: 120)
    var tag = 1000
    
    for item in body {
        var bodySubviews = [UIView]()
        
        //MARK: Paragraph
        if item.type == Body.DataType.paragraph {
            let paragraphView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 0))
            paragraphView.text = item.data as? String
            paragraphView.numberOfLines = 1000
            paragraphView.frame = CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: (paragraphView.text?.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: UIFont.systemFont(ofSize: 17.0)))!)
            //                print("Height of paragraph: \(paragraphView.frame.height)")
            cell.addSubview(paragraphView)
            bodySubviews.append(paragraphView)
            position.y += paragraphView.frame.height
        }
        
        //MARK: Unordered list
        if item.type == Body.DataType.unorderedList {
            let listView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 0))
            listView.numberOfLines = 1000
            listView.text = item.data as? String
            listView.frame = CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: (listView.text?.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: UIFont.systemFont(ofSize: 17.0)))!)
            cell.addSubview(listView)
            bodySubviews.append(listView)
            position.y += listView.frame.height
        }
        
        //MARK: Ordered list
        if item.type == Body.DataType.orderedList {
            let listView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 0))
            listView.numberOfLines = 1000
            listView.text = item.data as? String
            listView.frame = CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: (listView.text?.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: UIFont.systemFont(ofSize: 17.0)))!)
            cell.addSubview(listView)
            bodySubviews.append(listView)
            position.y += listView.frame.height
        }
        
        //MARK: Image
        if item.type == Body.DataType.image {
            let imageView = UIImageView(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 200))
            //                        imageView.center = cell.center            
            imageView.sd_setImage(with: URL(string: item.data as! String))
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            cell.addSubview(imageView)
            bodySubviews.append(imageView)
            position.y += imageView.frame.height
        }
        
        //MARK: Strong
        if item.type == Body.DataType.strong {
            let strongView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 0))
            
            //FIXME: Move to style file
            strongView.font = UIFont.boldSystemFont(ofSize: 17.0)
            
            strongView.text = item.data as? String
            strongView.numberOfLines = 1000
            strongView.frame = CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: (strongView.text?.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: strongView.font))!)
            cell.addSubview(strongView)
            bodySubviews.append(strongView)
            position.y += strongView.frame.height
        }
        
        //MARK: Video
        if item.type == Body.DataType.video {
            let videoView = YouTubePlayerView(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 200))
            videoView.loadVideoID(item.data as! String)
            cell.addSubview(videoView)
            bodySubviews.append(videoView)
            position.y += videoView.frame.height
        }
        
        //MARK: Link
        if item.type == Body.DataType.link {
            
        }
        
        //MARK: Blockquote
        if item.type == Body.DataType.blockquote {
            let blockquoteView = UILabel(frame: CGRect(x: 30, y: position.y, width: UIScreen.main.bounds.size.width, height: 0))
            blockquoteView.text = item.data as? String
            blockquoteView.numberOfLines = 1000
            blockquoteView.frame = CGRect(x: 30, y: position.y, width: UIScreen.main.bounds.size.width, height: (blockquoteView.text?.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: UIFont.systemFont(ofSize: 17.0)))!)
            blockquoteView.backgroundColor = UIColor.AppColors.Gray49
            blockquoteView.textColor = UIColor.AppColors.Text
            
            //MARK: Blockquote border
            let blockquoteViewBorder = CAShapeLayer()
            blockquoteViewBorder.strokeColor = UIColor.AppColors.Border.cgColor
            blockquoteViewBorder.lineDashPattern = [3, 3]
            blockquoteViewBorder.frame = blockquoteView.bounds
            blockquoteViewBorder.fillColor = nil
            blockquoteViewBorder.path = UIBezierPath(rect: blockquoteView.bounds).cgPath
            blockquoteView.layer.addSublayer(blockquoteViewBorder)

            cell.addSubview(blockquoteView)
            bodySubviews.append(blockquoteView)
            position.y += blockquoteView.frame.height
        }
        
        for view in bodySubviews {
            view.tag = tag
            tag += 1
        }
    }
    bodyHeight = CGFloat(position.y)
}

func removeBobySubviews(cell: UITableViewCell) {
    for subview in cell.subviews {
        if subview.tag >= 1000 {
            subview.removeFromSuperview()
        }
    }
}

func getBodyHeight() -> CGFloat {
    return bodyHeight
}
