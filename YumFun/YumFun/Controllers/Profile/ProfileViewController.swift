//
//  ProfileViewController.swift
//  YumFun
//
//  Created by Failury on 2/20/21.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var RecipePreviews: UICollectionView!
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var BioDisplay: UILabel!
    @IBOutlet weak var NoRecipe: UILabel!
    @IBOutlet weak var FollowingCount: UILabel!
    @IBOutlet weak var FollowerCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
            RecipePreviews.delegate = self
            RecipePreviews.dataSource = self
            Cosmetic()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DisplayUserInfo();
    }
    @IBAction func FllowingPressed(_ sender: UITapGestureRecognizer) {
        
        guard let CurrentUser = Core.currentUser else {return}
        //CurrentUser.followUser(withId: "dGPM9f2dxEWY77d19A9XU91qvMX2", {_ in })
        //CurrentUser.unfollowUser(withId: "dGPM9f2dxEWY77d19A9XU91qvMX2") { (_: Error?) in}
        guard let UserList = storyboard?.instantiateViewController(withIdentifier: "UserList") as? UserListViewController else {
            assertionFailure("Cannot find ViewController")
            return
        }
        UserList.List = CurrentUser.followings
        navigationController?.pushViewController(UserList, animated: true)
    }
    
    @IBAction func FollowersPressed(_ sender: UITapGestureRecognizer) {
        guard let CurrentUser = Core.currentUser else {return}
        guard let UserList = storyboard?.instantiateViewController(withIdentifier: "UserList") as? UserListViewController else {
            assertionFailure("Cannot find ViewController")
            return
        }
        UserList.List = CurrentUser.followers
        navigationController?.pushViewController(UserList, animated: true)
    }
    func Cosmetic(){
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        ProfileImage.layer.borderWidth = 1
        ProfileImage.layer.masksToBounds = true
        ProfileImage.layer.borderColor = UIColor.black.cgColor
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height/2
        ProfileImage.clipsToBounds = true
    }
    
    func DisplayUserInfo(){
        guard let CurrentUser = Core.currentUser else {return}
        //name
        if let displayname = CurrentUser.displayName {
            Name.text = displayname
        }else {
            Name.text = "please set a name"
        }
        if let Bio = CurrentUser.bio{
            BioDisplay.text = Bio
        }else{
            BioDisplay.text = "empty person"
        }
        //profile image
        LoadImage()
        FollowingCount.text = String(CurrentUser.followings.count)
        FollowerCount.text = String(CurrentUser.followers.count)
    }
    @IBAction func EditPressed(_ sender: UIBarButtonItem) {
        guard let ProfileEditPageController = storyboard?.instantiateViewController(withIdentifier: "PEPage") as? ProfileEditPage else {
            assertionFailure("Cannot find ViewController")
            return
        }
        navigationController?.pushViewController(ProfileEditPageController, animated: true)
    }
    
   

}
extension ProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: RecipePreviews.frame.width-8, height: RecipePreviews.frame.height-8)
        }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let CurrentUser = Core.currentUser
//        return CurrentUser.recipes.count
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as! RecipePreviewCell
        guard let cu = FirebaseAuth.Auth.auth().currentUser else {return cell}
        let CurrentUser = Core.currentUser
//        if CurrentUser.recipes[indexPath.row] != ""{
//            cell.Title.text = CurrentUser.recipes[indexPath.row]
//        }else {
//            cell.Title.text = "this is a title"
//        }
        cell.Title.text = "this is a title"
        cell.PreviewImage.image = UIImage(named:"previewimage")
       
        return cell
    }
    func LoadImage(){
        guard let currentUser = Core.currentUser else {
            return
        }
        if let picUrl = currentUser.photoUrl{
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

            self.ProfileImage.sd_setImage(with: myStorage.fileRef,
                                      placeholderImage: PlaceholderImage.imageWith(name: currentUser.displayName),
                                      completion: nil)
        }else{
            ProfileImage.image = PlaceholderImage.imageWith(name: currentUser.displayName)
        }
       
    }

}


