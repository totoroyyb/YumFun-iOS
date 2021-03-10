//
//  StartRecipeInputViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 2/28/21.
//

import UIKit
import QCropper
import JGProgressHUD

class StartRecipeInputViewController: UIViewController, CropperViewControllerDelegate {
    

    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var uploadImageButton: UIButton!
    var imagePicker = UIImagePickerController()
    var recipe: Recipe = Recipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        setupButton(uploadImageButton)
        recipeImage.layer.borderWidth = 5
        recipeImage.layer.borderColor = UIColor(named: "primary")?.cgColor ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8).cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(StartRecipeInputViewController.tapRecognized))
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        navigationItem.title = "Progress 1/5"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pushSecondRecipeInput))
        if recipe.steps.count > 0 {
            recipeName.text = recipe.title
        }
        
    }
    
    func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 10.0
        button.backgroundColor = UIColor(named: "primary") ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8)
    }
    
    @objc func tapRecognized() {
        closeKeyboard()
    }
    
    
    func closeKeyboard() {
        view.endEditing(true)
    }

    @objc func pushSecondRecipeInput() {
        let storyboard = UIStoryboard(name: "RecipeInput", bundle: nil)
        guard let secondRecipeInputViewController = storyboard.instantiateViewController(identifier: "secondRecipeInputVC") as SecondRecipeInputViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        recipe.title = recipeName.text ?? "None"
        secondRecipeInputViewController.recipe = recipe
        navigationController?.pushViewController(secondRecipeInputViewController, animated: true)
    }
    @IBAction func uploadPressed(_ sender: Any) {
        ImagePickerManager().pickImage(self) { image in
            let cropper = CustomImageClipViewController(originalImage: image)
            cropper.delegate = self
            self.present(cropper, animated: true, completion: nil)
        }
    }
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        guard let cropper = cropper as? CustomImageClipViewController else {
            displayErrorBottomPopUp(title: "ERROR",
                                    description: "Sorry, current user info has been correctly loaded. Please reload the entire app, and try again.")
            return
        }
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.show(in: cropper.view, animated: true)
        if let state = state,
            let image = cropper.originalImage.cropped(withCropperState: state) {
            print(cropper.isCurrentlyInInitialState)
            print(image)
            hud.dismiss()
            cropper.dismiss(animated: true, completion: nil)
            recipeImage.image = image
            recipe.uploadRecipeImage(with: image, nil) { (path) in
                if let path = path {
                    print("Path is \(path)")
                    self.recipe.picUrls.append(path)
                }
            }
        } else {
            hud.dismiss()
            displayErrorBottomPopUp(title: "ERROR",
                                    description: "Sorry, we cannot finish current operation.")
        }
    }
}

extension StartRecipeInputViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func uploadImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                return
        }
        recipeImage.image = image
        dismiss(animated: true, completion: nil)
    }
}
