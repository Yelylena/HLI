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

func getSubviews(body: [Body], cell: UITableViewCell) {
    
    var position = CGPoint(x: 0, y: 120)
    var tag = 1000
    
    for item in body {
        
        var bodySubviews = [UIView]()
        
        switch item.type {
            
        //MARK: Paragraph
        case Body.DataType.paragraph:
            let paragraphView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 0))
            paragraphView.text = item.data as? String
            paragraphView.text = paragraphView.text?.replacingOccurrences(of: "<br>", with: "\n")
            paragraphView.numberOfLines = 1000
            paragraphView.frame = CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: (paragraphView.text?.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: UIFont.systemFont(ofSize: 17.0)))!)
            //                print("Height of paragraph: \(paragraphView.frame.height)")
            cell.addSubview(paragraphView)
            bodySubviews.append(paragraphView)
            position.y += paragraphView.frame.height
        
        //MARK: List
        case Body.DataType.unorderedList, Body.DataType.orderedList:
            let listView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 0))
            listView.numberOfLines = 1000
            listView.text = item.data as? String
            listView.frame = CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: (listView.text?.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: UIFont.systemFont(ofSize: 17.0)))!)
            cell.addSubview(listView)
            bodySubviews.append(listView)
            position.y += listView.frame.height
        
        //MARK: Image
        case Body.DataType.image:
            let imageView = UIImageView(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 200))
            //                        imageView.center = cell.center
            imageView.sd_setImage(with: URL(string: item.data as! String))
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            cell.addSubview(imageView)
            bodySubviews.append(imageView)
            position.y += imageView.frame.height
        
        //MARK: ImagePNG
        case Body.DataType.imagePNG:
            let imagePNG = item.data as! ImagePNG
            let imageView = UIImageView(frame: CGRect(x: position.x, y: position.y, width: CGFloat(imagePNG.width), height: CGFloat(imagePNG.height)))
            imageView.sd_setImage(with: URL(string: imagePNG.url))
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: position.y + imageView.frame.height/2)
            cell.addSubview(imageView)
            bodySubviews.append(imageView)
            position.y += imageView.frame.height
            
        //MARK: Strong
        case Body.DataType.strong:
            let strongView = UILabel(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 0))
            
            //FIXME: Move to style file
            strongView.font = UIFont.boldSystemFont(ofSize: 17.0)
            
            strongView.text = item.data as? String
            strongView.numberOfLines = 1000
            strongView.frame = CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: (strongView.text?.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: strongView.font))!)
            cell.addSubview(strongView)
            bodySubviews.append(strongView)
            position.y += strongView.frame.height
            
        //MARK: Video
        case Body.DataType.video:
            let videoView = YouTubePlayerView(frame: CGRect(x: position.x, y: position.y, width: UIScreen.main.bounds.size.width, height: 200))
            videoView.loadVideoID(item.data as! String)
            cell.addSubview(videoView)
            bodySubviews.append(videoView)
            position.y += videoView.frame.height
        
        //MARK: Blockquote
        case Body.DataType.blockquote:
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
        
        //MARK: Link
        case Body.DataType.link:
            print()
        
        default:
            print()
        }
        
        for view in bodySubviews {
            view.tag = tag
            tag += 1
        }
    }
    bodyHeight = CGFloat(position.y)
}

func removeSubviews(cell: UITableViewCell) {
    for subview in cell.subviews {
        if subview.tag >= 1000 {
            subview.removeFromSuperview()
        }
    }
}

func getHeight() -> CGFloat {
    return bodyHeight
}
