//
//  Recipe.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/**
 Record all information about a recipe
 
 // - MARK: IN PROGRESS
 */
struct Recipe: Identifiable, Codable {
    /// This id maps to the id Firestore created automatically
    @DocumentID var id: String?
    
    /// This is used to track last update date
    @ServerTimestamp var lastUpdated: Timestamp?
    
    var author: String = "Unknown Author"
    
    var title: String = "Unnamed Recipe"
    
    var description: String?
    
    var serveSize: Int = 1
    
    var duration: Duration
    
    var dishType: DishType
    
    var cuisine = [CuisineType]()
    
    var occasion = [String]()
    
    var creationDate = Timestamp()
    
    var steps = [Step]()
    
    var ingredients = [Ingredient]()
    
    var picUrls = [URL]()
    
    var chefNote: String?
    
    var likedCount: Int = 0
}

extension Recipe: CrudOperable {
    static var collectionPath: String {
        "recipe"
    }
}
