//
//  DiscoverViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 2/20/21.
//

import UIKit

class DiscoverViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DiscoverCollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
//        collectionView.register(DiscoverImageCell.self, forCellWithReuseIdentifier: "DiscoverImageCell")
        
        let layout = collectionView.collectionViewLayout
        if let flowLayout = layout as? UICollectionViewFlowLayout{
            flowLayout.estimatedItemSize = CGSize(
                width: view.frame.width,
                // Make the height a reasonable estimate to
                // ensure the scroll bar remains smooth
                height: 300
            )
        }
    }
    
//    let testData : [(UIImage?, UIImage?)] = [(nil,nil), (nil,nil), (nil,nil), (nil,nil), (nil,nil), (nil,nil), (nil,nil)]
    
    let testData = [(nil, nil), (UIImage(named: "mascot"), UIImage(named: "mascot")), (nil, nil), (UIImage(named: "mascot"), nil), (UIImage(named: "mascot"), UIImage(named: "mascot")), (nil, nil), (UIImage(named: "mascot"), nil)]
    
    
    // DataSouce Implementation
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: integrate with view model
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image1 = testData[indexPath.row].0
        let image2 = testData[indexPath.row].1
        
        if let img1 = image1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverImageCell", for: indexPath) as? DiscoverImageCell ?? DiscoverImageCell()
            
            // set up cover images
            cell.coverImage1.image = img1
            cell.coverImage1.contentMode = .scaleAspectFit
            
            if let img2 = image2 {
                cell.coverImage2.image = img2
                cell.coverImage2.contentMode = .scaleAspectFit
            } else {
                cell.coverImage2.image = nil
            }
            
            // profile image
            cell.profileImage.image = UIImage(named: "Launch")
            
            // buttons
            cell.delegate = collectionView
            cell.indexPath = indexPath
            
            // TODO: set isFavored and isCollected based on thumbs up of the recipe, user favored list, user collected list
            cell.isFavored = false
            cell.favorCount = 0
            cell.isCollected = false
            cell.setUpButtonUI()
            
            return cell
        } else {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverTextCell", for: indexPath) as? DiscoverTextCell else {
                assertionFailure("no discovertextcell")
                return DiscoverTextCell()
            }
            
            cell.descrip.text = "\(indexPath.row)"
            
            cell.delegate = collectionView
            cell.indexPath = indexPath
            
            // profile image
            cell.profileImage.image = UIImage(named: "Launch")
            
            // TODO: set isFavored and isCollected
            cell.isFavored = false
            cell.favorCount = 0
            cell.isCollected = false
            cell.setUpButtonUI()
            
            return cell
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
        print("received!")
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


