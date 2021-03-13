//
//  Pagination.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/14.
//

import Foundation
import FirebaseFirestore

class Pagination {
    private let db = Firestore.firestore()
    
    private(set) var collectionPath: String
    private(set) var collectionRef: CollectionReference
    private(set) var collectionQuery: Query
    
    private(set) var isFetching = false {
        didSet {
            if isFetching {
                delegate?.startFetchBatch()
            } else {
                delegate?.endFetchBatch()
            }
        }
    }
    
    weak var delegate: PaginationDelegate?
    
    init(collectionPath path: String, limit: Int) {
        self.collectionPath = path
        self.collectionRef = db.collection(self.collectionPath)
        self.collectionQuery = self.collectionRef.limit(to: limit)
    }
    
    func getNewBatch<T: Decodable>(_ completion: @escaping (Error?, [T]?, QuerySnapshot?) -> Void) {
        if self.isFetching {
            return
        }
        
        self.isFetching = true
        self.collectionQuery.getDocuments { (querySnapshot, error) in
            guard let lastSnapshot = querySnapshot?.documents.last else {
                // The collection is empty.
                self.isFetching = false
                completion(error, nil, querySnapshot)
                return
            }
            
            self.collectionQuery = self.collectionQuery.start(afterDocument: lastSnapshot)
            
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
            
            DispatchQueue.main.async {
                self.isFetching = false
                completion(error, docs, querySnapshot)
            }
        }
    }
}
