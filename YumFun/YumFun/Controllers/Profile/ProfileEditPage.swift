//
//  ProfileEditPage.swift
//  YumFun
//
//  Created by Failury on 2/22/21.
//

import UIKit
import QCropper
import JGProgressHUD

class ProfileEditPage: UITableViewController {

    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var DisplayName: UILabel!
    @IBOutlet weak var Bio: UILabel!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var UserName: UILabel!
    fileprivate func Cosmetic() {
        ProfileImage.layer.borderWidth = 0
        ProfileImage.layer.masksToBounds = true
        ProfileImage.layer.borderColor = UIColor.clear.cgColor
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height/2
        ProfileImage.clipsToBounds = true
    }
    
    fileprivate func DisplayInfo(){
        guard let CurrentUser = Core.currentUser else {return}
        LoadImage()
        if let displayname = CurrentUser.displayName{
            DisplayName.text = displayname
        }else{
            DisplayName.text = "Not Set"
        }
        if let bio = CurrentUser.bio{
            Bio.text = bio
        }else{
            Bio.text = "Not Set"
        }
        if let email = CurrentUser.email{
            Email.text = email
        }else {
            Email.text = "error"
        }
        if let username = CurrentUser.userName{
            UserName.text = username
        }else{
            UserName.text = "Not Set"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Cosmetic()
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DisplayInfo()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            //image picker
            ImagePickerManager().pickImage(self) { image in
//                self.ProfileImage.image = image
                guard let CurrentUser = Core.currentUser else { return }
                
                let cropper = CustomImageClipViewController(originalImage: image)
                cropper.delegate = self
                self.present(cropper, animated: true, completion: nil)
//                CurrentUser.updateProfileImage(with: image) { error in
//                    print(error?.localizedDescription ?? "Unknown error")
//                }
            }

        case 1:
            //name change
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Name"
                viewController.Mode = "NameEdit"
                    navigationController?.pushViewController(viewController, animated: true)
                }

        case 2:
            //set Bio
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Bio"
                viewController.Mode = "BioEdit"
                    navigationController?.pushViewController(viewController, animated: true)
                }
        case 3:
            //set email
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Email"
                viewController.Mode = "EmailEdit"
                    navigationController?.pushViewController(viewController, animated: true)
                }
        case 4:
            //set UserName
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Username"
                viewController.Mode = "UserNameEdit"
                    navigationController?.pushViewController(viewController, animated: true)
                }
        case 5:
            //set password
            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
                viewController.navigationItem.title = "Password"
                viewController.Mode = "PasswordEdit"
                    navigationController?.pushViewController(viewController, animated: true)
                }
        case 6:
            print("logout")
            Core.logout(from: self.view)

        default:
            print("error")
        }
    }
    
    
    func LoadImage(){
        guard let currentUser = Core.currentUser, let picUrl = currentUser.photoUrl else {
            ProfileImage.image = #imageLiteral(resourceName: "Goopy")
            return
        }
        
        let myStorage = CloudStorage(picUrl)
        
        self.ProfileImage.sd_setImage(
            with: myStorage.fileRef,
            maxImageSize: 1 * 2048 * 2048,
            placeholderImage: nil,
            options: [ .refreshCached]) { (image, error, cache, storageRef) in
            if let error = error {
                print("Error load Image: \(error)")
            } else {
                print("Finished loading current user profile image.")
            }
        }
    }
}

extension ProfileEditPage: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
//        cropper.dismiss(animated: true, completion: nil)
        
//        let hud = JGProgressHUD()
//        hud.textLabel.text = "Loading"
//
//
//        cropper.view.addSubview(hud)
//        cropper.view.bringSubviewToFront(hud)
//        
//        hud.show(in: self.view)
//        hud.dismiss(afterDelay: 3.0)
//        guard let cropper = cropper as? CustomImageClipViewController else {
//            print("Cannot convert to custom clip view controller")
//            return
//        }
        
//        cropper.hud.show(in: self.view)
//        cropper.hud.dismiss(afterDelay: 3.0)
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.show(in: cropper.view)
        hud.dismiss(afterDelay: 3.0)
        
        

        if let state = state,
            let image = cropper.originalImage.cropped(withCropperState: state) {
//            cropperState = state
//            imageView.image = image
            self.ProfileImage.image = image
            print(cropper.isCurrentlyInInitialState)
            print(image)
        }
    }
}

