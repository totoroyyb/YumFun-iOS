//
//  InputRecipeStepsViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 3/1/21.
//

import UIKit

class InputRecipeStepsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addStepButton: UIButton!
    var recipe: Recipe = Recipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Progress 4/5"
        setupButton(addStepButton)
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pushRecipeSaveView))
    }
    
    func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 10.0
        button.backgroundColor = UIColor(named: "primary") ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepTableCell") as? StepTableCell ?? UITableViewCell(style: .default, reuseIdentifier: "StepTableCell") as? StepTableCell
        
        if let unwrappedCell = cell {
            unwrappedCell.stepLabel?.text = "Step " + String(indexPath.row + 1) + ": " + recipe.steps[indexPath.row].description
            if recipe.steps[indexPath.row].time ?? 0 > 0.0 {
                
                if let secs = recipe.steps[indexPath.row].time {
                    unwrappedCell.timeLabel?.text = Utility.parseTimeIntervalSec(time: secs)
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
