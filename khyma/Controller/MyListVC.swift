//
//  FavouriteVC.swift
//  khyma
//
//  Created by Belal Samy on 20/09/2021.
//

import UIKit
import GoogleMobileAds
import DesignX

class MyListVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var myListCollectionView: UICollectionView!

    //MARK: - variables
    
    var videos = Defaults.savedVideos()
    var indexPath = 0
    
    let emptyImage = UIImageView()
    
    // The banner ad
    private var bannerAd: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.MyListVCbannerUP
      banner.load(GADRequest())
      return banner
    }()
    
    
    //MARK: - constants
    
    
    //MARK: - lifecylce
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // nav bar
        setupNavBar()
        
        videos = Defaults.savedVideos()
        myListCollectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    override func viewDidLayoutSubviews() {
        // nav bar
        setupNavBar()
        
        videos = Defaults.savedVideos()
        myListCollectionView.reloadData()
        
        // empty image
        hideOrShowEmptyImage()
    }
    
    
    //MARK: - functions
    fileprivate func setupViews() {
        view.backgroundColor = Color.primary
        
        // banner Ad
        loadBannerAd()
        
        // nav bar
        setupNavBar()
        
        // list collection view
        myListCollectionView.backgroundColor = Color.primary
        myListCollectionView.layout(shortcut: .fillToSafeArea(nil, 60, nil, 0))
        
        myListCollectionView.delegate = self
        myListCollectionView.dataSource = self
        myListCollectionView.register(cell: MovieCell.self)
        myListCollectionView.reloadData()
        
        // empty image
        hideOrShowEmptyImage()
        
        // long press gesture
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        myListCollectionView.addGestureRecognizer(gesture)
    }
    
    fileprivate func setupNavBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = StringsKeys.myList.localized
    }
        
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer ) {
        print("Captured Long Press")
        let location = gesture.location(in: myListCollectionView)
        guard let selectedIndexPath = myListCollectionView.indexPathForItem(at: location) else { return }
        print(selectedIndexPath )
        
        let selectedMovie = self.videos[selectedIndexPath.item]
        print(selectedMovie ?? "")
        
        let alertTitle = StringsKeys.removeFromMyList.localized
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: StringsKeys.removeAlertAction.localized, style: .destructive, handler: { (_) in
            
            self.videos.remove(at: selectedIndexPath.item)
            self.myListCollectionView.deleteItems(at: [selectedIndexPath])
            Defaults.deleteVideos(video: selectedMovie)
            self.myListCollectionView.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(title: StringsKeys.cancelAlert.localized, style: .cancel ))
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func hideOrShowEmptyImage() {
        view.addSubview(emptyImage)
        emptyImage.layout(X: .center(nil), W: .fixed(200), Y: .center(nil), H: .fixed(200))
        emptyImage.image = UIImage(named: "icon-empty")
        emptyImage.alpha = 0.50
        emptyImage.isHidden = videos.count == 0 ? false : true
    }
    
    fileprivate func loadBannerAd() {
       bannerAd.rootViewController = self
       view.addSubview(bannerAd)
       bannerAd.layout(XW: .leadingAndCenter(nil, 0), Y: .topToSafeArea(nil, 0), H: .fixed(60))
    }
    
}


//MARK: - extensions


// MARK: - UICollectionView Data Source
extension MyListVC: UICollectionViewDataSource {

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
extension MyListVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (videos[indexPath.item] as? Series) != nil {
            // series
            let series = videos[indexPath.item]
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
extension MyListVC: UICollectionViewDelegateFlowLayout {
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

