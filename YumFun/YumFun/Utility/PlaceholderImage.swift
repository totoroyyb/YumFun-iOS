//
//  PlaceholderImage.swift
//  YumFun
//
//  Created by Failury on 3/3/21.
//

import Foundation
import UIKit
class PlaceholderImage{
    static func imageWith(name: String?) -> UIImage? {
            let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            let nameLabel = UILabel(frame: frame)
            nameLabel.textAlignment = .center
            nameLabel.backgroundColor = .lightGray
            nameLabel.textColor = .white
            nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
            var initials = ""
            if let initialsArray = name?.components(separatedBy: " ") {
                if let firstWord = initialsArray.first {
                    if let firstLetter = firstWord.first {
                        initials += String(firstLetter).capitalized }
                }
                if initialsArray.count > 1, let lastWord = initialsArray.last {
                    if let lastLetter = lastWord.first { initials += String(lastLetter).capitalized
                    }
                }
            } else {
                return nil
            }
            nameLabel.text = initials
            UIGraphicsBeginImageContext(frame.size)
            if let currentContext = UIGraphicsGetCurrentContext() {
                nameLabel.layer.render(in: currentContext)
                let nameImage = UIGraphicsGetImageFromCurrentImageContext()
                return nameImage
            }
            return nil
        }
}
