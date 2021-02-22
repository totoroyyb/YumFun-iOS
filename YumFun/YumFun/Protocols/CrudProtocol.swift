//
//  CrudExt.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/22.
//

import Foundation

/**
 A object that supports CRUD operation on Firestore (CREATE, READ, UPDATE, DELETE)
 */
protocol CrudOperable: Codable {
    /**
     Warning: This the collection path in the Firestore for data. Do you change it, if data migration is not prepared.
     */
    static var collectionPath: String { get }
    
    /**
     Post a data to the cloud. All recipe will be saved to the top-level collection with name that `collectionPath` specified.

     - Parameter data: the data you want to post to cloud
     - Parameter name: the name of document you want to set. Don't pass in anything, if you want to generate automatically
     -  Parameter merge: whether you want to perform merge or override if the name of doc already exists.
     
     ## Caution!!
     If `name` is provided, the second argument passed into the completion handler will always be `nil`
     
     ## Note
     If `name` argument is not provided, the document name/id will be randomly generated. Otherwise, it will use the name provided by the caller.
     
     If the name already exist, then it will perform a override action. If you set parameter `merge` to true to avoid override. __By default, override action is used.__ If name is `nil`, the merge option will not be used.
     */
    static func post(with data: Self,
                     named name: String?,
                     merge: Bool,
                     _ completion: @escaping postDataCompletionHandler)
    
    
    /**
     Update a data to the cloud. You can update partial data by passing in a dictionary-like object.

     - Parameter name: the name/id of the data stored in the cloud.
     - Parameter data: the partial data used to update the old data in the cloud.
     - Parameter trackUpdate: whether update the `lastUpdate` field automatically. By default, is set to `true`.
     */
    static func update(named name: String,
                       with data: [AnyHashable : Any],
                       trackUpdate: Bool,
                       _ completion: @escaping updateDataCompletionHandler)
    
    /**
     Update a data to the cloud. You can update an entire document by passing in a object.

     - Parameter name: the name/id of the recipe stored in the cloud.
     - Parameter data: the entire recipe object used to update the old data in the cloud.
     - Parameter trackUpdate: whether update the `lastUpdate` field automatically. By default, is set to `true`.

     ## Note
     If you want to create a entire new document, considering using `post()` function.
     */
    static func update(named name: String,
                       with data: Self,
                       trackUpdate: Bool,
                       _ completion: @escaping updateDataCompletionHandler)
    
    /**
     Get a data from the cloud with specified name/id.

     - Parameter name: the name/id of the data to get from the cloud.
     */
    static func get(named name: String,
                    _ completion: @escaping getDataCompletionHandler<Self>)
    
    /**
     Get all data from the cloud in the path specified in `collectionPath`.
     */
    static func getAll(_ completion: @escaping getAllDataCompletionHandler<Self>)
    
    /**
     Delete one data with specified document id/name.
     */
    static func delete(named name: String,
                       _ completion: @escaping deleteDataCompletionHandler)
}

extension CrudOperable {
    static func post(with data: Self,
                     named name: String? = nil,
                     merge: Bool = false,
                     _ completion: @escaping postDataCompletionHandler) {
        if let name = name {
            FirestoreApi.postData(in: collectionPath, with: data, named: name, merge: merge, completion)
        } else {
            FirestoreApi.postData(in: collectionPath, with: data, completion)
        }
    }
    
    static func update(named name: String,
                       with data: [AnyHashable : Any],
                       trackUpdate: Bool = true,
                       _ completion: @escaping updateDataCompletionHandler) {
        FirestoreApi.updateData(in: collectionPath, named: name, with: data, trackUpdate: trackUpdate, completion)
    }
    
    static func update(named name: String,
                       with data: Self,
                       trackUpdate: Bool = true,
                       _ completion: @escaping updateDataCompletionHandler) {
        FirestoreApi.updateData(in: collectionPath, named: name, with: data, trackUpdate: trackUpdate, completion)
    }
    
    static func get(named name: String,
                    _ completion: @escaping getDataCompletionHandler<Self>) {
        FirestoreApi.getData(in: collectionPath, named: name, completion)
    }
    
    static func getAll(_ completion: @escaping getAllDataCompletionHandler<Self>) {
        FirestoreApi.getAllData(in: collectionPath, completion)
    }
    
    static func delete(named name: String,
                       _ completion: @escaping deleteDataCompletionHandler) {
        FirestoreApi.deleteData(in: collectionPath, named: name, completion)
    }
}
