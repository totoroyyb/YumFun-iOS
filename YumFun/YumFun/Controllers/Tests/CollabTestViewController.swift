//
//  CollabTestViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/1.
//

import UIKit
import FirebaseFirestore

class CollabTestViewController: UIViewController {
    @IBOutlet weak var completionIndicatorLabel: UILabel!
    @IBOutlet weak var joinSessionTextField: UITextField!
    
    let recipeId = "oE8pFLooVeI8hTnoK9Wy"
    
    var sessionID: String = ""
    
    var currentSession: CollabSession?
    
    var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createSessionTapped(_ sender: Any) {
        guard let currUser = Core.currentUser, let currId = currUser.id else {
            return
        }
        
        CollabSession.createSession(withHostId: currId, withRecipeId: recipeId) { (error, sessionID) in
            guard error == nil, let sessionID = sessionID else {
                print("Error to create session: \(error)")
                return
            }
            self.sessionID = sessionID
            print("New Session ID is: \(sessionID)")
        }
    }
    
    @IBAction func joinSessionTapped(_ sender: Any) {
        guard let currUser = Core.currentUser, let currId = currUser.id else {
            return
        }
        
        guard let joinId = joinSessionTextField.text else {
            return
        }
        
        listener = CollabSession.joinSession(withSessionId: joinId, withParticipantId: currId) { (error) in
            if let error = error {
                print("Error in joining session \(error)")
            } else {
                print("Join successfully")
            }
        } whenChanged: { (newSession) in
            print("Session Updated\n\(newSession)")
            self.currentSession = newSession
            
            guard let session = self.currentSession else {
                return
            }
            
            let workload = session.workLoad[0]
            
            let target = workload.targetStep
            let result = session.targetRecipe.steps.first { (step) -> Bool in
                step.stepId == target
            }
            
            self.completionIndicatorLabel.text = workload.isCompleted ? "Completed \(result?.title)" : "Incompleted \(result?.title)"
        }
    }
    
    @IBAction func toggleStepCompletionTapped(_ sender: Any) {
//        guard let firstStepId = currentRecipe?.steps[0].stepId else {
//            print("Step id cannot be fetched.")
//            return
//        }
        
//        currentSession?.toggleStepCompletion(for: firstStepId)
        currentSession?.toggleStepCompletion(at: 0, { (error) in
            if let error = error {
                print("Error to toggle: \(error)")
            } else {
                print("Toggle successful.")
            }
        })
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
