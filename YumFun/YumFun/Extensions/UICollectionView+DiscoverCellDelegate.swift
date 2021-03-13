//
//  UICollectionView+DiscoverCellDelegate.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/14.
//

import UIKit

// This protocol is for handling button pressing events on a cell.
// The UICollectionView will be informed when a button pressing happens in a cell.
extension UICollectionView: DiscoverCellDelegate {
    
    func didFavorRecipeAt(at indexPath: IndexPath) {
        if let del = delegate as? DiscoverCollectionViewDelegate? {
            del?.collectionView(self, didFavorRecipeAt: indexPath)
        }
    }
    
    func didUnfavorRecipeAt(at indexPath: IndexPath) {
        if let del = delegate as? DiscoverCollectionViewDelegate? {
            del?.collectionView(self, didUnfavorRecipeAt: indexPath)
        }
    }
    
    func collectWasPressed(at indexPath: IndexPath) {
        if let del = delegate as? DiscoverCollectionViewDelegate? {
            del?.collectionView(self, collectWasPressedAt: indexPath)
        }
    }
}
