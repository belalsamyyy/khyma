//
//  LanguageCell.swift
//  khyma
//
//  Created by Belal Samy on 25/09/2021.
//

import UIKit

class LanguageCell: UITableViewCell {
    
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var currentLanguageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = Color.secondary

        LanguageLabel.layout(X: .leading(nil, 20), W: .wrapContent, Y: .top(nil, 0), H: .fixed(50))
        currentLanguageLabel.layout(X: .trailing(nil, 20), W: .wrapContent, Y: .top(nil, 0), H: .fixed(50))
        
        LanguageLabel.text = StringsKeys.language.localized
        currentLanguageLabel.text = StringsKeys.currentLanguage.localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        print("Language is English")
    }
    
}
