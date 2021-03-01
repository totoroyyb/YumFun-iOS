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
        navigationItem.title = "Step 1/5"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(pushSecondRecipeInput))
        
    }

    
    @objc func pushSecondRecipeInput() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let secondRecipeInputViewController = storyboard.instantiateViewController(identifier: "secondRecipeInputVC") as SecondRecipeInputViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        recipe.title = recipeName.text ?? "None"
        if let recipeURL = recipeImage.sd_imageURL {
            recipe.picUrls.append(recipeURL)
        }
        secondRecipeInputViewController.recipe = recipe
        navigationController?.pushViewController(secondRecipeInputViewController, animated: true)
    }
}

extension StartRecipeInputViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBAction func uploadImage(_ sender: Any) {
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
