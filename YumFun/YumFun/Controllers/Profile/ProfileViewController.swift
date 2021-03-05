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
    var CU:User?
    var OU:User?
    var isSelf = true
    
    @IBOutlet weak var EditButton: UIBarButtonItem!
    @IBOutlet weak var FollowingStack: UIStackView!
    @IBOutlet weak var FollowersStack: UIStackView!
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
        if isSelf{
            CU = Core.currentUser
        }else{
            CU = OU
        }
        DisplayUserInfo();
    }
    @IBAction func FllowingPressed(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 1) {
            self.FollowingStack.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            self.FollowingStack.layer.backgroundColor = UIColor.clear.cgColor
        }
        guard let CurrentUser = CU else {return}
        guard let UserList = storyboard?.instantiateViewController(withIdentifier: "UserList") as? UserListViewController else {
            assertionFailure("Cannot find ViewController")
            return
        }
        UserList.List = CurrentUser.followings
        navigationController?.pushViewController(UserList, animated: true)
    }
    
    @IBAction func FollowersPressed(_ sender: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 1) {
            self.FollowersStack.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            self.FollowersStack.layer.backgroundColor = UIColor.clear.cgColor
        }
        guard let CurrentUser = CU else {return}
        guard let UserList = storyboard?.instantiateViewController(withIdentifier: "UserList") as? UserListViewController else {
            assertionFailure("Cannot find ViewController")
            return
        }
        UserList.List = CurrentUser.followers
        navigationController?.pushViewController(UserList, animated: true)
    }
    @objc func Follow_Unfollow(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let FollowAction = UIAlertAction(title: "Follow", style: .default){
            UIAlertAction in
            guard let CurrentUser = Core.currentUser else{return}
            guard let followid = self.OU?.id else {return}
            CurrentUser.followUser(withId: followid) { (_) in}
        }
        let UnFollowAction = UIAlertAction(title: "Unfollow", style: .default){
            UIAlertAction in
            guard let CurrentUser = Core.currentUser else{return}
            guard let unfollowid = self.OU?.id else {return}
            CurrentUser.unfollowUser(withId: unfollowid) { (_) in}
            
        }
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
            alert.dismiss(animated: true) {}
        }
        alert.addAction(FollowAction)
        alert.addAction(UnFollowAction)
        alert.addAction(CancelAction)
        self.present(alert, animated: true)

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
        
        FollowersStack.layer.borderWidth = 0
        FollowersStack.layer.masksToBounds = true
        FollowersStack.layer.borderColor = UIColor.black.cgColor
        FollowersStack.layer.cornerRadius = ProfileImage.frame.height/16
        FollowersStack.clipsToBounds = true
        
        FollowingStack.layer.borderWidth = 0
        FollowingStack.layer.masksToBounds = true
        FollowingStack.layer.borderColor = UIColor.black.cgColor
        FollowingStack.layer.cornerRadius = ProfileImage.frame.height/16
        FollowingStack.clipsToBounds = true
        

    }

    
    func DisplayUserInfo(){
        guard let CurrentUser = CU else {return}
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
        if !isSelf{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(Follow_Unfollow))
        }
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
        guard let CurrentUser = CU else{
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text = "If you see this error please logout and login again"
            emptyLabel.textAlignment = NSTextAlignment.center
            self.RecipePreviews.backgroundView = emptyLabel
            return 0}
        if(CurrentUser.recipes.count == 0){
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text = "No Recipe Yet"
            emptyLabel.textAlignment = NSTextAlignment.center
            self.RecipePreviews.backgroundView = emptyLabel
            return 0
        }else{
            return CurrentUser.recipes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as! RecipePreviewCell
        guard let CurrentUser = CU else{return cell}
        if CurrentUser.recipes[indexPath.row] != ""{
            cell.Title.text = CurrentUser.recipes[indexPath.row]
        }else {
            cell.Title.text = "Untitled"
        }
       
        return cell
    }

    func LoadImage() {
        guard let currentUser = Core.currentUser, let currId = currentUser.id else {
            return
        }
        
        let myStorage = CloudStorage(.profileImage)
        myStorage.child(currId + ".jpeg")
        
        self.ProfileImage.sd_setImage(with: myStorage.fileRef,
                                  placeholderImage: PlaceholderImage.imageWith(name: currentUser.displayName),
                                  completion: nil)
    }

}


