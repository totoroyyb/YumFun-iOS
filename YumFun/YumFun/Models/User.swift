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

final class User: Identifiable, Codable {
    /// This id maps to the uid created by Firebase authentication
    @DocumentID var id: String?
    
    /// This is used to track last update date
    @ServerTimestamp var lastUpdated: Timestamp?
    
    var displayName: String?
    var userName: String?
    var email: String?
    var photoUrl: URL?
    var bio: String?
    
    private(set) var recipes: [String] = [] {
        willSet {
            if let validId = self.id {
                User.update(named: validId, with: ["recipes": newValue]) { (err) in
                    if let err = err {
                        print("Failed to update recipes in user. \(err)")
                    }
                }
            }
        }
    }
    
    var followers = [String]()
    
    private(set) var followings: [String] = [] {
        willSet {
            if let validId = self.id {
                User.update(named: validId, with: ["followings": newValue]) { (err) in
                    if let err = err {
                        print("Failed to update followings in user. \(err)")
                    }
                }
            }
        }
    }
    
    init(fromAuthUser authUser: Firebase.User) {
        self.id = authUser.uid
        self.displayName = authUser.displayName
        self.email = authUser.email
        self.photoUrl = authUser.photoURL
    }
}

extension User {
    /**
     Create recipe. This function should only be used to create a recipe for __current user__.
     */
    func createRecipe(with recipe: Recipe, _ completion: @escaping postDataCompletionHandler) {
        
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(currUserNoDataError, nil)
            return
        }
        
        var recipe = recipe
        recipe.author = currUserId
        
        Recipe.post(with: recipe) { (err, docRef) in
            if let err = err {
                completion(err, docRef)
            } else {
                if let docId = docRef?.documentID {
                    self.recipes.append(docId)
                }
            }
        }
    }
    
    /**
     Current user follows other user with specified user id.
     */
    func followUser(withId userId: String,
                    _ completion: @escaping updateDataCompletionHandler) {
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(currUserNoDataError)
            return
        }
        
        self.followings.append(userId)
        let newData = ["followers" : FieldValue.arrayUnion([currUserId])]
        User.update(named: userId, with: newData, completion)
    }
    
    /**
     Current user unfollows other user with specified user id.
     */
    func unfollowUser(withId userId: String,
                      _ completion: @escaping updateDataCompletionHandler) {
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(currUserNoDataError)
            return
        }
        
        self.followings.removeAll { $0 == userId }
        let newData = ["followers" : FieldValue.arrayUnion([currUserId])]
        User.update(named: userId, with: newData, completion)
    }
}

extension User: CrudOperable {
    static var collectionPath: String {
        "user"
    }
}

fileprivate let userInfo: [String : Any] = [
    NSLocalizedDescriptionKey: NSLocalizedString("Failed to Post", value: "Current user data cannot be fetched", comment: ""),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Failed to Post", value: "Current user data cannot be fetched", comment: "")
]

fileprivate let currUserNoDataError = NSError(domain: "FailedToFetchData", code: 0, userInfo: userInfo)

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
                let newUser = User(fromAuthUser: user)
                User.post(with: newUser, named: user.uid) { (err, _) in
                    if let err = err {
                        completion(result, err)
                    }
                }
            } else {
                completion(result, currUserNoDataError)
            }
        }
    }
    
}

