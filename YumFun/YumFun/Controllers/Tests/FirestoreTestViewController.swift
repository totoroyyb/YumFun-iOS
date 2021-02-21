//
//  FirestoreTestViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/20.
//

import UIKit
import FirebaseFirestoreSwift

class FirestoreTestViewController: UIViewController {
    
    @IBOutlet weak var serveSizeTextField: UITextField!
    @IBOutlet weak var prepTimeTextField: UITextField!
    @IBOutlet weak var dishTypeTextField: UITextField!
    @IBOutlet weak var cuisineTextField: UITextField!
    
    private var testRecipe: Recipe = {
        let serveSize: Int = 10
        let duration = Duration(prepTime: 5)
        let dishType = DishType.dessert
        let cuisine: [CuisineType] = [.asian, .chinese, .italian]
        let occasion = ["Hello"]
        
        return Recipe(serveSize: serveSize,
                     duration: duration,
                     dishType: dishType,
                     cuisine: cuisine,
                     occasion: occasion)
    }()
    
    private var recipeIDArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func printTestButtonTapped(_ sender: Any) {
//        print("Recipe as follow \n \(testRecipe.toJsonStr())")
    }
    
    @IBAction func saveToCloudButtonTapped(_ sender: Any) {
//        FirestoreApi.postData(with: testRecipe) { (err, docRef) in
//            if let err = err {
//                print("Failed to save to cloud with error: \(err)")
//            } else {
//                print("Document added with ID: \(docRef?.documentID)")
//            }
//        }
        testRecipe.occasion.append("\(recipeIDArray.count)")
        FirestoreApi.postRecipe(with: testRecipe) { (err, docRef) in
            if let err = err {
                print("Failed to save to cloud with error: \(err)")
            } else {
                
                if let docID = docRef?.documentID {
                    self.recipeIDArray.append(docID)
                    print("Document added with ID: \(docID)")
                }
            }
        }
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        let updateData = [ "serveSize": Int.random(in: 1...10) ]
        
        FirestoreApi.updateRecipe(named: recipeIDArray[0], with: updateData) { (err) in
            if let err = err {
                print("Failed to update data: \(updateData) with error: \(err)")
            } else {
                print("Successfully update data: \(updateData)")
            }
        }
        
//        testRecipe.serveSize = Int.random(in: 1...10)
//
//        FirestoreApi.updateRecipe(named: recipeIDArray[0], with: testRecipe) { (err) in
//            if let err = err {
//                print("Failed to update data: \(self.testRecipe.serveSize) with error: \(err)")
//            } else {
//                print("Successfully update data: \(self.testRecipe.serveSize)")
//            }
//        }
    }
    
    @IBAction func fetchAllButtonTapped(_ sender: Any) {
//        FirestoreApi.fetchAllData(in: "recipe") { (err, documents: [Recipe]?, querySnapshot) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                if let documents = documents {
//                    for document in documents {
////                        let doc = try? document.data(as: Recipe.self)
////                        print("\(document.documentID) => \(doc) with id: \(doc?.id)")
//                        print("Recipes as below: \(document)")
//                    }
//                } else {
//                    print("No document is fetched")
//                }
//            }
//        }
        
        FirestoreApi.getAllRecipes { (err, recipes, querySnapshot) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let documents = recipes {
                    for document in documents {
                        print("Recipes as below: \(document)")
                    }
                } else {
                    print("No document is fetched")
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
