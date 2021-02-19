//
//  FirestoreApi.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/20.
//

import Foundation
import Firebase

typealias completionHandler = (Error?, DocumentReference?) -> Void

class FirestoreApi {
    private static let db = Firestore.firestore()
    
    static func postData(in collection: String = "recipe",
                         with recipe: Recipe,
                         afterCompletion completion: @escaping completionHandler) {
        guard let recipeDict = try? recipe.toDict() else {
            print("Failed to parse Recipe: \(recipe)")
            return
        }
        
        var ref: DocumentReference? = nil
        ref = db.collection(collection).addDocument(data: recipeDict) { err in
            completion(err, ref)
        }
    }
    
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
