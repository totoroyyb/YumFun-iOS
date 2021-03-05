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
        
//        imageView.sd_setImage(
//            with: myStorage.fileRef,
//            maxImageSize: 1 * 2048 * 2048,
//            placeholderImage: nil,
//            options: [.progressiveLoad]) { (image, error, cache, storageRef) in
//            if error != nil {
//                //assertionFailure(error.debugDescription)
//            }
//
//            semaphore?.signal()
//        }
        
        imageView.sd_setImage(with: myStorage.fileRef, placeholderImage: nil) { (_, error, _, _) in
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
    
    static func layoutStep(contentView: UIView, index: Int, recipe: Recipe, previous: UIView) -> UIView {
        let step = recipe.steps[index]
        var previous = previous
        
        let stepNum = UILabel()
        stepNum.text = "Step \(index + 1)/\(recipe.steps.count): \(recipe.steps[index].title ?? "")"
        stepNum.font = UIFont.systemFont(ofSize: 19.0, weight: .semibold)
        contentView.addSubview(stepNum)
        stepNum.translatesAutoresizingMaskIntoConstraints = false
        stepNum.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: index == 0 ? 20 : 30).isActive = true
        stepNum.leadingAnchor.constraint(equalTo: previous.leadingAnchor).isActive = true

        
        // step description
        let stepDescrip = UILabel()
        stepDescrip.text = step.description
        stepDescrip.font = UIFont.systemFont(ofSize: 17.0)
        stepDescrip.numberOfLines = .max
        stepDescrip.lineBreakMode = .byWordWrapping
        contentView.addSubview(stepDescrip)
        stepDescrip.translatesAutoresizingMaskIntoConstraints = false
        stepDescrip.topAnchor.constraint(equalToSystemSpacingBelow: stepNum.bottomAnchor, multiplier: 1).isActive = true
        stepDescrip.leadingAnchor.constraint(equalTo: stepNum.leadingAnchor, constant: 10).isActive = true
        stepDescrip.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        previous = stepDescrip
        
        // ingredient subsection
        // TODO: change debug value to dynamic darta
        if step.ingredients.count != 0 {
            // ingredients label
            let ingredientLabel = UILabel()
            ingredientLabel.text = "Ingredients"
            ingredientLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
            contentView.addSubview(ingredientLabel)
            ingredientLabel.translatesAutoresizingMaskIntoConstraints = false
            ingredientLabel.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
            ingredientLabel.leadingAnchor.constraint(equalTo: previous.leadingAnchor).isActive = true
            previous = ingredientLabel
            
            for (_, ingredient) in step.ingredients.enumerated() {
                let name = UILabel()
                name.text = ingredient.name
                name.font = UIFont.systemFont(ofSize: 17.0)
                contentView.addSubview(name)
                name.translatesAutoresizingMaskIntoConstraints = false
                name.topAnchor.constraint(equalToSystemSpacingBelow: previous.bottomAnchor, multiplier: 1).isActive = true
                name.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
                
                let amount = UILabel()
                amount.text = "\(ingredient.amount) \(ingredient.unit.toString())"
                contentView.addSubview(amount)
                amount.translatesAutoresizingMaskIntoConstraints = false
                amount.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
                amount.trailingAnchor.constraint(equalTo: stepDescrip.trailingAnchor).isActive = true
                
                previous = name
            }
        }
        
        // utensils subsection
        if step.utensils.count != 0 {
            // ingredients label
            let utensilLabel = UILabel()
            utensilLabel.text = "Utensils"
            utensilLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
            contentView.addSubview(utensilLabel)
            utensilLabel.translatesAutoresizingMaskIntoConstraints = false
            utensilLabel.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
            utensilLabel.leadingAnchor.constraint(equalTo: previous.leadingAnchor).isActive = true
            previous = utensilLabel
            
            
            for (_, utensil) in step.utensils.enumerated() {
                let name = UILabel()
                name.text = "\(utensil.name)"
                name.font = UIFont.systemFont(ofSize: 17.0)
                contentView.addSubview(name)
                name.translatesAutoresizingMaskIntoConstraints = false
                name.topAnchor.constraint(equalToSystemSpacingBelow: previous.bottomAnchor, multiplier: 1).isActive = true
                name.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
                
                let amount = UILabel()
                amount.text = "\(utensil.amount)"
                contentView.addSubview(amount)
                amount.translatesAutoresizingMaskIntoConstraints = false
                amount.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
                amount.trailingAnchor.constraint(equalTo: stepDescrip.trailingAnchor).isActive = true
                
                previous = name
            }
        }
        
        // add time section
        let timeLabel = UILabel()
        timeLabel.text = "Time"
        timeLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        contentView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
        
        let time = UILabel()
        time.text = Utility.parseTimeIntervalSec(time: step.time ?? 0)
        time.font = UIFont.systemFont(ofSize: 17.0)
        contentView.addSubview(time)
        time.translatesAutoresizingMaskIntoConstraints = false
        time.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor).isActive = true
        time.trailingAnchor.constraint(equalTo: stepDescrip.trailingAnchor).isActive = true
        
        previous = timeLabel
        
        // add Image
        if let url = step.photoUrl {
            let stepImage = UIImageView()
            stepImage.contentMode = .scaleAspectFit
            setImage(url: url.absoluteString, imageView: stepImage)
            contentView.addSubview(stepImage)
            stepImage.translatesAutoresizingMaskIntoConstraints = false
            stepImage.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 15).isActive = true
            stepImage.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
            stepImage.widthAnchor.constraint(equalToConstant: 128).isActive = true
            stepImage.heightAnchor.constraint(equalToConstant: 128).isActive = true
            
            previous = stepImage
        }
        
        return previous
    }
}

