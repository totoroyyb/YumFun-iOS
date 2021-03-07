//
//  ChooseRecipeInputViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 3/3/21.
//

import UIKit

class ChooseRecipeInputViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    
    @IBAction func recipeSearchPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let recipeSearchInputViewController = storyboard.instantiateViewController(identifier: "recipeSearchVC") as RecipeSearchViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        navigationController?.pushViewController(recipeSearchInputViewController, animated: true)
    }
    
    @IBAction func recipeInputPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "RecipeInput", bundle: nil)
        guard let startRecipeInputViewController = storyboard.instantiateViewController(identifier: "startRecipeInputVC") as StartRecipeInputViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        navigationController?.pushViewController(startRecipeInputViewController, animated: true)
    }
    
}
