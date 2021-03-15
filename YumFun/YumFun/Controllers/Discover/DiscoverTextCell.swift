//
//  DiscoverTextCell.swift
//  YumFun
//
//  Created by Xiyu Zhang on 2/20/21.
//

import UIKit
import FaveButton

class DiscoverTextCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
//    @IBOutlet weak var descrip: UILabel!
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var profileImage: CircularImageView!
    @IBOutlet weak var favCountLabel: UILabel!
    @IBOutlet weak var favButton: CustomFavButton!
    
    weak var delegate : DiscoverCellDelegate?
    var indexPath: IndexPath?
    
    var isFavored = false
    var favorCount = 0
    
    func setUpButtonUI() {
        favCountLabel.text = String(favorCount)

        if isFavored {
            self.favButton.setSelected(selected: true, animated: false)
        } else {
            self.favButton.setSelected(selected: false, animated: false)
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
    
    @IBAction func favorButtonPressed(_ sender: Any) {
        // update UI immediately instead of wait for the api call to return to improve reponsiveness.
        if !isFavored {
            favorCount += 1
            isFavored = true
            
            // tell the collectionView that a favor button is pressed on this cell
            if let ipath = indexPath {
                delegate?.didFavorRecipeAt(at: ipath)
            }
        } else {
            favorCount -= 1
            isFavored = false
            
            // tell the collectionView that a favor button is pressed on this cell
            if let ipath = indexPath {
                delegate?.didUnfavorRecipeAt(at: ipath)
            }
        }
        
        favCountLabel.text = String(favorCount)
    }
}

extension DiscoverTextCell: FaveButtonDelegate {
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
        return
    }

    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        if(faveButton == self.favButton){
            return favButtonColor
        }
        return nil
    }
}
