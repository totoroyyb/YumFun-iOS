//
//  SignUpViewController.swift
//  YumFun
//
//  Created by Admin on 2/21/21.
//

import UIKit
import Firebase
class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorContainer: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createAccountButton(_ sender: UIButton){
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
                //add error message later
                self.errorContainer.text = "Missing field data"
                return
        }
        self.showCreateAccount(email: email, password: password)
    }
    
    func showCreateAccount(email: String, password: String){
        let alert = UIAlertController(title: "Create account", message: ("Confirm account creation for: " + email), preferredStyle: .alert)
        //if user press continue, use firebase to create an account with email and password
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: {_ in
            User.createUser(withEmail: email, withPassword: password) { result, error in
                guard error == nil else {
                    //find the type of error and give back the error message
                    let errorMesasge = error?.localizedDescription
                    self.errorContainer.text = errorMesasge
                    return
                }
                let confirmAlert = UIAlertController(title: "Account Created", message: "", preferredStyle: .alert)
                self.present(confirmAlert, animated:true)
                DispatchQueue.main.asyncAfter(deadline: .now()+1){
                  // your code with delay
                  confirmAlert.dismiss(animated: true, completion: nil)
                    self.goToLogin()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            
        }))
        present(alert, animated: true)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton){
        self.goToLogin()
    }
    func goToLogin(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let loginViewController = storyboard.instantiateViewController(identifier: "loginView") as? ViewController else {
            assertionFailure("Cannot instantiate HomeViewController.")
            return
            }
        
        //Change animation
        self.navigationController?.pushViewController(loginViewController, animated: true)
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
