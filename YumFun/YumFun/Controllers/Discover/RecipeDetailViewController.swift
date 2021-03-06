//
//  RecipeDetailViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 2/21/21.
//

import UIKit
import JJFloatingActionButton
import JGProgressHUD

class RecipeDetailViewController: UIViewController, UIScrollViewDelegate {
    
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
    
    var recipeIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewAnimation()
        setupViewColor()
        setupView()
    }
    func UserEntry(){
        profileImage.isUserInteractionEnabled = true
        authorName.isUserInteractionEnabled = true
        let ImageGotoUser = UITapGestureRecognizer(target: self, action: #selector(self.MoveToUserPage(_:)))
        let AuthorGotoUser = UITapGestureRecognizer(target: self, action: #selector(self.MoveToUserPage(_:)))
        profileImage.addGestureRecognizer(ImageGotoUser)
        authorName.addGestureRecognizer(AuthorGotoUser)
    }
    @objc func MoveToUserPage(_ sender: UITapGestureRecognizer) {
        guard let rec = recipe else { return }
        User.get(named: rec.author) { (error, user, _) in
            if error == nil{
                guard let UserView = self.storyboard?.instantiateViewController(withIdentifier: "ProfileView") as? ProfileViewController else {
                    assertionFailure("Cannot find ViewController")
                    return
                }
                UserView.OU = user
                UserView.isSelf = false
                self.navigationController?.pushViewController(UserView, animated: true)
            }else{
                print(error.debugDescription)
            }
            
        }
        }
    private func setupViewAnimation() {
        // Re-enable back pan gesture
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.hero.isEnabled = true
        self.profileImage.hero.id = HeroIdType.profileImage.getIdStr(at: recipeIndex)
        self.recipeTitle.hero.id = HeroIdType.recipeTitle.getIdStr(at: recipeIndex)
    }
    
    private func setupViewColor() {
        self.view.backgroundColor = UIColor(named: "collection_bg_color")
    }
    
    private func setupView() {
        guard let rec = recipe else { return }
        
        setAuthorName(authorID: rec.author)
        recipeTitle.text = rec.title
        recipeDescrip.text = rec.description
        serveSize.text = String(rec.portionSize)
        dishType.text = rec.dishType.rawValue
        cuisine.text = Utility.join(elements: rec.cuisine.map({$0.toString()}), with: ", ")
        occasion.text = Utility.join(elements: rec.occasion, with: ", ")
        
        setAuthorProfileImage(userID: rec.author, profileImage: profileImage)
        
        makeSteps(recipe: rec)
        setupCookFloatingButton()
        UserEntry()
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
        
        cookButton.layer.addShadow(color: UIColor(named: "shadow_color") ?? .darkGray)
        cookButton.overlayView.backgroundColor = UIColor.black.alpha(0.66)
        
//        cookButton.addItem(title: nil, image: nil) {[weak self] _ in
//            self?.cookPressed()
//        }

        cookButton.addItem(title: "Cook Now!", image: UIImage(named: "chef")?.withRenderingMode(.alwaysTemplate)) { item in
            self.cookPressed()
        }
        if let tabBarController = self.navigationController?.tabBarController, tabBarController.selectedIndex == 2 {
            cookButton.addItem(title: "New Recipe", image: UIImage(named: "add")?.withRenderingMode(.alwaysTemplate)) { item in
                self.newRecipePressed()
            }
        }
        
        if self.navigationController?.tabBarController?.selectedIndex == 2 ||
            Core.currentUser?.id != recipe?.author {
            cookButton.addItem(title: "Save", image: UIImage(named: "bookmark")?.withRenderingMode(.alwaysTemplate)) { item in
                self.savePressed()
            }
        }
        
        if Core.currentUser?.id == recipe?.author {
            cookButton.addItem(title: "Edit", image: UIImage(named: "edit")?.withRenderingMode(.alwaysTemplate)) { item in
                if let tabBarController = self.navigationController?.tabBarController {
                    if let arrController = tabBarController.viewControllers {
                        for vc in arrController {
                            if vc.restorationIdentifier == "Edit" {
                                if let navVC = vc as? UINavigationController {
                                    if tabBarController.selectedIndex == 2 {
                                        self.setEditView()
                                    } else if let chooseRecipeVC = navVC.viewControllers.first as? ChooseRecipeInputViewController, let rec = self.recipe {
                                        chooseRecipeVC.recipe = rec
                                        chooseRecipeVC.startEditMode = true
                                        tabBarController.selectedIndex = 2
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        for item in cookButton.items {
            item.imageSize = CGSize(width: 20, height: 20)
            item.buttonColor = UIColor(named: "floating_button_bg_color") ?? .white
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
        guard let rec = recipe, let recId = rec.id, let currUser = Core.currentUser else {
            displayWarningTopPopUp(title: "Error", description: "Failed to initialize recipe or current user.")
            return
        }
        
        if currUser.recipes.contains(recId) {
            navToCollabCook(rec: rec)
        } else {
            let hud = JGProgressHUD()
            hud.textLabel.text = "Loading"
            hud.backgroundColor = UIColor.black.alpha(0.55)
            hud.show(in: self.view)
            
            currUser.createRecipe(with: rec) { (error, docRef) in
                hud.dismiss()
                if let error = error {
                    displayWarningTopPopUp(title: "Error", description: "Failed to save recipe before entering cooking.")
                    print(error.localizedDescription)
                    return
                } else {
                    var newRecipe = rec
                    newRecipe.id = docRef?.documentID
                    self.navToCollabCook(rec: rec)
                }
            }
        }
    }
    
    private func navToCollabCook(rec: Recipe) {
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
    
    func savePressed() {
        if let rec = recipe {
            guard let currUser = Core.currentUser else { return }
            currUser.createRecipe(with: rec) { (error, docRef) in
                if error == nil {
                    print("created recipe with id: \(docRef?.documentID)")
                }
            }
            let alertController = UIAlertController(title: "Recipe Saved!", message:
                                                        rec.title, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(alertController, animated: true)
        }
    }
    
    func newRecipePressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let chooseRecipeViewController = storyboard.instantiateViewController(identifier: "chooseRecipeInputVC") as ChooseRecipeInputViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        navigationController?.setViewControllers([chooseRecipeViewController], animated: true)
    }
    
    func setEditView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let chooseRecipeViewController = storyboard.instantiateViewController(identifier: "chooseRecipeInputVC") as ChooseRecipeInputViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        if let rec = self.recipe {
            chooseRecipeViewController.recipe = rec
            chooseRecipeViewController.startEditMode = true
        }
        navigationController?.setViewControllers([chooseRecipeViewController], animated: true)
    }
}
