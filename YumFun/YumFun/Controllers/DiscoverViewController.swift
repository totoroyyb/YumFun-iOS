//
//  DiscoverViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 2/20/21.
//

import UIKit
import PhotosUI
import FirebaseUI

class DiscoverViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DiscoverCollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var recipes : [Recipe] = []
    
    let discoverQueue = DispatchQueue(label: "discoverQueue")
    let semaphore = DispatchSemaphore(value: 6)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        Core.setupCurrentUser() { err in
            guard err == nil else {
                assertionFailure(err.debugDescription)
                return
            }
            print("current user has been set up")
        }
        
        Recipe.getAll() { (err, recipes, _) in
            guard err == nil else {
                assertionFailure(err.debugDescription)
                return
            }
            self.recipes = recipes ?? []
            self.collectionView.reloadData()
        }
        
        let layout = collectionView.collectionViewLayout
        if let flowLayout = layout as? UICollectionViewFlowLayout{
            flowLayout.estimatedItemSize = CGSize(
                width: view.frame.width,
                // Make the height a reasonable estimate to
                // ensure the scroll bar remains smooth
                height: 500
            )
        }
    }
    
//    let testData : [(UIImage?, UIImage?)] = [(nil,nil), (nil,nil), (nil,nil), (nil,nil), (nil,nil), (nil,nil), (nil,nil)]
    
//    let testData = [(nil, nil), (UIImage(named: "mascot"), UIImage(named: "mascot")), (nil, nil), (UIImage(named: "mascot"), nil), (UIImage(named: "mascot"), UIImage(named: "mascot")), (nil, nil), (UIImage(named: "mascot"), nil)]
    
    
    // DataSouce Implementation
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: integrate with view model
        print(" in \(recipes.count)")
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let recipe = recipes[indexPath.row]
        
        if recipe.picUrls.count == 0 {  // text cell
            print("text Cell")
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverTextCell", for: indexPath) as? DiscoverTextCell else {
                assertionFailure("no discovertextcell")
                return DiscoverTextCell()
            }
            
            cell.title.text = recipe.title
            cell.descrip.text = recipe.description
            
            cell.delegate = collectionView
            cell.indexPath = indexPath
            
            // profile image
            discoverQueue.async {
                self.setAuthorProfileImage(name: recipe.author, profileImage: cell.profileImage)
                self.semaphore.signal()
            }
            
            // TODO: set isCollected
            if let user = Core.currentUser, let id = recipe.id {
                if user.likedRecipes.contains(id) {
                    cell.isFavored = true
                    cell.favorCount = user.likedRecipes.count
                }
                
                cell.isCollected = false
                cell.setUpButtonUI()
            }

            return cell
        } else {
            print("image cell")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverImageCell", for: indexPath) as? DiscoverImageCell ?? DiscoverImageCell()
            
            cell.title.text = recipe.title
            cell.descrip.text = recipe.description
            
            cell.delegate = collectionView
            cell.indexPath = indexPath
            
            // profile image
            discoverQueue.async {
                self.setAuthorProfileImage(name: recipe.author, profileImage: cell.profileImage)
                self.semaphore.wait()
            }
        
            // set up cover images
            discoverQueue.async {
                if recipe.picUrls.count == 1 {
                    self.setCoverImages(firstUrl: recipe.picUrls[0], secondUrl: nil, firstCover: cell.coverImage1, secondCover: cell.coverImage2)
                } else {
                    self.setCoverImages(firstUrl: recipe.picUrls[0], secondUrl: recipe.picUrls[1], firstCover: cell.coverImage1, secondCover: cell.coverImage2)
                }
            
                self.semaphore.wait()
                self.semaphore.wait()
            }
            
            // TODO: set isCollected
            if let user = Core.currentUser, let id = recipe.id {
                if user.likedRecipes.contains(id) {
                    cell.isFavored = true
                    cell.favorCount = user.likedRecipes.count
                }
                
                cell.isCollected = false
                cell.setUpButtonUI()
            }
            
            return cell
        }
    }
    
    private func setImage(url: String, imageView: UIImageView) {
        let myStorage = CloudStorage(url)
        
        imageView.sd_setImage(
            with: myStorage.fileRef,
            maxImageSize: 1 * 2048 * 2048,
            placeholderImage: nil,
            options: [.progressiveLoad, .refreshCached]) { (image, error, cache, storageRef) in
            if error != nil {
                assertionFailure(error.debugDescription)
            }
        }
    }
    
    private func setAuthorProfileImage(name: String, profileImage: UIImageView) {
        DispatchQueue.global(qos: .userInitiated).async {
            User.get(named: name) { (err, author, _) in
                guard err == nil else {
                    assertionFailure(err.debugDescription)
                    return
                }
                
                if let a = author, let url = a.photoUrl {
                    self.setImage(url: url, imageView: profileImage)
                }
            }
            self.semaphore.signal()
        }
    }
    
    private func setCoverImages(firstUrl: String?, secondUrl: String?, firstCover: UIImageView, secondCover: UIImageView) {
        if let url = firstUrl {
            firstCover.contentMode = .scaleAspectFit
            DispatchQueue.global(qos: .userInitiated).async {
                self.setImage(url: url, imageView: firstCover)
                self.semaphore.signal()
            }
        }
        if let url = firstUrl {
            secondCover.contentMode = .scaleAspectFit
            DispatchQueue.global(qos: .userInitiated).async {
                self.setImage(url: url, imageView: secondCover)
                self.semaphore.signal()
            }
        }
    }
    
    // UICollectionViewDelegate Implementation
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected! \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(identifier: "RecipeDetailViewController") as RecipeDetailViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // DiscoverCollectionViewDelegate Implementation
    func collectionView(_ collectionView: UICollectionView, favorWasPressedAt indexPath: IndexPath) {
        if let id = recipes[indexPath.row].id {
            discoverQueue.async {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let user = Core.currentUser {
                        user.likeRecipe(withId: id) { err in
                            guard err == nil else {
                                assertionFailure(err.debugDescription)
                                return
                            }
                        }
                        self.semaphore.signal()
                    }
                }
                self.semaphore.wait()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, collectWasPressedAt indexPath: IndexPath) {
        print("received!")
    }
    
}

//extension UICollectionView {
//    var widestCellWidth: CGFloat {
//        let insets = contentInset.left + contentInset.right
//        return bounds.width - insets
//    }
//}

// This protocol is for handling button pressing events on a cell.
// The class coforming to this protocol is informed by its collectionView of these events.
protocol DiscoverCollectionViewDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, favorWasPressedAt indexPath: IndexPath) -> Void
    
    func collectionView(_ collectionView: UICollectionView, collectWasPressedAt indexPath: IndexPath) -> Void
}

// This protocol is for handling button pressing events on a cell.
// The UICollectionView will be informed when a button pressing happens in a cell.
extension UICollectionView : DiscoverCellDelegate{
    func favorWasPressed(at indexPath: IndexPath) {
        if let del = delegate as? DiscoverCollectionViewDelegate? {
            del?.collectionView(self, favorWasPressedAt: indexPath)
        }
    }
    
    func collectWasPressed(at indexPath: IndexPath) {
        if let del = delegate as? DiscoverCollectionViewDelegate? {
            del?.collectionView(self, collectWasPressedAt: indexPath)
        }
    }
}


