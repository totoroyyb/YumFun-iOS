//
//  FirestoreTestViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/20.
//

import UIKit
import FirebaseFirestoreSwift
import Firebase

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
        let steps: [Step] = [
            Step(title: "Step 1", description: "Step 1"),
            Step(title: "Step 2", description: "Step 2"),
            Step(title: "Step 3", description: "Step 3"),
            Step(title: "Step 4", description: "Step 4")
        ]
        
        return Recipe(author: "Yibo Yan",
                      serveSize: serveSize,
                      duration: duration,
                      dishType: dishType,
                      cuisine: cuisine,
                      occasion: occasion,
                      steps: steps)
    }()
    
    private var recipeIDArray = [String]()
    private var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveToCloudButtonTapped(_ sender: Any) {
        testRecipe.occasion.append("\(recipeIDArray.count)")
        Recipe.post(with: testRecipe) { (err, docRef) in
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

        Recipe.update(named: recipeIDArray[0], with: updateData) { (err) in
            if let err = err {
                print("Failed to update data: \(updateData) with error: \(err)")
            } else {
                print("Successfully update data: \(updateData)")
            }
        }
    }
    
    @IBAction func fetchAllButtonTapped(_ sender: Any) {
        Recipe.getAll { (err, recipes, querySnapshot) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let documents = recipes {
                    for document in documents {
                        print("Recipes as below: \(document) with id \(document.id ?? "No ID Found")")
                    }
                } else {
                    print("No document is fetched")
                }
            }
        }
    }
    
    @IBAction func pushCurrentUserTapped(_ sender: Any) {
//        let testUser = User(displayName: "Yibo Yan", userName: "ybyan", bio: "This is a test bio")
        
        if let user = Auth.auth().currentUser {
            User.post(with: User(fromAuthUser: user), named: user.uid) { (err, _) in
                if let err = err {
                    print("Error to post user \(err)")
                }
            }
        } else {
            print("Cannot Fetch Current User.")
        }
    }
    
    @IBAction func fetchCurrentUserTapped(_ sender: Any) {
//        if let user = Auth.auth().currentUser {
//            User.get(named: user.uid) { (err, userBack, _) in
//                if let err = err {
//                    print("Error get user with id: \(user.uid), with error: \(err)")
//                } else {
//                    print("User as follow:\n \(userBack)")
//                }
//            }
//        } else {
//            print("Cannot Fetch Current User.")
//        }
        
        if let user = Core.currentUser {
            print("Current User as follow:\n \(user)")
        } else {
            print("Cannot Fetch Current User.")
        }
    }
    
    @IBAction func currentUserCreateRecipeTapped(_ sender: Any) {
        if let currUser = Core.currentUser {
            print("Current user id: \(currUser.id)")
            currUser.createRecipe(with: testRecipe) { (err, docRef) in
                if let err = err {
                    print("Error create recipe from current user. \(err)")
                }
            }
        }
    }
    
    @IBAction func deleteFirstRecipeTapped(_ sender: Any) {
        if let currUser = Core.currentUser {
            let firstRecipe = currUser.recipes[0]
            currUser.deleteRecipe(withId: firstRecipe) { (error) in
                if let err = error {
                    print("Error to delete the first recipe: \(err)")
                } else {
                    print("Deleted recipe \(firstRecipe)")
                }
            }
        }
    }
    
    
    //    var incrementInt: Int = 0
    
    @IBAction func postRecipeWithNameTapped(_ sender: Any) {
//        self.incrementInt += 1
//        FirestoreApi.postData(in: "recipe", with: testRecipe, named: "recipe\(incrementInt)") { (err, _) in
//            if let err = err {
//                print("Error post recipe \(err)")
//            }
//        }
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
