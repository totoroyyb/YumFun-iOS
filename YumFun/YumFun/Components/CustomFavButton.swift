//
//  CustomFavButton.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/15.
//

import Foundation
import FaveButton

class CustomFavButton: FaveButton {
    override func awakeFromNib() {
        self.isSelected = false
        if let normalColor = UIColor(named: "unselected_text_color") {
            self.normalColor = normalColor
        }
    }
}
