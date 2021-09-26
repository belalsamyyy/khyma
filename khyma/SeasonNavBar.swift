//
//  SeasonNavBar.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import UIKit

protocol SeasonNavBarDelegate: AnyObject {
    func handleSeasonTapped()
}

class SeasonNavBar: UIView {
    
    // delegate
    weak var delegate: SeasonNavBarDelegate?
    
    // stackview
    let stackView = UIStackView()
    
    // labels
    let seasonLabel = UILabel()
    let cancelBtn = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        self.addSubviews([stackView, seasonLabel, cancelBtn])
        
        // back label
        seasonLabel.textColor = Color.text
        seasonLabel.textAlignment = .center
        seasonLabel.font = UIFont.boldSystemFont(ofSize: 20)

        // back button
        cancelBtn.setTitle("X", for: .normal)
        cancelBtn.setTitleColor(Color.text, for: .normal)
        cancelBtn.titleLabel?.textAlignment = .center
        cancelBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
      

        // actions
        cancelBtn.addTarget(self, action: #selector(handleSeasonTapped), for: .touchUpInside)
      

        // stack view
        stackView.layout(shortcut: .fillSuperView(0))
        
        let subViews = [cancelBtn, seasonLabel]
        stackView.create(subviews: subViews, colors: [.color(.clear)], axis: .H, distribution: .custom([1, 9]))
    }
    
    
    // actions
    @objc fileprivate func handleSeasonTapped() {
        delegate?.handleSeasonTapped()
    }
    
}
