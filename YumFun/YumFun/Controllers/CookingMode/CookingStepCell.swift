//
//  CookingStepCell.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/5/21.
//

import UIKit

class CookingStepCell: UICollectionViewCell{
    
    var assigneeAvatars : [UIImage?] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var indexPath = IndexPath()
    
    weak var delegate: CookingStepCellDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    
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
    
    @IBAction func checkPressed() {
        checkButton.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        delegate?.didCheckCellAt(at: indexPath)
    }
}

extension CookingStepCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assigneeAvatars.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StepAvatarCell", for: indexPath) as? AvatarCell ?? AvatarCell()
        cell.avatar.image = assigneeAvatars[indexPath.row]
        return cell
    }
}

extension CookingStepCell:  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 42, height: 42)
    }
}

// CookingStepCellDelegate informs its master collctionView a button click event on the cell
protocol CookingStepCellDelegate: class {
    func didCheckCellAt(at indexPath: IndexPath)
}

