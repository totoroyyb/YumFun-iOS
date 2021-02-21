//
//  RecipeComponents.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/22.
//

import Foundation

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
enum DishType: String, Codable, CaseIterable {
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
enum CuisineType: String, Codable, CaseIterable {
    case chinese
    case italian
    case european
    case asian
    case american
    case spanish_portuguese = "Spanish & Portuguese"
    case indian
    case middle_eastern = "Middle Eastern"
    
    /**
     Helper function for get String presentation of CuisineType with capitalization.
     */
    func toString() -> String {
        switch self {
        case .spanish_portuguese:
            return "Spanish & Portuguese"
        default:
            return self.rawValue.replacingOccurrences(of: "_", with: " ").capitalized(with: Locale.current)
        }
    }
}

enum MeasureUnit: String, Codable, CaseIterable {
    case cup
    case fl_oz = "fl oz"
    case oz
    case tsp
    case tbsp
    case bag
    case bar
    case bulb
    case capsule
    case clove
    case cob
    case dash
    case drop
    case gallon
    case head
    case lb
    case leaf
    case loaf
    case package
    case pinch
    case pint
    case quart
    case scoop
    case sheet
    case slice
    case sprig
    case stalk
    case stick
    case strip
    case tea_bag = "tea bag"
    
    /**
     Helper function for get String representation of MeasureUnit without underscore,
     */
    func toString() -> String {
        return self.rawValue.replacingOccurrences(of: "_", with: " ")
    }
}

struct Ingredient: Codable {
    var name: String
    var amount: Double
    var unit: MeasureUnit
}

struct Utensil: Codable {
    var name: String
    var amount: Int = 1
}

struct Step: Codable {
    var title: String?
    var description: String
    var photoUrl: URL?
    var utensils = [Utensil]()
    var ingredients = [Ingredient]()
    var time: TimeInterval?
}
