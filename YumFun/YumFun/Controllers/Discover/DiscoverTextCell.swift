//
//  DiscoverTextCell.swift
//  YumFun
//
//  Created by Xiyu Zhang on 2/20/21.
//

import UIKit

class DiscoverTextCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
//    @IBOutlet weak var descrip: UILabel!
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var profileImage: CircularImageView!
    @IBOutlet weak var favor: UIButton!
    
    weak var delegate : DiscoverCellDelegate?
    var indexPath: IndexPath?
    
    var isFavored = false
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // cell rounded section
        self.layer.cornerRadius = 22
        self.layer.borderWidth = 0.0
        self.layer.masksToBounds = false
        
        // cell shadow section
        self.contentView.layer.cornerRadius = 20
        self.contentView.layer.borderWidth = 0.0
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor(named: "shadow_color")?.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 8.0
        self.layer.shadowOpacity = 0.6
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,
                                             cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var newFrame = layoutAttributes.frame
//        // note: don't change the width
//        newFrame.size.height = ceil(size.height)
//        newFrame.size.width = safeAreaLayoutGuide.layoutFrame.width - 30
//        layoutAttributes.frame = newFrame
//        return layoutAttributes
//    }
    
    override func systemLayoutSizeFitting(
                _ targetSize: CGSize,
                withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                verticalFittingPriority: UILayoutPriority) -> CGSize {

        // Replace the height in the target size to
        // allow the cell to flexibly compute its height
        var targetSize = targetSize
        targetSize.height = CGFloat.greatestFiniteMagnitude

        // The .required horizontal fitting priority means
        // the desired cell width (targetSize.width) will be
        // preserved. However, the vertical fitting priority is
        // .fittingSizeLevel meaning the cell will find the
        // height that best fits the content
        let size = super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        return size
    }
    
    
    @IBAction func favorButtonPressed() {
        // update UI immediately instead of wait for the api call to return to improve reponsiveness.
        if !isFavored {
            favor.setImage(UIImage(systemName: "suit.heart.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            favorCount += 1
            favor.setAttributedTitle(NSAttributedString(string: " \(favorCount)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
            favor.tintColor = .red
            isFavored = true
            
            // tell the collectionView that a favor button is pressed on this cell
            if let ipath = indexPath {
                delegate?.didFavorRecipeAt(at: ipath)
            }
        } else {
            favor.setImage(UIImage(systemName: "suit.heart")?.withRenderingMode(.alwaysTemplate), for: .normal)
            favorCount -= 1
            favor.setAttributedTitle(NSAttributedString(string: " \(favorCount)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
            favor.tintColor = .black
            isFavored = false
            
            // tell the collectionView that a favor button is pressed on this cell
            if let ipath = indexPath {
                delegate?.didUnfavorRecipeAt(at: ipath)
            }
        }
        
        print("button pressed!")
    }
}
