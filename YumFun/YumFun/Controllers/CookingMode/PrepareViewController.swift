//
//  PrepareViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/2/21.
//

import UIKit
import Firebase
import JGProgressHUD
import MagazineLayout

class PrepareViewController: UIViewController {
    
    @IBOutlet weak var avatarCollectionView: UICollectionView!
    
    private lazy var stepCollectionView: UICollectionView = {
        let layout = MagazineLayout()
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        let stepCellXib = UINib(nibName: "StepCell",
                                         bundle: nil)
        collectionView.register(stepCellXib, forCellWithReuseIdentifier: StepCell.description())
          
        collectionView.isPrefetchingEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .always
        return collectionView
    }()
    
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
        
        self.view.addSubview(stepCollectionView)
        
        stepCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        stepCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(avatarCollectionView.snp.bottom).offset(10)
            make.bottom.equalTo(inviteButton.snp.top).offset(-10)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
        }
        
        if let sid = sessionID {  // user is invited, join session here
            let hud = JGProgressHUD()
            hud.textLabel.text = "Joining Room"
            hud.show(in: self.view)
            hud.interactionType = .blockAllTouches
            hud.backgroundColor = UIColor.black.alpha(0.5)
            
            self.listner = self.curUser
                .joinCollabSession(withSessionId: sid,
                                   completion: { error in
                                        DispatchQueue.main.async {
                                            hud.dismiss()
                                            if let err = error {
                                                displayWarningTopPopUp(title: "Error", description: "Failed to join the room.")
                                                print(err.localizedDescription)
                                            }
                                        }
                                   },
                                   whenChanged: { session in
                                        self.collabSession = session
                                        self.recipe = session.targetRecipe
                                        self.cookingViewController?.collabSession = session
                                   }
                )
                                            
        }
    }
    
    @IBAction func invitePressed() {
        if collabSession == nil {   // create and join a session
            let hud = JGProgressHUD()
            hud.textLabel.text = "Generating Link"
            hud.show(in: self.view)
            hud.interactionType = .blockAllTouches
            hud.backgroundColor = UIColor.black.alpha(0.5)
            
            inviteButton.isUserInteractionEnabled = false
            DispatchQueue.global(qos: .userInitiated).async {
                if let rid = self.recipe.id {
                    self.curUser.createCollabSession(withRecipeId: rid) {(error, sessionID) in
                        if let err = error {
                            DispatchQueue.main.async {
                                hud.dismiss()
                                displayWarningTopPopUp(title: "Error", description: "Failed to generate sharing link.")
                            }
                            print(err.localizedDescription)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            hud.dismiss()
                            hud.textLabel.text = "Joining Room"
                            hud.show(in: self.view)
                            
                            if let sid = sessionID {
                                self.sessionID = sid
                                
                                self.listner = self.curUser.joinCollabSession(
                                    withSessionId: sid,
                                    completion: {error in
                                        if let err = error {
                                            hud.dismiss()
                                            displayWarningTopPopUp(title: "Error", description: "Failed to join room.")
                                            print(err.localizedDescription)
                                            return
                                        }
                                        DispatchQueue.main.async {
                                            hud.dismiss()
                                            self.inviteButton.isUserInteractionEnabled = true
                                            self.invokeInvitationSharing()
                                        }
                                    },
                                    whenChanged: { session in
                                        self.collabSession = session
                                        self.cookingViewController?.collabSession = session
                                    })
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        hud.dismiss()
                        displayWarningTopPopUp(title: "Error", description: "Failed to fetch valid recipe id.")
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
        
        cookingViewController.recipe = self.recipe
        cookingViewController.curUser = self.curUser
        cookingViewController.avatarDic = self.avatarDic
        
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
            if let c = collectionView.dequeueReusableCell(withReuseIdentifier: StepCell.description(), for: indexPath) as? StepCell {
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
                cell.setCollectionViewVisible(true)
                cell.assigneeAvatars = session.workLoad[indexPath.row].assignee.map() {(avatarDic[$0] ?? avatarPlaceholder)}
                cell.notAssigned.isHidden = (cell.assigneeAvatars.count != 0)
                cell.collectionView.isHidden = (cell.assigneeAvatars.count == 0)
            } else {
                cell.notAssigned.isHidden = true
                cell.collectionView.isHidden = true
                cell.setCollectionViewVisible(false)
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
        
        imageView.sd_setImage(with: myStorage.fileRef,
                              placeholderImage: nil) { (image, error, cache, storageRef) in
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

extension PrepareViewController: UICollectionViewDelegateMagazineLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForFooterInSectionAtIndex index: Int) -> MagazineLayoutFooterVisibilityMode {
        return .hidden
//        return .visible(heightMode: .dynamic, pinToVisibleBounds: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForHeaderInSectionAtIndex index: Int) -> MagazineLayoutHeaderVisibilityMode {
        return .hidden
//        return .visible(heightMode: .dynamic, pinToVisibleBounds: true)
    }
    

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeModeForItemAt indexPath: IndexPath) -> MagazineLayoutItemSizeMode {
    let heightMode = MagazineLayoutItemHeightMode.dynamic
    let widthMode = MagazineLayoutItemWidthMode.fullWidth(respectsHorizontalInsets: true)
    
//    if collectionView == avatarCollectionView {
//        let widthMode = MagazineLayoutItemWidthMode.fractionalWidth(divisor: 6)
//        return MagazineLayoutItemSizeMode(widthMode: widthMode, heightMode: heightMode)
//    } else if collectionView == stepCollectionView {
//        return MagazineLayoutItemSizeMode(widthMode: widthMode, heightMode: heightMode)
//    }
    return MagazineLayoutItemSizeMode(widthMode: widthMode, heightMode: heightMode)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForBackgroundInSectionAtIndex index: Int) -> MagazineLayoutBackgroundVisibilityMode {
    return .hidden
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, horizontalSpacingForItemsInSectionAtIndex index: Int) -> CGFloat {
    return  12
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, verticalSpacingForElementsInSectionAtIndex index: Int) -> CGFloat {
    return  15
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSectionAtIndex index: Int) -> UIEdgeInsets {
//    if collectionView == avatarCollectionView {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
    
    return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForItemsInSectionAtIndex index: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
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
