//
//  ProfileViewController.swift
//  YumFun
//
//  Created by Failury on 2/20/21.
//

import UIKit
import Firebase
import SegementSlide
class ProfileViewController: SegementSlideDefaultViewController {
    
    var CU:User?
    var OU:User?
    var isSelf = true
    var headerOutlet = BasicProfileView()
    
    var fetchedRecipe: [Recipe]? = nil
    var fetchedLikedRecipe: [Recipe]? = nil
    
    
    override func segementSlideHeaderView() -> UIView? {
        let headerView = BasicProfileView()

        Cosmetic(View: headerView)
        DisplayUserInfo(View: headerView)
        self.headerOutlet = headerView
        headerView.FollowingStack.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(FollowingPressed)))
        headerView.FollowersStack.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(FollowersPressed)))
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.heightAnchor.constraint(equalToConstant: 210).isActive = true
        return headerView
    }
    
    override var switcherConfig: SegementSlideDefaultSwitcherConfig {
        var config = super.switcherConfig
        config.type = .tab
        return config
    }
    
    @objc func FollowingPressed(){
        UIView.animate(withDuration: 1) {
            self.headerOutlet.FollowingStack.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            self.headerOutlet.FollowersStack.layer.backgroundColor = UIColor.clear.cgColor
               }
               guard let CurrentUser = CU else {return}
               guard let UserList = storyboard?.instantiateViewController(withIdentifier: "UserList") as? UserListViewController else {
                   assertionFailure("Cannot find ViewController")
                   return
               }
               UserList.List = CurrentUser.followings
               navigationController?.pushViewController(UserList, animated: true)
    }
    
    @objc func FollowersPressed(){
        UIView.animate(withDuration: 1) {
            self.headerOutlet.FollowersStack.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            self.headerOutlet.FollowersStack.layer.backgroundColor = UIColor.clear.cgColor
               }
               guard let CurrentUser = CU else {return}
               guard let UserList = storyboard?.instantiateViewController(withIdentifier: "UserList") as? UserListViewController else {
                   assertionFailure("Cannot find ViewController")
                   return
               }
               UserList.List = CurrentUser.followers
               navigationController?.pushViewController(UserList, animated: true)
        
    }
    
    override var titlesInSwitcher: [String] {
        return ["My Recipes", "Liked Recipes"]
    }

    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(
            width: UIScreen.main.bounds.width - 40,
            height: 200
        )
        guard let CurrentUser = CU else{return nil}
        let content = ContentViewController(collectionViewLayout: layout)
        if index == 0 {
            content.List = CurrentUser.recipes
        } else if index == 1 {
            content.List = CurrentUser.likedRecipes
        }
        
        return content
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isSelf{
            CU = Core.currentUser
        }else{
            CU = OU
        }
        defaultSelectedIndex = 0
        reloadData()
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
    
    func Cosmetic(View:BasicProfileView){
        View.ProfileImage.layer.borderWidth = 1
        View.ProfileImage.layer.masksToBounds = true
        View.ProfileImage.layer.borderColor = UIColor.black.cgColor
        View.ProfileImage.layer.cornerRadius = View.ProfileImage.frame.height/2
        View.ProfileImage.clipsToBounds = true

        View.FollowersStack.layer.borderWidth = 0
        View.FollowersStack.layer.masksToBounds = true
        View.FollowersStack.layer.borderColor = UIColor.black.cgColor
        View.FollowersStack.layer.cornerRadius = View.FollowersStack.frame.height/8
        View.FollowersStack.clipsToBounds = true

        View.FollowingStack.layer.borderWidth = 0
        View.FollowingStack.layer.masksToBounds = true
        View.FollowingStack.layer.borderColor = UIColor.black.cgColor
        View.FollowingStack.layer.cornerRadius = View.FollowingStack.frame.height/8
        View.FollowingStack.clipsToBounds = true
    }
    
    func DisplayUserInfo(View:BasicProfileView){
        guard let CurrentUser = CU else {return}
        //name
        if let displayname = CurrentUser.displayName {
            View.DisplayName.text = displayname
        }else {
            View.DisplayName.text = "please set a name"
        }
        if let Bio = CurrentUser.bio{
            View.Bio.text = Bio
        }else{
            View.Bio.text = "empty person"
        }
        //profile image
        LoadImage(View: View)
        View.FollowingCount.text = String(CurrentUser.followings.count)
        View.FollowersCount.text = String(CurrentUser.followers.count)
        if !isSelf{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(Follow_Unfollow))
        }
    }
    
    @IBAction func Editpress(_ sender: Any) {
        guard let ProfileEditPageController = storyboard?.instantiateViewController(withIdentifier: "PEPage") as? ProfileEditPage else {
            assertionFailure("Cannot find ViewController")
            return
        }
        navigationController?.pushViewController(ProfileEditPageController, animated: true)
    }
}

extension ProfileViewController{
    func LoadImage(View:BasicProfileView) {
        guard let currentUser = Core.currentUser, let currId = currentUser.id else {
            return
        }

        let myStorage = CloudStorage(.profileImage)
        myStorage.child(currId + ".jpeg")
        View.ProfileImage.sd_setImage(with: myStorage.fileRef,
                                  placeholderImage: PlaceholderImage.imageWith(name: currentUser.displayName),
                                  completion: nil)
    }
}


