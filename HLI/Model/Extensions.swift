//
//  Extensions.swift
//  HLI
//
//  Created by Lena on 20.06.17.
//  Copyright © 2017 Lena. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}

//extension NSMutableAttributedString {
//    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
//        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
//        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin,], context: nil)
//        
//        return boundingBox.height
//    }
//}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[Range(start ..< end)]
    }
}

extension UIColor {
    struct AppColors {
        static let brand = #colorLiteral(red: 0.7607843137, green: 0.5764705882, blue: 0, alpha: 1)
        static let bg = #colorLiteral(red: 0.3176470588, green: 0.3176470588, blue: 0.3176470588, alpha: 1)
        static let bgDark = #colorLiteral(red: 0.1215686275, green: 0.1058823529, blue: 0.1058823529, alpha: 1)
        static let text = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        static let title = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        static let border = #colorLiteral(red: 0.8745098039, green: 0.8745098039, blue: 0.8745098039, alpha: 1)
    }
}
