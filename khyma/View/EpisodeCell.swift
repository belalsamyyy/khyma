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
    
    var episode: Video? {
        didSet {
           episodeTitleLabel.text = episode?.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        posterImageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(nil, 0), H: .fixed(200))
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.cornerRadius = 10
        
        episodeTitleLabel.layout(X: .center(nil), W: .wrapContent, Y: .top(posterImageView, 1), H: .wrapContent)
        episodeTitleLabel.font = UIFont.systemFont(ofSize: 18)
        episodeTitleLabel.textColor = Color.secondary
        episodeTitleLabel.numberOfLines = 0
    }
}
