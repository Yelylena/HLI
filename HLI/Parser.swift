//
//  Parser.swift
//  HLI
//
//  Created by Lena on 11.07.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import UIKit
import Kanna
import Alamofire
import SDWebImage
import ActiveLabel

class Parser {
    
    var pageURL: URL?
    var html: String
    
    init(pageURL: URL, html: String) {
        self.pageURL = pageURL
        self.html = html
    }
    
    //MARK: News
    func parseNews() -> [News] {
        
        var news = [News]()
        
        var title: String?
        var newsURL: URL?
        var date: String?
        var author: String?
        var comments: String?
        
        if let doc = HTML(html: html, encoding: .windowsCP1251) {
            
            for newsItem in doc.css("div[class='block block_type_news']") {
                
                //FIXME: Make dictionary for tags
                var tags = [String?]()
                var tagsURL = [URL?]()
                
                var body = [Body]()
                
                //Title
                title = newsItem.at_css("a[class='b-link']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //News URL
                var newsURLLoc = newsItem.at_css("h2[class='news-title'] > a")
                newsURL = URL(string: "https://www.hl-inside.ru" + (newsURLLoc?["href"]!)!)
                
                //News date
                var newsDateLoc = newsItem.at_css("p[class='post-date']")
                date = newsDateLoc?["data-date"] ?? String()
                
                //Author
                author = newsItem.at_css("p[class='news__author']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Tags
                
                for tag in newsItem.css("p[class='news__tags'] > a") {
                    tags.append(tag.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                }
                
                //Tags URL
                
                for url in newsItem.css("p[class='news__tags'] > a") {
                    tagsURL.append(URL(string: url["href"]!)!)
                }
                
                //Comments
                comments = newsItem.at_css("p[class='news__comments']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Body
                for bodyItem in newsItem.css("div[class^='block-body']") {
                    let bodyString = bodyItem.innerHTML!
//                    print(bodyString)
                    
                    //MARK: Strong
                    for strong in bodyItem.css("strong") {
                        let strongText = strong.text!
                        let range = bodyString.localizedStandardRange(of: strong.toHTML!)
                        body.append(Body(type: Body.DataType.strong, data: strongText, range: range!))
                    }
                    
                    //MARK: Image
                    for image in bodyItem.css("img") {
                        let imageURL = image["src"]
                        var imageURLString = String()
                        let width = image["width"]
                        let height = image["height"]
                        if imageURL?[1] == "/" {
                            imageURLString = "https:" + imageURL!
                        } else {
                            imageURLString = "https://www.hl-inside.ru" + imageURL!
                        }
                        let range = bodyString.localizedStandardRange(of: image.toHTML!)
                        if width != nil && height != nil {
                            let imagePNG = ImagePNG(url: imageURLString, width: Int(width!)!, height: Int(height!)!)
                            body.append(Body(type: Body.DataType.imagePNG, data: imagePNG, range: range!))
                        } else {
                            body.append(Body(type: Body.DataType.image, data: imageURLString, range: range!))
                        }
                    }
                    
                    //MARK: Unordered list
                    for ul in bodyItem.css("ul") {
                        for li in ul.css("li") {
                            let listItem = "\u{25CF} \(li.text!)"
                            let range = bodyString.localizedStandardRange(of: ul.toHTML!)
                            body.append(Body(type: Body.DataType.unorderedList, data: listItem, range: range!))
                        }
                    }
                    
                    //MARK: Ordered list
                    var listItemNumber = 1
                    for ol in bodyItem.css("ol > li") {
                        for li in ol.css("li") {
                            let listItem = "\(listItemNumber) \(li.text!)"
                            let range = bodyString.localizedStandardRange(of: ol.toHTML!)
                            body.append(Body(type: Body.DataType.orderedList, data: listItem, range: range!))
                        }
                        listItemNumber += 1
                    }
                    //MARK: Video
                    for video in bodyItem.css("a[class*='video_type_youtube']") {
                        let videoItem = video["data-youtube-id"]!
                        let range = bodyString.localizedStandardRange(of: video.toHTML!)
                        body.append(Body(type: Body.DataType.video, data: videoItem, range: range!))
                    }
                    
                    //MARK: Paragraph
                    for paragraph in bodyItem.css("p") {
                        let paragraphText = paragraph.text!
                        let range = bodyString.localizedStandardRange(of: paragraph.toHTML!)
                        body.append(Body(type: Body.DataType.paragraph, data: paragraphText, range: range!))
                    }
                    //MARK: Blockquote
                    for blockquote in bodyItem.css("blockquote") {
                        let blockquoteText = blockquote.text!
                        let range = bodyString.localizedStandardRange(of: blockquote.toHTML!)
                        body.append(Body(type: Body.DataType.blockquote, data: blockquoteText, range: range!))
                        
                    }
//                    newsBodyString = newsBodyString.replacingOccurrences(of: "<br>", with: "\n")
                    body = body.sorted(by: { (first:Body, last:Body) -> Bool in
                        return first.range.lowerBound < last.range.upperBound
                    })
                    
                    var prevItem = body[0]
                    var prevEnd = bodyString.distance(from: bodyString.startIndex, to: prevItem.range.upperBound)
                    for idx in 1..<body.count {
                        let item = body[idx]
                        let startPos = bodyString.distance(from: bodyString.startIndex, to: item.range.lowerBound)
                        let endPos = bodyString.distance(from: bodyString.startIndex, to: item.range.upperBound)
                        
//                        print("start: \(prevEnd) end: \(startPos)")
                        if ((prevEnd + 1) != startPos) && (prevEnd+1 < startPos) {
                            let text = bodyString.substring(with: prevItem.range.upperBound..<item.range.lowerBound)
                            print("Ordinary text: \(text)")
                            let range = bodyString.localizedStandardRange(of: text)
                            body.append(Body(type: Body.DataType.paragraph, data: text, range: range!))
                        }
                        prevItem = item
                        prevEnd = bodyString.distance(from: bodyString.startIndex, to: prevItem.range.upperBound)
//                        print("First range: \(startPos), last range: \(endPos)")
//                        print("First range: \(item.range.lowerBound), last range: \(item.range.upperBound)")
                        
                    }
                    body = body.sorted(by: { (first:Body, last:Body) -> Bool in
                        return first.range.lowerBound < last.range.upperBound
                    })
                }
                news.append(News(newsURL: newsURL!, title: title!, date: date!, author: author!, tags: tags as! [String], tagsURL: tagsURL as! [URL], comments: comments!, body: body))
            }
        }
//        for idx in 0..<news.count {
//            let n = news[idx]
//            for i in 0..<n.body.count {
//                print("news[\(idx)], bodyItem[\(i)], text[\(n.body[i].data)]")
//            }
//        }
        return news
    }
    
    //MARK: Comment
    func parseComment() -> [Comment] {
        
        var comments = [Comment]()
        
        var name: String?
        var date: String?
        var image: String?
        
        if let doc = HTML(html: html, encoding: .windowsCP1251) {
            
            for commentItem in doc.css("div[itemscope='itemscope']") {
                
                var body = [Body]()
                
                //Name
                name = commentItem.at_css("div[class='comment__name']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Comment date
                date = commentItem.at_css("time[class='comment__date']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Image
                var imageLoc = commentItem.at_css("div[class='comment__steam'] > a > img")
                image = imageLoc?["src"] ?? ""
                
                //Text
                for textItem in commentItem.css("div[class='comment__text']") {
                    let textString = textItem.innerHTML!
                    
                    
                    
                    //MARK: Blockquote
                    for blockquote in textItem.css("div[class='comment__quote']") {
                        let blockquoteText = blockquote.text!
                        let range = textString.localizedStandardRange(of: blockquote.toHTML!)
                        body.append(Body(type: Body.DataType.blockquote, data: blockquoteText, range: range!))
                        
                    }
                    body = body.sorted(by: { (first:Body, last:Body) -> Bool in
                        return first.range.lowerBound < last.range.upperBound
                    })
                }
                
                comments.append(Comment(name: name!, date: date!, body: body, image: image))
            }
        }
        return comments
    }
    
    //MARK: Navigation
    func parseNavigation() -> (prevNews: URL?, nextNews: URL?) {
        
        var prevNews: URL?
        var nextNews: URL?
        
        if let doc = HTML(html: html, encoding: .windowsCP1251) {
            for newsNavigation in doc.css("div[class='next-prev']") {
                //Previous news
                var prevLoc = newsNavigation.at_css("span[class='next-prev__prev'] > a")
                if prevLoc != nil {
                    let prevNewsString = "https://www.hl-inside.ru" + (prevLoc?["href"]!)!
                    prevNews = URL(string: prevNewsString) ?? URL(string:"https://www.hl-inside.ru/fock")
                } else {
                    prevNews = URL(string: "https://www.hl-inside.ru/")
                }
                //Next news
                var nextLoc = newsNavigation.at_css("span[class='next-prev__next'] > a")
                
                if nextLoc != nil {
                    let nextNewsString = "https://www.hl-inside.ru" + (nextLoc?["href"]!)!
                    nextNews = URL(string: nextNewsString)
                } else {
                    nextNews = URL(string: "https://www.hl-inside.ru/")
                }
                
            }
        }
        return (prevNews!, nextNews!)
    }
    
}
