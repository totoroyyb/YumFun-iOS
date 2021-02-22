//
//  CollectionViewCell.swift
//  YumFun
//
//  Created by Failury on 2/21/21.
//

import UIKit

class RecipePreviewCell: UICollectionViewCell {

    @IBOutlet weak var PreviewImage: UIImageView!
    @IBOutlet weak var Title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        PreviewImage.layer.borderWidth = 1
        PreviewImage.layer.masksToBounds = true
        PreviewImage.layer.borderColor = UIColor.gray.cgColor
        PreviewImage.layer.cornerRadius = PreviewImage.frame.height/4
        PreviewImage.clipsToBounds = true
    }

}
