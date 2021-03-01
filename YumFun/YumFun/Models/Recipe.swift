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
    @DocumentID var id: String? = UUID().uuidString
    
    /// This is used to track last update date
    @ServerTimestamp var lastUpdated: Timestamp?
    
    var author: String = "Unknown Author"
    
    var title: String = "Unnamed Recipe"
    
    var description: String?
    
    var portionSize: Int = 1
    
    var duration: Duration?
    
    var dishType: DishType?
    
    var cuisine = [CuisineType]()
    
    var occasion = [String]()
    
    var creationDate = Timestamp()
    
    var steps = [Step]()
    
    var ingredients = [Ingredient]()
    
    var picUrls = [URL]()
    
    var chefNote: String?
    
    var assetPath: String = UUID().uuidString
    
    var likedCount: Int = 0
    
//    var likedUser = [String]()
}

extension Recipe: CrudOperable {
    static var collectionPath: String {
        "recipe"
    }
}

extension Recipe {
    /**
     Upload a image for recipe. Uploaded image path will be passed in the completion handler.
     
     By default, the upload file path will be `images/recipes/{assetPath}/{some-random-uuid}.jpeg`
     
     By default, the jpeg image compression ratio is 0.8
     */
    func uploadRecipeImage(with image: UIImage,
                           _ errorHandler: ((Error?) -> Void)?,
                           _ completionHandler: ((String?) -> Void)?) {
        guard self.id != nil else {
            if let errorHandler = errorHandler {
                errorHandler(CoreError.currUserNoDataError)
            }
            return
        }
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            if let errorHandler = errorHandler {
                errorHandler(CoreError.failedCompressImageError)
            }
            return
        }
        
        let uuid = UUID()
        
        let storage = CloudStorage(.recipeImage)
        storage.child("\(self.assetPath)/\(uuid).jpeg")
        
        storage.upload(data, metadata: nil) { (error) in
            if let errorHandler = errorHandler {
                errorHandler(error)
            }
        } completionHandler: { metadata in
            if let completion = completionHandler {
                completion(metadata.path)
            }
        }
    }
}
