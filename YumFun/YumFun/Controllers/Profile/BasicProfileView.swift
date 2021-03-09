//
//  BasicProfileView.swift
//  YumFun
//
//  Created by Failury on 3/6/21.
//

import Foundation
import UIKit
import SnapKit

@IBDesignable class BasicProfileView: UIView {
    let kCONTENT_XIB_NAME = "BasicProfile"
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var DisplayName: UILabel!
    @IBOutlet weak var Bio: UILabel!
    @IBOutlet weak var FollowingStack: UIStackView!
    @IBOutlet weak var FollowingCount: UILabel!
    @IBOutlet weak var FollowersStack: UIStackView!
    @IBOutlet weak var FollowersCount: UILabel!
    @IBOutlet weak var FollowRelatedStackView: UIStackView!
    
    override init(frame: CGRect) {
            super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        layoutView()
    }
    
    private func layoutView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor(named: "cell_bg_color")
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
}
