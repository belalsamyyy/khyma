//
//  CollectionCell.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import UIKit
import DesignX

class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var myLabel: UILabel!
    
     var movie: Movie? {
         didSet {
             myLabel.text = movie?.name
         }
     }

     override func awakeFromNib() {
         super.awakeFromNib()
        
         myLabel.layout(shortcut: .fillSuperView(0))
         myLabel.textColor = .white
         myLabel.textAlignment = .center
         myLabel.font = UIFont.systemFont(ofSize: 25)
        
         // Initialization code
         layer.masksToBounds = true
         layer.cornerRadius = 10
     }
 }
