//
//  ViewController.swift
//  YumFun
//
//  Created by Failury on 2/16/21.
//

import UIKit
import Firebase


let testFirestore = true


class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorContainer: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
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
                print(error)
                //if the error is "no account record create the account, else..."
                self.showCreateAccount(email: email, password: password)
            }
        })
    }
    
    
    func showCreateAccount(email: String, password: String){
        let alert = UIAlertController(title: "No account found", message: "Would you like to create an account?", preferredStyle: .alert)
        //if user press continue, use firebase to create an account with email and password
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: {_ in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {result, error in
                guard error == nil else {
                    //find the type of error and give back the error message
                    let errorMesasge = error?.localizedDescription
                    self.errorContainer.text = errorMesasge
                    return
                }
                //change screens after creation
                self.navToHomeView()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            
        }))
        present(alert, animated: true)
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
            
            guard let homeViewController = storyboard.instantiateViewController(identifier: "homeview") as? HomeViewController else {
                assertionFailure("Cannot instantiate HomeViewController.")
                return
            }

            self.navigationController?.pushViewController(homeViewController, animated: true)
        }
    }
}

