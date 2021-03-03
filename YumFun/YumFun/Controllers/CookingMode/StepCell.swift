//
//  StepCell.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/2/21.
//

import UIKit

class StepCell: UICollectionViewCell{
    
    var assigneeAvatars : [UIImage] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var notAssigned: UILabel!
    @IBOutlet weak var title: UILabel!
    
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
        collectionView.isHidden = (assigneeAvatars.count == 0)
        notAssigned.isHidden = !(assigneeAvatars.count == 0)
        return assigneeAvatars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as? AvatarCell ?? AvatarCell()
        cell.avatar.image = assigneeAvatars[indexPath.row]
        return cell
    }
}
