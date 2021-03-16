//
//  UpdatePasswordViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/16.
//

import UIKit
import JGProgressHUD
import LGButton

class UpdatePasswordViewController: UIViewController {
    @IBOutlet weak var oldEmailTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmButton: LGButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        guard let oldEmail = oldEmailTextField.text,
              let oldPassword = oldPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              (!oldEmail.isEmpty && !oldPassword.isEmpty && !newPassword.isEmpty) else {
            displayWarningTopPopUp(title: "Oops", description: "It seems you left some fields empty.")
            return
        }
        
        resignAllResponders()
        
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.backgroundColor = UIColor.black.alpha(0.4)
        hud.show(in: self.view.window?.rootViewController?.view ?? self.view)
        confirmButton.isLoading = true
        
        Core.changePassword(from: self.view,
                            withOldEmail: oldEmail,
                            withOldPassword: oldPassword,
                            withNewPassword: newPassword) { error in
            DispatchQueue.main.async {
                hud.dismiss()
                self.confirmButton.isLoading = false
            }
            
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    @IBAction func didTappedScreen(_ sender: Any) {
        resignAllResponders()
    }
    
    private func resignAllResponders() {
        if oldEmailTextField.isFirstResponder {
            oldEmailTextField.resignFirstResponder()
        }
        
        if oldPasswordTextField.isFirstResponder {
            oldPasswordTextField.resignFirstResponder()
        }
        
        if newPasswordTextField.isFirstResponder {
            newPasswordTextField.resignFirstResponder()
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
