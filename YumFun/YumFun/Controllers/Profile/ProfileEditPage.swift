//
//  ProfileEditPage.swift
//  YumFun
//
//  Created by Failury on 2/22/21.
//

import UIKit

class ProfileEditPage: UITableViewController {

    @IBOutlet weak var ProfileImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileImage.layer.borderWidth = 1
        ProfileImage.layer.masksToBounds = true
        ProfileImage.layer.borderColor = UIColor.black.cgColor
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height/4
        ProfileImage.clipsToBounds = true
    }



}
