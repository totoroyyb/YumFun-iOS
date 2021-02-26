//
//  CloudStorageApi.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/2/26.
//

import Foundation
import Firebase
import FirebaseStorage

enum AssetType: String, Codable, CaseIterable {
    case profileImage = "images/profiles"
    case recipeImage = "images/recipes"
    case image = "images"
    case video = "videos"
    case audio = "audios"
}

class CloudStorage {
    static let storage = Storage.storage()
    static let storageRef = storage.reference()
    
    fileprivate(set) var fileRef: StorageReference
    
    private(set) var uploadTask: StorageUploadTask?
    private(set) var downloadTask: StorageDownloadTask?
    
    /**
     Initialize a cloud storage object which points to the location sepcified by `filepath`
     
     - Parameter filepath: path of a file in the cloud storage
     */
    init(_ filepath: String) {
        fileRef = CloudStorage.storageRef.child(filepath)
    }
    
    /**
     Initialize a cloud storage object which points to the location specified by `assetType`
     */
    init(_ assetType: AssetType) {
        fileRef = CloudStorage.storageRef.child(assetType.rawValue)
    }
    
    /**
     Initialize a cloud storage object which points to the root path in the cloud.
     */
    init() {
        fileRef = CloudStorage.storageRef.root()
    }
}

extension CloudStorage {
    /**
     Wrapper function for fetching download url of current referred document.
     
     ## Note
     - Use error handler to catch error
     - Use completion handler to retrieve the URL.
     */
    func downloadURL(errorHandler: ((Error?) -> Void)?,
                     completion: @escaping (URL) -> Void) {
        self.fileRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                if let errorHandler = errorHandler {
                    DispatchQueue.main.async {
                        errorHandler(error)
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(downloadURL)
            }
        }
    }
}

/// Basic wrappers for navigating in Cloud Storage file structure.
extension CloudStorage {
    /**
     Set a file points to a `filepath` relative to current path
     */
    func child(_ filepath: String) {
        self.fileRef = fileRef.child(filepath)
    }
    
    /**
     Set a file points to the root location in the cloud.
     
     ## Note
     A file might not always have a parent. So this action might fail. If this action fails, `false` will be returned. Otherwise, `true` will be returned.
     */
    func parent() -> Bool {
        guard let rootRef = self.fileRef.parent() else {
            print("Cannot navigate to parent.")
            return false
        }
        
        self.fileRef = rootRef
        return true
    }
    
    /**
     Set a file points to the root.
     */
    func root() {
        self.fileRef = fileRef.root()
    }
}

/// Wrapper for uploading task
extension CloudStorage {
    typealias uploadErrorHandler = ((Error?) -> Void)?
    typealias uploadCompletionHandler = ((StorageMetadata) -> Void)?
    
    /**
     Upload the data into the cloud.
     
     ## Note
     If an error occurs, the error handler will be executed. If no error occurs, and completion handler is provided, then completion handler will be executed.
     */
    func upload(_ data: Data,
                metadata: StorageMetadata?,
                errorHandler: uploadErrorHandler,
                completionHandler: uploadCompletionHandler) {
        self.uploadTask = self.fileRef.putData(data, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                if let errorHandler = errorHandler {
                    DispatchQueue.main.async {
                        errorHandler(error)
                    }
                }
                return
            }
            
            if let completionHandler = completionHandler {
                DispatchQueue.main.async {
                    completionHandler(metadata)
                }
            }
        }
    }
    
    /**
     Pause the upload process if there is a upload task.
     */
    func pauseUpload() {
        self.uploadTask?.pause()
    }
    
    /**
     Resume the upload process if there is a upload task
     */
    func resumeUpload() {
        self.uploadTask?.resume()
    }
    
    /**
     Cancel the upload process if there is a upload task
     */
    func cancelUpload() {
        self.uploadTask?.cancel()
    }
}

/// Wrappers for downloading tasks
extension CloudStorage {
    typealias downloadErrorHandler = ((Error) -> Void)?
    typealias downloadCompletionHandler = ((Data?) -> Void)
    
    /**
     Download file into memory. Namely, return a `Data` object.
     */
    func download(maxSize size: Int64,
                  errorHandler: downloadErrorHandler,
                  completionHandler: @escaping downloadCompletionHandler) {
        self.downloadTask = self.fileRef.getData(maxSize: size) { (data, error) in
            if let error = error {
                if let errorHandler = errorHandler {
                    DispatchQueue.main.async {
                        errorHandler(error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(data)
                }
            }
        }
    }
    
    /**
     Download file into a specific system URL path.
     
     ## Note
     The resulting URL will be returned in the completion handler, please use that URL as the source of truth.
     */
    func download(toFile path: URL,
                  errorHandler: downloadErrorHandler,
                  completionHandler: @escaping (URL?) -> Void) {
        self.downloadTask = self.fileRef.write(toFile: path) { (url, error) in
            if let error = error {
                if let errorHandler = errorHandler  {
                    DispatchQueue.main.async {
                        errorHandler(error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(url)
                }
            }
        }
    }
    
    /**
     Pause the download process if is downloading
     */
    func pauseDownload() {
        self.downloadTask?.pause()
    }
    
    /**
     Resume the download process if is downloading
     */
    func resumeDownload() {
        self.downloadTask?.resume()
    }
    
    /**
     Cancel the download process if is downloading
     */
    func cancelDownload() {
        self.downloadTask?.cancel()
    }
}

/// Wrapper for deleting object in the cloud storage.
extension CloudStorage {
    typealias deleteErrorHandler = ((Error) -> Void)?
    
    func delete(errorHandler: deleteErrorHandler,
                completion: (() -> Void)?) {
        self.fileRef.delete { (error) in
            if let error = error {
                if let errorHandler = errorHandler {
                    DispatchQueue.main.async {
                        errorHandler(error)
                    }
                }
            } else {
                if let completion = completion {
                    completion()
                }
            }
        }
    }
}
