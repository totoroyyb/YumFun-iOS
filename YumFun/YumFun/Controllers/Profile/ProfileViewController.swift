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
        print("here")
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
        //profile image
        if let imgurl = CurrentUser.photoUrl{
            ProfileImage.downloaded(from: imgurl)
        }else {
            //default image
            ProfileImage.image = #imageLiteral(resourceName: "Goopy")
        }
        FollowingCount.text = String(CurrentUser.followings.count)
        FollowerCount.text = String(CurrentUser.followers.count)
        if CurrentUser.recipes.count == 0 {
            NoRecipe.text = "No Recipe Yet"
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let cu = FirebaseAuth.Auth.auth().currentUser else {return 0}
        let CurrentUser = User(fromAuthUser: cu)
        return CurrentUser.recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as! RecipePreviewCell
        guard let cu = FirebaseAuth.Auth.auth().currentUser else {return cell}
        let CurrentUser = User(fromAuthUser: cu)
        if CurrentUser.recipes[indexPath.row] != ""{
            cell.Title.text = CurrentUser.recipes[indexPath.row]
        }else {
            cell.Title.text = "this is a title"
        }

        cell.PreviewImage.image = UIImage(named:"previewimage")
       
        return cell
    }
    
    
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
