//
//  ProfileRecipeCell.swift
//  YumFun
//
//  Created by Failury on 3/7/21.
//

import UIKit

class ProfileRecipeCell: UICollectionViewCell {

    @IBOutlet weak var PreviewImage: UIImageView!
    @IBOutlet weak var Title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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

}
