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
    
    /**
     Layout step programmingly on a view
     */
    static func layoutStep(contentView: UIView, index: Int, recipe: Recipe, previous: UIView) -> UIView {
        
        let step = recipe.steps[index]
        var previous = previous
        
        let card = UIView()
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
        card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        
        let stepNum = UILabel()
        stepNum.text = "Step \(index + 1)/\(recipe.steps.count): \(recipe.steps[index].title ?? "")"
        stepNum.font = UIFont.systemFont(ofSize: 19.0, weight: .semibold)
        stepNum.textColor = UIColor(named: "text_high_emphasis")
        card.addSubview(stepNum)
        stepNum.translatesAutoresizingMaskIntoConstraints = false

        stepNum.snp.makeConstraints { (make) in
            make.top.equalTo(card).offset(20)
            make.leading.equalTo(card).offset(20)
            make.trailing.equalTo(card).offset(-20)
        }
        
        previous = stepNum

        // add Image
        if let url = step.photoUrl {
            let stepImage = UIImageView()
            stepImage.contentMode = .scaleAspectFit
            setImage(url: url, imageView: stepImage)
            card.addSubview(stepImage)
            stepImage.translatesAutoresizingMaskIntoConstraints = false
            
            stepImage.snp.makeConstraints { (make) in
                make.top.equalTo(previous.snp.bottom).offset(20)
                make.leading.equalTo(card).offset(20)
                make.trailing.equalTo(card).offset(-20)
                make.height.lessThanOrEqualTo(300)
            }
            
            previous = stepImage
        }
        
        // step description
        let stepDescrip = UILabel()
        stepDescrip.text = step.description
        stepDescrip.font = UIFont.systemFont(ofSize: 17.0)
        stepDescrip.textColor = UIColor(named: "text_medium_emphasis")
        stepDescrip.numberOfLines = .max
        stepDescrip.lineBreakMode = .byWordWrapping
        card.addSubview(stepDescrip)
        stepDescrip.translatesAutoresizingMaskIntoConstraints = false
        stepDescrip.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
        stepDescrip.leadingAnchor.constraint(equalTo: previous.leadingAnchor, constant: 10).isActive = true
        stepDescrip.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20).isActive = true
        
        previous = stepDescrip
        
        // ingredient subsection
        // TODO: change debug value to dynamic darta
        if step.ingredients.count != 0 {
            // ingredients icon
            let icon = UIImageView(image: UIImage(named: "ingrediants"))
            icon.contentMode = .scaleAspectFit
            
            card.addSubview(icon)
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
            icon.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 22).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 22).isActive = true

            // ingredients label
            let ingredientLabel = UILabel()
            ingredientLabel.text = "Ingredients"
            ingredientLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
            ingredientLabel.textColor = UIColor(named: "text_high_emphasis")
            card.addSubview(ingredientLabel)
            ingredientLabel.translatesAutoresizingMaskIntoConstraints = false
            ingredientLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10).isActive = true
            ingredientLabel.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
//            ingredientLabel.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
//            ingredientLabel.leadingAnchor.constraint(equalTo: previous.leadingAnchor).isActive = true
//            previous = ingredientLabel
            previous = icon
            
            for (_, ingredient) in step.ingredients.enumerated() {
                let name = UILabel()
                name.text = ingredient.name
                name.font = UIFont.systemFont(ofSize: 17.0)
                name.textColor = UIColor(named: "text_medium_emphasis")
                card.addSubview(name)
                name.translatesAutoresizingMaskIntoConstraints = false
                name.topAnchor.constraint(equalToSystemSpacingBelow: previous.bottomAnchor, multiplier: 1).isActive = true
                name.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
                
                let amount = UILabel()
                amount.text = "\(ingredient.amount) \(ingredient.unit.toString())"
                amount.textColor = UIColor(named: "text_medium_emphasis")
                card.addSubview(amount)
                amount.translatesAutoresizingMaskIntoConstraints = false
                amount.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
                amount.trailingAnchor.constraint(equalTo: stepDescrip.trailingAnchor).isActive = true
                
                previous = name
            }
        }
        
        // utensils subsection
        if step.utensils.count != 0 {
            // utensils icon
            let icon = UIImageView(image: UIImage(named: "utensils"))
            icon.contentMode = .scaleAspectFit
            card.addSubview(icon)
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
            icon.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 22).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 22).isActive = true
            
            // ingredients label
            let utensilLabel = UILabel()
            utensilLabel.text = "Utensils"
            utensilLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
            utensilLabel.textColor = UIColor(named: "text_high_emphasis")
            card.addSubview(utensilLabel)
            utensilLabel.translatesAutoresizingMaskIntoConstraints = false
            utensilLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10).isActive = true
            utensilLabel.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
            previous = icon
            
            
            for (_, utensil) in step.utensils.enumerated() {
                let name = UILabel()
                name.text = "\(utensil.name)"
                name.font = UIFont.systemFont(ofSize: 17.0)
                name.textColor = UIColor(named: "text_medium_emphasis")
                card.addSubview(name)
                name.translatesAutoresizingMaskIntoConstraints = false
                name.topAnchor.constraint(equalToSystemSpacingBelow: previous.bottomAnchor, multiplier: 1).isActive = true
                name.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
                
                let amount = UILabel()
                amount.text = "\(utensil.amount)"
                amount.textColor = UIColor(named: "text_medium_emphasis")
                card.addSubview(amount)
                amount.translatesAutoresizingMaskIntoConstraints = false
                amount.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
                amount.trailingAnchor.constraint(equalTo: stepDescrip.trailingAnchor).isActive = true
                
                previous = name
            }
        }
        
        // add time section
        // time icon
        let icon = UIImageView(image: UIImage(systemName: "clock"))
        icon.tintColor = UIColor(named: "text_high_emphasis")
        icon.contentMode = .scaleAspectFit
        card.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
        icon.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 22).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        let timeLabel = UILabel()
        timeLabel.text = "Time"
        timeLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        timeLabel.textColor = UIColor(named: "text_high_emphasis")
        card.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        
        let time = UILabel()
        time.text = Utility.parseTimeIntervalSec(time: step.time ?? 0)
        time.font = UIFont.systemFont(ofSize: 17.0)
        time.textColor = UIColor(named: "text_medium_emphasis")
        card.addSubview(time)
        time.translatesAutoresizingMaskIntoConstraints = false
        time.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor).isActive = true
        time.trailingAnchor.constraint(equalTo: stepDescrip.trailingAnchor).isActive = true
        time.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20).isActive = true
        
//        previous = icon
        
        card.backgroundColor = UIColor(named: "cell_bg_color")
        card.layer.cornerRadius = 22
        card.layer.borderWidth = 0.0
        card.layer.masksToBounds = false
        
        card.layer.shadowColor = UIColor(named: "shadow_color")?.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        card.layer.shadowRadius = 8.0
        card.layer.shadowOpacity = 0.6
        card.layer.shadowPath = UIBezierPath(roundedRect: card.bounds,
                                             cornerRadius: card.layer.cornerRadius).cgPath
        
        return card
    }
}

