//
//  ContentViewController.swift
//  YumFun
//
//  Created by Failury on 3/6/21.
//

import UIKit
import SegementSlide
class ContentViewController: UICollectionViewController, SegementSlideContentScrollViewDelegate {
    
    let discoverQueue = DispatchQueue(label: "discoverQueue")
    let semaphore: DispatchSemaphore? = DispatchSemaphore(value: 6)
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return List.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverTextCell", for: indexPath) as! DiscoverTextCell
        Recipe.get(named: List[indexPath.row]) { (Error, Recipe, DocumentSnapshot) in
            if Error == nil{
                guard let recipe = Recipe else {return}
    
                cell.title.text = recipe.title
                cell.delegate = collectionView
                cell.indexPath = indexPath
                
                self.setAuthorProfileImage(userID: recipe.author, profileImage: cell.profileImage)
                if let user = Core.currentUser, let id = recipe.id {
                    cell.isFavored = user.likedRecipes.contains(id)
                    cell.favorCount = recipe.likedCount
        //            print(cell.favorCount)
                    
                    cell.setUpButtonUI()
                }
                
                if recipe.picUrls.count == 0 {
                    cell.recipeImage.image = UIImage(named: "empty_image_placeholder")
                } else {
                    self.setCoverImages(firstUrl: recipe.picUrls[0], firstCover: cell.recipeImage)
                }
                
            }
        }
        return cell
    }
    
    var List:[String] = []
    @objc var scrollView: UIScrollView {
        return collectionView
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setup()
    }
    func setup(){
        self.collectionView.reloadData()
        

    }
    
    
    private func setAuthorProfileImage(userID: String, profileImage: UIImageView) {
        discoverQueue.async {
            DispatchQueue.global(qos: .userInitiated).async {
                let myStorage = CloudStorage(AssetType.profileImage)
                myStorage.child("\(userID).jpeg")
                
                profileImage.sd_setImage(with: myStorage.fileRef,
                                         placeholderImage: nil) { (_, error, _, _) in
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    
                    self.semaphore?.signal()
                }
            }
            self.semaphore?.wait()
        }
    }
    
    private func setCoverImages(firstUrl: String?, firstCover: UIImageView) {
        discoverQueue.async {
            if let url = firstUrl {
                DispatchQueue.global(qos: .userInitiated).async {
                    Utility.setImage(url: url, imageView: firstCover, placeholder: nil, semaphore: self.semaphore)
                }
                self.semaphore?.wait()
            }
        }
    }
}
