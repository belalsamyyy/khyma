//
//  UICollectionView+Extensions.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func register<Cell: UICollectionViewCell>(cell: Cell.Type) {
        let nibName = String(describing: Cell.self)
        self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: nibName)
    }
    
    func dequeue<Cell: UICollectionViewCell>(indexPath: IndexPath) -> Cell  {
        let identifier = String(describing: Cell.self)
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else  {
            fatalError("Error in dequeue extension code !")
        }
        return cell
    }
    
    func reloadDataAtSamePosition() {
        let contentOffset = self.contentOffset
        self.reloadData()
        self.layoutIfNeeded()
        self.setContentOffset(contentOffset, animated: false)
    }
    
    func size(rows: CGFloat, columns: CGFloat) -> CGSize {
        let width = ( self.frame.width - ( columns * 10 ) - 10 ) / columns //  horizontal spacing 10
        let height = ( self.frame.height - ( rows * 10 ) - 10 ) / rows // vertical spacing 10
        return CGSize(width: max(CGFloat.leastNonzeroMagnitude, width), height: max(CGFloat.leastNonzeroMagnitude, height))
    }
    
    func size(height: CGFloat, columns: CGFloat) -> CGSize {
        let width = ( self.frame.width - ( columns * 10 ) - 10 ) / columns //  horizontal spacing 10
        return CGSize(width: max(CGFloat.leastNonzeroMagnitude, width), height: max(CGFloat.leastNonzeroMagnitude, height))
    }
}
