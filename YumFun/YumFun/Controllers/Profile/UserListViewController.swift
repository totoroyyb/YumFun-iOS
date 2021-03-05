//
//  UserListViewController.swift
//  YumFun
//
//  Created by Failury on 3/2/21.
//

import UIKit

class UserListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var List:[String] = []
    
    @IBOutlet weak var Searchbar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if self.List.count == 0{
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text = "No User"
            emptyLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            return 0
        } else {
            return self.List.count
        }
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"usercell",for: indexPath) as! UserCell
        User.get(named: List[indexPath.row],{_,user,_ in
            guard let u = user else{return}
            cell.UserName.text = u.displayName
            cell.UserBio.text = u.bio
            if let picUrl = u.photoUrl{
                let myStorage = CloudStorage(picUrl)
                
                cell.UserImage.sd_setImage(with: myStorage.fileRef, placeholderImage: PlaceholderImage.imageWith(name: u.displayName), completion: nil)
            }else{
                cell.UserImage.image = PlaceholderImage.imageWith(name: u.displayName)
            }
        })
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
                
                User.get(named: List[indexPath.row]) { (_,User, _) in
                    guard let U = User else {return}
                    guard let UserView = self.storyboard?.instantiateViewController(withIdentifier: "ProfileView") as? ProfileViewController else {
                        assertionFailure("Cannot find ViewController")
                        return
                    }
                    UserView.OU = U
                    UserView.isSelf = false
                    self.navigationController?.pushViewController(UserView, animated: true)
                }
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
}

