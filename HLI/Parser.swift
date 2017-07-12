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
  
    func parseNews() -> [News] {
        
        var news = [News]()
        
        //FIXME: Make dictionary for title
        var title: String?
        var newsURL: URL?
        var date: String?
        var author: String?
        //FIXME: Make dictionary for tags
        var tags = [String?]()
        var tagsURL = [URL?]()
        var comments: String?
        var body = [Body]()
        
        if let doc = HTML(html: html, encoding: .windowsCP1251) {
            
            for newsItem in doc.css("div[class='block block_type_news']") {
                
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
                var tagsInItem = [String]()
                for tag in newsItem.css("p[class='news__tags'] > a") {
                    tagsInItem.append(tag.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                }
                tags = tagsInItem
                
                //Tags URL
                var tagsURLInItem = [URL]()
                for url in newsItem.css("p[class='news__tags'] > a") {
                    tagsURLInItem.append(URL(string: url["href"]!)!)
                }
                tagsURL = tagsURLInItem
                
                //Comments
                comments = newsItem.at_css("p[class='news__comments']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Body
                for bodyItem in newsItem.css("div[class^='block-body']") {
                    var bodyString = bodyItem.innerHTML!

//                    print(newsBodyString)
                    
                    //Strong
                    for strong in bodyItem.css("strong") {
                        let strongText = strong.text!
                        let range = bodyString.localizedStandardRange(of: strong.toHTML!)
//                        print("Range of strong is: \(String(describing: range))")
                        body.append(Body(type: Body.DataType.strong, data: strongText, range: range!))
                    }
                    
                    //Image in link
                    for img in bodyItem.css("a > img") {
                        let imageURLString = "https://www.hl-inside.ru" + (img["src"])!
                        //                        DispatchQueue.global(qos: .userInitiated).async {
                        //
                        //                            let imageView = UIImageView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:200))
                        //                            imageView.center = self.view.center
                        //
                        //                            // When from background thread, UI needs to be updated on main_queue
                        //                            DispatchQueue.main.async {
                        //                                imageView.sd_setImage(with: URL(string: imageURLString))
                        //                                imageView.contentMode = UIViewContentMode.scaleAspectFit
                        //                                self.view.addSubview(imageView)
                        //                            }
                        //                        }
                        let range = bodyString.localizedStandardRange(of: img.toHTML!)
//                        print("Range of image in link is: \(String(describing: range))")
                        body.append(Body(type: Body.DataType.image, data: imageURLString, range: range!))
                    }
                    
                    //Image in paragraph
                    for img in bodyItem.css("p > img") {
                        let imageURLString = "https://www.hl-inside.ru" + (img["src"])!
                        let range = bodyString.localizedStandardRange(of: img.toHTML!)
//                        print("Range of image in paragraph is: \(String(describing: range))")
                        body.append(Body(type: Body.DataType.image, data: imageURLString, range: range!))
                    }
                    
                    //Unordered list
                    for ul in bodyItem.css("ul > li") {
                        let range = bodyString.localizedStandardRange(of: ul.toHTML!)
//                        print("Range of unordered list is: \(String(describing: range))")
                        let listItem = "\u{25CF} " + ul.text!
                        body.append(Body(type: Body.DataType.unorderedList, data: listItem, range: range!))
                    }
                    
                    //Ordered list
                    var listItemNumber = 1
                    for ol in bodyItem.css("ol > li") {
                        let listItem = String(listItemNumber) + ol.text!
                        let range = bodyString.localizedStandardRange(of: ol.toHTML!)
//                        print("Range of ordered list is: \(String(describing: range))")
                        body.append(Body(type: Body.DataType.orderedList, data: listItem, range: range!))
                        listItemNumber += 1
                    }
                    
                    //Video
                    for video in bodyItem.css("a[class*='video']") {
                        let range = bodyString.localizedStandardRange(of: video.toHTML!)
//                        print("Range of video is: \(String(describing: range))")
                    }
                    
                    //Paragraph
                    for paragraph in bodyItem.css("p") {
                        var paragraphText = paragraph.text!
                        let range = bodyString.localizedStandardRange(of: paragraph.toHTML!)
//                        print(paragraphText)
//                        print(paragraph.toHTML!)
//                        print("Range of paragraph is: \(String(describing: range))")
                        body.append(Body(type: Body.DataType.paragraph, data: paragraphText, range: range!))
                    }
                    //Blockquote
                    for blockquote in bodyItem.css("blockquote") {
                        let blockquoteText = blockquote.text!
                        let range = bodyString.localizedStandardRange(of: blockquote.toHTML!)
//                        print("Range of blockquote is: \(String(describing: range))")
                        body.append(Body(type: Body.DataType.blockquote, data: blockquoteText, range: range!))
                        
                    }
//                    print(body)
//                    newsBodyString = newsBodyString.replacingOccurrences(of: "<br>", with: "\n")
                    body = body.sorted(by: { (first:Body, last:Body) -> Bool in
                        return first.range.lowerBound < last.range.upperBound
                    })
//                    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                    print(body)
                    //print(body.distance(from: (body.startIndex), to: (body.endIndex)))
                }
                //FIXME: Fix body type
                news.append(News(newsURL: newsURL!, title: title!, date: date!, author: author!, tags: tags as! [String], tagsURL: tagsURL as! [URL], comments: comments!, body: body))
            }
        }
        return news
    }
    
    func parseComment() -> [Comment] {
        
        var comments = [Comment]()
        
        var name: String?
        var date: String?
        var text: String?
        var image: String?
        //            var quote: String?
        
        if let doc = HTML(html: html, encoding: .windowsCP1251) {
            
            for commentItem in doc.css("div[itemscope='itemscope']") {
                
                //Name
                name = commentItem.at_css("div[class='comment__name']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Comment date
                date = commentItem.at_css("time[class='comment__date']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Text
                text = commentItem.at_css("div[class='comment__text']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Image
                var imageLoc = commentItem.at_css("div[class='comment__steam'] > a > img")
                image = imageLoc?["src"] ?? ""
                
                //Comment quote
                comments.append(Comment(name: name!, date: date!, text: text!, image: image, commentQuote: ""))
            }
        }
        return comments
    }
    
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
                    //                print(prevNews)
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
