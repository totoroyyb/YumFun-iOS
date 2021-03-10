//
//  ChooseRecipeInputViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 3/3/21.
//

import UIKit

class ChooseRecipeInputViewController: UIViewController {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var inputButton: UIButton!
    var startEditMode: Bool = false
    var recipe: Recipe?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton(searchButton)
        setupButton(inputButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if startEditMode, let rec = recipe {
            let storyboard = UIStoryboard(name: "RecipeInput", bundle: nil)
            guard let startRecipeViewController = storyboard.instantiateViewController(identifier: "startRecipeInputVC") as StartRecipeInputViewController? else {
                assertionFailure("couln't get vc")
                return
            }
            startRecipeViewController.recipe = rec
            startEditMode = false
            recipe = nil
            navigationController?.pushViewController(startRecipeViewController, animated: true)
        }
    }
    
    func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 10.0
        button.backgroundColor = UIColor(named: "primary") ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8)
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
