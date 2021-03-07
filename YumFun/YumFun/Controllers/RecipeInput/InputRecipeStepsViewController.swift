//
//  InputRecipeStepsViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 3/1/21.
//

import UIKit

class InputRecipeStepsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var recipe: Recipe = Recipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Progress 4/5"
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pushRecipeSaveView))
    }
    
    @IBAction func addStep(_ sender: Any) {
        if let addStepViewController = storyboard?.instantiateViewController(identifier: "editStepVC") as? EditStepViewController {
            addStepViewController.recipe = recipe
            addStepViewController.modalPresentationStyle = .fullScreen
            addStepViewController.inputRecipeStepsViewController = self
            navigationController?.present(addStepViewController, animated: true, completion: nil)
        }
    }
    
    // Pass recipe and tell controller that step already present
    func setupStepController(_ step: Step, _ index: Int) {
        if let editStepViewController = storyboard?.instantiateViewController(identifier: "editStepVC") as? EditStepViewController {
            editStepViewController.recipe = recipe
            
            editStepViewController.isPreviousStep = true
            editStepViewController.currentStepIndex = index
            editStepViewController.inputRecipeStepsViewController = self
    
            editStepViewController.modalPresentationStyle = .fullScreen
            navigationController?.present(editStepViewController, animated: true, completion: nil)
        }
    }
    
    @objc func pushRecipeSaveView() {
        let storyboard = UIStoryboard(name: "RecipeInput", bundle: nil)
        guard let recipeSaveViewController = storyboard.instantiateViewController(identifier: "recipeSaveVC") as RecipeSaveViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        
        recipeSaveViewController.recipe = recipe
        navigationController?.pushViewController(recipeSaveViewController, animated: true)
    }
}

class StepTableCell: UITableViewCell {
    
    @IBOutlet weak var stepImage: UIImageView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}

extension InputRecipeStepsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe.steps.count
    }
    
    // TODO fix step UI
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepTableCell") as? StepTableCell ?? UITableViewCell(style: .default, reuseIdentifier: "StepTableCell") as? StepTableCell
        
        if let unwrappedCell = cell {
//            let step = recipe.steps[indexPath.row]
//            if let url = step.photoUrl {
//                DispatchQueue.global().async {
//                    if let data = try? Data(contentsOf: url) {
//                        DispatchQueue.main.async {
//                            //unwrappedCell.stepImage?.image = UIImage(data: data)
//                        }
//                    }
//                }
//            }
            
            unwrappedCell.stepLabel?.text = "Step " + String(indexPath.row) + ": " + recipe.steps[indexPath.row].description
            if recipe.steps[indexPath.row].time ?? 0 > 0.0 {
                let hours = String(recipe.steps[indexPath.row].time ?? 0 / 3600)
                let minutes = String((recipe.steps[indexPath.row].time ?? 0 / 3600) / 60)
                if recipe.steps[indexPath.row].time ?? 0 / 3600 > 0.0 {
                    if (((recipe.steps[indexPath.row].time ?? 0 / 3600) / 60) > 0.0) {
                        unwrappedCell.timeLabel?.text = hours + " hrs " + minutes + " m"
                    } else {
                        unwrappedCell.timeLabel?.text = hours + " hrs "
                    }
                } else {
                    unwrappedCell.timeLabel?.text = minutes + " m"
                }
                
            }
            return unwrappedCell
        }
        
        return StepTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Select Option", message:
        "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (_) in
            self.setupStepController(self.recipe.steps[indexPath.row], indexPath.row)
        }))
        alertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
            self.recipe.steps.remove(at: indexPath.row)
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true)
    }
}
