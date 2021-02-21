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
 Record how much time will be spent on prep, baking or resting.
 
 ## Property
 Prep is represented as `Int`, bake and rest are represented as `Int?`. Hence prep time should be required from user.
 
 ## Note
 Please be sure to check nullity when using bake and rest, since they are not required from user.
 */
struct Duration: Codable {
    var prep: Int = 0
    var bake: Int?
    var rest: Int?
    
    init(prepTime: Int) {
        self.prep = prepTime
    }
}

/**
 Record which kind of dish this recipe is working on
 */
enum DishType: String, Codable {
    case starter
    case main
    case dessert
    case snack
    case breakfast
    case drink
}

/**
 Record the type of cuisine
 */
enum CuisineType: String, Codable {
    case chinese
    case italian
    case european
    case asian
    case american
    case spanish
    case portuguese
    case indian
    case middleEastern
}

/**
 Record all information about a recipe
 
 // - MARK: NOT DONE YET
 */
struct Recipe: Codable, Identifiable, UpdateTrackable {
    /// This id maps to the id Firestore created automatically
    @DocumentID var id: String?
    
    /// This is used to track last update date
    @ServerTimestamp var lastUpdated: Timestamp?
    
    var serveSize: Int = 1
    var duration: Duration
    var dishType: DishType
    var cuisine = [CuisineType]()
    var occasion = [String]()
    var creationDate = Timestamp()
}
