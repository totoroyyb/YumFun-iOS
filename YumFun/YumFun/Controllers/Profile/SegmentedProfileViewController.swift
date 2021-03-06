//
//  SegmentedProfileViewController.swift
//  YumFun
//
//  Created by Failury on 3/6/21.
//

import UIKit
import SegementSlide
class SegmentedProfileViewController: SegementSlideDefaultViewController {
    
    override func segementSlideHeaderView() -> UIView? {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: view.bounds.height/4).isActive = true
        return headerView
    }
    
    override var titlesInSwitcher: [String] {
        return ["Swift", "Ruby", "Kotlin"]
    }
    
    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        return ContentViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSelectedIndex = 0
        reloadData()
    }
    
}


