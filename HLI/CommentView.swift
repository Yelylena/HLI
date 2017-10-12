//
//  CommentView.swift
//  HLI
//
//  Created by Lena on 12.10.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class CommentView: UIView {
    var shouldSetupConstraints = true
    
    var textView: UITextView!
    var sendButton: UIButton!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        textView = UITextView(frame: CGRect.zero)
        textView.backgroundColor = UIColor.AppColors.Text
        textView.autoSetDimensions(to: CGSize(width: 150.0, height: 30.0))
        
        self.addSubview(textView)
        
        sendButton = UIButton(frame: CGRect.zero)
        sendButton.backgroundColor = UIColor.AppColors.Brand
        sendButton.autoSetDimensions(to: CGSize(width: 50.0, height: 30.0))
        sendButton.setTitle("Send", for: .normal)
        
        self.addSubview(sendButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if(shouldSetupConstraints) {        
            
            let edgesInset: CGFloat = 15.0
            
            textView.autoPinEdge(toSuperviewEdge: .top, withInset: edgesInset)
            textView.autoPinEdge(toSuperviewEdge: .left, withInset: edgesInset)
            textView.autoPinEdge(toSuperviewEdge: .bottom, withInset: edgesInset)
            textView.autoPinEdge(.right, to: .left, of: sendButton, withOffset: edgesInset)
            
            sendButton.autoPinEdge(toSuperviewEdge: .top, withInset: edgesInset)
            sendButton.autoPinEdge(toSuperviewEdge: .right, withInset: edgesInset)
            sendButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: edgesInset)
            sendButton.autoPinEdge(.left, to: .right, of: textView, withOffset: edgesInset)
            
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
}
