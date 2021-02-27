//
//  DiscoverViewCell.swift
//  YumFun
//
//  Created by Xiyu Zhang on 2/20/21.
//

import UIKit

class DiscoverImageCell: UICollectionViewCell {
    @IBOutlet weak var descrip: UILabel!
    @IBOutlet weak var favor: UIButton!
    @IBOutlet weak var collect: UIButton!
    @IBOutlet weak var profileImage: CircularImageView!
    
    @IBOutlet weak var coverImage1: UIImageView!
    @IBOutlet weak var coverImage2: UIImageView!
    
    weak var delegate : DiscoverCellDelegate?
    var indexPath: IndexPath?
    
    var isFavored = false
    var isCollected = false
    var favorCount = 0
    
    func setUpButtonUI() {
        favor.setAttributedTitle(NSAttributedString(string: " \(favorCount)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
        
        if isFavored {
            favor.setImage(UIImage(systemName: "suit.heart.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            favor.tintColor = .red
        } else {
            favor.setImage(UIImage(systemName: "suit.heart")?.withRenderingMode(.alwaysTemplate), for: .normal)
            favor.tintColor = .black
        }

        if isCollected {
            collect.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            collect.tintColor = .yellow
        } else {
            collect.setImage(UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate), for: .normal)
            collect.tintColor = .black
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            setNeedsLayout()
            layoutIfNeeded()
            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
            var newFrame = layoutAttributes.frame
            // note: don't change the width
            print(size.height)
            newFrame.size.height = ceil(size.height)
            layoutAttributes.frame = newFrame
            return layoutAttributes
        }
    
    
    @IBAction func favorButtonPressed() {
        // update UI immediately instead of wait for the api call to return to improve reponsiveness.
        if !isFavored {
            favor.setImage(UIImage(systemName: "suit.heart.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            favorCount += 1
            favor.setAttributedTitle(NSAttributedString(string: " \(favorCount)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
            favor.tintColor = .red
            isFavored = true
        } else {
            favor.setImage(UIImage(systemName: "suit.heart")?.withRenderingMode(.alwaysTemplate), for: .normal)
            favorCount -= 1
            favor.setAttributedTitle(NSAttributedString(string: " \(favorCount)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
            favor.tintColor = .black
            isFavored = false
        }
        
        print("button pressed!")
        
        // tell the collectionView that a favor button is pressed on this cell
        if let ipath = indexPath {
            delegate?.favorWasPressed(at: ipath)
        }
    }
    
    
    @IBAction func collectButtonPressed() {
        if !isCollected {
            collect.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            collect.tintColor = .yellow
            isCollected = true
        } else {
            collect.setImage(UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate), for: .normal)
            collect.tintColor = .black
            isCollected = false
        }
        
        if let ipath = indexPath {
            delegate?.favorWasPressed(at: ipath)
        }
    }
    
}
