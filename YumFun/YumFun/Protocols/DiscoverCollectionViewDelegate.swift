//
//  DiscoverCollectionViewDelegate.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/14.
//

import UIKit

// This protocol is for handling button pressing events on a cell.
// The class coforming to this protocol is informed by its collectionView of these events.
protocol DiscoverCollectionViewDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didFavorRecipeAt indexPath: IndexPath) -> Void
    
    func collectionView(_ collectionView: UICollectionView, didUnfavorRecipeAt indexPath: IndexPath) -> Void
    
    func collectionView(_ collectionView: UICollectionView, collectWasPressedAt indexPath: IndexPath) -> Void
}
