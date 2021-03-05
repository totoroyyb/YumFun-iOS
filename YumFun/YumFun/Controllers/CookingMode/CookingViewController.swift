//
//  CookingViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/4/21.
//

import UIKit
import Firebase

class CookingViewController: UIViewController {

    @IBOutlet weak var avatarCollectionView: UICollectionView!
    @IBOutlet weak var stepCollectionView: UICollectionView!
    
    var recipe = Recipe()
    var curUser = User()
    var avatarDic : [String: UIImage?] = [:]
    var collabSession: CollabSession?
    var listner: ListenerRegistration?
    
    let avatarPlaceholder = UIImage(named: "mascot")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stepCollectionView.delegate = self
        stepCollectionView.dataSource = self
        avatarCollectionView.dataSource = self
        
        let layout = stepCollectionView.collectionViewLayout
        if let flowLayout = layout as? UICollectionViewFlowLayout{
            flowLayout.estimatedItemSize = CGSize(
                width: view.frame.width - 20,
                // Make the height a reasonable estimate to
                // ensure the scroll bar remains smooth
                height: 100
            )
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

extension CookingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == avatarCollectionView {
            if let session = collabSession {
                return session.participants.count
            } else {
                return 1
            }
        } else {
            print(avatarDic.count)
            return recipe.steps.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == avatarCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as? AvatarCell ?? AvatarCell()
            
            if indexPath.row == 0 {  // display the current user's avatar first
                if let uid = curUser.id {
                    cell.avatar.image = avatarDic[uid] ?? avatarPlaceholder
                    cell.avatar.chooseWithBorder(width: 5.0, color: UIColor.blue.cgColor)
                }
            } else {  // display others' avatars
                let uid = getOtherParticipants()[indexPath.row - 1]
                cell.avatar.image = avatarDic[uid] ?? avatarPlaceholder
            }

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CookingStepCell", for: indexPath) as? CookingStepCell ?? CookingStepCell()
            
            // basic UI set up
            cell.title.text = String(
                format: "Step %d/%d: %@",
                indexPath.row + 1,
                recipe.steps.count,
                recipe.steps[indexPath.row].title ?? "")
            cell.checkButton.setImage(UIImage(systemName: "checkmark.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
            cell.timerButton.setImage(UIImage(systemName: "clock")?.withRenderingMode(.alwaysTemplate), for: .normal)

            
            if let session = collabSession {  // collab mode
                cell.collectionView.dataSource = cell
                cell.collectionView.delegate = cell
                
                cell.assigneeAvatars = session.workLoad[indexPath.row].assignee.map() {(avatarDic[$0] ?? avatarPlaceholder)}
                
                // special UI for assigned steps
                if let uid = curUser.id,
                session.workLoad[indexPath.row].assignee.contains(uid) {
                    cell.layer.backgroundColor = UIColor.blue.cgColor
                    cell.checkButton.isHidden = false
                    cell.timerButton.isHidden = false
                } else {
                    cell.layer.backgroundColor = UIColor.clear.cgColor
                    cell.checkButton.isHidden = true
                    cell.timerButton.isHidden = true
                }
            } else {
                if cell.collectionView != nil {
                    cell.collectionView.removeFromSuperview()
                }
            }
            
            cell.indexPath = indexPath
            cell.delegate = stepCollectionView
            return cell
        }
    }
    
    private func getOtherParticipants() -> [String] {
        guard let session = collabSession else {return []}
        return session.participants.filter() {$0 != curUser.id}
    }
    
//    private func checkAssigned(at indexPath: IndexPath, session: CollabSession) -> Bool {
//        if let uid = curUser.id {
//            return session.workLoad[indexPath.row].assignee.contains(uid)
//        }
//        return false
//    }
}

extension CookingViewController: UICollectionViewDelegate {
}

extension UICollectionView: CookingStepCellDelegate {
    func didCheckCellAt(at indexPath: IndexPath) {
        if let del = delegate as? StepCollectionViewControllerDelegate {
            del.didCheckCellAt(self, at: indexPath)
        }
    }
}

// StepCollectionViewControllerDelegate notifies the mater view controller that a child collectionView has detected a button click on its cell
// TODO: integrate with DiscoverView protocols
protocol StepCollectionViewControllerDelegate: UICollectionViewDelegate {
    func didCheckCellAt(_ collectionView: UICollectionView, at indexPath: IndexPath)
}

extension CookingViewController: StepCollectionViewControllerDelegate {
    func didCheckCellAt(_ collectionView: UICollectionView, at indexPath: IndexPath) {
        print("check!")
        // dismiss the step
        if let session = collabSession {  // collab Mode
            session.toggleStepCompletion(at: indexPath.row) { error in
                if let err = error {
                    print(err.localizedDescription)
                } else {
                    collectionView.performBatchUpdates({
                        collectionView.reloadSections(IndexSet.init(integersIn: 0...0))
                    }, completion: nil)
                }
                
            }
        } else {  // cooking by oneself
            recipe.steps.remove(at: indexPath.row)
            collectionView.performBatchUpdates({
                collectionView.reloadSections(IndexSet.init(integersIn: 0...0))
            }, completion: nil)
        }
        
    }
}
