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
    //MARK: Get range
    
    //MARK: Parse element
    
    //MARK: Parse elements in news body
    func parseBody(element: XMLElement, selector: String) -> [Body] {
        var body = [Body]()
        
        for bodyItem in element.css(selector) {
//            let bodyString = bodyItem.innerHTML!
            
            //MARK: Strong
            
            //MARK: Image
            
            //MARK: Unordered list
            
            //MARK: Ordered list

            //MARK: Video
            
            //MARK: Paragraph

            //MARK: Blockquote

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
    func parseOrdinaryText(body: [Body], bodyString: String) -> [Body] {
        
        func getOrdinaryText(start: String.Index, end: String.Index) -> Body {
            let text = bodyString.substring(with: start..<end)
            let range = bodyString.localizedStandardRange(of: text)
            return Body(type: Body.DataType.paragraph, data: text, range: range!)
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
            
            for idx in 1..<body.count {
                let item = body[idx]
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
    //FIXME: Fix removing
    func removeDuplicateElements(body: [Body]) -> [Body] {
        var body = body
        var idx = 0
        for item in body {
            print("Item \(idx)(\(item.type)): low \(item.range.lowerBound), upp \(item.range.upperBound)")
            
            idx += 1
        }
        
//        var newBody = [Body]()
//        var prevItem = body[0]
//
//        for idx in 0..<body.count {
//            let item = body[idx]
//
//            if item.range.lowerBound != prevItem.range.lowerBound {
//                newBody.append(prevItem)
//            }
//            prevItem = item
//        }
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
//                        var imageURLString = String()
                        let width = image["width"]
                        let height = image["height"]
//                        if imageURL?[1] == "/" {
//                            imageURLString = "https:" + imageURL!
//                        } else {
//                            imageURLString = "https://www.hl-inside.ru" + imageURL!
//                        }
                        let imageURLString = ((imageURL?[1] == "/") ? "https:" : "https://www.hl-inside.ru") + imageURL!
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
                            let range = bodyString.localizedStandardRange(of: li.toHTML!)
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
                    body = self.parseOrdinaryText(body: body, bodyString: bodyString)
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
                for bodyItem in commentItem.css("div[class='comment__text']") {
                    let bodyString = bodyItem.innerHTML!
                    print(bodyString)
                    
                    //Image
                    for image in bodyItem.css("img") {
                        let imageURL = image["src"]
                        var imageURLString = String()
                        if imageURL?[1] == "/" {
                            imageURLString = "https:" + imageURL!
                        } else {
                            imageURLString = "https://www.hl-inside.ru" + imageURL!
                        }
                        let range = bodyString.localizedStandardRange(of: image.toHTML!)
                        
                        let imagePNG = ImagePNG(url: imageURLString, width: 28, height: 25)
                        body.append(Body(type: Body.DataType.imagePNG, data: imagePNG, range: range!))
                    }
                    //MARK: Blockquote
                    for blockquote in bodyItem.css("div[class='comment__quote']") {
                        let blockquoteText = blockquote.text!
                        let range = bodyString.localizedStandardRange(of: blockquote.toHTML!)
                        body.append(Body(type: Body.DataType.blockquote, data: blockquoteText, range: range!))
                    }
                    body = self.parseOrdinaryText(body: body, bodyString: bodyString)
                    body = self.removeDuplicateElements(body: body)
                }
                
                comments.append(Comment(name: name!, date: date!, body: body, image: image))
            }
        }
        return comments
    }
    
    //MARK: Form
    func parseForm() -> FormData {
        var formData = FormData(date: String(), wallace: String(), breen: String())
        if let doc = HTML(html: html, encoding: .windowsCP1251) {
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
    func parseNavigation() -> (prevNews: URL?, nextNews: URL?) {
        
        var prevNews: URL?
        var nextNews: URL?
        
        if let doc = HTML(html: html, encoding: .windowsCP1251) {
            for newsNavigation in doc.css("div[class='next-prev']") {
                
                //Previous news
                let prevLoc = newsNavigation.at_css("span[class='next-prev__prev'] > a")
                prevNews = URL(string: "https://www.hl-inside.ru" + ((prevLoc != nil) ? (prevLoc?["href"])! : "/"))
                
                //Next news
                var nextLoc = newsNavigation.at_css("span[class='next-prev__next'] > a")
                nextNews = URL(string: "https://www.hl-inside.ru" + ((nextLoc != nil) ? (nextLoc?["href"])! : "/"))
            }
        }
        return (prevNews!, nextNews!)
    }
}
