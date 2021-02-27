//
//  CloudStorageTestViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/26.
//

import UIKit
import PhotosUI
import FirebaseUI

class CloudStorageTestViewController: UIViewController, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firebaseUIImageView: UIImageView!
    
    private let storage = CloudStorage(.profileImage)
    private var filepath: String?
    
    private var testRecipe: Recipe = {
        let serveSize: Int = 10
        let duration = Duration(prepTime: 5)
        let dishType = DishType.dessert
        let cuisine: [CuisineType] = [.asian, .chinese, .italian, .spanish_portuguese]
        let occasion = ["Hello"]
        
        return Recipe(author: "Yibo Yan",
                      serveSize: serveSize,
                      duration: duration,
                      dishType: dishType,
                      cuisine: cuisine,
                      occasion: occasion)
    }()
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            let previousImage = imageView.image
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    
                    self.imageView.image = image
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        storage.child("testProfile.jpeg")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loadImageTapped(_ sender: Any) {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            
            picker.delegate = self
            
            present(picker, animated: true)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func upload2ProfileTapped(_ sender: Any) {
        guard let image = self.imageView.image else { return }
        
//        guard let data = image.jpegData(compressionQuality: 0.8) else {
//            print("failed to get data.")
//            return
//        }
//
//        storage.upload(data, metadata: nil, errorHandler: uploadErrorHandler(error:)) { (metadata) in
//            self.filepath = self.storage.fileRef.fullPath
//        }
        
        guard let currentUser = Core.currentUser else {
            return
        }
        
        let _ = currentUser.updateProfileImage(with: image) { (error) in
            if let error = error {
                print("Error to update profile image: \(error)")
            } else {
                print("Successfully update the current user profile image.")
            }
        }
        
//        storage.uploadWithURLBack(data, metadata: nil) { (error) in
//            print("Error detected for uploading image: \(error)")
//        } completionHandler: { (url) in
//            self.downloadUrl = url
//            print("URL is fetched: \(url.absoluteString)")
//        }
        
    }
    
    @IBAction func loadCurrentUserImageTapped(_ sender: Any) {
        guard let currentUser = Core.currentUser, let picUrl = currentUser.photoUrl else {
            return
        }
        
        let myStorage = CloudStorage(picUrl)
        
        self.firebaseUIImageView.sd_setImage(
            with: myStorage.fileRef,
            maxImageSize: 1 * 2048 * 2048,
            placeholderImage: nil,
            options: [.progressiveLoad, .refreshCached]) { (image, error, cache, storageRef) in
            if let error = error {
                print("Error load Image: \(error)")
            } else {
                print("Finished loading current user profile image.")
            }
        }
    }
    
    @IBAction func deleteTestImageTapped(_ sender: Any) {
        storage.delete(errorHandler: nil) {
            print("Successfully Deleted.")
        }
    }
    
    @IBAction func loadImageWithFirebaseUITapped(_ sender: Any) {
        guard let path = self.filepath else {
            print("Cannot fetch download filpath.")
            return
        }
        
        let myStorage = CloudStorage(path)
        
        self.firebaseUIImageView.sd_setImage(
            with: myStorage.fileRef,
            maxImageSize: 1 * 2014 * 1024,
            placeholderImage: nil,
            options: [.progressiveLoad, .refreshCached]) { (image, error, cache, storageRef) in
            if let error = error {
                print("Error load Image: \(error)")
            } else {
                print("Finished with FirebaseUI loading.")
            }
        }
    }
    
    @IBAction func loadImageWithDownloadTapped(_ sender: Any) {
        guard let path = self.filepath else {
            print("Cannot fetch download filpath.")
            return
        }
        
        let myStorage = CloudStorage(path)
        
        myStorage.download(maxSize: 1 * 2048 * 2048, errorHandler: { (error) in
            print("Error detected with download image: \(error)")
        }) { (data) in
            guard let data = data else {
                print("failed to load image with downloading")
                return
            }
            
            self.firebaseUIImageView.image = UIImage(data: data)
        }
    }
    
    @IBAction func uploadRecipeImageTapped(_ sender: Any) {
        guard let image = self.imageView.image else {return}
        
        testRecipe.uploadRecipeImage(with: image, nil) { (path) in
            if let path = path {
                print("Path is \(path)")
            }
        }
        
        guard let currUser = Core.currentUser else { return }
        currUser.createRecipe(with: testRecipe) { (error, docRef) in
            if error == nil {
                print("created recipe with id: \(docRef?.documentID)")
            }
        }
    }
    
    
    func uploadErrorHandler(error: Error?) {
        if let error = error {
            print("Error in uploading data: \(error)")
        }
    }
    
    func getUrlErrorHandler(error: Error?) {
        if let error = error {
            print("Error in getting url: \(error)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
