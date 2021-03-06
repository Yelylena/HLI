//
//  Parser.swift
//  HLI
//
//  Created by Lena on 11.07.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import UIKit
import Foundation
import SwiftSoup
import Kanna
import SDWebImage
//import ActiveLabel

class Parser {
    
    var pageURL: URL?
    var html: String
    
    init(pageURL: URL, html: String) {
        self.pageURL = pageURL
        self.html = html
    }
    
    
    
    //MARK: Parse elements in news body
    func parseBody(element: XMLElement, selector: String, priority: Int) -> [Body] {
        var body = [Body]()
        let emojis = Emojis()
        
        for bodyItem in element.css(selector) {
            let bodyString = bodyItem.innerHTML!
            
            //MARK: Strong
            for strong in bodyItem.css("strong") {
                let strongText = strong.text!
                let range = bodyString.localizedStandardRange(of: strong.toHTML!)
                body.append(Body(type: Body.DataType.strong, data: strongText, range: range!, priority: priority))
            }
            
            //MARK: Unordered list
            for ul in bodyItem.css("ul") {
                let range = bodyString.localizedStandardRange(of: ul.toHTML!)
                for li in ul.css("li") {
                    let listItem = "\u{25CF} \(li.text!)"
                    let range = bodyString.localizedStandardRange(of: li.toHTML!)
                    body.append(Body(type: Body.DataType.unorderedListItem, data: listItem, range: range!, priority: priority))
                }
                body.append(Body(type: Body.DataType.unorderedList, data: String(), range: range!, priority: priority))
            }
            
            //MARK: Ordered list
            var listItemNumber = 1
            for ol in bodyItem.css("ol") {
                let range = bodyString.localizedStandardRange(of: ol.toHTML!)
                for li in ol.css("li") {
                    let listItem = "\(listItemNumber) \(li.text!)"
                    let range = bodyString.localizedStandardRange(of: li.toHTML!)
                    body.append(Body(type: Body.DataType.orderedListItem, data: listItem, range: range!, priority: priority))
                    listItemNumber += 1
                }
                body.append(Body(type: Body.DataType.orderedList, data: String(), range: range!, priority: priority))
            }
            
            //MARK: Video
            for video in bodyItem.css("video") {
//                let videoItem = video["data-youtube-id"]!
                let range = bodyString.localizedStandardRange(of: video.toHTML!)
                body.append(Body(type: Body.DataType.video, data: "", range: range!, priority: priority))
            }
            
            //MARK: YouTubeVideo
            for video in bodyItem.css("a[class*='video_type_youtube']") {
                let videoItem = video["data-youtube-id"]!
                let range = bodyString.localizedStandardRange(of: video.toHTML!)
                body.append(Body(type: Body.DataType.youTubeVideo, data: videoItem, range: range!, priority: priority))
            }
            
            //MARK: Paragraph
            for paragraph in bodyItem.css("p") {
                let paragraphText = paragraph.text!
                let range = bodyString.localizedStandardRange(of: paragraph.toHTML!)
                body.append(Body(type: Body.DataType.paragraph, data: paragraphText, range: range!, priority: priority))
//               body += parseBody(element: paragraph, selector: "p", priority: priority + 1)
            }
            
            //FIXME: Link??
            if selector.contains("comment") {
                //Image
                for image in bodyItem.css("img") {
                    let imageURL = image["src"]
                    let data = emojis.getEmoji(loc: imageURL!)
                    let range = bodyString.localizedStandardRange(of: image.toHTML!)
                    body.append(Body(type: Body.DataType.emoji, data: data, range: range!, priority: priority))
                }

                //MARK: Blockquote
                for blockquote in bodyItem.css("div[class='comment__quote']") {
                    let blockquoteText = blockquote.text!
                    let range = bodyString.localizedStandardRange(of: blockquote.toHTML!)
                    body.append(Body(type: Body.DataType.blockquote, data: blockquoteText, range: range!, priority: priority))
//                    body += parseBody(element: blockquote, selector: "div[class='comment__quote']", priority: priority + 1)
                }
            } else {
                //MARK: Image
                for image in bodyItem.css("img") {
                    let imageURL = image["src"]
                    let width = image["width"]
                    let height = image["height"]
                    
                    let imageURLString = ((imageURL?[1] == "/") ? "https:" : "https://www.hl-inside.ru") + imageURL!
                    let range = bodyString.localizedStandardRange(of: image.toHTML!)
                    if width != nil && height != nil {
                        let image = ImageWithSize(url: imageURLString, width: Int(width!)!, height: Int(height!)!)
                        body.append(Body(type: Body.DataType.imageWithSize, data: image, range: range!, priority: priority))
                    } else {
                        body.append(Body(type: Body.DataType.image, data: imageURLString, range: range!, priority: priority))
                    }
                }
                //MARK: Blockquote
                for blockquote in bodyItem.css("blockquote") {
                    let blockquoteText = blockquote.text!
                    let range = bodyString.localizedStandardRange(of: blockquote.toHTML!)
                    body.append(Body(type: Body.DataType.blockquote, data: blockquoteText, range: range!, priority: priority))
//                    body += parseBody(element: blockquote, selector: "div[class='comment__quote']", priority: 2)
                }
            }
            body = self.parseOrdinaryText(body: body, bodyString: bodyString, type: Body.DataType.paragraph)
            body = self.removeDuplicateElements(body: body)
        }
        return body
    }
    
    //MARK: Sort
    func sortBody(body: [Body]) -> [Body] {
        return body.sorted(by: { (first:Body, last:Body) -> Bool in
            return first.range.lowerBound < last.range.upperBound
        })
    }
    
    //Mark: Parse ordinary text
    func parseOrdinaryText(body: [Body], bodyString: String, type: Body.DataType) -> [Body] {
        
        func getOrdinaryText(start: String.Index, end: String.Index) -> Body {
            var text = bodyString.substring(with: start..<end)
            let range = bodyString.localizedStandardRange(of: text)
            
            if type == Body.DataType.commentText {
                text = text.replacingOccurrences(of: "<br>", with: "\n")
                return Body(type: type, data: NSMutableAttributedString(string: text), range: range!, priority: 1)
            }
            
            return Body(type: type, data: text, range: range!, priority: 1)
        }
        
        var body = self.sortBody(body: body)
        
        if body.isEmpty {
            body.append(getOrdinaryText(start: bodyString.startIndex, end: bodyString.endIndex))
        } else {
            var prevItem = body[0]
            var prevEnd = bodyString.distance(from: bodyString.startIndex, to: prevItem.range.upperBound)
            
            //MARK: Ordinary text before body array
            if bodyString.distance(from: bodyString.startIndex, to: prevItem.range.lowerBound) != String.IndexDistance.init(exactly: 1.0) {
                body.append(getOrdinaryText(start: bodyString.startIndex, end: prevItem.range.lowerBound))
            }
            
            for (_, item) in body.enumerated() {
                let startPos = bodyString.distance(from: bodyString.startIndex, to: item.range.lowerBound)
                //                let endPos = bodyString.distance(from: bodyString.startIndex, to: item.range.upperBound)
                
                if ((prevEnd + 1) != startPos) && ((prevEnd + 1) < startPos) {
                    body.append(getOrdinaryText(start: prevItem.range.upperBound, end: item.range.lowerBound))
                }
                prevItem = item
                prevEnd = bodyString.distance(from: bodyString.startIndex, to: prevItem.range.upperBound)
            }
            
            body = self.sortBody(body: body)
            
            //MARK: Ordinary text after body array
            if bodyString.distance(from: (body.last?.range.upperBound)!, to: bodyString.endIndex) != String.IndexDistance.init(exactly: 1.0) {
                body.append(getOrdinaryText(start: (body.last?.range.upperBound)!, end: bodyString.endIndex))
            }
            
            body = self.sortBody(body: body)
        }
        return body
    }
    
    //MARK: Attach emoji
    func attachEmoji(body: [Body]) -> [Body] {
        var body = body
        var prevItem = body[0]
        var lastCommentText = body[0]
        
        if body.isEmpty {
            print("Body is empty")
        } else {
            for (_, item) in body.enumerated() {
                if (prevItem.type == Body.DataType.commentText) && (item.type == Body.DataType.emoji) {
                    let str = prevItem.data as! NSMutableAttributedString
                    str.append(NSAttributedString(attachment: item.data as! NSTextAttachment))
                    prevItem.data = str
                    lastCommentText = prevItem
                } else if (prevItem.type == Body.DataType.emoji) && (item.type == Body.DataType.emoji) {
                    let str = lastCommentText.data as! NSMutableAttributedString
                    str.append(NSAttributedString(attachment: item.data as! NSTextAttachment))
                    lastCommentText.data = str
                }
                prevItem = item
            }
        }
        return body
    }
    
    //FIXME: Fix removing
    func removeDuplicateElements(body: [Body]) -> [Body] {
        var body = body
       
        for (_, item) in body.enumerated(){
            //            print("Item \(idx)(\(item.type)): low \(item.range.lowerBound), upp \(item.range.upperBound)")
        }
        
        return body
    }
    
    //MARK: News
    func parseNews() -> [News] {
        
        var news = [News]()
        
        var title: String?
        var newsURL: URL?
        var date: String?
        var author: String?
        var comments: String?
        
        if let doc = try? HTML(html: html, encoding: .windowsCP1251) {
            
            for newsItem in doc.css("div[class='block block_type_news']") {
                
                //FIXME: Make dictionary for tags
                var tags = [String?]()
                var tagsURL = [URL?]()
                
                var body = [Body]()
                
                //Title
                title = newsItem.at_css("a[class='b-link']")?.text!
                
                //News URL
                var newsURLLoc = newsItem.at_css("h2[class='news-title'] > a")
                newsURL = URL(string: "https://www.hl-inside.ru" + (newsURLLoc?["href"]!)!)
                
                //News date
                var newsDateLoc = newsItem.at_css("p[class='post-date']")
                date = newsDateLoc?["data-date"] ?? String()
                
                //Author
                author = newsItem.at_css("span[class='block-bottom-author']")?.text!
                
                //Tags
                
                for tag in newsItem.css("p[class='news__tags'] > a") {
                    tags.append(tag.text!)
                }
                
                //Tags URL
                
                for url in newsItem.css("p[class='news__tags'] > a") {
                    tagsURL.append(URL(string: url["href"]!)!)
                }
                
                //Comments
                comments = newsItem.at_css("p[class='news__comments']")?.text!
                
                //Body
                
 //               body = parseBody(element: newsItem, selector: "div[class^='block-body']", priority: 1)
                for bodyItem in newsItem.css("div[class^='block-body']") {
                    let bodyString = bodyItem.innerHTML!
                    //                    print(bodyString)

                    //MARK: Strong
                    for strong in bodyItem.css("strong") {
                        let strongText = strong.text!
                        let range = bodyString.localizedStandardRange(of: strong.toHTML!)
                        body.append(Body(type: Body.DataType.strong, data: strongText, range: range!, priority: 1))
                    }

                    //MARK: Image
                    for image in bodyItem.css("img") {
                        let imageURL = image["src"]
                        let width = image["width"]
                        let height = image["height"]

                        let imageURLString = ((imageURL?[1] == "/") ? "https:" : "https://www.hl-inside.ru") + imageURL!
                        let range = bodyString.localizedStandardRange(of: image.toHTML!)
                        if width != nil && height != nil {
                            let image = ImageWithSize(url: imageURLString, width: Int(width!)!, height: Int(height!)!)
                            body.append(Body(type: Body.DataType.imageWithSize, data: image, range: range!, priority: 1))
                        } else {
                            body.append(Body(type: Body.DataType.image, data: imageURLString, range: range!, priority: 1))
                        }
                    }

                    //MARK: Unordered list
                    for ul in bodyItem.css("ul") {
                        for li in ul.css("li") {
                            let listItem = "\u{25CF} \(li.text!)"
                            let range = bodyString.localizedStandardRange(of: li.toHTML!)
                            body.append(Body(type: Body.DataType.unorderedList, data: listItem, range: range!, priority: 1))
                        }
                    }

                    //MARK: Ordered list
                    var listItemNumber = 1
                    for ol in bodyItem.css("ol > li") {
                        for li in ol.css("li") {
                            let listItem = "\(listItemNumber) \(li.text!)"
                            let range = bodyString.localizedStandardRange(of: ol.toHTML!)
                            body.append(Body(type: Body.DataType.orderedList, data: listItem, range: range!, priority: 1))
                        }
                        listItemNumber += 1
                    }
                    //MARK: Video
                    for video in bodyItem.css("a[class*='video_type_youtube']") {
                        let videoItem = video["data-youtube-id"]!
                        let range = bodyString.localizedStandardRange(of: video.toHTML!)
                        body.append(Body(type: Body.DataType.video, data: videoItem, range: range!, priority: 1))
                    }

                    //MARK: Paragraph
                    for paragraph in bodyItem.css("p") {
                        let paragraphText = paragraph.text!
                        let range = bodyString.localizedStandardRange(of: paragraph.toHTML!)
                        body.append(Body(type: Body.DataType.paragraph, data: paragraphText, range: range!, priority: 1))
                    }
                    //MARK: Blockquote
                    for blockquote in bodyItem.css("blockquote") {
                        let blockquoteText = blockquote.text!
                        let range = bodyString.localizedStandardRange(of: blockquote.toHTML!)
                        body.append(Body(type: Body.DataType.blockquote, data: blockquoteText, range: range!, priority: 1))

                    }
                    body = self.parseOrdinaryText(body: body, bodyString: bodyString, type: Body.DataType.paragraph)
                    body = self.removeDuplicateElements(body: body)
                }
                news.append(News(newsURL: newsURL!, title: title!, date: date!, author: author!, tags: tags as! [String], tagsURL: tagsURL as! [URL], comments: comments!, body: body))
            }
        }
        return news
    }
    
    //MARK: Comment
    func parseComment() -> [Comment] {
        
        var comments = [Comment]()
        var emojis = Emojis()
        
        var name: String?
        var date: String?
        var image: String?
        
        if let doc = try? HTML(html: html, encoding: .windowsCP1251) {
            
            for commentItem in doc.css("div[itemscope='itemscope']") {
                
                var body = [Body]()
                
                //Name
                name = commentItem.at_css("div[class='comment__name']")?.text!
                
                //Comment date
                date = commentItem.at_css("time[class='comment__date']")?.text!
                
                //Image
                var imageLoc = commentItem.at_css("div[class='comment__steam'] > a > img")
                image = imageLoc?["src"] ?? ""
                
                //Body
                for bodyItem in commentItem.css("div[class='comment__text']") {
                    let bodyString = bodyItem.innerHTML!
                    print(bodyString)
                    
                    //Image
                    for image in bodyItem.css("img") {
                        let imageURL = image["src"]
                        let data = emojis.getEmoji(loc: imageURL!)
                        let range = bodyString.localizedStandardRange(of: image.toHTML!)
                        body.append(Body(type: Body.DataType.emoji, data: data, range: range!, priority: 1))
                    }
                    //MARK: Blockquote
                    for blockquote in bodyItem.css("div[class='comment__quote']") {
                        let blockquoteText = blockquote.text!
                        let range = bodyString.localizedStandardRange(of: blockquote.toHTML!)
                        body.append(Body(type: Body.DataType.blockquote, data: blockquoteText, range: range!, priority: 1))
                    }
                    body = self.parseOrdinaryText(body: body, bodyString: bodyString, type: Body.DataType.commentText)
                    //FIXME: Add to attachEmoji func
                    var prevItem = body[0]
                    var lastCommentText = body[0]
                    
                    if body.isEmpty {
                        print("Body is empty")
                    } else {
                        for (_, item) in body.enumerated() {
                            if (prevItem.type == Body.DataType.commentText) && (item.type == Body.DataType.emoji) {
                                let str = prevItem.data as! NSMutableAttributedString
                                str.append(NSAttributedString(attachment: item.data as! NSTextAttachment))
                                prevItem.data = str
                                lastCommentText = prevItem
                            } else if (prevItem.type == Body.DataType.emoji) && (item.type == Body.DataType.emoji) {
                                let str = lastCommentText.data as! NSMutableAttributedString
                                str.append(NSAttributedString(attachment: item.data as! NSTextAttachment))
                                lastCommentText.data = str
                            }
                            prevItem = item
                        }
                    }
                }
                
                comments.append(Comment(name: name!, date: date!, body: body, image: image))
            }
        }
        return comments
    }
    
    //MARK: Form
    func parseForm() -> FormData {
        var formData = FormData(date: String(), wallace: String(), breen: String())
        if let doc = try? HTML(html: html, encoding: .windowsCP1251) {
            for form in doc.css("form") {
                for date in form.css("input[name='date']") {
                    formData.date = date["value"]!
                }
                for wallace in form.css("input[name='wallace']") {
                    formData.wallace = wallace["value"]!
                }
                for breen in form.css("input[name='breen']") {
                    formData.breen = breen["value"]!
                }
            }
        }
        return formData
    }
    
    //MARK: Navigation
    func parseNavigation() -> (prevNewsURL: URL?, nextNewsURL: URL?) {
        
        var prevNewsURL: URL?
        var nextNewsURL: URL?
        
        if let doc = try? HTML(html: html, encoding: .windowsCP1251) {
            for newsNavigation in doc.css("div[class='next-prev']") {
                
                //Previous news
                let prevLoc = newsNavigation.at_css("span[class='next-prev__prev'] > a")
                prevNewsURL = URL(string: "https://www.hl-inside.ru" + ((prevLoc != nil) ? (prevLoc?["href"])! : "/"))
                
                //Next news
                var nextLoc = newsNavigation.at_css("span[class='next-prev__next'] > a")
                nextNewsURL = URL(string: "https://www.hl-inside.ru" + ((nextLoc != nil) ? (nextLoc?["href"])! : "/"))
            }
        }
        return (prevNewsURL!, nextNewsURL!)
    }
}
