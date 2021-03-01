//
//  RecipeDetailViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 2/21/21.
//

import UIKit

class RecipeDetailViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImage: CircularImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeDescrip: UILabel!
    @IBOutlet weak var serveSize: UILabel!
    @IBOutlet weak var dishType: UILabel!
    @IBOutlet weak var cuisine: UILabel!
    @IBOutlet weak var occasion: UILabel!
    
    @IBOutlet weak var cookButton: UIButton!
    
    let detailQueue = DispatchQueue(label: "detailQueue")
    let semaphore = DispatchSemaphore(value: 3)
    
    var recipe : Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let rec = recipe else {return}
        
        authorName.text = rec.author
        recipeTitle.text = rec.title
        recipeDescrip.text = rec.description
        serveSize.text = String(rec.serveSize)
        dishType.text = rec.dishType.rawValue
        cuisine.text = Utility.join(elements: rec.cuisine.map({$0.toString()}), with: " ,")
        occasion.text = Utility.join(elements: rec.occasion, with: " ,")
        
        setAuthorProfileImage(name: rec.author, profileImage: profileImage)
        
        makeSteps(recipe: rec)
        contentView.bringSubviewToFront(cookButton)
    }
    
    // dynamically create steps
    func makeSteps(recipe rec: Recipe) {
        guard var previous : UIView = stepLabel else {return}
       
        for (i, step) in rec.steps.enumerated() {
            // step title
            let stepNum = UILabel()
            stepNum.text = "Step \(i + 1)/\(rec.steps.count): \(step.title ?? "")"
            stepNum.font = UIFont.systemFont(ofSize: 19.0, weight: .semibold)
            contentView.addSubview(stepNum)
            stepNum.translatesAutoresizingMaskIntoConstraints = false
            stepNum.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: i == 0 ? 20 : 30).isActive = true
            stepNum.leadingAnchor.constraint(equalTo: stepLabel.leadingAnchor).isActive = true

            
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
                setStepImage(url: url.absoluteString, stepImageView: stepImage)
                contentView.addSubview(stepImage)
                stepImage.translatesAutoresizingMaskIntoConstraints = false
                stepImage.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 15).isActive = true
                stepImage.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
                stepImage.widthAnchor.constraint(equalToConstant: 128).isActive = true
                stepImage.heightAnchor.constraint(equalToConstant: 128).isActive = true
                
                previous = stepImage
            }
        }
        
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: previous.bottomAnchor, constant: 20).isActive = true
    }
    
    private func setStepImage(url: String, stepImageView: UIImageView) {
        detailQueue.async {
            DispatchQueue.global(qos: .userInitiated).async {
                Utility.setImage(url: url, imageView: stepImageView, placeholder: nil, semaphore: self.semaphore)
                
            }
            self.semaphore.wait()
        }
    }
    
    private func setAuthorProfileImage(name: String, profileImage: UIImageView) {
        detailQueue.async {
            DispatchQueue.global(qos: .userInitiated).async {
                User.get(named: name) { (err, author, _) in
                    guard err == nil else {
                        assertionFailure(err.debugDescription)
                        return
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let a = author, let url = a.photoUrl {
                            Utility.setImage(url: url, imageView: profileImage, placeholder: nil, semaphore: self.semaphore)
                        } else {
                            self.semaphore.signal()
                        }
                    }
                }
            }
            self.semaphore.wait()
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
