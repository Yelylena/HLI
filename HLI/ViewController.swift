//
//  ViewController.swift
//  HLI
//
//  Created by Lena on 13.06.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import UIKit
import Kanna
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var newsTable: UITableView!
    
    var newsItems = [HLINews]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        newsTable.delegate = self
        newsTable.dataSource = self
        self.scrape()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrape() -> Void {
        Alamofire.request("https://www.hl-inside.ru/").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseHTML(html: html)
            }
            
        }
    }
    
    func parseHTML(html: String) -> Void {
        if let doc = HTML(html: html, encoding: .windowsCP1251) {
            
            var title: String?
            var newsURL: URL?
            var date: String?
            var author: String?
            var tags = [String?]()
            var tagsURL = [URL?]()
            var comments: String?
            var body: String?
            
            for item in doc.css("div[class^='block block_type_news']") {
                
                //Title
                title = item.at_css("a[class^='b-link']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //NewsURL
                var newsURLLoc = item.at_css("h2[class^='news-title'] > a")
                newsURL = URL(string: (newsURLLoc?["href"]!)!)
                
                //Date
                date = item.at_css("p[class^='post-date']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Author
                author = item.at_css("p[class^='news__author']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Tags
                var tagsInItem = [String]()
                for tag in item.css("p[class^='news__tags'] > a") {
                    tagsInItem.append(tag.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                }
                tags = tagsInItem
                
                //TagsURL
                var tagsURLInItem = [URL]()
                for url in item.css("p[class^='news__tags'] > a") {
                    tagsURLInItem.append(URL(string: url["href"]!)!)
                }
                tagsURL = tagsURLInItem
                
                //Comments
                comments = item.at_css("p[class^='news__comments']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                //Body
                body = item.at_css("div[class^='block-body']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                
                newsItems.append(HLINews(newsURL: newsURL!, title: title!, date: date!, author: author!, tags: tags as! [String], tagsURL: tagsURL as! [URL], comments: comments!, body: body!))
                
            }
            print("\(newsItems)")
        }
        DispatchQueue.main.async {
            self.newsTable.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
        if newsItems.count > indexPath.row {
            let news = newsItems[indexPath.row]
            
            cell.title.text = news.title
            cell.date.text = news.date
            cell.author.text = news.author
            cell.tags.text = news.tags.description
            cell.comments.text = news.comments
            cell.body.text = news.body
            cell.body.sizeToFit()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let news = newsItems[indexPath.row]
        let bodyFont = UIFont(name: "Helvetica", size: 17.0)
        return 200 + news.body.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: bodyFont!)
    }
}

