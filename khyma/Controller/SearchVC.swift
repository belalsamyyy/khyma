//
//  SearchVC.swift
//  khyma
//
//  Created by Belal Samy on 20/09/2021.
//

import UIKit
import SimpleAPI

class SearchVC: UIViewController {
    
    //MARK: - outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    //MARK: - variables
    
    var filteredVideos = [Video?]()
    
    //MARK: - constants
    
    var videos = [Video?]()
                
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getVideos()
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
    
    fileprivate func getVideos() {
        Video.endpoint = Endpoints.movies
        API<Video>.list { [weak self] result in
            switch result {
            case .success(let data):
                self?.videos = data
                data.forEach { video in
                    print(video?.en_name ?? "")
                }
                DispatchQueue.main.async {
                    self?.searchCollectionView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    //MARK: - actions
    
}

//MARK: - extensions

// search bar delegate
extension SearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        if searchText.isEmpty {
            filteredVideos = videos
        }else {
            filteredVideos = self.videos.filter { (movie) -> Bool in
                return Language.currentLanguage == Lang.english.rawValue ? (movie?.en_name?.lowercased().contains(searchText.lowercased()))! : (movie?.ar_name?.lowercased().contains(searchText.lowercased()))!
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
        return filteredVideos.count == 0 ? videos.count : filteredVideos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(indexPath: indexPath) as MovieCell
        cell.backgroundColor = Color.secondary
        cell.video = filteredVideos.count == 0 ? videos[indexPath.item] : filteredVideos[indexPath.item]
        return cell
    }
}


// MARK: - UICollectionView Delegate
extension SearchVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let video = filteredVideos.count == 0 ? videos[indexPath.item] : filteredVideos[indexPath.item]
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.video = video
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
