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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let serveSize: Int = 2
        let duration = Duration(prepTime: 5)
        let dishType = DishType.dessert
        let cuisine: [CuisineType] = [.asian, .chinese, .italian]
        let occasion = ["Unknown"]
        let creationDate = Date()
    
        let recipe = Recipe(serveSize: serveSize,
                            duration: duration,
                            dishType: dishType,
                            cuisine: cuisine,
                            occasion: occasion,
                            creationDate: creationDate)
        
        
        guard let jsonData = try? recipe.toJson() else {
            print("Failed to parse recipe to json")
            return
        }
        let dataStr = String(data: jsonData, encoding: .utf8)
        
        print("Recipe as follow \n \(dataStr)")
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
