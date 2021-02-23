//
//  ViewController.swift
//  YumFun
//
//  Created by Failury on 2/16/21.
//

import UIKit
import Firebase


let testFirestore = false


class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorContainer: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
        emailField.becomeFirstResponder()
        //if there is a user already logged in, skip login
//        if FirebaseAuth.Auth.auth().currentUser != nil {
//            self.navToHomeView()
//        }
    }

    @IBAction func didTapScreen(_ sender: Any){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    @IBAction func didTapButton(_ sender: UIButton){
        print ("pressed Button")
        //get the email and username
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
                //add error message later
                self.errorContainer.text = "Missing field data"
                return
        }
        //If email and password found, Get auth instance and attempt to sign in
        //if fails, present alert to create account, if user continues, create account
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {result, error in

            //error means it could not sign in due to no accounts found
            if error == nil {
                self.navToHomeView()
            } else {
                let errorMesasge = error?.localizedDescription
                self.errorContainer.text = errorMesasge
                //if the error is "no account record create the account, else..."
            }
        })
    }
    
    
    
    func navToHomeView() {
        if testFirestore {
            let storyboard = UIStoryboard(name: "FirestoreTest", bundle: nil)
            guard let firestoreTestViewController = storyboard.instantiateViewController(identifier: "FirestoreTestViewController") as? FirestoreTestViewController else {
                assertionFailure("Cannot instantiate FirestoreTestViewController")
                return
            }
            self.navigationController?.pushViewController(firestoreTestViewController, animated: true)
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let homeViewController = storyboard.instantiateViewController(identifier: "tabBarView") as? UITabBarController else {
                assertionFailure("Cannot instantiate HomeViewController.")
                return
            }

            self.navigationController?.pushViewController(homeViewController, animated: true)
        }
    }
    @IBAction func signUpButton(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let signUpViewController = storyboard.instantiateViewController(identifier: "signupView") as? SignUpViewController else {
            assertionFailure("Cannot instantiate HomeViewController.")
            return
        }

        self.navigationController?.pushViewController(signUpViewController, animated: true)
    }
}

