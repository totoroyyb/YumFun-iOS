//
//  EditDetailController.swift
//  YumFun
//
//  Created by Failury on 2/24/21.
//

import UIKit

class EditDetailController: UIViewController {
    @IBOutlet weak var TextField: UITextField!
    var Mode :String?
    override func viewDidLoad() {
        super.viewDidLoad()
        TextField.becomeFirstResponder()
        if Mode == "BioEdit"{
            TextField.font = UIFont(name: "System", size: 12)
        }
        
    }

    @IBAction func emptyPressed(_ sender: Any) {
        TextField.text = ""
    }
    @IBAction func DonePressed(_ sender: Any) {
        guard let CurrentUser = Core.currentUser else {return}
        guard let text = TextField.text else {
            return
        }
        switch Mode {
        case "NameEdit":
            if text.count < 3{
                self.AlertWindow(Message: "The display name can't be less than 3 character")
            }
            else{
                CurrentUser.updateDisplayName(withNewName: text, {error in})
            }
            
        case "BioEdit":
            if text.count > 60{
                self.AlertWindow(Message: "The bio should not longer than 60 characters")
            }else{
                CurrentUser.updateBio(withNewBio: text, {error in
                })
            }
            
        case "EmailEdit":
            //??? noemail update method???
            CurrentUser.updateDisplayName(withNewName: text, {error in
                guard let e = error else {return}
                self.AlertWindow(Message: e.localizedDescription)
            })
        case "UserNameEdit":
            if text.count < 3{
                self.AlertWindow(Message: "The user name can't be less than 3 character")
            }
            else{
                CurrentUser.updateUsername(withNewName: text, {error in})
            }
        case "PasswordEdit":
            //no password edit method
            CurrentUser.updateDisplayName(withNewName: text, {error in
                guard let e = error else {return}
                self.AlertWindow(Message: e.localizedDescription)
            })
        default:
            break
        }
        if (storyboard?.instantiateViewController(identifier: "ProfileView") as? ProfileViewController) != nil {
            navigationController?.popToRootViewController(animated: true)
            }
    }
    func AlertWindow(Message:String){
        // Create new Alert
        let dialogMessage = UIAlertController(title: "Error", message: Message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
         })
        
        //Add OK button to a dialog message
        dialogMessage.addAction(ok)
        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
}
