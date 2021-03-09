//
//  ContentViewController.swift
//  YumFun
//
//  Created by Failury on 3/6/21.
//

import UIKit
import SegementSlide

class ContentViewController: UICollectionViewController, SegementSlideContentScrollViewDelegate {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return List.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileRecipeCell", for: indexPath) as! ProfileRecipeCell
        
        cell.PreviewImage.image = UIImage(named: "empty_image_placeholder")

        let recipeId = List[indexPath.row]
        
        let recipe = recipeCache[recipeId]
        
        if let cachedRecipe = recipe {
            if let firstUrl = cachedRecipe.picUrls.first {
                let myStorage = CloudStorage(firstUrl)
                cell.PreviewImage.sd_setImage(with: myStorage.fileRef,placeholderImage: nil,completion: nil)
            }
            cell.Title.text = cachedRecipe.title
        } else {
            Recipe.get(named: recipeId) { (error, recipe, _) in
                guard error == nil, let fetchedRecipe = recipe, let fetchedId = fetchedRecipe.id else {
                    return
                }
                self.recipeCache[fetchedId] = fetchedRecipe
                
                if fetchedId == recipeId {
                    if let firstUrl = fetchedRecipe.picUrls.first {
                        let myStorage = CloudStorage(firstUrl)
                        cell.PreviewImage.sd_setImage(with: myStorage.fileRef,placeholderImage: nil,completion: nil)
                    }
                    cell.Title.text = fetchedRecipe.title
                }
            }
        }

        return cell
    }
    
    var List = [String]()
    private var recipeCache = [String : Recipe]()
    
    @objc var scrollView: UIScrollView {
        return collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "ProfileRecipeCell", bundle: nil), forCellWithReuseIdentifier: "ProfileRecipeCell")
        collectionView.backgroundColor = UIColor(named: "collection_bg_color")
        self.collectionView.reloadData()
    }
}

extension ContentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
    }
}
