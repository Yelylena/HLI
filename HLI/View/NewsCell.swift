//
//  HLINewsCell.swift
//  HLI
//
//  Created by Lena on 16.06.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import UIKit
//import ActiveLabel

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var tags: UILabel! //it was ActiveLabel
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var body: UILabel! //it was ActiveLabel
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
