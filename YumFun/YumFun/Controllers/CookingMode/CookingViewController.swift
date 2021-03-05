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
    private lazy var completeStatus : [Bool] = {
        return [Bool](repeating: false, count: recipe.steps.count)
    }()
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
    
    @IBAction func leavePressed() {
        if let session = collabSession, let lis = listner, let sid = session.id {
            curUser.leaveCollabSession(withSessionId: sid, withListener: lis) { error in
                if let err = error {
                    print(err.localizedDescription)
                }
            }
        }
       
        dismiss(animated: true, completion: nil)
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

            // TODO: change timer appearance based on status
            cell.timerButton.setImage(UIImage(systemName: "clock")?.withRenderingMode(.alwaysTemplate), for: .normal)

            
            if let session = collabSession {  // collab mode
                cell.collectionView.dataSource = cell
                cell.collectionView.delegate = cell
                
                cell.assigneeAvatars = session.workLoad[indexPath.row].assignee.map() {(avatarDic[$0] ?? avatarPlaceholder)}
                
                // special UI for checked steps
                if session.workLoad[indexPath.row].isCompleted {
                    cell.layer.backgroundColor = UIColor.red.cgColor
                    cell.checkButton.isUserInteractionEnabled = false
                    cell.checkButton.isHidden = false
                    cell.timerButton.isHidden = true
                    cell.checkButton.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
                } else {
                    // special UI for assigned steps
                    cell.checkButton.setImage(UIImage(systemName: "checkmark.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
                    if let uid = curUser.id,
                    session.workLoad[indexPath.row].assignee.contains(uid) {
                        cell.layer.backgroundColor = UIColor.blue.cgColor
                        cell.checkButton.isUserInteractionEnabled = true
                        cell.checkButton.isHidden = false
                        cell.timerButton.isHidden = false
                    } else {
                        cell.layer.backgroundColor = UIColor.clear.cgColor
                        cell.checkButton.isHidden = true
                        cell.timerButton.isHidden = true
                    }
                }
            } else {  // cooking by oneself
                if completeStatus[indexPath.row] {  // checked steps
                    cell.layer.backgroundColor = UIColor.red.cgColor
                    cell.checkButton.isUserInteractionEnabled = false
                    cell.timerButton.isHidden = true
                    cell.checkButton.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
                } else {  // unchecked
                    cell.layer.backgroundColor = UIColor.clear.cgColor
                    cell.checkButton.isUserInteractionEnabled = true
                    cell.timerButton.isHidden = false
                    cell.checkButton.setImage(UIImage(systemName: "checkmark.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
                }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Cooking", bundle: nil)
        guard let stepDetailViewController = storyboard.instantiateViewController(withIdentifier: "StepDetailViewController") as? StepDetailViewController else {
            assertionFailure("couldn't find StepDetailViewController")
            return
        }
        
        stepDetailViewController.index = indexPath.row
        stepDetailViewController.recipe = recipe
        present(stepDetailViewController, animated: true)
    }
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
                    }) {[weak self] _ in
                        if let indexPath = self?.getNextStep() {
                            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        } else {  // cooking by oneself
            completeStatus[indexPath.row] = true
           
            collectionView.performBatchUpdates({
                collectionView.reloadSections(IndexSet.init(integersIn: 0...0))
            }) { [weak self] _ in
                if let indexPath = self?.getNextStep() {
                    collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                }
            }
        }
        
    }
    
    private func getNextStep() -> IndexPath? {
        if let session = collabSession, let uid = curUser.id {
            for (i, load) in session.workLoad.enumerated() {
                if load.assignee.contains(uid) && !load.isCompleted {
                    return IndexPath(index: i)
                }
            }
            return nil
        } else {
            for (i, complete) in completeStatus.enumerated() {
                if !complete {
                    return IndexPath(index: i)
                }
            }
            return nil
        }
    }
    
    
}
