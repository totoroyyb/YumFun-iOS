//
//  ProfileViewController.swift
//  YumFun
//
//  Created by Failury on 2/20/21.
//

import UIKit

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var RecipePreviews: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        ProfileImage.layer.borderWidth = 1
        ProfileImage.layer.masksToBounds = true
        ProfileImage.layer.borderColor = UIColor.black.cgColor
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height/2
        ProfileImage.clipsToBounds = true
        
        
        RecipePreviews.delegate = self
        RecipePreviews.dataSource = self
        
      
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
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as! RecipePreviewCell
        cell.PreviewImage.image = UIImage(named:"previewimage")
        cell.Title.text = "this is a title"
        return cell
    }
    
    
}
