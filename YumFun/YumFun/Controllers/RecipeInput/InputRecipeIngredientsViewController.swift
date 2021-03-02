//
//  InputRecipeIngredientsViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 2/28/21.
//

import UIKit

class InputRecipeIngredientsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var recipe: Recipe = Recipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Step 3/5"
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    @IBAction func addIngredientClicked(_ sender: Any) {
        if let addIngredientViewController = storyboard?.instantiateViewController(identifier: "editIngredientVC") as? EditIngredientViewController {
        
            addIngredientViewController.inputRecipeViewController = self
            addIngredientViewController.modalPresentationStyle = .fullScreen
            navigationController?.present(addIngredientViewController, animated: true, completion: nil)
        }
    }
    
    func addIngredient(_ ingredient: Ingredient) {
        recipe.ingredients.append(ingredient)
        print("Ingredient added")
        self.tableView.reloadData()
    }
    
    func updateIngredient(_ ingredient: Ingredient, _ index: Int) {
        recipe.ingredients[index] = ingredient
        print("Ingredient updated")
        self.tableView.reloadData()
    }
}

class IngredientTableCell: UITableViewCell {
        
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
}

extension InputRecipeIngredientsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe.ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableCell") as? IngredientTableCell ?? UITableViewCell(style: .default, reuseIdentifier: "IngredientTableCell") as? IngredientTableCell
        guard let unwrappedCell = cell else {
            return cell ?? IngredientTableCell()
        }
        let ingredient = recipe.ingredients[indexPath.row]
        unwrappedCell.nameLabel.text = ingredient.name
        unwrappedCell.unitLabel.text = ingredient.amount.description + " " + ingredient.unit.toString()
        
        return unwrappedCell
    }
    
    @objc func removeCell(sender: UIButton) {
        recipe.ingredients.remove(at: sender.tag)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Select Option", message:
        "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (_) in
            self.setupIngredientController(self.recipe.ingredients[indexPath.row], indexPath.row)
        }))
        alertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
            self.recipe.ingredients.remove(at: indexPath.row)
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true)
    }
    
    func setupIngredientController(_ ingredient: Ingredient, _ index: Int) {
        if let editIngredientViewController = storyboard?.instantiateViewController(identifier: "editIngredientVC") as? EditIngredientViewController {
        
            editIngredientViewController.inputRecipeViewController = self
            editIngredientViewController.name = ingredient.name
            editIngredientViewController.amount = ingredient.amount
            editIngredientViewController.selectedIngredientIndex = index
            editIngredientViewController.isEditingIngredient = true
            var unitIndex = 0
            for unit in MeasureUnit.allCases {
                if unit == ingredient.unit {
                    break
                }
                unitIndex+=1
            }
            editIngredientViewController.selectedUnitIndex = unitIndex
            editIngredientViewController.modalPresentationStyle = .fullScreen
            navigationController?.present(editIngredientViewController, animated: true, completion: nil)
        }
    }
}
