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
    
    var filteredMovies = [Movie]()
    
    //MARK: - constants
    
    let movies = [Movie(name: "BodyGuard", poster: UIImage(named: "poster-movie-1")!),
                  Movie(name: "Avengers: End Game", poster: UIImage(named: "poster-movie-2")!),
                  Movie(name: "Welad Rizk 2", poster: UIImage(named: "poster-movie-3")!),
                  Movie(name: "Batman Hush", poster: UIImage(named: "poster-movie-4")!),
                  Movie(name: "Blue Elephant 2", poster: UIImage(named: "poster-movie-5")!)]
    
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = "Search"
        searchBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //
    }
    
    //MARK: - functions

    fileprivate func setupViews() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = "Search"
        view.backgroundColor = Color.primary
        
        // search bar
        searchBar.delegate = self
        
        searchBar.placeholder = "Search movies, series, plays ..."
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
                return movie.name.lowercased().contains(searchText.lowercased())
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
        
        let movie = filteredMovies[indexPath.item]
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.youtubeID = movie.youtubeUrl.youtubeID
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
        return CGSize(width: 125, height: 200)
    }
}
