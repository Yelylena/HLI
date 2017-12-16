//
//  EmojisView.swift
//  HLI
//
//  Created by Lena on 11.12.2017.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation
import UIKit

class EmojisView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var emoji = Emojis()
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoji.emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell",
                                                      for: indexPath) as! EmojiCell
        
        let emojis = self.emoji.emojis[indexPath.row]
        cell.emoji.image = emojis.image
        cell.backgroundColor = UIColor.black
        return cell
    }
}
