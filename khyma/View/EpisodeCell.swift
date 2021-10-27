//
//  EpisodeCell.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import UIKit
import DesignX

class EpisodeCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    
    var episode: Watchable? {
        didSet {
            let placeHolderImage = UIImage(named: "logo-khyma-transparent")?.withRenderingMode(.automatic).withTintColor(Defaults.darkMode ? .lightGray : .darkGray)
            posterImageView.sd_setImage(with: URL(string: "\(episode?.posterImageLink ?? "")"),
                                        placeholderImage: placeHolderImage,
                                        options: .progressiveLoad,
                                        context: nil)
           episodeTitleLabel.text = Language.currentLanguage == Lang.english.rawValue ? episode?.en_name : episode?.ar_name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        posterImageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(nil, 0), H: .fixed(UIDevice.current.userInterfaceIdiom != .pad ? 200 : 300))
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.cornerRadius = 10
        posterImageView.backgroundColor = Color.secondary
        
        episodeTitleLabel.layout(X: .center(nil), W: .wrapContent, Y: .top(posterImageView, 5), H: .wrapContent)
        episodeTitleLabel.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom != .pad ? 18 : 25)
        episodeTitleLabel.textColor = Color.text
        episodeTitleLabel.numberOfLines = 0
    }
}
