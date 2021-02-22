//
//  User.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    /// This id maps to the uid created by Firebase authentication
    @DocumentID var id: String?
    
    /// This is used to track last update date
    @ServerTimestamp var lastUpdated: Timestamp?
    
    var displayName: String?
    var userName: String?
    var email: String?
    var photoUrl: URL?
    var bio: String?
    
    var recipes = [String]()
    var followers = [String]()
    var followings = [String]()
}

extension User: CrudOperable {
    static var collectionPath: String {
        "user"
    }
}

fileprivate let userInfo: [String : Any] = [
    NSLocalizedDescriptionKey: NSLocalizedString("Failed to Post", value: "The new created user data cannot be posted to Firestore", comment: ""),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Failed to Post", value: "Newly created user data cannot be fetched", comment: "")
]

fileprivate let createUserNoDataError = NSError(domain: "FailedToFetchData", code: 0, userInfo: userInfo)

extension User {
    typealias createUserCompletionHandler = ((AuthDataResult?, Error?) -> Void)
    
    /**
     Wrap function for firebase `createUser` function.
     
     ## Note
     Do not directly use firebase's `createUser` functino. Instead, use this function to create user. It will post user data to the firestore at the same time when creating a user in the firebase.
     */
    static func createUser(withEmail email: String,
                           withPassword password: String,
                           completion: @escaping createUserCompletionHandler) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard error == nil else {
                completion(result, error)
                return
            }
            
            if let user = result?.user {
                let newUser = copyFromAuthUser(user)
                User.post(with: newUser, named: user.uid) { (err, _) in
                    if let err = err {
                        completion(result, err)
                    }
                }
            } else {
                completion(result, createUserNoDataError)
            }
        }
    }
    
    fileprivate static func copyFromAuthUser(_ authUser: FirebaseAuth.User) -> User {
        let user = User(displayName: authUser.displayName,
                        email: authUser.email,
                        photoUrl: authUser.photoURL)
        return user
    }
}

