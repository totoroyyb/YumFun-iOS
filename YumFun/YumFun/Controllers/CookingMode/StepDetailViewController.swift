//
//  StepDetailViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/5/21.
//

import UIKit

class StepDetailViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var index: Int = 0
    var recipe = Recipe()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = Utility.layoutStep(contentView: contentView, index: index, recipe: recipe, previous: timerLabel)
    }
    
    @IBAction func cancelPressed() {
        print("pressed!")
        dismiss(animated: true, completion: nil)
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
