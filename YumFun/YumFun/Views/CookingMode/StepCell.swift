//
//  StepCollectionViewCell.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/12.
//

import UIKit
import MagazineLayout

class StepCell: MagazineLayoutCollectionViewCell {
    private let XIB_NAME = "StepCell"
    
    var assigneeAvatars : [UIImage?] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewToDescripHeight: NSLayoutConstraint!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descrip: UILabel!
    @IBOutlet weak var notAssigned: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerCell()
        layoutView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCell()
        layoutView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        collectionView.dataSource = nil
        collectionView.delegate = nil
        
        title.text = nil
        descrip.text = nil
        
        layoutView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func registerCell() {
        let avatarCellXib = UINib(nibName: "AvatarCell",
                                         bundle: nil)
        collectionView.register(avatarCellXib, forCellWithReuseIdentifier: "StepAvatarCell")
    }
    
    private func layoutView() {
        addShadowDrop()
    }
    
    private func addShadowDrop() {
        self.layer.backgroundColor = UIColor(named: "cell_bg_color")?.cgColor
        
        // cell rounded section
        self.layer.cornerRadius = 22
        self.layer.borderWidth = 0.0
        self.layer.masksToBounds = false
    }
    
    func setCollectionViewVisible(_ visible: Bool) {
        if visible {
            self.collectionViewHeight.constant = 45
            self.collectionViewToDescripHeight.constant = 15
        } else {
            collectionViewHeight.constant = 0
            self.collectionViewToDescripHeight.constant = 0
        }
    }
    
}

extension StepCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assigneeAvatars.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StepAvatarCell", for: indexPath) as? AvatarCell ?? AvatarCell()
        cell.avatar.image = assigneeAvatars[indexPath.row]
        return cell
    }
}

extension StepCell:  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 42, height: 42)
    }
}
