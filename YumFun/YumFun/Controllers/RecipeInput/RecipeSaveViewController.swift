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
    @IBOutlet weak var previewButton: UIButton!
    var recipe: Recipe = Recipe()
    override func viewDidLoad() {
        super.viewDidLoad()
        textInput.layer.borderColor = UIColor(named: "primary")?.cgColor ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8).cgColor;
        textInput.layer.borderWidth = 1.0;
        textInput.layer.cornerRadius = 8;
        setupButton(previewButton)
        if let note = recipe.chefNote {
            textInput.text = note
        }
        
        navigationItem.title = "Progress 5/5"
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)))
        if let link = recipe.url {
            urlLabel.text = "Recipe from: \n" + link.absoluteString
        }
    }
    
    func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 10.0
        button.backgroundColor = UIColor(named: "primary") ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8)
    }

    @IBAction func previewPressed(_ sender: Any) {
        recipe.chefNote = textInput.text
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let recipeDetailViewController = storyboard.instantiateViewController(identifier: "RecipeDetailViewController") as RecipeDetailViewController? else {
            assertionFailure("couln't get vc")
            return
        }
    
        recipeDetailViewController.recipe = recipe
        self.navigationController?.setViewControllers([recipeDetailViewController], animated: true)
    }
}
