//
//  ProfileEditPage.swift
//  YumFun
//
//  Created by Failury on 2/22/21.
//

import UIKit
import QCropper
import JGProgressHUD
import WXImageCompress
import SwiftEntryKit
import FirebaseFirestoreSwift

class ProfileEditPage: UITableViewController {

    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var DisplayName: UILabel!
    @IBOutlet weak var Bio: UILabel!
    
    fileprivate func Cosmetic() {
        ProfileImage.layer.borderWidth = 1
        ProfileImage.layer.masksToBounds = true
        ProfileImage.layer.borderColor = UIColor.clear.cgColor
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height/4
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
                let cropper = CustomImageClipViewController(originalImage: image)
                cropper.delegate = self
                self.present(cropper, animated: true, completion: nil)
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
//        case 3:
//            //set email
//            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
//                viewController.navigationItem.title = "Email"
//                viewController.Mode = "EmailEdit"
//                    navigationController?.pushViewController(viewController, animated: true)
//                }
//        case 4:
//            //set UserName
//            if let viewController = storyboard?.instantiateViewController(identifier: "Editdetails") as? EditDetailController {
//                viewController.navigationItem.title = "Username"
//                viewController.Mode = "UserNameEdit"
//                    navigationController?.pushViewController(viewController, animated: true)
//                }

        case 3:
            //set password
            if let viewController = storyboard?.instantiateViewController(identifier: "UpdatePassword") as? UpdatePasswordViewController {
                viewController.navigationItem.title = "Password"
                navigationController?.pushViewController(viewController, animated: true)
            }
        case 4:
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
        
        self.ProfileImage.sd_setImage(with: myStorage.fileRef,
                                      placeholderImage: nil,
                                      completion: nil)
    }
}

extension ProfileEditPage: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        guard let CurrentUser = Core.currentUser, let cropper = cropper as? CustomImageClipViewController else {
            displayErrorBottomPopUp(title: "ERROR",
                                    description: "Sorry, current user info has been correctly loaded. Please reload the entire app, and try again.")
            return
        }
        
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.show(in: cropper.view, animated: true)

        if let state = state,
            let image = cropper.originalImage.cropped(withCropperState: state) {
            
            print(cropper.isCurrentlyInInitialState)
            print(image)
            
            CurrentUser.updateProfileImage(with: image) { error, cs in
                hud.dismiss()
                
                if let error = error {
                    displayErrorBottomPopUp(title: "ERROR",
                                            description: "Sorry, upload failed.")
                    print(error.localizedDescription)
                } else {
                    cropper.dismiss(animated: true, completion: nil)
                    if let cs = cs {
                        displaySuccessBottomPopUp(title: "Congrats!",
                                                description: "Your profile image has been updated!")
                        DispatchQueue.main.async {
                            self.ProfileImage.sd_setImage(
                                with: cs.fileRef,
                                maxImageSize: 3 * 2048 * 2048,
                                placeholderImage: nil,
                                options: [.refreshCached],
                                completion: nil)
                        }
                    }
                }
            }
        } else {
            hud.dismiss()
            displayErrorBottomPopUp(title: "ERROR",
                                    description: "Sorry, we cannot finish current operation.")
        }
    }
}

