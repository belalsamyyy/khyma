//
//  SearchVC.swift
//  khyma
//
//  Created by Belal Samy on 20/09/2021.
//

import UIKit
import SimpleAPI
import GoogleMobileAds
import DesignX

class SearchVC: UIViewController {
    
    //MARK: - outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    var filterBtn = UIButton(type: .custom)
    
    //MARK: - variables
    var categoryName = CategoryName.movies
    
    // The banner ad
    private var bannerAd: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.SearchVCbannerUP
      banner.load(GADRequest())
      return banner
    }()
    
    //MARK: - constants
    
    var videos = [Video?]()
    var series = [Series?]()
                
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getVideos(categoryName: CategoryName.movies, nameEn: "", nameAr: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationController?.navigationBar.topItem?.title = ""
    }

    override func viewDidLayoutSubviews() {
        setupNavBar()
        searchBar.isHidden = false
    }
    
    //MARK: - functions

    fileprivate func setupViews() {
        view.backgroundColor = Color.primary
        
        // banner Ad
        loadBannerAd()
        
        // nav bar
        setupNavBar()
        
        // filter Button
        view.addSubview(filterBtn)
        filterBtn.layout(X: .trailing(nil, 7), W: .fixed(30), Y: .topToSafeArea(nil, 20+60), H: .fixed(35))
        let image = UIImage(named: "icon-filter")?.withRenderingMode(.alwaysTemplate)

        filterBtn.setImage(image, for: .normal)
        filterBtn.tintColor = Color.text
        filterBtn.addTarget(self, action: #selector(handleFilterBtnTapped), for: .touchUpInside)
        
        // search bar
        searchBar.delegate = self
        
        searchBar.placeholder = "\(StringsKeys.searchPlaceholder.localized)\(StringsKeys.movies.localized) ..."
        searchBar.barTintColor = Color.primary
        searchBar.layer.borderColor = Color.primary.cgColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = Color.secondary
        
        searchBar.layout(XW: .leadingAndTrailing(nil, 5, filterBtn, 1), Y: .topToSafeArea(nil, 60), H: .fixed(75))
        
        //collectionView
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.register(cell: MovieCell.self)
        searchCollectionView.alwaysBounceVertical = true
        searchCollectionView.keyboardDismissMode = .onDrag
        searchCollectionView.backgroundColor = Color.primary
        searchCollectionView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottom(searchBar, 0, nil, 0))
    
    }
    
    @objc fileprivate func handleFilterBtnTapped() {
        let alertController = UIAlertController(title: StringsKeys.searchPlaceholder.localized, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: StringsKeys.movies.localized, style: .default, handler: { (_) in
            print("filter by movies")
            self.categoryName = CategoryName.movies
            self.getVideos(categoryName: self.categoryName , nameEn: "", nameAr: "")
            self.searchBar.placeholder = "\(StringsKeys.searchPlaceholder.localized)\(StringsKeys.movies.localized) ..."

        }))
        
        alertController.addAction(UIAlertAction(title: StringsKeys.series.localized, style: .default, handler: { (_) in
            print("filter by series")
            self.categoryName = CategoryName.series
            self.getSeries(nameEn: "", nameAr: "")
            self.searchBar.placeholder = "\(StringsKeys.searchPlaceholder.localized)\(StringsKeys.series.localized) ..."
            
        }))
        
        alertController.addAction(UIAlertAction(title: StringsKeys.plays.localized, style: .default, handler: { (_) in
            print("filter by plays")
            self.categoryName = CategoryName.plays
            self.getVideos(categoryName: self.categoryName , nameEn: "", nameAr: "")
            self.searchBar.placeholder = "\(StringsKeys.searchPlaceholder.localized)\(StringsKeys.plays.localized) ..."
        }))
        
        alertController.addAction(UIAlertAction(title: StringsKeys.cancelAlert.localized, style: .cancel ))
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func setupNavBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = StringsKeys.search.localized
    }
    
    fileprivate func getVideos(categoryName: String, nameEn: String, nameAr: String) {
        Video.endpoint = "\(BASE_URL)/api/\(categoryName)?nameEn=\(nameEn)&nameAr=\(nameAr)"
        API<Video>.list { [weak self] result in
            switch result {
            case .success(let data):
                self?.videos = Array(data.prefix(20))
                data.forEach { video in
                    print(Language.currentLanguage == Lang.english.rawValue ? video?.en_name ?? "" : video?.ar_name ?? "")
                }
                DispatchQueue.main.async {
                    self?.searchCollectionView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    fileprivate func getSeries(nameEn: String, nameAr: String) {
        Series.endpoint = "\(BASE_URL)/api/series?nameEn=\(nameEn)&nameAr=\(nameAr)"
        API<Series>.list { [weak self] result in
            switch result {
            case .success(let data):
                self?.series = Array(data.prefix(20))
                data.forEach { serie in
                    print(Language.currentLanguage == Lang.english.rawValue ? serie?.en_name ?? "" : serie?.ar_name ?? "")
                }
                DispatchQueue.main.async {
                    self?.searchCollectionView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    fileprivate func loadBannerAd() {
       bannerAd.rootViewController = self
       view.addSubview(bannerAd)
       bannerAd.layout(XW: .leadingAndCenter(nil, 0), Y: .topToSafeArea(nil, 0), H: .fixed(60))
    }
    
    //MARK: - actions
    
}

//MARK: - extensions

// search bar delegate
extension SearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        self.categoryName = CategoryName.movies
        if Language.currentLanguage == Lang.english.rawValue {
            self.getVideos(categoryName: self.categoryName , nameEn: searchText, nameAr: "")
            searchCollectionView.reloadData()
        } else {
            // allow arabic characters in urls
            let arabicSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            self.getVideos(categoryName: self.categoryName , nameEn: "", nameAr: arabicSearchText)
            searchCollectionView.reloadData()
        }

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
        return categoryName == CategoryName.series ? series.count : videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(indexPath: indexPath) as MovieCell
        cell.backgroundColor = Color.secondary
        cell.video = categoryName == CategoryName.series ? series[indexPath.item] : videos[indexPath.item]
        return cell
    }
}


// MARK: - UICollectionView Delegate
extension SearchVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
//
//        let video = videos[indexPath.item]
//        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
//        detailsVC.modalPresentationStyle = .fullScreen
//        detailsVC.video = video
//        self.navigationController?.pushViewController(detailsVC, animated: true)
        
        
        if categoryName == CategoryName.series {
            // series
            let series = series[indexPath.item]
            let episodesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EpisodesVC") as! EpisodesVC
            episodesVC.modalPresentationStyle = .fullScreen
            episodesVC.series = series
            self.navigationController?.pushViewController(episodesVC, animated: true)
            
        } else {
            let video = videos[indexPath.item]
            let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! VideoPlayerVC
            detailsVC.modalPresentationStyle = .fullScreen
            detailsVC.video = video
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
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
