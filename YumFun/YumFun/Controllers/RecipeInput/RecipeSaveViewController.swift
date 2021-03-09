//
//  RecipeSaveViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 3/2/21.
//

import UIKit

class RecipeSaveViewController: UIViewController {

    @IBOutlet weak var textInput: UITextView!
    @IBOutlet var urlLabel: UITextField!
    var recipe: Recipe = Recipe()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Progress 5/5"
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)))
        if let link = recipe.url {
            urlLabel.text = "Recipe from: \n" + link.absoluteString
            // TODO input reference to parsed recipe site
        }
    }

    @IBAction func previewPressed(_ sender: Any) {
        recipe.chefNote = textInput.text
        // TODO preview recipe RecipeDetailViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let recipeDetailViewController = storyboard.instantiateViewController(identifier: "RecipeDetailViewController") as RecipeDetailViewController? else {
            assertionFailure("couln't get vc")
            return
        }
    
        recipeDetailViewController.recipe = recipe
        navigationController?.pushViewController(recipeDetailViewController, animated: true)
    }
}
