//
//  Core.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/27.
//

import Foundation
import Firebase
import UIKit

class Core {
    static var urlOpenTask: UrlOpenTaskType? {
        didSet {
            NotificationCenter.default.post(name: .newUrlTaskAdded, object: nil)
        }
    }
    
    /**
     Source of truth for the current user
     
     ## Note
     Please call `setupCurrentUser` whenever the Firebase authentication user is changed to update the user information.
     */
    private(set) static var currentUser: User? {
        didSet {
            NotificationCenter.default.post(name: .userDidSet, object: currentUser, userInfo: nil)
        }
    }
    
    private(set) static var isFetching = false
    
    /**
     Update the source of truth of current user.
     
     ## Note
     Always check the completion handler. If error occurs, you shouldn't proceed.
     */
    static func setupCurrentUser(completion: @escaping (Error?) -> Void) {
        self.isFetching = true
        if let authUser = Auth.auth().currentUser {
            User.get(named: authUser.uid) { (error, user, snapshot) in
                guard let snapshot = snapshot else {
                    DispatchQueue.main.async {
                        self.isFetching = false
                        completion(error)
                    }
                    return
                }
                
                // If user info is created in the firebase authen db, but not in the firestore db.
                if !snapshot.exists {
                    let newUser = User(fromAuthUser: authUser)
                    User.post(with: newUser, named: authUser.uid) { (error, _) in
                        if let error = error {
                            completion(error)
                        } else {
                            Core.setupCurrentUser(completion: completion)
                        }
                    }
                    self.isFetching = false
                    return
                }
                
                
                guard let user = user, error == nil else {
                    DispatchQueue.main.async {
                        self.isFetching = false
                        completion(error)
                    }
                    return
                }
                
                self.currentUser = user
                DispatchQueue.main.async {
                    self.isFetching = false
                    completion(error)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isFetching = false
                completion(CoreError.currUserNoDataError)
            }
        }
    }
    
    static func logout(from view: UIView) {
        do {
            try Auth.auth().signOut()
            Core.currentUser = nil
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let navigationViewController = storyboard.instantiateViewController(identifier: "BaseNavController") as? UINavigationController else {
                assertionFailure("Failed to initialize the navigation controller.")
                return
            }
            
            guard let loginViewController = storyboard.instantiateViewController(identifier: "loginView") as? ViewController else {
                assertionFailure("Cannot instantiate LoginView.")
                return
            }
            
            navigationViewController.setViewControllers([loginViewController], animated: true)
            
            view.window?.rootViewController = navigationViewController
            view.window?.makeKeyAndVisible()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

//class UrlOpenTask {
//    private let semaphore = DispatchSemaphore(value: 0)
//
//    private var urlOpenTaskQueue = [UrlOpenTaskType]()
//
//    func popUrlOpenTask(_ completion: @escaping (UrlOpenTaskType?) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            if self.urlOpenTaskQueue.count == 0 {
//                completion(nil)
//            } else {
//                completion(self.urlOpenTaskQueue.removeFirst())
//            }
//            self.semaphore.signal()
//        }
//        semaphore.wait()
//    }
//
//    func addUrlOpenTask(_ task: UrlOpenTaskType) {
//        DispatchQueue.global(qos: .userInitiated).async  {
//            self.urlOpenTaskQueue.append(task)
//            self.semaphore.signal()
//            NotificationCenter.default.post(name: .newUrlTaskAdded, object: nil)
//        }
//        semaphore.wait()
//    }
//
//    func peekNextUrlOpenTask() -> UrlOpenTaskType? {
//        return urlOpenTaskQueue.first
//    }
//}

enum UrlOpenTaskType {
    case joinCollabSession(sessionId: String)
}
