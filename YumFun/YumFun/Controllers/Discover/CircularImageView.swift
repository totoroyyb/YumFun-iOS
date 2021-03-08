//
//  CircularImageView.swift
//  YumFun
//
//  Created by Xiyu Zhang on 2/20/21.
//

import UIKit

class CircularImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
