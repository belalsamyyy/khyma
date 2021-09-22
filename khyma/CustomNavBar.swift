//
//  CustomNavBar.swift
//  khyma
//
//  Created by Belal Samy on 22/09/2021.
//

import Foundation
import UIKit


protocol CustomNavBarDelegate: AnyObject {
    func handleMoviesTapped()
    func handleSeriesTapped()
    func handlePlaysTapped()
}

class CustomNavBar: UIView {
    
    // delegate
    weak var delegate: CustomNavBarDelegate?
    
    // stackview
    let stackView = UIStackView()
    
    // logo image
    let logoImageView = UIImageView()
    let imageContainer = UIView()
    
    // labels
    let moviesBtn = UIButton()
    let seriesBtn = UIButton()
    let playsBtn = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        self.tag = 500
        self.addSubviews([stackView, imageContainer, moviesBtn, seriesBtn, playsBtn])
        
        // logo image
        logoImageView.image = UIImage(named: "logo")
        imageContainer.addSubview(logoImageView)
        logoImageView.layout(X: .center(nil), W: .fixed(80), Y: .center(nil), H: .fixed(40))

        // labels
        moviesBtn.setTitle("Movies", for: .normal)
        seriesBtn.setTitle("Series", for: .normal)
        playsBtn.setTitle("Plays", for: .normal)
        
        moviesBtn.setTitleColor(Color.text, for: .normal)
        seriesBtn.setTitleColor(Color.text, for: .normal)
        playsBtn.setTitleColor(Color.text, for: .normal)

        moviesBtn.titleLabel?.textAlignment = .center
        seriesBtn.titleLabel?.textAlignment = .center
        playsBtn.titleLabel?.textAlignment = .center
        
        moviesBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        seriesBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        playsBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)

        // actions
        moviesBtn.addTarget(self, action: #selector(handleMoviesTapped), for: .touchUpInside)
        seriesBtn.addTarget(self, action: #selector(handleSeriesTapped), for: .touchUpInside)
        playsBtn.addTarget(self, action: #selector(handlePlaysTapped), for: .touchUpInside)

        // stack view
        stackView.layout(shortcut: .fillSuperView(0))
        
        //let subViews2 = stackView.fakeViews(4)
        let subViews = [imageContainer, moviesBtn, seriesBtn, playsBtn]
        stackView.create(subviews: subViews, colors: [.color(.clear)], axis: .H, distribution: .fillEqually(5))
    }
    
    
    // actions
    @objc fileprivate func handleMoviesTapped() {
        delegate?.handleMoviesTapped()
    }
    
    @objc fileprivate func handleSeriesTapped() {
        delegate?.handleSeriesTapped()
    }
    
    @objc fileprivate func handlePlaysTapped() {
        delegate?.handlePlaysTapped()
    }
    
}


