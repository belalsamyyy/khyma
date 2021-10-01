//
//  CoinsCell.swift
//  khyma
//
//  Created by Belal Samy on 24/09/2021.
//

import UIKit

class CoinsCell: UITableViewCell {

    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var currentCoinsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = Color.secondary

        coinsLabel.layout(X: .leading(nil, 20), W: .wrapContent, Y: .top(nil, 0), H: .fixed(50))
        currentCoinsLabel.layout(X: .trailing(nil, 20), W: .wrapContent, Y: .top(nil, 0), H: .fixed(50))
        coinsLabel.text = StringsKeys.coins.localized
        currentCoinsLabel.text = "\(Defaults.coins)"
        currentCoinsLabel.font = UIFont.boldSystemFont(ofSize: 25)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
