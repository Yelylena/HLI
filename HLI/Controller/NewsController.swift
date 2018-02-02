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
    @IBOutlet weak var navigationView: UIView!
    
    var prevNewsButton = UIButton()
    var nextNewsButton = UIButton()
    
    var news = [News]()
    private var mainPageURL = URL(string: "https://www.hl-inside.ru/")
    private var pageURL = URL(string: "https://www.hl-inside.ru/")
    private var prevNews: URL?
    private var nextNews: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Table
        newsTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        newsTable.delegate = self
        newsTable.dataSource = self
        self.parse()
        
        //Navigation buttons
        nextNewsButton.setImage(#imageLiteral(resourceName: "back30"), for: .normal)
        nextNewsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        nextNewsButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width / 2, height: 50)
        nextNewsButton.addTarget(self, action: #selector(self.showNextNews), for: .touchUpInside)
        
        prevNewsButton.setImage(#imageLiteral(resourceName: "forward30"), for: .normal)
        prevNewsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        prevNewsButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50)
        prevNewsButton.addTarget(self, action: #selector(self.showPrevNews), for: .touchUpInside)
        self.navigationView.addSubview(prevNewsButton)
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
            let html = response.result.value!
            let parser = Parser(pageURL: self.pageURL!, html: html)

            self.news = parser.parseNews()
            self.nextNews = parser.parseNavigation().nextNews
            self.prevNews = parser.parseNavigation().prevNews
            
            DispatchQueue.main.async {
                self.newsTable.reloadData()
            }
        }
    }
    
    @IBAction func showPrevNews(_ sender: UIButton) {
        pageURL = prevNews
        news = [News]()
        self.parse()
        self.newsTable.reloadData()
        self.addNextNewsButton()
    }
    
    @IBAction func showNextNews(_ sender: UIButton) {
        pageURL = nextNews
        news = [News]()
        self.parse()
        self.newsTable.reloadData()
        self.removeNextNewsButton()
    }
    
    func addNextNewsButton() {
        if pageURL != mainPageURL {
            self.navigationView.addSubview(nextNewsButton)
            prevNewsButton.frame = CGRect(x: self.view.frame.size.width / 2, y: 0, width: self.view.frame.size.width / 2, height: 50)
//            self.view.updateConstraintsIfNeeded()
        }
    }
    func removeNextNewsButton() {
        if pageURL == mainPageURL {
            nextNewsButton.removeFromSuperview()
            prevNewsButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50)
        }
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
            var tags = ""
            for tag in news.tags {
                tags += "\(tag) "
            }
            cell.tags.enabledTypes = [.mention, .hashtag, .url]
            cell.tags.text = tags

            cell.comments.text = news.comments
            
            //MARK: Body
            cell.body.enabledTypes = [.mention, .hashtag, .url]
            
            removeSubviews(cell: cell) // remove old subviews
            getSubviews(body: news.body, cell: cell) // create new subviews
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getHeight()
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


