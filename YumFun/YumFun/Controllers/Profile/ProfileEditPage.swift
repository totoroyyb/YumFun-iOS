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
            print("direct to name changer")
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Name"
                    navigationController?.pushViewController(viewController, animated: true)
                }

        case 2:
            print("direct to bio changer")
        case 3:
            print("direct to email changer")
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Email"
                    navigationController?.pushViewController(viewController, animated: true)
                }
        case 4:
            print("direct to username changer")
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Username"
                    navigationController?.pushViewController(viewController, animated: true)
                }
        case 5:
            print("direct to password changer")
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
