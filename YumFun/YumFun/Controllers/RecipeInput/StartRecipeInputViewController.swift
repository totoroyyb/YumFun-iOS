//
//  StartRecipeInputViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 2/28/21.
//

import UIKit

class StartRecipeInputViewController: UIViewController {
    

    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UITextField!
    var imagePicker = UIImagePickerController()
    var recipe: Recipe = Recipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(StartRecipeInputViewController.tapRecognized))
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        navigationItem.title = "Progress 1/5"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pushSecondRecipeInput))
        if recipe.title != "" {
            recipeName.text = recipe.title
        }
        
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
//        if let recipeURL = recipeImage.sd_imageURL {
//            recipe.picUrls.append(recipeURL)
//        }
        secondRecipeInputViewController.recipe = recipe
        navigationController?.pushViewController(secondRecipeInputViewController, animated: true)
    }
    @IBAction func uploadPressed(_ sender: Any) {
        uploadImage(sender)
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
