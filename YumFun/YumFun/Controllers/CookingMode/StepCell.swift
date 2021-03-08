//
//  StepCell.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/2/21.
//

import UIKit

class StepCell: UICollectionViewCell{
    
    var assigneeAvatars : [UIImage?] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var notAssigned: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descrip: UILabel!
    
    override func layoutSubviews() {
        // cell background color
        self.layer.backgroundColor = UIColor(named: "cell_bg_color")?.cgColor
        
        // cell rounded section
        self.layer.cornerRadius = 22
        self.layer.borderWidth = 0.0
        self.layer.masksToBounds = false
        
//        self.layer.shadowColor = UIColor(named: "shadow_color")?.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
//        self.layer.shadowRadius = 8.0
//        self.layer.shadowOpacity = 0.6
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,
//                                             cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    // for dynamically resized height
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
    
}

extension StepCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assigneeAvatars.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StepAvatarCell", for: indexPath) as? AvatarCell ?? AvatarCell()
        cell.avatar.image = assigneeAvatars[indexPath.row]
        return cell
    }
}

extension StepCell:  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 42, height: 42)
    }
}
