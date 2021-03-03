//
//  UserListViewController.swift
//  YumFun
//
//  Created by Failury on 3/2/21.
//

import UIKit

class UserListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var List:[String] = []
    
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
                
                cell.UserImage.sd_setImage(
                    with: myStorage.fileRef,
                    maxImageSize: 1 * 2048 * 2048,
                    placeholderImage: nil,
                    options: [ .refreshCached]) { (image, error, cache, storageRef) in
                    if let error = error {
                        print("Error load Image: \(error)")
                    } else {
                        print("Finished loading current user profile image.")
                    }
                }
            }else{
                cell.UserImage.image = PlaceholderImage.imageWith(name: u.displayName)
            }
        })
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    
    
}
