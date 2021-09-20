//
//  CollectionCell.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import UIKit
import DesignX

class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
     var movie: Movie? {
         didSet {
             posterImageView.image = movie?.posterImage
         }
     }

     override func awakeFromNib() {
         super.awakeFromNib()
   
        posterImageView.layout(shortcut: .fillSuperView(0))
        posterImageView.contentMode = .scaleAspectFill
        
         // Initialization code
         layer.masksToBounds = true
         layer.cornerRadius = 10
     }
 }
