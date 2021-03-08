//
//  CookingViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/4/21.
//

import UIKit
import Firebase
import JJFloatingActionButton

enum ModelClass {
    static let round = "0 round"
    static let palm = "1 palm"
    static let side = "2 fist"
    static let background = "3 background"
}

class CookingViewController: UIViewController {

    @IBOutlet weak var avatarCollectionView: UICollectionView!
    @IBOutlet weak var stepCollectionView: UICollectionView!
    var handsFreeButton = JJFloatingActionButton()
    
    // for collab mode
    var recipe = Recipe()
    private lazy var completeStatus : [Bool] = {
        return [Bool](repeating: false, count: recipe.steps.count)
    }()
    var curUser = User()
    var avatarDic : [String: UIImage?] = [:]
    var collabSession: CollabSession? {
        didSet {
            stepCollectionView?.reloadData()
        }
    }
    var listner: ListenerRegistration?
    var curStep: Int = 0  // index of the current step
    
    let avatarPlaceholder = UIImage(named: "mascot")
    
    // gesture recognition
    private var modelDataHandler: ModelDataHandler? = ModelDataHandler(modelFileInfo: MobileNet.modelInfo, labelsFileInfo: MobileNet.labelsInfo)
    
    private var camera: CameraFeedManager?
        
    private var firstPress = true
    private var isCapturing = false
    
    private var previousInference = Date().timeIntervalSince1970 * 1000  // current time in ms
    private var inferenceInterval = 1000 // in ms
    private var reinforceClass = ModelClass.background
    private var reinforceCount = 0  // track the number of successive recognized gestures
    private var previousClass = ModelClass.background
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // data source & delegate
        stepCollectionView.delegate = self
        stepCollectionView.dataSource = self
        avatarCollectionView.dataSource = self
        
        // Floting button
        view.addSubview(handsFreeButton)
        handsFreeButton.translatesAutoresizingMaskIntoConstraints = false
        handsFreeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        handsFreeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        handsFreeButton.handleSingleActionDirectly = true
        handsFreeButton.buttonImage = UIImage(systemName: "hand.raised.slash.fill")
        handsFreeButton.buttonDiameter = 65
        handsFreeButton.buttonImageColor = UIColor(named: "text_high_emphasis") ?? UIColor.white
        handsFreeButton.buttonColor = UIColor(named: "primary") ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8)
        handsFreeButton.buttonImageSize = CGSize(width: 30, height: 30)
        handsFreeButton.layer.shadowColor = UIColor(named: "shadow_color")?.cgColor ?? UIColor.clear.cgColor
        handsFreeButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        handsFreeButton.layer.shadowOpacity = Float(0.4)
        handsFreeButton.layer.shadowRadius = CGFloat(2)
        
        handsFreeButton.addItem(title: nil, image: nil) {[weak self] _ in
            self?.handsFreePressed()
        }
        
        // cur step
        if let indexPath = getNextStep() {
            curStep = indexPath.row
        }
        
        // model handler check
        if modelDataHandler == nil {
            print("model initialization falied")
        }
        
        // camera set up
        camera = CameraFeedManager()
        camera?.delegate = self
        
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
    

    private func handsFreePressed() {
        if !isCapturing {
            if firstPress {
                camera?.checkCameraConfigurationAndStartSession()
                firstPress = false
            } else {
                camera?.resumeInterruptedSession { success in
                    print("Resume \(success ? "Successfully" : "Failed")")
                }
            }
            isCapturing = true
            handsFreeButton.buttonImage = UIImage(systemName: "hand.raised.fill")
        } else {
            camera?.stopSession()
            isCapturing = false
            handsFreeButton.buttonImage = UIImage(systemName: "hand.raised.slash.fill")
        }

    }
    
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
                    cell.avatar.setBorder(width: 2.0, color: UIColor(named: "primary")?.cgColor)
                }
            } else {  // display others' avatars
                let uid = getOtherParticipants()[indexPath.row - 1]
                cell.avatar.image = avatarDic[uid] ?? avatarPlaceholder
                cell.avatar.setBorder(width: 2.0, color: UIColor(named: "text_high_emphasis")?.cgColor)
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
            cell.layer.backgroundColor = UIColor(named: "cell_bg_color")?.cgColor
            cell.layer.borderWidth = 0.0
            
        
            // TODO: change timer appearance based on status
            cell.timerButton.setImage(UIImage(systemName: "clock")?.withRenderingMode(.alwaysTemplate), for: .normal)

            
            if let session = collabSession {  // collab mode
                cell.collectionView.dataSource = cell
                cell.collectionView.delegate = cell
                
                cell.assigneeAvatars = session.workLoad[indexPath.row].assignee.map() {(avatarDic[$0] ?? avatarPlaceholder)}
                
                // special UI for checked steps
                if session.workLoad[indexPath.row].isCompleted {
                    cell.layer.backgroundColor = UIColor(named: "text_low_emphasis")?.cgColor
                    cell.checkButton.isUserInteractionEnabled = false
                    cell.checkButton.isHidden = false
                    cell.timerButton.isHidden = true
                    cell.checkButton.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
                } else {
                    // special UI for assigned steps
                    cell.checkButton.setImage(UIImage(systemName: "checkmark.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
                    if let uid = curUser.id,
                    session.workLoad[indexPath.row].assignee.contains(uid) {
                        cell.layer.borderColor = UIColor(named: "secondary")?.cgColor
                        cell.layer.borderWidth = 1.0
                        cell.checkButton.isUserInteractionEnabled = true
                        cell.checkButton.isHidden = false
                        cell.timerButton.isHidden = false
                    } else {
                        cell.checkButton.isHidden = true
                        cell.timerButton.isHidden = true
                    }
                }
            } else {  // cooking by oneself
                if completeStatus[indexPath.row] {  // checked steps
                    cell.layer.backgroundColor = UIColor(named: "text_low_emphasis")?.cgColor
                    cell.checkButton.isUserInteractionEnabled = false
                    cell.timerButton.isHidden = true
                    cell.checkButton.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
                } else {  // unchecked
                    cell.checkButton.isUserInteractionEnabled = true
                    cell.timerButton.isHidden = false
                    cell.checkButton.setImage(UIImage(systemName: "checkmark.circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
                }
                if cell.collectionView != nil {
                    cell.collectionView.removeFromSuperview()
                }
            }
            
            // special UI for cur step
            if indexPath.row == curStep {
                cell.layer.borderColor = UIColor(named: "primary")?.cgColor
                cell.layer.borderWidth = 2.8
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
                    if let indexPath = self.getNextStep() {
                        self.curStep = indexPath.row
                    }
                    collectionView.performBatchUpdates({
                        collectionView.reloadSections(IndexSet.init(integersIn: 0...0))
                    }) { _ in
                        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                    }
                }
            }
        } else {  // cooking by oneself
            completeStatus[indexPath.row] = true
            if let indexPath = self.getNextStep() {
                self.curStep = indexPath.row
               
            }
            collectionView.performBatchUpdates({
                collectionView.reloadSections(IndexSet.init(integersIn: 0...0))
            }) { _ in
                collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
        
    }
    
    private func getNextStep() -> IndexPath? {
        if let session = collabSession, let uid = curUser.id {
            for (i, load) in session.workLoad.enumerated() {
                if load.assignee.contains(uid) && !load.isCompleted {
                    return IndexPath(row: i, section: 0)
                }
            }
            return nil
        } else {
            for (i, complete) in completeStatus.enumerated() {
                if !complete {
                    return IndexPath(row: i, section: 0)
                }
            }
            return nil
        }
    }
}

// gesture recognization model data handling
extension CookingViewController {
    private func handleResult(modelClass: String) {
        switch modelClass {
        case ModelClass.palm:
            print("palm")
            if previousClass != ModelClass.palm {
                collectionView(stepCollectionView, didSelectItemAt: IndexPath(row: curStep, section: 0))
            }
            break
        case ModelClass.side:
            print("side")
            if presentedViewController != nil {
                presentedViewController?.dismiss(animated: true, completion: nil)
            }
            break
        case ModelClass.round:
            print("round")
            if presentedViewController != nil {
                presentedViewController?.dismiss(animated: true, completion: nil)
            }
            didCheckCellAt(stepCollectionView, at: IndexPath(row: curStep, section: 0))
            break
        default:
            break
        }
    }
}

// gesture recognization camera capture
extension CookingViewController: CameraFeedManagerDelegate {
    func didOutput(pixelBuffer: CVPixelBuffer) {
        let currentTime = Date().timeIntervalSince1970 * 1000
        guard Int(currentTime - previousInference) >= inferenceInterval else {
            return
        }
        previousInference = currentTime
        
        let result = modelDataHandler?.runModel(onFrame: pixelBuffer)
        
        DispatchQueue.main.async {
            if let res = result {
                let inference = res.inferences[0]
                if inference.label != ModelClass.background {
                    if self.reinforceClass == inference.label {  // same gesture detected
                        self.reinforceCount += 1  // reinforce gesture
                        if self.reinforceCount == 3 {  // confirm gesture and reset
//                            self.resultLabel.text = inference.label
                            self.handleResult(modelClass: self.reinforceClass)
                            self.reinforceCount = 0
                            self.reinforceClass = ModelClass.background
                            
                            self.inferenceInterval = 2000
                        }
                    } else if self.reinforceClass == ModelClass.background{
                        self.reinforceClass = inference.label  // first time
                        self.reinforceCount += 1
                        
                        self.inferenceInterval = 500
                    } else { // not same gesture, reset
                        self.reinforceClass = ModelClass.background
                        self.reinforceCount = 0
                    }
                } else {
                    self.reinforceClass = ModelClass.background
                    self.reinforceCount = 0
//                    self.resultLabel.text = inference.label
                }
            }
        }
    }
    
    func presentCameraPermissionsDeniedAlert() {
        let alert = UIAlertController(title: "Camera Permision Denied", message: "Please change Permission settings in system settings to ", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentVideoConfigurationErrorAlert() {
        let alert = UIAlertController(title: "Video Configure Error", message: "THere is an error configuring the camera", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    func sessionRunTimeErrorOccured() {
        print("session runtime error")
    }
    
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
        print("session was interrupted")
    }
    
    func sessionInterruptionEnded() {
        print("session interrupt ended")
    }
    
    
}

