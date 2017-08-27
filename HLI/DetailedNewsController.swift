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
    var pageURL: URL?
    var news = [News]()
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            //           print("\(response.result.isSuccess)")
            let html = response.result.value!
            
            let newsTest = Parser(pageURL: self.pageURL!, html: html)
            
            self.news = newsTest.parseNews()
            self.comments = newsTest.parseComment()
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
        
        if indexPath.section == 0 {
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
                
                removeBobySubviews(cell: cell)
                makeBobySubviews(body: news.body, cell: cell)
                cell.body.text = ""
                
                cell.body.sizeToFit()
            }
            cell.selectionStyle = .none

            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            if comments.count > indexPath.row {
                let comment = comments[indexPath.row]
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
//        let font = UIFont(name: "Helvetica", size: 17.0)
        
        if indexPath.section == 0 {
            return makeBodyHeight()
        } else if indexPath.section == 1 {
//            let comment = comments[indexPath.row]
            return 100
                //+ comment.text.height(withConstrainedWidth: UIScreen.main.bounds.size.width, font: font!)
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
