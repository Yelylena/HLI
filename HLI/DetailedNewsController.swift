//
//  DetailedNewsController.swift
//  HLI
//
//  Created by Lena on 22.06.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import UIKit
import Kanna
import Alamofire
import SDWebImage
import ActiveLabel

class DetailedNewsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var detailedNewsTable: UITableView!
    var newsURL: URL?
    var newsItems = [News]()
    var commentItems = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailedNewsTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        detailedNewsTable.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        detailedNewsTable.delegate = self
        detailedNewsTable.dataSource = self
        self.parseHTML()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func parseHTML() -> Void {
        Alamofire.request(newsURL!).responseString { response in
            if let html = response.result.value,
               let doc = HTML(html: html, encoding: .windowsCP1251) {
            
            //News
            //FIXME: Make dictionary for title
            var newsTitle: String?
            var newsURL: URL?
            var newsDate: String?
            var newsAuthor: String?
            //FIXME: Make dictionary for tags
            var newsTags = [String?]()
            var tagsURL = [URL?]()
            var newsComments: String?
            var newsBody: String?
            
            //Comment
            var commentName: String?
            var commentDate: String?
            var commentText: String?
            var commentImage: String?
//            var commentQuote: String?
            
            for newsItem in doc.css("div[class='block block_type_news']") {

                //Title
                newsTitle = newsItem.at_css("a[class='b-link']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //News URL
                var newsURLLoc = newsItem.at_css("h2[class='news-title'] > a")
                newsURL = URL(string: (newsURLLoc?["href"]!)!)
                
                //News date
                var newsDateLoc = newsItem.at_css("p[class='post-date']")
                newsDate = newsDateLoc?["data-date"] ?? String()
                
                //Author
                newsAuthor = newsItem.at_css("p[class='news__author']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Tags
                var tagsInItem = [String]()
                for tag in newsItem.css("p[class='news__tags'] > a") {
                    tagsInItem.append(tag.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                }
                newsTags = tagsInItem
                
                //Tags URL
                var tagsURLInItem = [URL]()
                for url in newsItem.css("p[class='news__tags'] > a") {
                    tagsURLInItem.append(URL(string: url["href"]!)!)
                }
                tagsURL = tagsURLInItem
                
                //Comments
                newsComments = newsItem.at_css("p[class='news__comments']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Body
                for body in newsItem.css("div[class^='block-body']") {
                    newsBody = body.innerHTML!

                    print(newsBody!)
                    
                    //Strong
                    for strong in body.css("strong") {
                        let strongText = strong.text!
                        print(strongText)
                        
                        let range = newsBody?.range(of: strong.toHTML!)
                        print("Range of strong is: \(String(describing: range))")
                    }
                    
                    //Image
                    for img in body.css("a > img") {
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
                        print(imageURLString)
                        let range = newsBody?.range(of: img.toHTML!)
                        print("Range of image is: \(String(describing: range))")
                    }
                    
                    //Unordered list
                    var unorderedList = [String]()
                    for ul in body.css("ul > li") {
                        let range = newsBody?.range(of: ul.toHTML!)
                        print("Range of unordered list is: \(String(describing: range))")
                        let listItem = "\u{25CF} " + ul.text!
                        unorderedList.append(listItem)
                    }
                    print(unorderedList)
                    
                    //Ordered list
                    var orderedList = [String]()
                    var listItemNumber = 1
                    for ol in body.css("ol > li") {
                        let listItem = String(listItemNumber) + ol.text!
                        let range = newsBody?.range(of: ol.toHTML!)
                        print("Range of ordered list is: \(String(describing: range))")
                        orderedList.append(listItem)
                        listItemNumber += 1
                    }
                    print(orderedList)
                    
                    
                    //Video
                    for video in body.css("a[class*='video']") {
                        
                        let range = newsBody?.range(of: video.toHTML!)
                        print("Range of video is: \(String(describing: range))")
                    }
                    
                    //Paragraph
                    for paragraph in body.css("p") {
                        let paragraphText = paragraph.text!
                        
                        let range = newsBody?.range(of: paragraph.toHTML!)
                        print("Range of paragraph is: \(String(describing: range))")
                    }
                    
                    newsBody = newsBody?.replacingOccurrences(of: "<br>", with: "\n")
 
                    print(newsBody?.distance(from: (newsBody?.startIndex)!, to: (newsBody?.endIndex)!) ?? 0)
                }
                
                self.newsItems.append(News(newsURL: newsURL!, title: newsTitle!, date: newsDate!, author: newsAuthor!, tags: newsTags as! [String], tagsURL: tagsURL as! [URL], comments: newsComments!, body: newsBody!))
                
            }
            
            for commentItem in doc.css("div[itemscope='itemscope']") {
                
                //Name
                commentName = commentItem.at_css("div[class='comment__name']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Comment date
                commentDate = commentItem.at_css("time[class='comment__date']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Text
                commentText = commentItem.at_css("div[class='comment__text']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Image
                var imageLoc = commentItem.at_css("div[class='comment__steam'] > a > img")
                commentImage = imageLoc?["src"] ?? ""

                //Comment quote
                self.commentItems.append(Comment(name: commentName!, date: commentDate!, text: commentText!, image: commentImage, commentQuote: ""))
            }
 //           print("\(self.commentItems)")
        }
        DispatchQueue.main.async {
            self.detailedNewsTable.reloadData()
        }
    }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return newsItems.count
        case 1:
            return commentItems.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            if newsItems.count > indexPath.row {
                let news = newsItems[indexPath.row]
                
                cell.title.text = news.title
                cell.date.text = news.date
                cell.author.text = news.author
                //Tags
                var temp = ""
                for tag in news.tags {
                    temp += "\(tag) "
                }
                cell.tags.enabledTypes = [.mention, .hashtag, .url]
                cell.tags.text = temp
                
                cell.comments.text = ""
                cell.body.enabledTypes = [.mention, .hashtag, .url]
                cell.body.text = news.body
                cell.body.sizeToFit()
            }
            cell.isUserInteractionEnabled = false
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            if commentItems.count > indexPath.row {
                let comment = commentItems[indexPath.row]
                cell.name.text = comment.name
                cell.date.text = comment.date
                cell.commentImage.sd_setImage(with: URL(string: comment.image!))
                cell.commentText.text = comment.text
                cell.commentText.sizeToFit()
            }
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let font = UIFont(name: "Helvetica", size: 17.0)
        
        if indexPath.section == 0 {
            let news = newsItems[indexPath.row]
            //FIXME: Recount height for cell
            return 200 + news.body.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: font!)
        } else if indexPath.section == 1 {
            let comment = commentItems[indexPath.row]
            return 100 + comment.text.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: font!)
        }
       return 0
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "Comments"
        default:
            return ""
        }
    }
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        <#code#>
    //    }
}
