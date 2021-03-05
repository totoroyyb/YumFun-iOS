//
//  SecondRecipeInputViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 2/28/21.
//

import UIKit

class SecondRecipeInputViewController: UIViewController {
        
    @IBOutlet weak var portionPicker: UIPickerView!
    @IBOutlet weak var prepTimePicker: UIPickerView!
    @IBOutlet weak var cookTimePicker: UIPickerView!
    @IBOutlet weak var restTimePicker: UIPickerView!
    @IBOutlet weak var parsedRecipeInfo: UILabel!
    var recipe: Recipe = Recipe()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Progress 2/5"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pushInputRecipeIngredientsViewController))
        portionPicker.delegate = self
        portionPicker.dataSource = self
        prepTimePicker.delegate = self
        prepTimePicker.dataSource = self
        cookTimePicker.delegate = self
        cookTimePicker.dataSource = self
        restTimePicker.delegate = self
        restTimePicker.dataSource = self
        if recipe.ingredients.count > 0 {
            initializePreviousRecipe()
        }
    }
    
    func initializePreviousRecipe() {
        portionPicker.selectRow(recipe.portionSize, inComponent: 0, animated: true)
        if let duration = recipe.duration {
            prepTimePicker.selectRow(duration.prep, inComponent: 0, animated: true)
            if let cook = duration.cook {
                cookTimePicker.selectRow(cook, inComponent: 0, animated: true)
            }
            if let rest = duration.rest {
                restTimePicker.selectRow(rest, inComponent: 0, animated: true)
            }
            var parseText = "Here's what we weren't able to automatically fill in:\n\n"
            var wasParsed = false
            if let parsedText = recipe.portionLabel {
                wasParsed = true
                parseText += "Portion Size: " + parsedText + "\n"
            }
            if let parsedText = duration.totalTimeLabel {
                wasParsed = true
                parseText += "Total time: " + parsedText + "\n"
            }
            if let parsedText = duration.cookLabel {
                wasParsed = true
                parseText += "Cook Time: " + parsedText + "\n"
            }
            if let parsedText = duration.restLabel {
                wasParsed = true
                parseText += "Rest Time: " + parsedText + "\n"
            }
            if wasParsed {
                parsedRecipeInfo.text = parseText
            }
        }
        
    }
    
    @objc func pushInputRecipeIngredientsViewController() {
        let storyboard = UIStoryboard(name: "RecipeInput", bundle: nil)
        guard let inputRecipeIngredientsViewController = storyboard.instantiateViewController(identifier: "inputRecipeIngredientsVC") as InputRecipeIngredientsViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        let selectedPortion = [portionPicker.selectedRow(inComponent: 0)]
        let prepTime = [prepTimePicker.selectedRow(inComponent: 0)]
        let cookTime = [cookTimePicker.selectedRow(inComponent: 0)]
        let restTime = [restTimePicker.selectedRow(inComponent: 0)]
        recipe.portionSize = selectedPortion[0]
        recipe.duration = Duration(prepTime: prepTime[0])
        recipe.duration?.prep = prepTime[0]
        recipe.duration?.cook = cookTime[0]
        recipe.duration?.rest = restTime[0]
        inputRecipeIngredientsViewController.recipe = recipe
        navigationController?.pushViewController(inputRecipeIngredientsViewController, animated: true)
    }

}

extension SecondRecipeInputViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == portionPicker {
            return 1
        } else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == portionPicker {
            return 50
        } else {
            if component == 0 {
                return 100
            } else if component == 1 {
                return 60
            } else {
                return 1
            }
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
