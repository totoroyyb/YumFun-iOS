//
//  FirestoreApi.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/20.
//

import Foundation
import Firebase

class FirestoreApi {
    typealias postDataCompletionHandler = (Error?, DocumentReference?) -> Void
    typealias fetchAllDataCompletionHandler = (Error?, [QueryDocumentSnapshot]?) -> Void
    
    private static let db = Firestore.firestore()
    
    /**
     Post a recipe in the specified collection
     
     ## Note
     By default, it will put recipe inside a top level collection named "recipe".
     */
    static func postData(in collection: String = "recipe",
                         with recipe: Recipe,
                         _ completion: @escaping postDataCompletionHandler) {
        guard let recipeDict = try? recipe.toDict() else {
            print("Failed to parse Recipe: \(recipe)")
            return
        }
        
        var ref: DocumentReference? = nil
        ref = db.collection(collection).addDocument(data: recipeDict) { err in
            completion(err, ref)
        }
        
        db.collection("recipe").document("Test")
    }
    
    static func fetchAllData(in collection: String = "recipe",
                             _ completion: @escaping fetchAllDataCompletionHandler) {
        db.collection(collection).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//            }
            completion(err, querySnapshot?.documents)
        }
    }
}



// - MARK: All test functions for FirestoreApi are organized here
extension FirestoreApi {
    static func testPostData() {
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "first": "Ada",
            "last": "Lovelace",
            "born": 1815
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    
}
