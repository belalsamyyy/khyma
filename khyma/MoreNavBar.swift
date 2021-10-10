//
//  MoreNavBar.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import Foundation
import UIKit

protocol MoreNavBarDelegate: AnyObject {
    func handleCancelTapped()
}

class MoreNavBar: UIView {
    
    // delegate
    weak var delegate: MoreNavBarDelegate?
    
    // stackview
    let stackView = UIStackView()
    
    // labels
    let moreLabel = UILabel()
    let cancelBtn = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        self.backgroundColor = Color.primary
        self.addSubviews([stackView, moreLabel, cancelBtn])
        
        // back label
        moreLabel.textColor = Color.text
        moreLabel.textAlignment = .center
        moreLabel.font = UIFont.boldSystemFont(ofSize: 20)

        // back button
        cancelBtn.setTitle("X", for: .normal)
        cancelBtn.setTitleColor(Color.text, for: .normal)
        cancelBtn.titleLabel?.textAlignment = .center
        cancelBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
      

        // actions
        cancelBtn.addTarget(self, action: #selector(handleCancelTapped), for: .touchUpInside)
      

        // stack view
        stackView.layout(shortcut: .fillSuperView(0))
        
        let subViews = [cancelBtn, moreLabel]
        stackView.create(subviews: subViews, colors: [.color(.clear)], axis: .H, distribution: .custom([1, 9]))
    }
    
    
    // actions
    @objc fileprivate func handleCancelTapped() {
        delegate?.handleCancelTapped()
    }
    
}
