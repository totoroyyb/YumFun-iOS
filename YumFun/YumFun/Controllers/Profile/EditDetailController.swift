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
            CurrentUser.updateDisplayName(withNewName: text, {error in
                guard let e = error else {return}
                self.AlertWindow(Message: e.localizedDescription)
            })
        case "BioEdit":
            CurrentUser.updateBio(withNewBio: text, {error in
                guard let e = error else {return}
                self.AlertWindow(Message: e.localizedDescription)
            })
        case "EmailEdit":
            //??? noemail update method???
            CurrentUser.updateDisplayName(withNewName: text, {error in
                guard let e = error else {return}
                self.AlertWindow(Message: e.localizedDescription)
            })
        case "UserNameEdit":
            CurrentUser.updateUsername(withNewName: text, {error in
                guard let e = error else {return}
                self.AlertWindow(Message: e.localizedDescription)
            })
        case "PasswordEdit":
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
