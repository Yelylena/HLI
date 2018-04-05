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
//import ActiveLabel

class NewsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var newsTable: UITableView!
    @IBOutlet weak var navigationView: UIView!
    
    var mainPageButton = UIButton()
    var prevNewsButton = UIButton()
    var nextNewsButton = UIButton()
    
    var news = [News]()
    private var mainPageURL = URL(string: "https://www.hl-inside.ru/")
    private var currentPageURL = URL(string: "https://www.hl-inside.ru/")
    private var prevNewsURL: URL?
    private var nextNewsURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Table
        newsTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        newsTable.delegate = self
        newsTable.dataSource = self
        self.parse()
        
        //Navigation buttons
        mainPageButton.setImage(#imageLiteral(resourceName: "screen"), for: .normal)
        mainPageButton.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0)
        mainPageButton.frame = CGRect(x: self.view.frame.size.width / 2 - 15, y: 0, width: 30, height: 50)
        mainPageButton.addTarget(self, action: #selector(self.returnToMainPage), for: .touchUpInside)
        navigationView.addSubview(mainPageButton)
        
        nextNewsButton.setImage(#imageLiteral(resourceName: "back30"), for: .normal)
        nextNewsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        nextNewsButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width / 2 - 15, height: 50)
        nextNewsButton.addTarget(self, action: #selector(self.showNextNews), for: .touchUpInside)
        nextNewsButton.isEnabled = false
        navigationView.addSubview(nextNewsButton)
        
        
        prevNewsButton.setImage(#imageLiteral(resourceName: "forward30"), for: .normal)
        prevNewsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        prevNewsButton.frame = CGRect(x: self.view.frame.size.width / 2 + 15, y: 0, width: self.view.frame.size.width / 2 - 15, height: 50)
        prevNewsButton.addTarget(self, action: #selector(self.showPrevNews), for: .touchUpInside)
        navigationView.addSubview(prevNewsButton)
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
        Alamofire.request(currentPageURL!).responseString { response in
            let html = response.result.value!
            let parser = Parser(pageURL: self.currentPageURL!, html: html)

            self.news = parser.parseNews()
            self.nextNewsURL = parser.parseNavigation().nextNewsURL
            self.prevNewsURL = parser.parseNavigation().prevNewsURL
            
            DispatchQueue.main.async {
                self.newsTable.reloadData()
            }
        }
    }
    
    func parseAndReloadData(url: URL?) {
        currentPageURL = url
        news = [News]()
        self.parse()
        self.newsTable.reloadData()
    }
    
    func returnToMainPage(_ sender: UIButton) {
        self.parseAndReloadData(url: mainPageURL)
        self.nextNewsButton.isEnabled = false
    }
    
    func showPrevNews(_ sender: UIButton) {
        self.parseAndReloadData(url: prevNewsURL)
        self.nextNewsButton.isEnabled = true
    }
    
    func showNextNews(_ sender: UIButton) {
        self.parseAndReloadData(url: nextNewsURL)
        if currentPageURL == mainPageURL {
            self.nextNewsButton.isEnabled = false
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
            //cell.tags.enabledTypes = [.mention, .hashtag, .url]
            cell.tags.text = tags

            cell.comments.text = news.comments
            
            //MARK: Body
            //cell.body.enabledTypes = [.mention, .hashtag, .url]
            
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


