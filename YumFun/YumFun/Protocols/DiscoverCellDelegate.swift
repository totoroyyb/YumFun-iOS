//
//  DiscoverCellDelegate.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/14.
//

import Foundation

protocol DiscoverCellDelegate: class {
    func didFavorRecipeAt(at indexPath: IndexPath)
    func didUnfavorRecipeAt(at indexPath: IndexPath)
    func collectWasPressed(at indexPath: IndexPath)
}
