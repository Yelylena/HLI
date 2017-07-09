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
import ActiveLabel

class NewsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var newsTable: UITableView!
    @IBOutlet weak var PrevButton: UIButton!
    
    var news = [News]()
    private var newsURL = URL(string: "https://www.hl-inside.ru/")
    private var prevNews: URL?
    private var nextNews: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        newsTable.delegate = self
        newsTable.dataSource = self
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
                
                var title: String?
                
                var date: String?
                var author: String?
                var tags = [String?]()
                var tagsURL = [URL?]()
                var comments: String?
                var body: String?
                
                
                for newsItem in doc.css("div[class^='block block_type_news']") {
                    
                    //Title
                    title = newsItem.at_css("a[class^='b-link']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    //NewsURL
                    var newsURLLoc = newsItem.at_css("h2[class^='news-title'] > a")
                    let newsURLString = "https://www.hl-inside.ru/" + (newsURLLoc?["href"]!)!
                    self.newsURL = URL(string: newsURLString)
                    
                    //Date
                    var dateLoc = newsItem.at_css("p[class^='post-date']")
                    date = dateLoc?["data-date"]
                    
                    //Author
                    author = newsItem.at_css("p[class^='news__author']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    //Tags
                    var tagsInItem = [String]()
                    for tag in newsItem.css("p[class^='news__tags'] > a") {
                        tagsInItem.append(tag.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                    }
                    tags = tagsInItem
                    
                    //TagsURL
                    var tagsURLInItem = [URL]()
                    for url in newsItem.css("p[class^='news__tags'] > a") {
                        tagsURLInItem.append(URL(string: url["href"]!)!)
                    }
                    tagsURL = tagsURLInItem
                    
                    //Comments
                    comments = newsItem.at_css("p[class^='news__comments']")?.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    //Body
                    body = newsItem.at_css("div[class^='block-body']")?.text!
                    
                    self.news.append(News(newsURL: self.newsURL!, title: title!, date: date!, author: author!, tags: tags as! [String], tagsURL: tagsURL as! [URL], comments: comments!, body: body!))
                    
                }
                
                for newsNavigation in doc.css("div[class='next-prev']") {
                    //Previous news
                    var prevLoc = newsNavigation.at_css("span[class='next-prev__prev'] > a")
                    let prevNewsString = "https://www.hl-inside.ru" + (prevLoc?["href"]!)!
                    self.prevNews = URL(string: prevNewsString)
                    //                print(prevNews)
                    
                    //Next news
                    var nextLoc = newsNavigation.at_css("span[class='next-prev__next'] > a")

                    if nextLoc != nil {
                        var nextNewsString = "https://www.hl-inside.ru" + (nextLoc?["href"]!)!
                        self.nextNews = URL(string: nextNewsString)
                    } else {
                        self.nextNews = URL(string: "https://www.hl-inside.ru/")
                    }
                }
            }
            DispatchQueue.main.async {
                self.newsTable.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
        if news.count > indexPath.row {
            let news = self.news[indexPath.row]
            
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

            cell.comments.text = news.comments
            cell.body.enabledTypes = [.mention, .hashtag, .url]
            cell.body.text = news.body
            cell.body.sizeToFit()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let news = self.news[indexPath.row]
        let bodyFont = UIFont(name: "Helvetica", size: 17.0)
        
        //FIXME: Recount height for cell
        return 200 + news.body.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: bodyFont!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "DetailedNewsSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailedNewsSegue" {
            if let viewController = segue.destination as? DetailedNewsController {
                if let indexPath = newsTable.indexPathForSelectedRow {
                    let news = self.news[indexPath.row]
                    viewController.newsURL = news.newsURL as URL!
                
                }
            }
        }
    }
    
    @IBAction func showPrevNews(_ sender: UIButton) {
        newsURL = prevNews
        print("\(String(describing: newsURL))")
        news = [News]()
        self.parseHTML()
        self.newsTable.reloadData()
    }
    
    @IBAction func showNextNews(_ sender: UIButton) {
        newsURL = nextNews
        print("\(String(describing: newsURL))")
        news = [News]()
        self.parseHTML()
        self.newsTable.reloadData()
    }
}


