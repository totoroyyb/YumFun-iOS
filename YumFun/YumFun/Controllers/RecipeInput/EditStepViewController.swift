//
//  EditStepViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 3/1/21.
//

import UIKit

class EditStepViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var recipeDescription: UITextView!
    @IBOutlet weak var recipeTime: UIPickerView!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var utensilsTableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    var imagePicker = UIImagePickerController()
    let highlighted: UIColor = UIColor.gray
    var inputRecipeStepsViewController: InputRecipeStepsViewController?
    var recipe: Recipe = Recipe()
    var stepCopy: Step = Step(description: "")
    var currentStepIndex: Int = 0
    var isPreviousStep: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(EditStepViewController.tapRecognized))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        initialize()
        if isPreviousStep {
            initializePreviousStepData()
        } else {
            let newStep = Step(description: "")
            recipe.steps.append(newStep)
            currentStepIndex = recipe.steps.count - 1
            saveButton.isUserInteractionEnabled = false
            saveButton.backgroundColor = .gray
        }
    }
    
    func initialize() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        recipeTime.delegate = self
        recipeTime.dataSource = self
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        utensilsTableView.delegate = self
        utensilsTableView.dataSource = self
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Copy previous step so if cancel is pressed, can revert changes
    func initializePreviousStepData() {
        stepCopy.description = recipe.steps[currentStepIndex].description
        stepCopy.photoUrl = recipe.steps[currentStepIndex].photoUrl
        stepCopy.ingredients = recipe.steps[currentStepIndex].ingredients.map { $0 }
        stepCopy.time = recipe.steps[currentStepIndex].time
        stepCopy.title = recipe.steps[currentStepIndex].title
        stepCopy.utensils = recipe.steps[currentStepIndex].utensils.map { $0 }
        stepCopy.time = recipe.steps[currentStepIndex].time
        recipeDescription.text = recipe.steps[currentStepIndex].description
    }
    
    @objc func tapRecognized(_ gesture: UITapGestureRecognizer) {
        if let count = recipeDescription.text?.count, count > 0 {
            saveButton.isUserInteractionEnabled = true
            saveButton.backgroundColor = .systemBlue
            recipe.steps[currentStepIndex].description = recipeDescription.text ?? ""
        }
        view.endEditing(true)
    }
    
    @IBAction func addUtensil(_ sender: Any) {
        let alertController = UIAlertController(title: "Enter Utensil Name", message:
        "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "e.g., whisk"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            if let utensilTextField = alertController.textFields {
                if let utensilName = utensilTextField[0].text {
                    let addedUtensil = Utensil(name: utensilName)
                    self.recipe.steps[self.currentStepIndex].utensils.append(addedUtensil)
                    self.utensilsTableView.reloadData()
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true)
    }
    
    // If editing previous step, replace with copy, else remove newly created step
    @IBAction func cancelPressed(_ sender: Any) {
        if isPreviousStep {
            recipe.steps[currentStepIndex] = stepCopy
        } else {
            recipe.steps.remove(at: currentStepIndex)
        }
        dismissCurrentView()
    }
    
    
    @IBAction func savePressed(_ sender: Any) {
        let hoursToSeconds = recipeTime.selectedRow(inComponent: 0) * 60 * 60
        let minutesToSeconds = recipeTime.selectedRow(inComponent: 1) * 60
        let seconds: TimeInterval = TimeInterval(hoursToSeconds + minutesToSeconds)
        recipe.steps[currentStepIndex].time = seconds
        dismissCurrentView()
    }
    
    func dismissCurrentView() {
        if let vc = inputRecipeStepsViewController {
            vc.recipe = recipe
            vc.tableView.reloadData()
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension EditStepViewController: UITableViewDataSource, UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ingredientsTableView {
            return recipe.ingredients.count
        } else {
            if recipe.steps.count > 0 {
                return recipe.steps[currentStepIndex].utensils.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ingredientsTableView {
            return setupIngredientCell(tableView, indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
            let utensil = recipe.steps[currentStepIndex].utensils[indexPath.row]
            cell.textLabel?.text = utensil.name
            return cell
        }
    }
    
    func setupIngredientCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableCell") as? IngredientTableCell ?? UITableViewCell(style: .default, reuseIdentifier: "IngredientTableCell") as? IngredientTableCell
        guard let unwrappedCell = cell else {
            return cell ?? IngredientTableCell()
        }
        let ingredient = recipe.ingredients[indexPath.row]
        unwrappedCell.nameLabel.text = ingredient.name
        //unwrappedCell.unitLabel.text = ingredient.amount.description + " " + ingredient.unit.toString()
        if unwrappedCell.isChecked {
            unwrappedCell.contentView.backgroundColor = highlighted
        }
        
        return unwrappedCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == ingredientsTableView {
            handleIngredientSelected(tableView, indexPath)
        } else {
            handleUtensilSelected(tableView, indexPath)
        }
    }
    
    func handleIngredientSelected(_ tableView: UITableView, _ indexPath: IndexPath) {
        let selectedIngredient = recipe.ingredients[indexPath.row]
        if let currentCell = tableView.cellForRow(at: indexPath) as? IngredientTableCell {
            if currentCell.isChecked {
                currentCell.isChecked = false
                currentCell.contentView.backgroundColor = UIColor.white
                if let index = recipe.steps[currentStepIndex].ingredients.firstIndex(of: selectedIngredient) {
                    recipe.steps[currentStepIndex].ingredients.remove(at: index)
                }
            } else {
//                    let hasIngredient =  recipe.steps[currentStepIndex].ingredients.contains{ (ingredient) -> Bool in
//                        ingredient.name == selectedIngredient.name
//                    }
                currentCell.isChecked = true
                currentCell.contentView.backgroundColor = highlighted
                recipe.steps[currentStepIndex].ingredients.append(selectedIngredient)
            }
            //self.ingredientsTableView.reloadData()
        }
    }
    
    func handleUtensilSelected(_ tableView: UITableView, _ indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Select Option", message:
        "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
            let selectedIngredient = self.recipe.steps[self.currentStepIndex].utensils[indexPath.row]
            if let index = self.recipe.steps[self.currentStepIndex].utensils.firstIndex(of: selectedIngredient) {
                self.recipe.steps[self.currentStepIndex].utensils.remove(at: index)
            }
            self.utensilsTableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true)
    }
}

extension EditStepViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                return
        }
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
}

extension EditStepViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 100
        } else {
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return setupRowLabel(row)
    }
    
    func setupRowLabel(_ row: Int) -> UIView {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 15)
        label.text =  row.description
        label.textAlignment = .center
        return label
    }
    
}

