//
//  CollectionCell.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import UIKit
import DesignX
import SDWebImage

class MovieCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
     var video: Watchable? {
         didSet {
             let placeHolderImage = UIImage(named: "logo-khyma-transparent")?.withRenderingMode(.automatic).withTintColor(Defaults.darkMode ? .lightGray : .darkGray) 
             
             posterImageView.sd_setImage(with: URL(string: "\(video?.posterImageLink ?? "")"),
                                         placeholderImage: placeHolderImage,
                                         options: .progressiveLoad,
                                         context: nil)
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
