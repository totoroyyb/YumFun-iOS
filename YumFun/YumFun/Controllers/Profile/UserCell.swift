//
//  UserCell.swift
//  YumFun
//
//  Created by Failury on 3/2/21.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var UserImage: UIImageView!
    @IBOutlet weak var UserName: UILabel!
    
    @IBOutlet weak var UserBio: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.frame.height/8
        self.layer.masksToBounds = true
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.clipsToBounds = true
        
        
        
        UserImage.layer.borderWidth = 1
        UserImage.layer.masksToBounds = true
        UserImage.layer.borderColor = UIColor.black.cgColor
        UserImage.layer.cornerRadius = UserImage.frame.height/2
        UserImage.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
