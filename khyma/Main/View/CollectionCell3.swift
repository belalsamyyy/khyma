//
//  CollectionCell3.swift
//  khyma
//
//  Created by Belal Samy on 21/09/2021.
//

import UIKit

class CollectionCell3: UICollectionViewCell {

    var gradientLayer = CAGradientLayer()
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    
    var movie: Movie? {
       didSet {
           posterImageView.image = movie?.posterImage
           movieNameLabel.text = movie?.name
       }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.clipsToBounds = true
        posterImageView.contentMode = .scaleAspectFill
        movieNameLabel.textColor = .white
        addGradientLayer(to: posterImageView)
    }
    
    fileprivate func addGradientLayer(to view: UIView) {
        DispatchQueue.main.async {
            self.gradientLayer = view.fill(gradient: [.color(.clear), .color(Color.primary)], locations: [0, 1], opacity: 1)
            self.gradientLayer.frame = view.bounds
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        gradientLayer.removeFromSuperlayer()
        switch traitCollection.userInterfaceStyle {
            case .dark:
                darkModeEnabled()   // Switch to dark mode colors, etc.
            case .light:
                fallthrough
            case .unspecified:
                fallthrough
            default:
                lightModeEnabled()   // Switch to light mode colors, etc.
        }
    }
    
    fileprivate func lightModeEnabled() {
        addGradientLayer(to: posterImageView)
    }
    
    fileprivate func darkModeEnabled() {
        addGradientLayer(to: posterImageView)
    }
    
  
    
    
}
