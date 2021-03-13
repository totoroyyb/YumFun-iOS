//
//  DiscoverViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 2/20/21.
//

import UIKit
import PhotosUI
import FirebaseUI
import GradientLoadingBar

extension UICollectionView {
    var widestCellWidth: CGFloat {
        let insets = contentInset.left + contentInset.right
        return bounds.width - insets
    }
}

class DiscoverViewController: UIViewController, UICollectionViewDelegateFlowLayout, DiscoverCollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var recipes : [Recipe] = []
    
    let discoverQueue = DispatchQueue(label: "discoverQueue")
    let semaphore: DispatchSemaphore? = DispatchSemaphore(value: 6)
    
    private let pagination = Pagination(collectionPath: Recipe.collectionPath, limit: 5)
    private var hasMoreData = true
    private let leadingScreensForBatch: CGFloat = 2
    
    private let gradientLoadingBar = GradientActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(viewSetup), name: .userDidSet, object: nil)
        
        self.view.backgroundColor = UIColor(named: "collection_bg_color")
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "collection_bg_color")
        
        self.pagination.delegate = self
        
        self.view.addSubview(gradientLoadingBar)
        gradientLoadingBar.snp.makeConstraints { (make) in
            make.leading.equalTo(collectionView.snp.leading)
            make.trailing.equalTo(collectionView.snp.trailing)
            make.bottom.equalTo(collectionView.snp.bottom)
            make.height.equalTo(5)
        }
        
        if Core.currentUser != nil {
            viewSetup()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .userDidSet, object: nil)
        super.viewDidDisappear(animated)
    }
    
    @objc func viewSetup() {
        // Do any additional setup after loading the view.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        fetchNextBatch()
        
        let layout = self.collectionView.collectionViewLayout
        if let flowLayout = layout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(
                width: self.collectionView.frame.width - 40,
                // Make the height a reasonable estimate to
                // ensure the scroll bar remains smooth
                height: 300
            )
        }
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
    
    private func fetchNextBatch() {
        if hasMoreData {
            pagination.getNewBatch { (error, recipes: [Recipe]?, _) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    guard let newRecipes = recipes else {
                        print("No new data.")
                        self.hasMoreData = false
                        return
                    }
                    
                    self.recipes.append(contentsOf: newRecipes)
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

// DataSouce Implementation
extension DiscoverViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: integrate with view model
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width - 40,
                      height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let recipe = recipes[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverTextCell", for: indexPath) as? DiscoverTextCell else {
            assertionFailure("no discovertextcell")
            return DiscoverTextCell()
        }
        
        cell.title.text = recipe.title
        cell.delegate = collectionView
        cell.indexPath = indexPath
        
        self.setAuthorProfileImage(userID: recipe.author, profileImage: cell.profileImage)

        if let user = Core.currentUser, let id = recipe.id {
            cell.isFavored = user.likedRecipes.contains(id)
            cell.favorCount = recipe.likedCount
            cell.setUpButtonUI()
        }
        
        if recipe.picUrls.count == 0 {
            cell.recipeImage.image = UIImage(named: "empty_image_placeholder")
        } else {
            self.setCoverImages(firstUrl: recipe.picUrls[0], firstCover: cell.recipeImage)
        }
        
        cell.isHeroEnabled = true
        cell.profileImage.heroID = HeroIdType.profileImage.getIdStr(at: indexPath.row)
        cell.title.heroID = HeroIdType.recipeTitle.getIdStr(at: indexPath.row)
        return cell
    }
}

// UICollectionViewDelegate Implementation
extension DiscoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected! \(indexPath.row)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(identifier: "RecipeDetailViewController") as RecipeDetailViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        
        detailViewController.recipe = recipes[indexPath.row]
        
        detailViewController.recipeIndex = indexPath.row
        navigationController?.hero.isEnabled = true
        
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // DiscoverCollectionViewDelegate Implementation
    func collectionView(_ collectionView: UICollectionView, didFavorRecipeAt indexPath: IndexPath) {
        if let id = recipes[indexPath.row].id {
            discoverQueue.async {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let user = Core.currentUser {
                        user.likeRecipe(withId: id) { err in
                            if err != nil {
                                print(err.debugDescription)
                            }
                            self.semaphore?.signal()
                        }
                    }
                }
                self.semaphore?.wait()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnfavorRecipeAt indexPath: IndexPath) {
        if let id = recipes[indexPath.row].id {
            discoverQueue.async {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let user = Core.currentUser {
                        user.unlikeRecipe(withId: id) { err in
                            if err != nil {
                                print(err.debugDescription)
                            }
                            self.semaphore?.signal()
                        }
                    }
                }
                self.semaphore?.wait()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, collectWasPressedAt indexPath: IndexPath) {
        print("received!")
    }
}

extension DiscoverViewController: PaginationDelegate {
    func startFetchBatch() {
        gradientLoadingBar.fadeIn()
    }
    
    func endFetchBatch() {
        gradientLoadingBar.fadeOut()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - leadingScreensForBatch * scrollView.frame.size.height {
            fetchNextBatch()
        }
    }
}

