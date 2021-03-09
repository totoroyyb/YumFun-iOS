//
//  RecipeDetailViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 2/21/21.
//

import UIKit
import JJFloatingActionButton

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
    

    var cookButton: JJFloatingActionButton = JJFloatingActionButton()
    
    let detailQueue = DispatchQueue(label: "detailQueue")
    let semaphore: DispatchSemaphore? = DispatchSemaphore(value: 3)
//    let semaphore: DispatchSemaphore? = nil
    
    var recipe : Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(named: "collection_bg_color")
        
        guard let rec = recipe else {return}
        
        setAuthorName(authorID: rec.author)
        recipeTitle.text = rec.title
        recipeDescrip.text = rec.description
        serveSize.text = String(rec.portionSize)
        dishType.text = rec.dishType.rawValue
        cuisine.text = Utility.join(elements: rec.cuisine.map({$0.toString()}), with: " ,")
        occasion.text = Utility.join(elements: rec.occasion, with: " ,")
        
        setAuthorProfileImage(userID: rec.author, profileImage: profileImage)
        
        makeSteps(recipe: rec)
        setupCookFloatingButton()
        
    }
    
    private func setupCookFloatingButton() {
        contentView.addSubview(cookButton)
        cookButton.translatesAutoresizingMaskIntoConstraints = false
        cookButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        cookButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        cookButton.handleSingleActionDirectly = true
        cookButton.buttonImage = UIImage(named: "cooking")
        cookButton.buttonDiameter = 65
        cookButton.buttonImageColor = UIColor(named: "text_high_emphasis") ?? UIColor.white
        cookButton.buttonColor = UIColor(named: "primary") ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8)
        cookButton.buttonImageSize = CGSize(width: 30, height: 30)
        cookButton.layer.shadowColor = UIColor(named: "shadow_color")?.cgColor ?? UIColor.clear.cgColor
        cookButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        cookButton.layer.shadowOpacity = Float(0.4)
        cookButton.layer.shadowRadius = CGFloat(2)
        
        cookButton.addItem(title: nil, image: nil) {[weak self] _ in
            self?.cookPressed()
        }
    }
    
    // set the fetched author name to label
    func setAuthorName(authorID: String) {
        User.get(named: authorID) { (err, user, _) in
            guard err == nil else {
                print(err.debugDescription)
                return
            }
            self.authorName.text = user?.displayName
        }
    }
    
    // dynamically create steps
    func makeSteps(recipe rec: Recipe) {
        guard var previous : UIView = stepLabel else {return}
       
        for (i, _) in rec.steps.enumerated() {
            previous = Utility.layoutStep(contentView: contentView, index: i, recipe: rec, previous: previous)
        }
        
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: previous.bottomAnchor, constant: 20).isActive = true
    }
    
    private func setAuthorProfileImage(userID: String, profileImage: UIImageView) {
        detailQueue.async {
            DispatchQueue.global(qos: .userInitiated).async {
                let myStorage = CloudStorage(AssetType.profileImage)
                myStorage.child("\(userID).jpeg")
                
                profileImage.sd_setImage(
                    with: myStorage.fileRef,
                    maxImageSize: 1 * 2048 * 2048,
                    placeholderImage: nil,
                    options: [.progressiveLoad]) { (image, error, cache, storageRef) in
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    
                    self.semaphore?.signal()
                }
            }
        }
        self.semaphore?.wait()
    }
    
    
    private func cookPressed() {
        
        if let rec = recipe {
            let storyboard = UIStoryboard(name: "Cooking", bundle: nil)
            
            guard let cookingNavController = storyboard.instantiateViewController(withIdentifier: "CookingNavigationController") as? UINavigationController else {
                assertionFailure("couldn't find CookingNavigationController")
                return
            }
            
            guard let prepareViewController = storyboard.instantiateViewController(withIdentifier: "PrepareViewController") as? PrepareViewController else {
                assertionFailure("couldn't find PrepareViewController")
                return
            }
            
            prepareViewController.recipe = rec
            cookingNavController.setViewControllers([prepareViewController], animated: false)
            cookingNavController.modalPresentationStyle = .overFullScreen
            
            self.present(cookingNavController, animated: true)
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
