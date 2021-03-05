//
//  ViewComponentTestViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/5.
//

import UIKit

class ViewComponentTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func warningTopPopupTapped(_ sender: Any) {
        displayWarningTopPopUp(title: "Hello", description: "Description")
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
