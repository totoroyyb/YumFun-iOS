//
//  User.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    /// This id maps to the uid created by Firebase authentication
    @DocumentID var id: String?
    
    /// This is used to track last update date
    @ServerTimestamp var lastUpdated: Timestamp?
    
    var displayName: String?
    var userName: String?
    var photoUrl: String?
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
