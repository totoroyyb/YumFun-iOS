//
//  AvatarCell.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/12.
//

import UIKit
import MagazineLayout

class AvatarCell: UICollectionViewCell {
    
    @IBOutlet weak var avatar: CircularImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .green
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.image = nil
    }
}

extension CircularImageView {
    func setBorder(width: CGFloat, color: CGColor?) {
        self.layer.borderWidth = width
        self.layer.borderColor = color
    }
}
