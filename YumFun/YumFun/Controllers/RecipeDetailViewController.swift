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
    @IBOutlet weak var profileView: CircularImageView!
    @IBOutlet weak var cookButton: UIButton!
    
    let steps = [1, 2, 3, 4, 5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.image = UIImage.init(named: "Launch")
        makeSteps()
        contentView.bringSubviewToFront(cookButton)
    }
    
    // dynamically create steps
    func makeSteps() {
        guard var previous : UIView = stepLabel else {return}
       
        for (i, _) in steps.enumerated() {
            // step title
            let stepNum = UILabel()
            stepNum.text = "Step \(i + 1)/\(steps.count)"
            stepNum.font = UIFont.systemFont(ofSize: 19.0, weight: .semibold)
            contentView.addSubview(stepNum)
            stepNum.translatesAutoresizingMaskIntoConstraints = false
            stepNum.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: i == 0 ? 20 : 30).isActive = true
            stepNum.leadingAnchor.constraint(equalTo: stepLabel.leadingAnchor).isActive = true

            
            // step description
            let stepDescrip = UILabel()
            stepDescrip.text = "Here is the description of the step. Here is the description of the step. Here is the description of the step. Here is the description of the step. "
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
            let ingredients = [1, 2, 3, 4]
            if ingredients.count != 0 {
                // ingredients label
                let ingredientLabel = UILabel()
                ingredientLabel.text = "Ingredients"
                ingredientLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
                contentView.addSubview(ingredientLabel)
                ingredientLabel.translatesAutoresizingMaskIntoConstraints = false
                ingredientLabel.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
                ingredientLabel.leadingAnchor.constraint(equalTo: previous.leadingAnchor).isActive = true
                previous = ingredientLabel
                
                for (_, _) in ingredients.enumerated() {
                    let name = UILabel()
                    name.text = "ingredient #"
                    name.font = UIFont.systemFont(ofSize: 17.0)
                    contentView.addSubview(name)
                    name.translatesAutoresizingMaskIntoConstraints = false
                    name.topAnchor.constraint(equalToSystemSpacingBelow: previous.bottomAnchor, multiplier: 1).isActive = true
                    name.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
                    
                    let amount = UILabel()
                    amount.text = "000 g"
                    contentView.addSubview(amount)
                    amount.translatesAutoresizingMaskIntoConstraints = false
                    amount.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
                    amount.trailingAnchor.constraint(equalTo: stepDescrip.trailingAnchor).isActive = true
                    
                    previous = name
                }
            }
            
            // utensils subsection
            let utensils = [1, 2, 3, 4]
            if utensils.count != 0 {
                // ingredients label
                let utensilLabel = UILabel()
                utensilLabel.text = "Utensils"
                utensilLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
                contentView.addSubview(utensilLabel)
                utensilLabel.translatesAutoresizingMaskIntoConstraints = false
                utensilLabel.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
                utensilLabel.leadingAnchor.constraint(equalTo: previous.leadingAnchor).isActive = true
                previous = utensilLabel
                
                
                for (_, _) in utensils.enumerated() {
                    let name = UILabel()
                    name.text = "utensils #"
                    name.font = UIFont.systemFont(ofSize: 17.0)
                    contentView.addSubview(name)
                    name.translatesAutoresizingMaskIntoConstraints = false
                    name.topAnchor.constraint(equalToSystemSpacingBelow: previous.bottomAnchor, multiplier: 1).isActive = true
                    name.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
                    
                    let amount = UILabel()
                    amount.text = "1"
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
            time.text = "00.00"
            time.font = UIFont.systemFont(ofSize: 17.0)
            contentView.addSubview(time)
            time.translatesAutoresizingMaskIntoConstraints = false
            time.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor).isActive = true
            time.trailingAnchor.constraint(equalTo: stepDescrip.trailingAnchor).isActive = true
            
            previous = timeLabel
            
            // add Image
            let stepImage = UIImageView()
            stepImage.image = UIImage(named: "Launch")
            stepImage.contentMode = .scaleAspectFit
            contentView.addSubview(stepImage)
            stepImage.translatesAutoresizingMaskIntoConstraints = false
            stepImage.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 15).isActive = true
            stepImage.leadingAnchor.constraint(equalTo:previous.leadingAnchor).isActive = true
            stepImage.widthAnchor.constraint(equalToConstant: 128).isActive = true
            stepImage.heightAnchor.constraint(equalToConstant: 128).isActive = true
            
            previous = stepImage
        }
        
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: previous.bottomAnchor, constant: 20).isActive = true
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
