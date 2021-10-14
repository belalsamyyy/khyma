//
//  CustomBackNavBar.swift
//  khyma
//
//  Created by Belal Samy on 25/09/2021.
//

import Foundation
import UIKit

protocol BackNavBarDelegate: AnyObject {
    func handleBackTapped()
}

class BackNavBar: UIView {
    
    // delegate
    weak var delegate: BackNavBarDelegate?
    
    // stackview
    let stackView = UIStackView()
    
    // labels
    let backLabel = UILabel()
    let backBtn = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        self.addSubviews([stackView, backLabel, backBtn])
        
        // back label
        backLabel.textColor = Color.text
        backLabel.textAlignment = .center
        backLabel.font = UIFont.boldSystemFont(ofSize: 20)

        // back button
        backBtn.setTitle(StringsKeys.back.localized, for: .normal)
        backBtn.setTitleColor(Color.text, for: .normal)
        backBtn.titleLabel?.textAlignment = .center
        backBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        
        // actions
        backBtn.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
      

        // stack view
        stackView.layout(shortcut: .fillSuperView(0))
        
        let subViews = [backBtn, backLabel, UIView()]
        stackView.create(subviews: subViews, colors: [.color(.clear)], axis: .H, distribution: .custom([1, 2.5, 6.5]))
    }
    
    
    // actions
    @objc fileprivate func handleBackTapped() {
        delegate?.handleBackTapped()
    }
    
}
