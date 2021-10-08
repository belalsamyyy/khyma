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
            posterImageView.sd_setImage(with: URL(string: "\(Endpoints.image)\(episode?.posterImageUrl ?? "")"),
                                        placeholderImage: UIImage(named: "poster-movie-1"),
                                        options: .progressiveLoad,
                                        context: nil)
           // posterImageView.sd_setImage(with: URL(string: "\(Endpoints.image)\(episode?.posterImageUrl ?? "")"))
           episodeTitleLabel.text = Language.currentLanguage == Lang.english.rawValue ? episode?.en_name : episode?.ar_name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        posterImageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(nil, 0), H: .fixed(200))
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.cornerRadius = 10
        posterImageView.backgroundColor = Color.secondary
        
        episodeTitleLabel.layout(X: .center(nil), W: .wrapContent, Y: .top(posterImageView, 5), H: .wrapContent)
        episodeTitleLabel.font = UIFont.systemFont(ofSize: 18)
        episodeTitleLabel.textColor = Color.text
        episodeTitleLabel.numberOfLines = 0
    }
}
