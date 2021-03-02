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
    
    var recipe: Recipe = Recipe()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Step 2/5"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pushInputRecipeIngredientsViewController))
        portionPicker.delegate = self
        portionPicker.dataSource = self
        prepTimePicker.delegate = self
        prepTimePicker.dataSource = self
        cookTimePicker.delegate = self
        cookTimePicker.dataSource = self
        restTimePicker.delegate = self
        restTimePicker.dataSource = self

    }
    
    @objc func pushInputRecipeIngredientsViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
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
