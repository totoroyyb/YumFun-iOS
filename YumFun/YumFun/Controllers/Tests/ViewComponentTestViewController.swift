//
//  ViewComponentTestViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/5.
//

import UIKit
import TKSwarmAlert

class ViewComponentTestViewController: UIViewController {
    
    let page = Pagination(collectionPath: "recipe", limit: 5)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func warningTopPopupTapped(_ sender: Any) {
        displayWarningTopPopUp(title: "Hello", description: "Description")
    }
    
    @IBAction func testCompletionAnimationTapped(_ sender: Any) {
        displayCompletionAnimation()
    }
    
    @IBAction func getNextBatchTapped(_ sender: Any) {
        page.getNewBatch { (error, recipes: [Recipe]?, snapshot) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                
                guard let fetchRecipes = recipes else {
                    print("No recipe returned.")
                    return
                }
                
                for recipe in fetchRecipes {
                    print("Named: \(recipe.title) with Id: \(recipe.id)")
                }
            }
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
