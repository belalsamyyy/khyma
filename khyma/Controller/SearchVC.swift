//
//  SearchVC.swift
//  khyma
//
//  Created by Belal Samy on 20/09/2021.
//

import UIKit

class SearchVC: UIViewController {
    
    //MARK: - outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    //MARK: - variables
    
    var filteredMovies = [Video]()
    
    //MARK: - constants
    
    let movies = [Video(name: StringsKeys.bodyGuard.localized,
                        posterUrl: "poster-movie-1",
                        youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk",
                        continueWatching: Float(2.toMinutes())),
                  
                  Video(name: StringsKeys.avengers.localized,
                        posterUrl: "poster-movie-2",
                        youtubeUrl: "https://www.youtube.com/watch?v=dEiS_WpFuc0",
                        continueWatching:  Float(2.toMinutes())),
                  
                  Video(name: StringsKeys.weladRizk.localized,
                        posterUrl: "poster-movie-3",
                        youtubeUrl: "https://www.youtube.com/watch?v=hqkSGmqx5tM",
                        continueWatching:  Float(2.toMinutes())),
                  
                  Video(name: StringsKeys.batman.localized,
                        posterUrl: "poster-movie-4",
                        youtubeUrl: "https://www.youtube.com/watch?v=OEqLipY4new&list=PLRYXdAxk10I4rWNxWyelz7cXyGR94Q0eY",
                        continueWatching:  Float(2.toMinutes())),
                  
                  Video(name: StringsKeys.blueElephant.localized,
                        posterUrl: "poster-movie-5",
                        youtubeUrl: "https://www.youtube.com/watch?v=miH5SCH9at8",
                        continueWatching:  Float(2.toMinutes()))]
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationController?.navigationBar.topItem?.title = ""
//    }
    
    override func viewDidLayoutSubviews() {
        setupNavBar()
        searchBar.isHidden = false
    }
    
    //MARK: - functions

    fileprivate func setupViews() {
        view.backgroundColor = Color.primary
        
        // nav bar
        setupNavBar()
        
        // search bar
        searchBar.delegate = self
        
        searchBar.placeholder = StringsKeys.searchPlaceholder.localized
        searchBar.barTintColor = Color.primary
        searchBar.layer.borderColor = Color.primary.cgColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = Color.secondary
        
        searchBar.layout(XW: .leadingAndCenter(nil, 5), Y: .topToSafeArea(nil, 0), H: .fixed(75))
        
        //collectionView
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.register(cell: MovieCell.self)
        searchCollectionView.alwaysBounceVertical = true
        searchCollectionView.keyboardDismissMode = .onDrag
        searchCollectionView.backgroundColor = Color.primary
        searchCollectionView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottom(searchBar, 0, nil, 0))
    
    }
    
    fileprivate func setupNavBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = StringsKeys.search.localized
    }
    
    
    //MARK: - actions
    
}

//MARK: - extensions

// search bar delegate
extension SearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        if searchText.isEmpty {
            filteredMovies = movies
        }else {
            filteredMovies = self.movies.filter { (movie) -> Bool in
                return (movie.name?.lowercased().contains(searchText.lowercased()))!
            }
        }
        searchCollectionView.reloadData()
    }
}



// MARK: - UICollectionView Data Source
extension SearchVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count == 0 ? movies.count : filteredMovies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(indexPath: indexPath) as MovieCell
        cell.backgroundColor = Color.secondary
        cell.movie = filteredMovies.count == 0 ? movies[indexPath.item] : filteredMovies[indexPath.item]
        return cell
    }
}


// MARK: - UICollectionView Delegate
extension SearchVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let movie = filteredMovies.count == 0 ? movies[indexPath.item] : filteredMovies[indexPath.item]
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.video = movie
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}


// MARK: - UICollectionViewDelegate Flow Layout
extension SearchVC: UICollectionViewDelegateFlowLayout {
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
