//
//  PrepareViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/2/21.
//

import UIKit
import Firebase

class PrepareViewController: UIViewController {
    
    @IBOutlet weak var avatarCollectionView: UICollectionView!
    @IBOutlet weak var stepCollectionView: UICollectionView!
    
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    
    var cookingViewController : CookingViewController?
    
    var recipe: Recipe = Recipe()
    
    private var curUser: User {
        get {
            guard let user = Core.currentUser else {
                assertionFailure("user is nil")
                return User()
            }
            return user
        }
    }
    
    private var avatarDic : [String: UIImage?] = [:] {
        didSet {
            stepCollectionView.reloadData()
        }
    }  // userid -> profileimage
    
    private var collabSession : CollabSession? {
        didSet {
            avatarCollectionView.reloadData()
            stepCollectionView.reloadData()
        }
    }
    
    var sessionID : String?
    
    private var listner: ListenerRegistration?
    
    let avatarPlaceholder = UIImage(named: "mascot")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Basic UI set up
        navigationController?.isNavigationBarHidden = true
        
        avatarCollectionView.dataSource = self
        stepCollectionView.dataSource = self
        stepCollectionView.delegate = self
        
        let layout = stepCollectionView.collectionViewLayout
        if let flowLayout = layout as? UICollectionViewFlowLayout{
            flowLayout.estimatedItemSize = CGSize(
                width: view.frame.width - 20,
                // Make the height a reasonable estimate to
                // ensure the scroll bar remains smooth
                height: 500
            )
        }
        
        if let sid = sessionID {  // user is invited, join session here
            self.listner = self.curUser.joinCollabSession(withSessionId: sid,
                                           completion: {error in
                                            if let err = error {
                                                print(err.localizedDescription)
                                            }
                                           },
                                           whenChanged: { session in
                                            self.collabSession = session
                                            self.recipe = session.targetRecipe
                                            self.cookingViewController?.collabSession = session
                                           })
        }
    }
    
    @IBAction func invitePressed() {
        if collabSession == nil {   // create and join a session
            inviteButton.isUserInteractionEnabled = false
            DispatchQueue.global(qos: .userInitiated).async {
                if let rid = self.recipe.id {
                    self.curUser.createCollabSession(withRecipeId: rid) {(error, sessionID) in
                        if let err = error {
                            print(err.localizedDescription)
                            return
                        }
                        
                        if let sid = sessionID {
                            self.sessionID = sid
                            
                            self.listner = self.curUser.joinCollabSession(
                                withSessionId: sid,
                                completion: {error in
                                    if let err = error {
                                        print(err.localizedDescription)
                                    }
                                    self.inviteButton.isUserInteractionEnabled = true
                                    self.invokeInvitationSharing()
                                },
                                whenChanged: { session in
                                    self.collabSession = session
                                    self.cookingViewController?.collabSession = session
                                })
                        }
                    }
                }
            }
        } else {
            invokeInvitationSharing()
        }
    }
    
    private func invokeInvitationSharing() {
        if let sid = sessionID {
            let items = [URL(string: "yumfun://collabcook/join?sessionid=\(sid)")]
            let ac = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
            present(ac, animated: true)
        }
    }
    
    @IBAction func leavePressed() {
        if let session = collabSession, let lis = listner, let sid = session.id {
            curUser.leaveCollabSession(withSessionId: sid, withListener: lis) {error in
                if let err = error {
                    print(err.localizedDescription)
                }
            }
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startPressed() {
        let storyboard = UIStoryboard(name: "Cooking", bundle: nil)
        guard let cookingViewController = storyboard.instantiateViewController(withIdentifier: "CookingViewController") as? CookingViewController else {
            assertionFailure("couldn't find CookingViewController")
            return
        }
        
        if let session = collabSession {  // collab Mode
            // check step assignment completion
            for stepAssignment in session.workLoad {
                if stepAssignment.assignee.count == 0 {
                    print("need to complete step assignment first")
                    return
                }
            }
            
            // ready for navigating to cooking mode
            cookingViewController.collabSession = self.collabSession
            cookingViewController.listner = self.listner
        }
        
        cookingViewController.recipe = self.recipe
        cookingViewController.curUser = self.curUser
        cookingViewController.avatarDic = self.avatarDic
        self.cookingViewController = cookingViewController
        navigationController?.pushViewController(cookingViewController, animated: true)
    }
}
    
// UICollectionViewDataSource Impelmentation
extension PrepareViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == avatarCollectionView {
            if let session = collabSession {
                return session.participants.count
            } else {
                return 1  // cooking by onself
            }
        } else {
            return recipe.steps.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == avatarCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as? AvatarCell ?? AvatarCell()
            
            if indexPath.row == 0 {  // display the current user's avatar first
                if let uid = curUser.id {
                    setAvatar(userID: uid, imageView: cell.avatar)
                    cell.avatar.setBorder(width: 2.0, color: UIColor(named: "primary")?.cgColor)
                }
            } else {  // display others' avatars
                let userID = getOtherParticipants()[indexPath.row - 1]
                setAvatar(userID: userID, imageView: cell.avatar)
                cell.avatar.setBorder(width: 2.0, color: UIColor(named: "text_high_emphasis")?.cgColor)
            }
            
            return cell
        } else {
            var cell: StepCell
            if let c = collectionView.dequeueReusableCell(withReuseIdentifier: "StepCell", for: indexPath) as? StepCell {
                cell = c
            } else {
                cell = StepCell()
            }
            
            // Basic UI set up
            cell.title.text = String(
                format: "Step %d/%d: %@",
                indexPath.row + 1,
                recipe.steps.count,
                recipe.steps[indexPath.row].title ?? "")
            
            cell.descrip.text = recipe.steps[indexPath.row].description
            
            cell.collectionView.dataSource = cell
            cell.collectionView.delegate = cell
            
            if let session = collabSession {  // collab mode
                
                cell.assigneeAvatars = session.workLoad[indexPath.row].assignee.map() {(avatarDic[$0] ?? avatarPlaceholder)}
                cell.notAssigned.isHidden = (cell.assigneeAvatars.count != 0)
                cell.collectionView.isHidden = (cell.assigneeAvatars.count == 0)
                
                if let uid = curUser.id,
                session.workLoad[indexPath.row].assignee.contains(uid) {
                    cell.layer.backgroundColor = UIColor.blue.cgColor
                } else {
                    cell.layer.backgroundColor = UIColor.clear.cgColor
                }
            } else {
                cell.notAssigned.isHidden = true
                cell.collectionView.isHidden = true
            }
            
            return cell
        }
    }
    
    private func setAvatar(userID: String, imageView: UIImageView) {
        if let image = avatarDic[userID] {
            imageView.image = image
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                self.getAndSetAvatar(userID: userID, imageView: imageView)
            }
        }
    }
    
    private func getAndSetAvatar(userID: String, imageView: UIImageView) {
        let myStorage = CloudStorage(AssetType.profileImage)
        myStorage.child("\(userID).jpeg")
        
        imageView.sd_setImage(
            with: myStorage.fileRef,
            maxImageSize: 1 * 2048 * 2048,
            placeholderImage: nil,
            options: [.progressiveLoad]) { (image, error, cache, storageRef) in
        
            if let err = error {
                print(err.localizedDescription)
                self.avatarDic[userID] = self.avatarPlaceholder
            } else {
                self.avatarDic[userID] = image // update avatarDic
            }
            self.stepCollectionView.reloadData()
        }
    }
    
    private func getOtherParticipants() -> [String] {
        guard let session = collabSession else {return []}
        return session.participants.filter() {$0 != curUser.id}
    }
    
}

// UICollectionViewDelegate Implementation
extension PrepareViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == stepCollectionView {
            if let session = collabSession, let uid = curUser.id {
                session.toggleAssignee(at: indexPath.row, forUser: uid) { err in
                    if err != nil {
                        print(err.debugDescription)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == stepCollectionView {
            if let session = collabSession, let uid = curUser.id {
                session.toggleAssignee(at: indexPath.row, forUser: uid) { err in
                    if err != nil {
                        print(err.debugDescription)
                    }
                }
            }
            
        }

    }
}
