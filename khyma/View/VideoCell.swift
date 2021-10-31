//
//  EpisodeCell.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import UIKit
import DesignX

class VideoCell: UICollectionViewCell {
    var genreID: String?

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    var video: Watchable? {
        didSet {
            let placeHolderImage = UIImage(named: "logo-khyma-transparent")?.withRenderingMode(.automatic).withTintColor(Defaults.darkMode ? .lightGray : .darkGray)
            posterImageView.sd_setImage(with: URL(string: "\(video?.posterImageLink ?? "")"),
                                        placeholderImage: placeHolderImage,
                                        options: .progressiveLoad,
                                        context: nil)
           videoTitleLabel.text = Language.currentLanguage == Lang.english.rawValue ? video?.en_name : video?.ar_name
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
        
        videoTitleLabel.layout(X: .center(nil), W: .wrapContent, Y: .top(posterImageView, 5), H: .wrapContent)
        videoTitleLabel.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom != .pad ? 18 : 25)
        videoTitleLabel.textColor = Color.text
        videoTitleLabel.numberOfLines = 0
    }
}
