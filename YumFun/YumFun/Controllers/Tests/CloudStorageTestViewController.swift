//
//  CloudStorageTestViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/26.
//

import UIKit
import PhotosUI

class CloudStorageTestViewController: UIViewController, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private let storage = CloudStorage(.profileImage)
    
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
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("failed to get data.")
            return
        }
        
        storage.upload(data, metadata: nil, errorHandler: uploadErrorHandler(error:)) { (metadata) in
            self.storage.downloadURL(errorHandler: self.getUrlErrorHandler(error:)) { (url) in
                print("URL is fetched: \(url)")
            }
        }
    }
    
    @IBAction func deleteTestImageTapped(_ sender: Any) {
        storage.delete(errorHandler: nil) {
            print("Successfully Deleted.")
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
