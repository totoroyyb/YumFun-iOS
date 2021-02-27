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
    var photoUrl: String?
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
//        self.photoUrl = authUser.photoURL
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
     Delete recipe by specified recipe id.
     */
    func deleteRecipe(withId recipeId: String,
                      _ completion: @escaping updateDataCompletionHandler) {
        guard self.id != nil else {
            print("Failed to fetch current user id")
            completion(currUserNoDataError)
            return
        }
        
        self.recipes.removeAll { $0 == recipeId }
        Recipe.delete(named: recipeId) { (error) in
            completion(error)
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
    
    /**
     Current user upload a profile image to the server
     */
    func updateProfileImage(with image: UIImage,
                            _ completion: @escaping (Error?) -> Void) -> CloudStorage? {
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(currUserNoDataError)
            return nil
        }
        
        let data = image.jpegData(compressionQuality: 0.6)
        
        guard let validData = data else {
            completion(failedCompressImageError)
            return nil
        }
        
        let storage = CloudStorage(.profileImage)
        storage.child("\(currUserId).jpeg")
        
        storage.upload(validData, metadata: nil) { (error) in
            completion(error)
        } completionHandler: { metadata in
            self.photoUrl = storage.fileRef.fullPath
            let newData = ["photoUrl": storage.fileRef.fullPath]
            User.update(named: currUserId, with: newData) { (error) in
                completion(error)
            }
        }
        
        return storage
    }
}

extension User: CrudOperable {
    static var collectionPath: String {
        "user"
    }
}

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


// - MARK: ALL ERRORS
fileprivate let currUserNoDataInfo: [String : Any] = [
    NSLocalizedDescriptionKey: NSLocalizedString("Failed to Post", value: "Current user data cannot be fetched", comment: ""),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Failed to Post", value: "Current user data cannot be fetched", comment: "")
]

fileprivate let currUserNoDataError = NSError(domain: "FailedToFetchData", code: 0, userInfo: currUserNoDataInfo)

fileprivate let failedCompressImageInfo: [String : Any] = [
    NSLocalizedDescriptionKey: NSLocalizedString("Failed to Compress Image", value: "Cannot convert image to data", comment: ""),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Unknow compression error", value: "Cannot convert image to data", comment: "")
]

fileprivate let failedCompressImageError = NSError(domain: "FailedToConvertImage", code: 0, userInfo: failedCompressImageInfo)
