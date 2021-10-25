//
//  MoreVC.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import UIKit
import SimpleAPI
import GoogleMobileAds
import DesignX

class MoreVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var moreCollectionView: UICollectionView!
    
    //MARK: - variables
    
    // The banner ad
    private var bannerAd1: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.MoreVCbannerUP
      banner.load(GADRequest())
      return banner
    }()
    
    private var bannerAd2: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.MoreVCbannerDown
      banner.load(GADRequest())
      return banner
    }()
    
    var videos = [Video?]()
    var categoryName: String?
    var genreID: String?
    var genreName: String?

    // pagination
    var paginagationManager: PaginationManager!
    var CURRENT_PAGE = 0

    
    //MARK: - constants
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pagination manager
        paginagationManager = PaginationManager(scrollView: moreCollectionView, direction: .vertical)
        paginagationManager.refreshViewColor = .clear
        paginagationManager.loaderColor = Color.text
        paginagationManager.delegateV = self 
        
        // admob ads
        loadBannerAd()
        
        print("genre id is => \(genreID ?? "")")
        setupViews()
        getVideos(page: 1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //
    }
    
    //MARK: - functions
    
    fileprivate func getVideos(page: Int) {
        CURRENT_PAGE = page
        Video.endpoint = "\(Defaults.BASE_URL)\(categoryName ?? "")/genre/\(genreID ?? "")/\(CURRENT_PAGE)"
        API<Video>.list { [weak self] result in
            switch result {
            case .success(let data):
                if self?.CURRENT_PAGE == 1{
                    self?.videos = data
                } else {
                    self?.videos.append(contentsOf: data)
                }
                
                DispatchQueue.main.async {
                    self?.moreCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    fileprivate func setupViews() {
        addNavBar()
        
        moreCollectionView.backgroundColor = Color.primary
        moreCollectionView.layout(shortcut: .fillToSafeArea(nil, 60, nil, 60))
        
        moreCollectionView.delegate = self
        moreCollectionView.dataSource = self
        moreCollectionView.register(cell: MovieCell.self)
        moreCollectionView.alwaysBounceVertical = true
        moreCollectionView.isPagingEnabled = false 
        moreCollectionView.reloadData()
    }
    
    fileprivate func addNavBar() {
        navigationController?.navigationBar.barTintColor = Color.primary
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.largeTitleDisplayMode = .never
        let navBar = navigationController?.navigationBar
        navBar?.topItem?.backButtonTitle = genreName
    }

    fileprivate func loadBannerAd() {
       bannerAd1.rootViewController = self
       view.addSubview(bannerAd1)
       bannerAd1.layout(XW: .leadingAndCenter(nil, 0), Y: .topToSafeArea(nil, 0), H: .fixed(60))
        
       bannerAd2.rootViewController = self
       view.addSubview(bannerAd2)
       bannerAd2.layout(XW: .leadingAndCenter(nil, 0), Y: .bottomToSafeArea(nil, 0), H: .fixed(60))
    }
    
    //MARK: - actions
    
}

//MARK: - extensions

//MARK: - UIScrollView Delegate

extension MoreVC: VerticalPaginationManagerDelegate {
    
    func loadMore(completion: @escaping (Bool) -> Void) {
        refreshDelay(2.0) { [weak self] in
            // load more videos from genre id
            var currentPage = self?.CURRENT_PAGE ?? 0
            currentPage = currentPage + 1
            print("load more vertically from page \(currentPage) ...")
            self?.getVideos(page: currentPage)
            
            completion(true)
        }
    }
    
}


// MARK: - UICollectionView Data Source
extension MoreVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(indexPath: indexPath) as MovieCell
        cell.backgroundColor = Color.secondary
        cell.video = videos[indexPath.item]
        return cell
    }
}


// MARK: - UICollectionView Delegate
extension MoreVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = videos[indexPath.item]
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! VideoPlayerVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.video = movie
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



