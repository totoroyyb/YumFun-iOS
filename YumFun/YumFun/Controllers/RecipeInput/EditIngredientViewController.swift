//
//  EditIngredientViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 2/28/21.
//

import UIKit

class EditIngredientViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var unitPicker: UIPickerView!
    var inputRecipeViewController: InputRecipeIngredientsViewController?
    var selectedIngredientIndex = 0
    var selectedUnitIndex: Int = 0
    var name: String?
    var amount: Double?
    var isPreviousIngredient: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton(saveButton)
        setupButton(cancelButton)
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)))
        unitPicker.delegate = self
        unitPicker.dataSource = self
        initialize()
    }
    
    func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 10.0
        button.backgroundColor = UIColor(named: "primary") ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8)
    }
    
    func initialize() {
        if !isPreviousIngredient {
            saveButton.isUserInteractionEnabled = false
            saveButton.backgroundColor = .gray
        }
        if let name = name {
            nameTextField.text = name
        }
        
        if let amount = amount {
            amountTextField.text = amount.description
        }
        unitPicker.selectRow(selectedUnitIndex, inComponent: 0, animated: true)
        amountTextField.keyboardType = .decimalPad
    }
    
    @IBAction func enterPressed(_ sender: Any) {
        closeKeyboard()
    }
    
    
    @IBAction func editingChanged(_ sender: Any) {
        let count = nameTextField.text?.count ?? 0
        if count > 0 {
            saveButton.isUserInteractionEnabled = true
            saveButton.backgroundColor = UIColor(named: "primary") ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8)
        } else {
            saveButton.isUserInteractionEnabled = false
            saveButton.backgroundColor = .gray
        }
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismissCurrentView()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        guard let inputVC = inputRecipeViewController else {
            dismissCurrentView()
            return
        }
        let selectedUnit = MeasureUnit.allCases[unitPicker.selectedRow(inComponent: 0)]
        let ingredient = Ingredient(name: nameTextField.text ?? "", amount: Double(amountTextField.text ?? "0") ?? 0, unit: selectedUnit)
        if isPreviousIngredient {
            inputVC.updateIngredient(ingredient, selectedIngredientIndex)
        } else {
            inputVC.addIngredient(ingredient)
        }
        dismissCurrentView()
    }
    
    func dismissCurrentView() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension EditIngredientViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MeasureUnit.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 15)
        label.text =  MeasureUnit.allCases[row].toString()
        label.textAlignment = .center
        return label
    }
}
