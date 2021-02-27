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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("direct to image changer")

        case 1:
            //name change
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Name"
                    navigationController?.pushViewController(viewController, animated: true)
                }

        case 2:
            //set Bio
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Bio"
                    navigationController?.pushViewController(viewController, animated: true)
                }
        case 3:
            //set email
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Email"
                    navigationController?.pushViewController(viewController, animated: true)
                }
        case 4:
            //set UserName
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Username"
                    navigationController?.pushViewController(viewController, animated: true)
                }
        case 5:
            //set password
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Password"
                    navigationController?.pushViewController(viewController, animated: true)
                }
        case 6:
            print("logout")

        default:
            print("error")
        }
    }
    
}
