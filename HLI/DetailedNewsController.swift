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
//            var email: String?
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
                newsDate = newsDateLoc?["data-date"]
                
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
                newsBody = newsItem.at_css("div[class='block-body']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                
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
                if imageLoc != nil {
                    commentImage = imageLoc?["src"]
                } else {
                    commentImage = ""
                }
                //Comment quote
                self.commentItems.append(Comment(name: commentName!, date: commentDate!, text: commentText!, image: commentImage, commentQuote: ""))
            }
            print("\(self.commentItems)")
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
                cell.tags.text = news.tags.description
                cell.comments.text = ""
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
