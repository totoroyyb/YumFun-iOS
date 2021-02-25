//
//  EditDetailController.swift
//  YumFun
//
//  Created by Failury on 2/24/21.
//

import UIKit

class EditDetailController: UIViewController {
    @IBOutlet weak var TextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func emptyPressed(_ sender: Any) {
        TextField.text = ""
    }
    
}
