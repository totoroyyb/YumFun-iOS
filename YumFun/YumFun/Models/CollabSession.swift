//
//  CollabSession.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/1.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class CollabSession: Identifiable, Codable {
    @DocumentID var id: String?
    
    @ServerTimestamp var lastUpdated: Timestamp?
    
    var host: String
    
    var participants = [String]()
    
    /**
     Base recipe which the collab session is based on.
     
     This recipe will be stored when the collab session is created. So the data won't change even if the original recipe has been updated.
     */
    var targetRecipe: Recipe
    
    /**
     Used to track which step is completed, and assignee of each step
     
     This array index is corresponding to the steps in the recipe object.
     */
    var workLoad = [StepAssignment]()
    
    var started = false
    
    var ended = false
    
    init(host: String, targetRecipe: Recipe){
        self.host = host
        self.targetRecipe = targetRecipe
    }
}

class StepAssignment: Codable {
    // UUID to track the corresponding step
    var targetStep: String
    
    // Track whether this step is finished or not
    var isCompleted: Bool = false
    
    // Users who are in charge of this step
    var assignee = [String]()
    
    init(stepId: String) {
        self.targetStep = stepId
    }
    
    func toggleComplete() {
        self.isCompleted.toggle()
    }
}

extension CollabSession: CrudOperable {
    static var collectionPath: String {
        "collabSession"
    }
}

extension CollabSession {
    /**
     Toggle one step's completion status by specifying step id.
     */
    func toggleStepCompletion(for stepId: String,
                              _ completion: @escaping (Error?) -> Void) {
        guard let id = self.id else {
            print("session id cannot be fetched.")
            completion(CoreError.failedGetSessionIdError)
            return
        }
        
        self.workLoad.first { $0.targetStep == stepId }?.toggleComplete()
        
        updateWorkloadField(withDocId: id, completion)
    }
    
    /**
     Toggle one step's completion status by specifying index.
     */
    func toggleStepCompletion(at index: Int,
                              _ completion: @escaping (Error?) -> Void) {
        guard let id = self.id else {
            print("session id cannot be fetched.")
            completion(CoreError.failedGetSessionIdError)
            return
        }
        
        if index < 0 || index >= workLoad.count { return }
        workLoad[index].toggleComplete()
        
        updateWorkloadField(withDocId: id, completion)
    }
    
    /**
     Assign a user to a task. If triggered twice, this function will help you to remove the existing user.
     */
    func toggleAssignee(at index: Int,
                        forUser userId: String,
                        _ completion: @escaping (Error?) -> Void) {
        guard let id = self.id else {
            print("session id cannot be fetched.")
            completion(CoreError.failedGetSessionIdError)
            return
        }
        if index < 0 || index >= workLoad.count { return }
        
        let assigned = self.workLoad[index].assignee.contains(userId)
        if assigned {
            self.workLoad[index].assignee.removeAll { $0 == userId }
        } else {
            self.workLoad[index].assignee.append(userId)
        }
        
        updateWorkloadField(withDocId: id, completion)
    }
    
    private func updateWorkloadField(withDocId id: String,
                                     _ completion: @escaping (Error?) -> Void) {
        let result = self.workLoad.compactMap { try? $0.toFirebaseDict() }
        
        let newData = ["workLoad": result]
        CollabSession.update(named: id, with: newData) { (error) in
            completion(error)
        }
    }
}

extension CollabSession {
    static func createSession(withHostId hostId: String,
                              withRecipeId recipeId: String,
                              _ completion: @escaping (Error?, String?) -> Void) {
        Recipe.get(named: recipeId) { (error, recipe, _) in
            guard error == nil, let recipe = recipe else {
                completion(error, nil)
                return
            }
            
            self.createSession(withHostId: hostId, withRecipe: recipe, completion)
        }
    }
    
    static func createSession(withHostId hostId: String,
                              withRecipe recipe: Recipe,
                              _ completion: @escaping (Error?, String?) -> Void) {
        let session = CollabSession(host: hostId, targetRecipe: recipe)
        
        session.workLoad = recipe.steps.compactMap { (step) -> StepAssignment? in
            guard let stepId = step.stepId else {
                return nil
            }
            return StepAssignment(stepId: stepId)
        }
        
        self.post(with: session) { (error, docRef) in
            completion(error, docRef?.documentID)
        }
    }
    
    static func joinSession(withSessionId sessionId: String,
                            withParticipantId participantId: String,
                            completion: @escaping (Error?) -> Void,
                            whenChanged changedHandler: @escaping (CollabSession) -> Void) -> ListenerRegistration {
        
        let listener = FirestoreApi.monitorChange(in: collectionPath, named: sessionId, changedHandler)
        
        let newData = ["participants": FieldValue.arrayUnion([participantId])]
        self.update(named: sessionId, with: newData) { (error) in
            completion(error)
        }
        
        return listener
    }
    
    static func leaveSession(withSessionId sessionId: String,
                             withParticipantId participantId: String,
                             withListener listener: ListenerRegistration,
                             completion: @escaping (Error?) -> Void) {
        let newData = ["participants": FieldValue.arrayRemove([participantId])]
        self.update(named: sessionId, with: newData) { (error) in
            if let error = error {
                completion(error)
            } else {
                listener.remove()
                completion(nil)
            }
        }
    }
}
