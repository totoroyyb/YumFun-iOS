//
//  Utility.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/2/21.
//

import Foundation
import UIKit
import FirebaseStorage

class Utility {
    /**
     Parse an instance of type `TimeInterval` into the form "00:00:00".
     */
    static func parseTimeIntervalSec(time: TimeInterval) -> String {
        var time = Int(ceil(time))
        let hour = time / 3600
        time %= 3600
        let min = time / 60
        let sec = time % 60
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    
    /**
     Set the content of an `UIImageView` by fetching url content from Firebase Cloud Storage.
     */
    static func setImage(url: String, imageView: UIImageView, placeholder: UIImage? = nil, semaphore: DispatchSemaphore? = nil) {
        let myStorage = CloudStorage(url)
        
        imageView.sd_setImage(
            with: myStorage.fileRef,
            maxImageSize: 1 * 2048 * 2048,
            placeholderImage: nil,
            options: [.progressiveLoad]) { (image, error, cache, storageRef) in
            if error != nil {
                //assertionFailure(error.debugDescription)
            }
            
            semaphore?.signal()
        }
    }
    
    /**
     Join the elements in a list into a string with a binder
     */
    static func join(elements: [String], with binder: String) -> String {
        if elements.count == 0 {
            return ""
        }
        
        return elements[0] + elements.dropFirst().reduce("") {$0 + "\(binder)\($1)"}
    }
}

