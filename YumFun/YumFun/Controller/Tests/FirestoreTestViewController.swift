//
//  FirestoreTestViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/20.
//

import UIKit

class FirestoreTestViewController: UIViewController {
    
    @IBOutlet weak var serveSizeTextField: UITextField!
    @IBOutlet weak var prepTimeTextField: UITextField!
    @IBOutlet weak var dishTypeTextField: UITextField!
    @IBOutlet weak var cuisineTextField: UITextField!
    
    private let testRecipe: Recipe = {
        let serveSize: Int = 2
        let duration = Duration(prepTime: 5)
        let dishType = DishType.dessert
        let cuisine: [CuisineType] = [.asian, .chinese, .italian]
        let occasion = ["Unknown"]
        let creationDate = Date()
        
        return Recipe(serveSize: serveSize,
                     duration: duration,
                     dishType: dishType,
                     cuisine: cuisine,
                     occasion: occasion,
                     creationDate: creationDate)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func printTestButtonTapped(_ sender: Any) {
        print("Recipe as follow \n \(testRecipe.toJsonStr())")
    }
    
    @IBAction func saveToCloudButtonTapped(_ sender: Any) {
        FirestoreApi.postData(with: testRecipe) { (err, docRef) in
            if let err = err {
                print("Failed to save to cloud with error: \(err)")
            } else {
                print("Document added with ID: \(docRef?.documentID)")
            }
        }
    }
    
    @IBAction func fetchAllButtonTapped(_ sender: Any) {
        FirestoreApi.fetchAllData { (err, documents) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let documents = documents {
                    for document in documents {
                        print("\(document.documentID) => \(document.data())")
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
