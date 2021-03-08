//
//  AvatarCellCollectionViewCell.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/2/21.
//

import UIKit

class AvatarCell: UICollectionViewCell {
    @IBOutlet weak var avatar: CircularImageView!
}

extension CircularImageView {
    func setBorder(width: CGFloat, color: CGColor?) {
        self.layer.borderWidth = width
        self.layer.borderColor = color
    }
}
