//
//  ContentViewController.swift
//  YumFun
//
//  Created by Failury on 3/6/21.
//

import UIKit
import SegementSlide
class ContentViewController: UITableViewController, SegementSlideContentScrollViewDelegate {
    @objc var scrollView: UIScrollView {
           return tableView
       }

}
