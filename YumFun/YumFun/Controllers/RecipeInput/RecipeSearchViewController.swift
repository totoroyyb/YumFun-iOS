//
//  RecipeViewController.swift
//  YumFun
//
//  Created by Travis Garcia on 2/16/21.
//

import UIKit
import WebKit
import Alamofire
import Kanna
import JJFloatingActionButton

struct RecipeParser1: Codable {
    let graph: [RecipeParser2]
    enum CodingKeys: String, CodingKey {
        case graph = "@graph"
    }
}

struct RecipeParser2: Codable {
    let context: String
    let type, datePublished, welcomeDescription: String
    let image: String
    let name: String
    let author: [Author]
    let nutrition: Nutrition
    let recipeIngredient: [String]
    let recipeYield: String
    let recipeInstructions: [RecipeInstruction]
    let tool: String

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type = "@type"
        case datePublished
        case welcomeDescription = "description"
        case image, name, author, nutrition, recipeIngredient, recipeYield, recipeInstructions,  tool
    }
}

// MARK: - Author
struct Author: Codable {
    let type, name: String

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case name
    }
}


// MARK: - Nutrition
struct Nutrition: Codable {
    let type, calories, carbohydrateContent, fatContent: String
    let fiberContent, proteinContent, sugarContent: String

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case calories, carbohydrateContent, fatContent, fiberContent, proteinContent, sugarContent
    }
}

// MARK: - RecipeInstruction
struct RecipeInstruction: Codable {
    let type, text: String

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case text
    }
}

class RecipeSearchViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webView: WKWebView!
    var recipe: Recipe = Recipe()
    var cookButton: JJFloatingActionButton = JJFloatingActionButton()
    var recipeSite = false
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.addSubview(cookButton)
        view = webView
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        recipe.duration = Duration(prepTime: 0)
        let myURL = URL(string:"https://www.google.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        setupWebView()
        setupFloatingButton()
    }
    
    func setupWebView() {
        navigationItem.rightBarButtonItems = [  UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(goForward)), UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(goBack))]
        
        if webView.isLoading {
            let loader = UIActivityIndicatorView(style: .medium)
            loader.startAnimating()
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: loader)
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        }
    }
    
    @objc func setupFloatingButton() {
        webView.addSubview(cookButton)
        cookButton.translatesAutoresizingMaskIntoConstraints = false
        cookButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        cookButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        cookButton.handleSingleActionDirectly = true
        cookButton.buttonImage = UIImage(named: "add")
        cookButton.buttonDiameter = 65
        cookButton.buttonImageColor = UIColor.white
        cookButton.buttonColor = UIColor(named: "primary") ?? UIColor(red: 0.09, green: 0.6, blue: 0.51, alpha: 0.8)
        cookButton.buttonImageSize = CGSize(width: 30, height: 30)
        cookButton.layer.shadowColor = UIColor(named: "shadow_color")?.cgColor ?? UIColor.clear.cgColor
        cookButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        cookButton.layer.shadowOpacity = Float(0.4)
        cookButton.layer.shadowRadius = CGFloat(2)
        
        cookButton.addItem(title: nil, image: nil) {[weak self] _ in
            self?.previewPressed()
        }
        cookButton.isHidden = true
    }
    
    func previewPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let recipeDetailViewController = storyboard.instantiateViewController(identifier: "RecipeDetailViewController") as RecipeDetailViewController? else {
            assertionFailure("couln't get vc")
            return
        }
    
        recipeDetailViewController.recipe = recipe
        recipeDetailViewController.isEditView = true
        navigationController?.pushViewController(recipeDetailViewController, animated: true)
    }
    
    @objc func parseRecipe() {
        // Return to recipe view and if parse successful, update table view
        let webURL = webView.url?.absoluteString
        if let unwrappedURL = webURL {
            AF.request(unwrappedURL).responseString { response in
                switch response.result {
                case .success:
                    if let html = response.value {
                        self.parseHTML(html)
                    }
                case let .failure(error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    func parseHTML(_ html: String) {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            // TODO test on more websites
            // Searching for nodes by CSS selector
            for recipeJSON in doc.xpath("//script[@type='application/ld+json']") {
                if let recipeData = recipeJSON.content?.data(using: .utf8) {
                    recipeSite = true
                    if let parsedRecipe = try? JSONDecoder().decode(RecipeParser1.self, from: recipeData) {
                        //print("---Parser 1---: \n\n\n\(parsedRecipe)")
                        for r in parsedRecipe.graph {
                            parseRecipeParser(r)
                        }
                    }
                    if let parsedRecipes = try? JSONDecoder().decode(RecipeParser2.self, from: recipeData) {
                        //print("---Parser 2---: \n\n\n\(parsedRecipes)")
                        parseRecipeParser(parsedRecipes)
                    }
                    if let json = try? JSONSerialization.jsonObject(with: recipeData, options: []) as? [String: Any] {
                        parseRecipeJSON(json)
                    }
                }
            }
        }
    }
    
    func parseRecipeJSON(_ json: [String: Any]) {
        for data in json {
            if let nsArray = data.value as? NSArray {
                for nsData in nsArray {
                    if let nsDict = nsData as? NSDictionary {
                        if let name = nsDict["name"] as? NSString {
                            if let type = nsDict["@type"] as? NSString {
                                switch type {
                                case "Person":
                                    recipe.author = name.description
                                case "Recipe":
                                    recipe.title = name.description
                                default:
                                    var _ = type
                                }
                            }
                        }
                        if let ingredients = nsDict["recipeIngredient"] as? NSArray {
                            var ingredientList = [Ingredient]()
                            for ingredient in ingredients {
                                if let ingredientString = ingredient as? String {
                                    let parsedIngredient = parseIngredient(ingredientString)
                                    ingredientList.append(parsedIngredient)
                                }
                            }
                            recipe.ingredients = ingredientList
                        }
                        if let instructions = nsDict["recipeInstructions"] as? NSArray {
                            var steps = [Step]()
                            for step in instructions {
                                if let stepDetails = step as? NSDictionary {
                                    if let text = stepDetails["text"] as? NSString {
                                        var newStep = Step(description: text.description)
                                        newStep.description = text.description
                                        steps.append(newStep)
                                    }
                                }
                            }
                            recipe.steps = steps
                        }
                        if let amount = nsDict["recipeYield"] as? NSString {
                            recipe.portionLabel = amount.description
                        }
                        var duration = Duration(prepTime: 0)
                        if let totalTime = nsDict["totalTime"] as? NSString {
                            duration.totalTimeLabel = totalTime.description
                        }
                        if let cookTime = nsDict["cookTime"] as? NSString {
                            duration.cookLabel = cookTime.description
                        }
                        recipe.duration = duration
                    }
                }
            }
        }
    }
    
    func parseRecipeParser(_ parsedRecipe: RecipeParser2) {
        recipe.title = parsedRecipe.name
        for author in parsedRecipe.author {
            if author.type == "Person" {
                recipe.author = author.name
            }
        }
        var ingredients = [Ingredient]()
        for ingredient in parsedRecipe.recipeIngredient {
            ingredients.append(parseIngredient(ingredient))
        }
        recipe.ingredients = ingredients
        var steps = [Step]()
        for step in parsedRecipe.recipeInstructions {
            steps.append(Step(description: step.text))
        }
        recipe.portionLabel = parsedRecipe.recipeYield
        recipe.steps = steps
    }
    
    // Go through any ingredients already in recipe and make sure no duplicates added
    func parseIngredient(_ ingredient: String) -> Ingredient {
        var parsedIngredient = Ingredient(name: ingredient, amount: 0, unit: MeasureUnit.tsp)
        for unit in MeasureUnit.allCases {
            switch unit {
            case MeasureUnit.tbsp:
                if ingredient.contains("tablespoon") || ingredient.contains("tablespoons") || ingredient.contains("tbsp") {
                    parsedIngredient.unit = unit
                }
            case MeasureUnit.cup:
                if ingredient.contains("cup") || ingredient.contains("cups") {
                    parsedIngredient.unit = unit
                }
            default:
                break
            }
        }
        return parsedIngredient
    }
    
    @objc func goBack() {
        if webView.canGoBack {
            clearUI()
            webView.goBack()
        }
    }
    
    @objc func goForward() {
        if webView.canGoForward {
            clearUI()
            webView.goForward()
        }
    }
    
    @objc func refresh() {
        clearUI()
        webView.reload()
    }
    
    func clearUI() {
        navigationItem.title = ""
        cookButton.isHidden = true
    }
    
    @objc func returnHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let chooseRecipeInputViewController = storyboard.instantiateViewController(identifier: "chooseRecipeInputVC") as ChooseRecipeInputViewController? else {
            assertionFailure("couln't get vc")
            return
        }
        self.navigationController?.setViewControllers([chooseRecipeInputViewController], animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.leftBarButtonItems = [ UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh)), UIBarButtonItem(title: "home", style: .plain, target: self, action: #selector(returnHome)) ]
        navigationItem.title = ""
        // Usually fails first time, but can still determine if recipe site
        parseRecipe()
        cookButton.isHidden = true
        if recipeSite {
            navigationItem.title = "Parsing recipe..."
        }
        // Try parsing one or two more times after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.parseRecipe()
            self.updateUI()
            if self.recipeSite && self.recipe.ingredients.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.parseRecipe()
                    self.updateUI()
                }
            }
        }
    }
    
    func updateUI() {
        if recipeSite && recipe.ingredients.count > 0 {
            recipe.url = webView.url
            navigationItem.title = "Recipe Parsed!"
            recipeSite = false
            cookButton.isHidden = false
        } else if recipeSite {
            navigationItem.title = "Unable to parse recipe"
            recipeSite = false
        }
    }
    
}
