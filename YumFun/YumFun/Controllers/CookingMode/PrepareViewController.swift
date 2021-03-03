//
//  PrepareViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/2/21.
//

import UIKit

class PrepareViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var avatarCollectionView: UICollectionView!
    @IBOutlet weak var stepCollectionView: UICollectionView!
    
    var recipe: Recipe?
    var curSelectedUser: String = ""
    var assignment : [String: [Int]] = [:]
    var avatarUrls : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarCollectionView.dataSource = self
        avatarCollectionView.delegate = self
        stepCollectionView.dataSource = self
        stepCollectionView.delegate = self
        // Do any additional setup after loading the view.
        guard let rec = recipe else {
            assertionFailure("recipe is nil")
            return
        }
        // curSelectedUser =
        // avatarUrls =
    }
    
    // UICollectionViewDataSource Impelmentation
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let rec = recipe else {
            assertionFailure("recipe is nil")
            return 0
        }
        if collectionView == avatarCollectionView {
            return 2
        } else {
            return rec.steps.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let rec = recipe else {
            assertionFailure("recipe is nil")
            return UICollectionViewCell()
        }
        
        if collectionView == avatarCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as? AvatarCell ?? AvatarCell()
            
            cell.avatar.image = UIImage(named: "mascot")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StepCell", for: indexPath) as? StepCell ?? StepCell()
            
            cell.title.text = String(
                format: "Step %d/%d: %s",
                indexPath.row + 1,
                rec.steps.count,
                rec.steps[indexPath.row].title ?? "")
            
            return cell
        }
    }
    
    
    // UICollectionViewDelegate Implementation
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let rec = recipe else {
            assertionFailure("recipe is nil")
            return
        }
        
        if collectionView == avatarCollectionView {
            curSelectedUser = avatarUrls[indexPath.row]
        } else {
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
