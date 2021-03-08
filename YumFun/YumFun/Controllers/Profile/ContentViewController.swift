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
//        return List.count
        return 8
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileRecipeCell", for: indexPath) as! ProfileRecipeCell
        cell.PreviewImage.image = #imageLiteral(resourceName: "Goopy")
        cell.Title.text = "placveholder"
        if List.count > 0{
            Recipe.get(named: List[indexPath.row]) { (Error, Recipe, DocumentSnapshot) in
                if Error == nil{
                    guard let recipeid = Recipe?.id else {return}
                    let myStorage = CloudStorage(.recipeImage)
                    myStorage.child(recipeid + ".jpeg")
                    cell.PreviewImage.sd_setImage(with: myStorage.fileRef,placeholderImage: nil,completion: nil)
                    guard let recipetitle = Recipe?.title else {return}
                    cell.Title.text = recipetitle

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
        collectionView.register(UINib(nibName: "ProfileRecipeCell", bundle: nil), forCellWithReuseIdentifier: "ProfileRecipeCell")
        collectionView.backgroundColor = UIColor.clear
        self.collectionView.reloadData()
    }
}
