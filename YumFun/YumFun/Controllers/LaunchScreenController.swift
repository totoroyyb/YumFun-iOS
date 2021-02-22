//
//  LaunchScreenController.swift
//  YumFun
//
//  Created by Admin on 2/21/21.
//

import UIKit

class LaunchScreenController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var yumfunLogo: UIImageView!
    @IBOutlet weak var gifView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        gifView.loadGif(name: "flavors-of-youth")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.fadeInLogo()
        })
        
    }
    

    private func fadeInLogo(){
        UIView.animate(withDuration: 1, delay: 1.5, options: .curveEaseOut, animations: {
            self.yumfunLogo.alpha = 1
        }){(success) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let loginViewController = storyboard.instantiateViewController(identifier: "loginView") as? ViewController else {
                assertionFailure("Cannot instantiate HomeViewController.")
                return
                }
            
            //Change animation
            self.navigationController?.pushViewController(loginViewController, animated: true)
        }
    }

}
