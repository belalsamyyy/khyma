//
//  HomeVC.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import GoogleMobileAds
import DesignX

class MainVC: UIViewController {

    //MARK: - outlets
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    
    //MARK: - variables
        
    // The banner ad
    private var bannerAd: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.banner
      banner.load(GADRequest())
      banner.backgroundColor = .lightGray
      return banner
    }()
    
    var timer = Timer()
    var counter = 0

        
    //MARK: - constants
    
    let continueWatching = [Movie(name: "Body Guard", poster: UIImage(named: "poster-movie-1")!),
                            Movie(name: "Avengers: End Game", poster: UIImage(named: "poster-movie-2")!),
                            Movie(name: "Welad Rizk 2", poster: UIImage(named: "poster-movie-3")!),
                            Movie(name: "Batman Hush", poster: UIImage(named: "poster-movie-4")!)]
       
    let movies = [Movie(name: "BodyGuard", poster: UIImage(named: "poster-movie-1")!),
                  Movie(name: "Avengers: End Game", poster: UIImage(named: "poster-movie-2")!),
                  Movie(name: "Welad Rizk 2", poster: UIImage(named: "poster-movie-3")!),
                  Movie(name: "Batman Hush", poster: UIImage(named: "poster-movie-4")!),
                  Movie(name: "Blue Elephant 2", poster: UIImage(named: "poster-movie-5")!)]

    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadBannerAd()
    }
    
    override func viewDidLayoutSubviews() {
        sliderCollectionView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)

            switch traitCollection.userInterfaceStyle {
                case .dark:
                    darkModeEnabled()   // Switch to dark mode colors, etc.
                case .light:
                    fallthrough
                case .unspecified:
                    fallthrough
                default:
                    lightModeEnabled()   // Switch to light mode colors, etc.
            }
        }
    
    //MARK: - functions
    
    fileprivate func setupViews() {
        
        // navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // tab bar
        UITabBar.appearance().tintColor = .white

        // scroll
        mainScrollView.create(container: scrollContainer)

        mainScrollView.backgroundColor = Color.primary
        scrollContainer.backgroundColor = Color.primary
        
        // posters slider
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        
        sliderCollectionView.register(cell: CollectionCell3.self)
        sliderCollectionView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomAndHeight(nil, 0, mainTableView, 0, .fixed(500)))
        
        // pager
        pageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(sliderCollectionView, -75), H: .fixed(50))
        pageView.numberOfPages = movies.count
        pageView.currentPage = 0
        
        // timer
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.slideImage), userInfo: nil, repeats: true)
        }
        
        // table view
        mainTableView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomToSafeAreaAndHeight(sliderCollectionView, 0, nil, 0, .fixed(1600)))
        mainTableView.backgroundColor = Color.primary
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainScrollView.delegate = self
        
    }
    
    @objc func slideImage() {
         if counter < movies.count {
             let index = IndexPath.init(item: counter, section: 0)
             self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
             pageView.currentPage = counter
             counter += 1
         } else {
             counter = 0
             let index = IndexPath.init(item: counter, section: 0)
             self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
             pageView.currentPage = counter
             counter = 1
         }
        print("image slider => \(counter)")
    }
    
    fileprivate func lightModeEnabled() {
        print("dark mode")
        sliderCollectionView.reloadData()
    }
    
    fileprivate func darkModeEnabled() {
        print("light mode")
        sliderCollectionView.reloadData()
    }
    
    fileprivate func loadBannerAd() {
           bannerAd.rootViewController = self
           scrollContainer.addSubview(bannerAd)
           bannerAd.layout(XW: .leadingAndCenter(nil, 0), Y: .bottomToSafeArea(nil, 0), H: .fixed(60))
    }
    
    
    //MARK: - actions
    
    
}


//MARK: - extensions

//MARK: - UIScrollView Delegate

extension MainVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.navigationController?.setNavigationBarHidden(velocity.y < 0, animated: true)
    }
}


// MARK: - UITableView Data Source

extension MainVC: UITableViewDataSource {

    // section
     func numberOfSections(in _: UITableView) -> Int {
        return TableSections.allCases.count
    }
    
    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
       let section = TableSections.allCases[section]
        return section.ui.sectionTitle
   }

    // row
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let section = TableSections.allCases[indexPath.section]
        var cell = tableView.dequeueReusableCell(withIdentifier: TableCell.identifier) as? TableCell
        
        if cell == nil {
            cell = TableCell(style: .default, reuseIdentifier: TableCell.identifier)
            cell?.collectionFlowLayout.scrollDirection = .horizontal
            cell?.selectionStyle = .none
        }
        return cell!
    }
}


// MARK: - UITableView Delegate
extension MainVC: UITableViewDelegate {
    
    // section
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
       return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()

       let myLabel = UILabel()
       myLabel.frame = CGRect(x: 20, y: 8, width: 320, height: 30)
       myLabel.font = UIFont.boldSystemFont(ofSize: 18)
       myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
       myLabel.textColor = Color.text

       headerView.addSubview(myLabel)

       return headerView
    }
    
    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
       return 0
    }
    
     // row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = TableSections.allCases[indexPath.section]
        return section.ui.sectionHeight
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       guard let cell: TableCell = cell as? TableCell else { return }
       cell.setCollectionView(dataSource: self, delegate: self, indexPath: indexPath)
    }
}


// MARK: - UICollectionView Data Source
extension MainVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = TableSections.allCases[collectionView.tag]
        
        if collectionView == sliderCollectionView {
            return movies.count
        }
        
        switch section {
        case .continueWatching:
            return 4
            
        case .popular, .Movies, .Series, .Plays, .games:
            return movies.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = TableSections.allCases[collectionView.tag]
        
        if collectionView == sliderCollectionView {
            let cell3 = collectionView.dequeue(indexPath: indexPath) as CollectionCell3
            cell3.backgroundColor = .blue
            cell3.movie = movies[indexPath.item]
            return cell3
        }
        
        switch section {
        case .popular, .Movies, .Series, .Plays, .games:
            let cell1 = collectionView.dequeue(indexPath: indexPath) as CollectionCell
            cell1.backgroundColor = Color.secondary
            cell1.movie = movies[indexPath.item]
            return cell1
            
        case .continueWatching:
            let cell2 = collectionView.dequeue(indexPath: indexPath) as CollectionCell2
            cell2.backgroundColor = Color.secondary
            cell2.movie = continueWatching[indexPath.item]
            return cell2
        }
   
    }
}


// MARK: - UICollectionView Delegate
extension MainVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // section
        let section = TableSections.allCases[collectionView.tag]
        print("section : \(section.ui.sectionTitle) => \(indexPath.item)")
        
        // movie
        let movie = movies[indexPath.item]
        
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.youtubeID = movie.youtubeUrl.youtubeID
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}


// MARK: - UICollectionViewDelegate Flow Layout
extension MainVC: UICollectionViewDelegateFlowLayout {
    // section
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        if collectionView == sliderCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
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
        let section = TableSections.allCases[collectionView.tag]
        
        if collectionView == sliderCollectionView {
            let size = sliderCollectionView.frame.size
            return CGSize(width: size.width, height: size.height)
        }
        
        switch section {
        case .continueWatching:
            return collectionView.size(rows: 1, columns: 1.25)
      
        case .popular, .Movies, .Series, .Plays, .games:
            return collectionView.size(rows: 1, columns: 3.5)
        }
        
    }
}
