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
             posterImageView.sd_setImage(with: URL(string: "\(Endpoints.image)\(video?.posterImageUrl ?? "")"),
                                         placeholderImage: UIImage(named: "poster-movie-1"),
                                         options: .progressiveLoad,
                                         context: nil)
            //posterImageView.sd_setImage(with: URL(string: "\(Endpoints.image)\(video?.posterImageUrl ?? "")"))
            //posterImageView.image = UIImage(named: video?.posterImageUrl ?? "")
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
