//
//  CollectionCell3.swift
//  khyma
//
//  Created by Belal Samy on 21/09/2021.
//

import UIKit
import DesignX

class MainSliderCell: UICollectionViewCell {

    var gradientLayer = CAGradientLayer()
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    
    var video: Watchable? {
       didSet {
           posterImageView.image = UIImage(named: video?.posterImageUrl ?? "")
           movieNameLabel.text = video?.name
       }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        changeTheme()
        
        self.clipsToBounds = true
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.layout(shortcut: .fillSuperView(0))
        movieNameLabel.textColor = .white
    }
    
    override func layoutSubviews() {
        changeTheme()
        self.gradientLayer.frame = posterImageView.bounds
    }

    
    fileprivate func addGradientLayer(to view: UIView, color: UIColor) {
        DispatchQueue.main.async { [weak self] in
            // Add colors and locations
            self?.gradientLayer.colors = [UIColor.clear.cgColor, color.cgColor]
            self?.gradientLayer.locations = [0 ,1]

            self?.gradientLayer.frame = self?.bounds ?? CGRect.zero
            view.layer.addSublayer(self?.gradientLayer ?? CAGradientLayer())
        }
    }
    
    fileprivate func changeTheme() {
        addGradientLayer(to: posterImageView, color: Defaults.darkMode == true ? #colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }

    
    
}
