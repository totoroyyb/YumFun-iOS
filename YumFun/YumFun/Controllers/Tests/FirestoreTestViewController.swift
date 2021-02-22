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
        let cuisine: [CuisineType] = [.asian, .chinese, .italian, .spanish_portuguese]
        let occasion = ["Hello"]
        
        return Recipe(author: "Yibo Yan",
                      serveSize: serveSize,
                      duration: duration,
                      dishType: dishType,
                      cuisine: cuisine,
                      occasion: occasion)
    }()
    
    private var recipeIDArray = [String]()
    private var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveToCloudButtonTapped(_ sender: Any) {
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
    }
    
    @IBAction func fetchAllButtonTapped(_ sender: Any) {
        FirestoreApi.getAllRecipes { (err, recipes, querySnapshot) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let documents = recipes {
                    for document in documents {
                        print("Recipes as below: \(document) \n \(document.cuisine) and \(document.cuisine[3])")
                    }
                } else {
                    print("No document is fetched")
                }
            }
        }
    }
    
    
//    @IBAction func updateFirstServeSizeTapped(_ sender: Any) {
//        self.recipes[0].serveSize = 100
//        print("Changed doc \(self.recipes[0].id ?? "Not Found")")
//    }
//
//
//    @IBAction func updateFirstDurationTapped(_ sender: Any) {
//        var new = Duration(prepTime: 50)
//        self.recipes[0].duration = new
//        print("Changed doc \(self.recipes[0].id ?? "Not Found")")
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
