//
//  FirestoreApi.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/20.
//

import Foundation
import Firebase

// - MARK: Handler Type
typealias postDataCompletionHandler = (Error?, DocumentReference?) -> Void

typealias updateDataCompletionHandler = (Error?) -> Void

typealias getDataCompletionHandler<T: Decodable> = (Error?, T?, DocumentSnapshot?) -> Void

typealias getAllDataCompletionHandler<T: Decodable> = (Error?, [T]?, QuerySnapshot?) -> Void

typealias deleteDataCompletionHandler = (Error?) -> Void

class FirestoreApi {
    private static let db = Firestore.firestore()
    
    /**
     Post data in the specified collection to the cloud.
     
     - Parameter collectionPath: which collection you want to post data in
     - Parameter data: Encodable data you want to post to the cloud
     - Parameter completion: completion handler takes two arguments, error and document reference.
     
     ## Note
     The document id will be automatically generated by Firestore.
     
     You can access the automatically created id in the completion handler like:
     ```
     postData(in: "NewCollection", with: data) { (err, ref) in
        let id = ref?.documentID
     }
     ```
     */
    static func postData<T: Encodable>(in collectionPath: String,
                                       with data: T,
                                       _ completion: @escaping postDataCompletionHandler) {
        var ref: DocumentReference? = nil
        ref = try? self.db.collection(collectionPath).addDocument(from: data) { err in
            completion(err, ref)
        }
    }
    
    /**
     Post data in the specified collection with specific name to the cloud.
     
     - Parameter collection: which collection you want to post data in
     - Parameter data: encodable data you want to post to the cloud
     - Parameter docName: name or doc id you want to set
     - Parameter merge: define whether merge behavior is used. Override behavior by default.
     - Parameter completion: completion handler takes two arguments, error and document reference.
     
     ## Be Caution!
     By default, new data will automatically override the old data in the specified document. You can set `merge` argument to `true` to perform merge action, instead of override. If you are using `merge` option, maybe you want to use `updateData` instead.
     
     __!!! Last updated date will not be updated by calling post functions, considering using update functions__
     
     ## Note
     Document reference passed into the completion handler will always be `nil`. The document id is identical to what you named it.
     */
    static func postData<T: Encodable>(in collectionPath: String,
                                       with data: T,
                                       named docName: String,
                                       merge: Bool = false,
                                       _ completion: @escaping postDataCompletionHandler) {
        do {
            try self.db.collection(collectionPath).document(docName).setData(from: data,
                                                                        merge: merge) { (err) in
                completion(err, nil)
            }
        } catch {
            completion(error, nil)
        }
    }
    
    /**
     Update partial data with specified collection path and document name/id, by passing a dictionary-like data.
     
     - Parameter collectionPath: which collection you want to update data in
     - Parameter docName: which document you want to update data in
     - Parameter data: partial data you want to update
     - Parameter trackUpdate: whether you want to update the `lastUpdated` field
     - Parameter completion: completion handler for data update action
     */
    static func updateData(in collectionPath: String,
                           named docName: String,
                           with data: [AnyHashable : Any],
                           trackUpdate: Bool = true,
                           _ completion: @escaping updateDataCompletionHandler) {
        var data = data
        if trackUpdate {
            data["lastUpdated"] = FieldValue.serverTimestamp()
        }

        self.db.collection(collectionPath).document(docName).updateData(data) { (err) in
            completion(err)
        }
    }
    
    /**
     Update data with specified collection path and document name/id, by passing a `Encodable` object.
     
     - Parameter collectionPath: which collection you want to update data in
     - Parameter docName: which document you want to update data in
     - Parameter data: `Encodable` data object you want to update
     - Parameter trackUpdate: whether you want to update the `lastUpdated` field
     - Parameter completion: completion handler for data update action
     */
    static func updateData(in collectionPath: String,
                           named docName: String,
                           with data: Encodable,
                           trackUpdate: Bool = true,
                           _ completion: @escaping updateDataCompletionHandler) {
        do {
            let data = try data.toFirebaseDict()
            self.updateData(in: collectionPath, named: docName, with: data, completion)
        } catch {
            completion(error)
        }
    }
    
    /**
     Get data with specified collection path and document id/name from the cloud
     
     ## Note
     You can access the second argument in the completion handler to directly access the parsed object.
     To gain full access of object that passed back by Firestore, you can access the third argument in the completion handler.
     */
    static func getData<T: Decodable>(in collectionPath: String,
                          named docName: String,
                          _ completion: @escaping getDataCompletionHandler<T>) {
        let docRef = self.db.collection(collectionPath).document(docName)
        
        docRef.getDocument { (docSnapshot, err) in
            if let err = err {
                completion(err, nil, docSnapshot)
            } else {
                if let docSnapshot = docSnapshot, docSnapshot.exists {
                    let result = Result {
                        try docSnapshot.data(as: T.self)
                    }
                    
                    switch result {
                    case .success(let data):
                        completion(err, data, docSnapshot)
                    case .failure(let error):
                        completion(error, nil, docSnapshot)
                    }
                } else {
                    completion(err, nil, docSnapshot)
                }
            }
        }
    }
    
    /**
     Get all documents inside the specified collection path
     
     ## Note
     All documents that cannot be parsed will be filtered out. However, the error message will be printed to the console.
     
     You can access the second argument in the completion handler to directly access the parsed document array.
     To gain full access of snapshot that passed back by Firestore, you can access the third argument in the completion handler.
     */
    static func getAllData<T: Decodable>(in collectionPath: String,
                                           _ completion: @escaping getAllDataCompletionHandler<T>) {
        db.collection(collectionPath).getDocuments() { (querySnapshot, err) in
            let docs = querySnapshot?.documents.compactMap { document -> T? in
                let result = Result {
                    try document.data(as: T.self)
                }
                
                switch result {
                case .success(let data):
                    return data
                case .failure(let error):
                    print("Error decoding data: \(error)")
                    return nil
                }
            }
            completion(err, docs, querySnapshot)
        }
    }
    
    /**
     Delete the data with specified collection path and document name/id.
     */
    static func deleteData(in collectionPath: String,
                           named name: String,
                           _ completion: @escaping deleteDataCompletionHandler) {
        self.db.collection(collectionPath).document(name).delete { (err) in
            completion(err)
        }
    }
}

// - MARK: Convenient Functions for Recipe operations
extension FirestoreApi {
    
}

// - MARK: Test Functions
extension FirestoreApi {
    /**
     This test fuction will create a demo document in the collection `tests`.
     */
    static func testPostData() {
        var ref: DocumentReference? = nil
        ref = db.collection("tests").addDocument(data: [
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