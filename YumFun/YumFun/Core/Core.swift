//
//  Core.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/27.
//

import Foundation
import Firebase

class Core {
    /**
     Source of truth for the current user
     
     ## Note
     Please call `setupCurrentUser` whenever the Firebase authentication user is changed to update the user information.
     */
    private(set) static var currentUser: User?
    
    /**
     Update the source of truth of current user.
     
     ## Note
     Always check the completion handler. If error occurs, you shouldn't proceed.
     */
    static func setupCurrentUser(completion: @escaping (Error?) -> Void) {
        if let user = Auth.auth().currentUser {
            User.get(named: user.uid) { (error, user, _) in
                guard let user = user, error == nil else {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                    return
                }
                
                self.currentUser = user
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(currUserNoDataError)
            }
        }
    }
}

fileprivate let currUserNoDataInfo: [String : Any] = [
    NSLocalizedDescriptionKey: NSLocalizedString("Failed to Post", value: "Current user data cannot be fetched", comment: ""),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Failed to Post", value: "Current user data cannot be fetched", comment: "")
]

fileprivate let currUserNoDataError = NSError(domain: "FailedToFetchData", code: 0, userInfo: currUserNoDataInfo)
