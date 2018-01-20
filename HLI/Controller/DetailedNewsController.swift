//
//  DetailedNewsController.swift
//  HLI
//
//  Created by Lena on 22.06.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import UIKit
import Foundation
import Kanna
import Alamofire
import SDWebImage
import ActiveLabel


class DetailedNewsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var detailedNewsTable: UITableView!
    @IBOutlet weak var commentView: UIView!
//    @IBOutlet weak var sendCommentBtn: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    
    var emojisView: EmojisView?
    var pageURL: URL?
    var news = [News]()
    var comments = [Comment]()
    var formData = FormData()
    let emojisButton = UIButton()
    let sendCommentButton = UIButton()
    
    let date = Date()
    let calendar = Calendar.current
    var keyboardIsOpen = false
    var emojisViewIsOpen = false
    var sendCommentButtonWillShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Emojis view
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: 34.5, height: 30)

        emojisView = EmojisView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0), collectionViewLayout: layout)
        emojisView?.backgroundColor = UIColor.black
        emojisView?.layer.zPosition = CGFloat(MAXFLOAT)
        emojisView?.register(UINib(nibName: "EmojiCell", bundle: nil), forCellWithReuseIdentifier: "EmojiCell")
        emojisView?.delegate = self
        emojisView?.dataSource = self.emojisView
        
        //Emojis button
        emojisButton.setImage(#imageLiteral(resourceName: "emo_biggrin25"), for: .normal)
        emojisButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        emojisButton.frame = CGRect(x: CGFloat(commentTextField.frame.size.width - 30), y: CGFloat(5), width: 29, height: 25)
        emojisButton.addTarget(self, action: #selector(self.showEmojisView), for: .touchUpInside)
        commentTextField.rightView = emojisButton
        commentTextField.rightViewMode = .whileEditing
        
        //Send comment button
        sendCommentButton.setImage(#imageLiteral(resourceName: "send30"), for: .normal)
        sendCommentButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        sendCommentButton.frame = CGRect(x: CGFloat(333), y: CGFloat(10), width: 35, height: 30)
        sendCommentButton.addTarget(self, action: #selector(self.sendComment), for: .touchUpInside)
        
        //Table
        detailedNewsTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        detailedNewsTable.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        detailedNewsTable.delegate = self
        detailedNewsTable.dataSource = self
        self.parse()
        
        //Text field
        commentTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetailedNewsController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailedNewsController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailedNewsController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func parse() {
        Alamofire.request(pageURL!).responseString { response in
            let html = response.result.value!
            let parser = Parser(pageURL: self.pageURL!, html: html)
            
            self.news = parser.parseNews()
            self.comments = parser.parseComment()
            self.formData = parser.parseForm()
            
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
    
        func sendComment(sender: UIButton!) {
    //        let parameters = [
    //            "name": "Swift_test",
    //            "email": "",
    //            "textdata": self.commentView.textView.text!,
    //            "date": formData.date,
    //            "wallace": formData.wallace,
    //            "breen": formData.breen
    //        ]
    //        //Alamofire.request(pageURL!, method: .post, parameters: parameters, encoding:  URLEncoding.default, headers: nil)
    //        self.detailedNewsTable.reloadData()
        }
    
    @IBAction func showEmojisView(_ sender: UIButton) {
        if emojisViewIsOpen == false {
            let windowCount = UIApplication.shared.windows.count
            UIApplication.shared.windows[windowCount-1].addSubview(emojisView!)
            self.emojisButton.setImage(#imageLiteral(resourceName: "keyboard-25"), for: .normal)
            emojisViewIsOpen = true
        } else {
            self.emojisButton.setImage(#imageLiteral(resourceName: "emo_biggrin25"), for: .normal)
            self.emojisView?.removeFromSuperview()
            emojisViewIsOpen = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = emojisView?.emoji.emojis[indexPath.row]
        commentTextField.text = "\(commentTextField.text!) \((emoji?.data)!) "
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
                self.detailedNewsTable.frame.origin.y += keyboardSize.height
                self.emojisView?.frame = CGRect(x: 0, y: self.view.frame.size.height-keyboardSize.height, width: self.view.frame.size.width, height: keyboardSize.height)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
                self.detailedNewsTable.frame.origin.y = 0
                self.commentView.willRemoveSubview(sendCommentButton)
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // UITextField Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        print("TextField did begin editing method called")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("TextField did end editing method called")
        if sendCommentButtonWillShow == true {
            self.sendCommentButton.fadeOut()
            sendCommentButton.removeFromSuperview()
            self.commentTextField.sizeIncrease()
            sendCommentButtonWillShow = false
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        print("TextField should begin editing method called")
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        print("TextField should clear method called")
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        print("TextField should end editing method called")
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        print("While entering the characters this method gets called")
        if sendCommentButtonWillShow == false {
            self.commentTextField.sizeReduce()
            self.commentView.addSubview(sendCommentButton)
            self.sendCommentButton.fadeIn()
            sendCommentButtonWillShow = true
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        print("TextField should return method called")
        textField.resignFirstResponder()
        return true
    }
}
