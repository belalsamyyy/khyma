//
//  MoreVC.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import UIKit

class MoreVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var moreCollectionView: UICollectionView!
    
    
    //MARK: - variables
    
    var navBarTitle: String!
    
    //MARK: - constants
    
    let movies = [Movie(name: StringsKeys.bodyGuard.localized, posterUrl: "poster-movie-1"),
                  Movie(name: StringsKeys.avengers.localized, posterUrl: "poster-movie-2"),
                  Movie(name: StringsKeys.weladRizk.localized, posterUrl: "poster-movie-3"),
                  Movie(name: StringsKeys.batman.localized, posterUrl: "poster-movie-4"),
                  Movie(name: StringsKeys.blueElephant.localized, posterUrl: "poster-movie-5")]
    
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    //MARK: - functions
    
    fileprivate func setupViews() {
        setupNavBar()
        
        moreCollectionView.backgroundColor = Color.primary
        moreCollectionView.layout(shortcut: .fillSuperView(0))
        
        moreCollectionView.delegate = self
        moreCollectionView.dataSource = self
        moreCollectionView.register(cell: MovieCell.self)
        moreCollectionView.reloadData()
    }
    
    fileprivate func setupNavBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.topItem?.title = StringsKeys.more.localized
    }
    
    
    //MARK: - actions
    
}

//MARK: - extensions

// MARK: - UICollectionView Data Source
extension MoreVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(indexPath: indexPath) as MovieCell
        cell.backgroundColor = Color.secondary
        cell.movie = movies[indexPath.item]
        return cell
    }
}


// MARK: - UICollectionView Delegate
extension MoreVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.item]
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.movie = movie
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}


// MARK: - UICollectionViewDelegate Flow Layout
extension MoreVC: UICollectionViewDelegateFlowLayout {
    // section
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 10 // vertical spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0 // horizontal spacing
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return collectionView.size(height: 200, columns: 3)
    }
}



