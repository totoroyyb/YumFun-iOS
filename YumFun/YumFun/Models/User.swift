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
    
    fileprivate(set) var recipes: [String] = [] {
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
    
    fileprivate(set) var followers = [String]()
    
    fileprivate(set) var followings: [String] = [] {
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
    
    private(set) var likedRecipes: [String] = [] {
        willSet {
            if let validId = self.id {
                User.update(named: validId, with: ["likedRecipes": newValue]) { (err) in
                    if let err = err {
                        print("Failed to update liked recipes in user. \(err)")
                    }
                }
            }
        }
    }
    
    init() {
        // zero initialization
    }
    
    init(fromAuthUser authUser: Firebase.User) {
        self.id = authUser.uid
        self.displayName = authUser.displayName
        self.email = authUser.email
//        self.photoUrl = authUser.photoURL
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
                    completion(result, err)
                }
            } else {
                completion(result, CoreError.currUserNoDataError)
            }
        }
    }
}

/// Basic operations for current user. For example, create a recipe, update their profile image, etc.
extension User {
    /**
     Create recipe. This function should only be used to create a recipe for __current user__.
     */
    func createRecipe(with recipe: Recipe, _ completion: @escaping postDataCompletionHandler) {
        
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(CoreError.currUserNoDataError, nil)
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
                completion(nil, docRef)
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
            completion(CoreError.currUserNoDataError)
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
            completion(CoreError.currUserNoDataError)
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
            completion(CoreError.currUserNoDataError)
            return
        }
        
        self.followings.removeAll { $0 == userId }
        let newData = ["followers" : FieldValue.arrayRemove([currUserId])]
        User.update(named: userId, with: newData, completion)
    }
    
    /**
     Current user liked a recipe.
     */
    func likeRecipe(withId id: String,
                    _ completion: @escaping updateDataCompletionHandler) {
        guard self.id != nil else {
            print("Failed to fetch current user id")
            completion(CoreError.currUserNoDataError)
            return
        }
        
        self.likedRecipes.append(id)
        
        let newData = [
            "likedCount": FieldValue.increment(Int64(1))
        ]
        Recipe.update(named: id, with: newData, completion)
    }
    
    /**
     Current user unliked a recipe.
     */
    func unlikeRecipe(withId id: String,
                      _ completion: @escaping updateDataCompletionHandler) {
        guard self.id != nil else {
            print("Failed to fetch current user id")
            completion(CoreError.currUserNoDataError)
            return
        }
        
        self.likedRecipes.removeAll { $0 == id }
        let newData = [
            "likedCount": FieldValue.increment(Int64(-1))
        ]
        Recipe.update(named: id, with: newData, completion)
    }
    
    /**
     Current user upload a profile image to the server
     */
    func updateProfileImage(with image: UIImage,
                            _ completion: @escaping (Error?) -> Void) -> CloudStorage? {
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(CoreError.currUserNoDataError)
            return nil
        }
        
        let data = image.jpegData(compressionQuality: 0.6)
        
        guard let validData = data else {
            completion(CoreError.failedCompressImageError)
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
    
    /**
     Update current user's display name.
     */
    func updateDisplayName(withNewName name: String,
                           _ completion: @escaping updateDataCompletionHandler) {
        self.displayName = name
        self.updateUserStrField(withFieldName: "displayName", withFieldValue: name, completion)
    }
    
    /**
     Update current user's user name.
     */
    func updateUsername(withNewName name: String,
                        _ completion: @escaping updateDataCompletionHandler) {
        self.userName = name
        self.updateUserStrField(withFieldName: "userName", withFieldValue: name, completion)
    }
    
    /**
     Update current user's bio.
     */
    func updateBio(withNewBio bio: String,
                   _ completion: @escaping updateDataCompletionHandler) {
        self.bio = bio
        self.updateUserStrField(withFieldName: "bio", withFieldValue: bio, completion)
    }
}

extension User {
    /**
     Create a collab cooking session from current user with a __recipe id__. This action will set current user as the host automatically.
     
     __Newly created collab cook session id will be passed back as the second argument in the completion handler.__
     
     - Parameter recipeId: recipe id which collab cook session based on
     - Parameter completion: The first argument passed back is the Error, if any. The second argument passed back is the newly created session number.
     */
    func createCollabSession(withRecipeId recipeId: String,
                             _ completion: @escaping (Error?, String?) -> Void) {
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(CoreError.currUserNoDataError, nil)
            return
        }
        
        CollabSession.createSession(withHostId: currUserId, withRecipeId: recipeId, completion)
    }
    
    /**
     Create a collab cooking session from current user with a __recipe__. This action will set current user as the host automatically.
     
     __Newly created collab cook session id will be passed back as the second argument in the completion handler.__
     
     - Parameter recipeId: recipe id which collab cook session based on
     - Parameter completion: The first argument passed back is the Error, if any. The second argument passed back is the newly created session number.
     */
    func createCollabSession(withRecipe recipe: Recipe,
                             _ completion: @escaping (Error?, String?) -> Void) {
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(CoreError.currUserNoDataError, nil)
            return
        }
        
        CollabSession.createSession(withHostId: currUserId, withRecipe: recipe, completion)
    }
    
    /**
     Join a collab session for current user.
     
     ## Note
     As a host, you need to call `createCollabSession` first to get the newly created session id. And join session with that id.
     
     This function will return a `Listener` if executed successfully. If possible, you should always pass this listener back to the `leaveCollabSession` function to clean up, if you intend to leave.
     
     - Parameter sessionId: the session id you want to join
     - Parameter completion: a completion handler to indicate whether there is a error.
     - Parameter changedHandler: this is important, as it will keep you data sync with cloud real-time. This handler will be called everytime when the cloud data update is detected. The new data will be passed into this handler as an argument.
     */
    func joinCollabSession(withSessionId sessionId: String,
                           completion: @escaping (Error?) -> Void,
                           whenChanged changedHandler: @escaping (CollabSession) -> Void) -> ListenerRegistration? {
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(CoreError.currUserNoDataError)
            return nil
        }
        
        return CollabSession.joinSession(withSessionId: sessionId, withParticipantId: currUserId, completion: completion, whenChanged: changedHandler)
    }
    
    /**
     Leave the specified collab session for current user.
     
     ## Note
     If possible, always execute this function before you leave the collab session or navigate to other views. Remove listener is important to avoid latent crash.
     */
    func leaveCollabSession(withSessionId sessionId: String,
                            withListener listener: ListenerRegistration,
                            completion: @escaping (Error?) -> Void) {
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(CoreError.currUserNoDataError)
            return
        }
        
        CollabSession.leaveSession(withSessionId: sessionId, withParticipantId: currUserId, withListener: listener, completion: completion)
    }
}

extension User {
    private func updateUserStrField(withFieldName fieldName: String,
                                    withFieldValue fieldValue: Any,
                                    _ completion: @escaping updateDataCompletionHandler) {
        guard let currUserId = self.id else {
            print("Failed to fetch current user id")
            completion(CoreError.currUserNoDataError)
            return
        }
        
        let newData = [fieldName: fieldValue]
        User.update(named: currUserId, with: newData, completion)
    }
}

