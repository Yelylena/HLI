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
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var news = [News]()
    private var  pageURL = URL(string: "https://www.hl-inside.ru/")
    private var prevNews: URL?
    private var nextNews: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        newsTable.delegate = self
        newsTable.dataSource = self
        self.parse()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = newsTable.indexPathForSelectedRow {
            newsTable.deselectRow(at: indexPath, animated: animated)
        }
    }

    func parse() {
        Alamofire.request(pageURL!).responseString { response in
 //           print("\(response.result.isSuccess)")
            let html = response.result.value!

            let newsTest = Parser(pageURL: self.pageURL!, html: html)

            self.news = newsTest.parseNews()
            self.nextNews = newsTest.parseNavigation().nextNews
            self.prevNews = newsTest.parseNavigation().prevNews
            DispatchQueue.main.async {
                self.newsTable.reloadData()
            }
        }
    }
    
    @IBAction func showPrevNews(_ sender: UIButton) {
        pageURL = prevNews
        print("\(String(describing: pageURL))")
        news = [News]()
        self.parse()
        self.newsTable.reloadData()
    }
    
    @IBAction func showNextNews(_ sender: UIButton) {
        pageURL = nextNews
        print("\(String(describing: pageURL))")
        news = [News]()
        self.parse()
        self.newsTable.reloadData()
    }
    
    // MARK: - Table view data source
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
            
            //MARK: Body
            cell.body.enabledTypes = [.mention, .hashtag, .url]
            
            removeBobySubviews(cell: cell)
            makeBobySubviews(body: news.body, cell: cell)

            cell.body.text = ""
 
            cell.body.sizeToFit()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return makeBodyHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailedNewsSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailedNewsSegue" {
            if let viewController = segue.destination as? DetailedNewsController {
                if let indexPath = newsTable.indexPathForSelectedRow {
                    let news = self.news[indexPath.row]
                    print(news.newsURL)
                    viewController.pageURL = news.newsURL as URL!
                
                }
            }
        }
    }
}


