//
//  BasicProfileView.swift
//  YumFun
//
//  Created by Failury on 3/6/21.
//

import Foundation
import UIKit

@IBDesignable class BasicProfileView:UIStackView{
    let kCONTENT_XIB_NAME = "BasicProfile"
    @IBOutlet var contentView: UIStackView!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var DisplayName: UILabel!
    @IBOutlet weak var Bio: UILabel!
    @IBOutlet weak var RecipeCount: UILabel!
    @IBOutlet weak var FollowingStack: UIStackView!
    @IBOutlet weak var FollowingCount: UILabel!
    @IBOutlet weak var FollowersStack: UIStackView!
    @IBOutlet weak var FollowersCount: UILabel!
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
                commonInit()
    }
    

    
    func commonInit() {
            Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
            contentView.fixInView(self)
        }
    

}

extension UIStackView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 8).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
