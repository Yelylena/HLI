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
    var commentView: CommentView!
    var pageURL: URL?
    var news = [News]()
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentView = CommentView(frame: CGRect.zero)
        commentView.backgroundColor = UIColor.AppColors.BgDark
        self.view.addSubview(commentView)
        
        // AutoLayout
        commentView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.init(top: UIScreen.main.bounds.height - 60.0, left: 0, bottom: 0, right: 0))

        
        detailedNewsTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        detailedNewsTable.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        detailedNewsTable.delegate = self
        detailedNewsTable.dataSource = self
        self.parse()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parse() {
        Alamofire.request(pageURL!).responseString { response in
            let html = response.result.value!
            let parser = Parser(pageURL: self.pageURL!, html: html)
            
            self.news = parser.parseNews()
            self.comments = parser.parseComment()
            
            DispatchQueue.main.async {
                self.detailedNewsTable.reloadData()
            }
        }
    }

    // MARK: - Table view data source    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return news.count
        case 1:
            return comments.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
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
                
                cell.comments.text = ""
                
                //MARK: Body
                cell.body.enabledTypes = [.mention, .hashtag, .url]
                
                removeSubviews(cell: cell)
                getSubviews(body: news.body, cell: cell)
            }
            cell.selectionStyle = .none
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            if comments.count > indexPath.row {
                let comment = comments[indexPath.row]
                cell.name.text = comment.name
                cell.date.text = comment.date
                cell.commentImage.sd_setImage(with: URL(string: comment.image!))
                removeSubviews(cell: cell)
                getSubviews(body: comment.body, cell: cell)
            }
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return getHeight()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return String()
        case 1:
            return "Comments"
        default:
            return String()
        }
    }
}
