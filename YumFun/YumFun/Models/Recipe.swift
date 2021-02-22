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
struct Recipe: Codable, Identifiable {
    /// This id maps to the id Firestore created automatically
    @DocumentID var id: String?
    /// This is used to track last update date
    @ServerTimestamp var lastUpdated: Timestamp?
    
    var author: String
    
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
}

//extension Recipe {
//    func updateErrorHandler(err: Error?) {
//        if let err = err {
//            print("Error to update value with err: \(err)")
//        }
//    }
//}
