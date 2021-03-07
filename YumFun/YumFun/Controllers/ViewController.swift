//
//  ViewController.swift
//  YumFun
//
//  Created by Failury on 2/16/21.
//

import UIKit
import Firebase
import AnimatedField
import Pastel
import Hue
import LGButton

let testFirestore = false
let testCloudStorage = false
let testCollab = false


class ViewController: UIViewController {

    @IBOutlet weak var bgEffectView: UIView!
    @IBOutlet weak var emailField: AnimatedField!
    @IBOutlet weak var passwordField: AnimatedField!
    @IBOutlet weak var bottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButton: LGButton!
    
    var inCurrentView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBgGradientEffect()
//        addCometEffect(for: self.bgEffectView)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupEmailField()
        setupPasswordField()
        
        emailField.dataSource = self
        passwordField.dataSource = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        _ = emailField.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            if bottomHeightConstraint.constant == 15 {
                bottomHeightConstraint.constant += size.height
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }

    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if bottomHeightConstraint.constant != 15 {
            bottomHeightConstraint.constant = 15
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    @IBAction func didTapScreen() {
        _ = emailField.resignFirstResponder()
        _ = passwordField.resignFirstResponder()
    }
    
    @IBAction func didTapButton() {
        print ("Pressed Log in button")
        
        //get the email and username
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            //add error message later
//            self.errorContainer.text = "Missing field data"
            displayWarningTopPopUp(title: "Error", description: "Cannot leave any field empty.")
            return
        }
        
        loginButton.isLoading = true
        
        //If email and password found, Get auth instance and attempt to sign in
        //if fails, present alert to create account, if user continues, create account
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result, error in
            
            guard let self = self, self.inCurrentView else {
                return
            }

            //error means it could not sign in due to no accounts found
            if error == nil {
                Core.setupCurrentUser { (error) in
                    if let error = error {
                        self.loginButton.isLoading = false
                        let errorMesasge = error.localizedDescription
                        displayWarningTopPopUp(title: "Error", description: errorMesasge)
                    } else {
                        DispatchQueue.main.async {
                            self.loginButton.isLoading = false
                            self.navToHomeView()
                        }
                    }
                }
            } else {
                self.loginButton.isLoading = false
                let errorMesasge = error?.localizedDescription
                displayWarningTopPopUp(title: "Error", description: errorMesasge ?? "Unknown error is detected.")
                //if the error is "no account record create the account, else..."
            }
        })
    }
    
    func navToHomeView() {
        if testCollab {
            let storyboard = UIStoryboard(name: "CollabTest", bundle: nil)
            guard let collabTestViewController = storyboard.instantiateViewController(identifier: "CollabTestViewController") as? CollabTestViewController else {
                assertionFailure("Cannot instantiate CollabTestViewController")
                return
            }
            self.navigationController?.pushViewController(collabTestViewController, animated: true)
        } else if testCloudStorage {
            let storyboard = UIStoryboard(name: "CloudStorageTest", bundle: nil)
            guard let cloudStorageTestViewController = storyboard.instantiateViewController(identifier: "CloudStorageTestViewController") as? CloudStorageTestViewController else {
                assertionFailure("Cannot instantiate CloudStorageTestViewController")
                return
            }
            self.navigationController?.pushViewController(cloudStorageTestViewController, animated: true)
        } else if testFirestore {
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
        self.inCurrentView = false
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let signUpViewController = storyboard.instantiateViewController(identifier: "signupView") as? SignUpViewController else {
            assertionFailure("Cannot instantiate HomeViewController.")
            return
        }

        self.navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    private func setupEmailField() {
        emailField.format = emailFieldFormat
        emailField.type = AnimatedFieldType.email
        emailField.text = ""
        emailField.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                 attributes:[.foregroundColor: UIColor.lightGray])
            
        /// Keyboard type
        emailField.keyboardType = UIKeyboardType.emailAddress
    }
    
    private func setupPasswordField() {
        passwordField.format = passwordFieldFormat
        passwordField.type = AnimatedFieldType.password(0, 20)
        passwordField.text = ""
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                 attributes:[.foregroundColor: UIColor.lightGray])
        passwordField.keyboardType = UIKeyboardType.alphabet
        passwordField.isSecure = true
        passwordField.showVisibleButton = true
    }
    
    private func setupBgGradientEffect() {
        let pastelView = PastelView(frame: view.bounds)
        
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight

        // Custom Duration
        pastelView.animationDuration = 6

        // Custom Color
        pastelView.setColors([
            UIColor(hex: "#7117EA"),
            UIColor(hex: "#EA6066"),
            UIColor(hex: "#6078EA"),
            UIColor(hex: "#57CA85")
        ])

        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }
}

extension ViewController: AnimatedFieldDataSource {
    func animatedFieldShouldReturn(_ animatedField: AnimatedField) -> Bool {
        switch animatedField.placeholder {
        case "Email":
            _ = emailField.resignFirstResponder()
            _ = passwordField.becomeFirstResponder()
        case "Password":
            _ = passwordField.resignFirstResponder()
            didTapButton()
        default:
            break
        }
        return false
    }
}

