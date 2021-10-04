//
//  MoviesVC.swift
//  khyma
//
//  Created by Belal Samy on 22/09/2021.
//

import Network
import DesignX
import GoogleMobileAds

class MoviesVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var moviesScrollView: UIScrollView!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var moviesTableView: UITableView!

    @IBOutlet weak var moviesSliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    
    //MARK: - variables
    
    // The banner ad
    private var bannerAd: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.banner
      banner.load(GADRequest())
      return banner
    }()
    
    var sliderTimer: Timer?
    var counter = 0
    
    var timerState = TimerState.notStarted

        
    //MARK: - constants
    
    // check network
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    // Timer state
    enum TimerState {
      case notStarted
      case playing
      case delaying
      case ended
    }
    
    let customNavBar = BackNavBar()
    
    let movies = [Video(name: StringsKeys.bodyGuard.localized,
                        posterUrl: "poster-movie-1",
                        youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                  
                  Video(name: StringsKeys.avengers.localized,
                        posterUrl: "poster-movie-2",
                        youtubeUrl: "https://www.youtube.com/watch?v=dEiS_WpFuc0"),
                  
                  Video(name: StringsKeys.weladRizk.localized,
                        posterUrl: "poster-movie-3",
                        youtubeUrl: "https://www.youtube.com/watch?v=hqkSGmqx5tM"),
                  
                  Video(name: StringsKeys.batman.localized,
                        posterUrl: "poster-movie-4",
                        youtubeUrl: "https://www.youtube.com/watch?v=OEqLipY4new&list=PLRYXdAxk10I4rWNxWyelz7cXyGR94Q0eY"),
                  
                  Video(name: StringsKeys.blueElephant.localized,
                        posterUrl: "poster-movie-5",
                        youtubeUrl: "https://www.youtube.com/watch?v=miH5SCH9at8")]

    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        // check connection
        checkConnection()
        
        // stop timer when application is backgrounded.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        // start timer when application is returned to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check connection
        checkConnection()
        
        moviesSliderCollectionView.reloadData()
        addCustomNavBar()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customNavBar.removeFromSuperview()
        timerState = .ended
    }
    
    override func viewDidLayoutSubviews() {
        moviesSliderCollectionView.reloadData()
    }

    
    //MARK: - functions
    
    fileprivate func checkConnection() {
        self.monitor.pathUpdateHandler = { [weak self] pathUpdateHandler in
           if pathUpdateHandler.status == .satisfied {
               print("Internet connection is on.")
           } else {
                print("There's no internet connection.")
                DispatchQueue.main.async {
                let noConnection = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NoConnectionVC") as! NoConnectionVC
                noConnection.modalPresentationStyle = .fullScreen
                    self?.present(noConnection, animated: true)
               }
           }
        }
        self.monitor.start(queue: self.queue)
    }
    
    fileprivate func setupViews() {
        loadBannerAd()

        // navigation bar
        navigationItem.largeTitleDisplayMode = .never
        addCustomNavBar()
        
        // tab bar
        UITabBar.appearance().tintColor = Color.text

        // scroll
        moviesScrollView.create(container: scrollContainer)

        moviesScrollView.backgroundColor = Color.primary
        scrollContainer.backgroundColor = Color.primary
        
        // posters slider
        moviesSliderCollectionView.backgroundColor = Color.primary
        moviesSliderCollectionView.delegate = self
        moviesSliderCollectionView.dataSource = self
        moviesSliderCollectionView.isPagingEnabled = true
        
        moviesSliderCollectionView.register(cell: MainSliderCell.self)
        moviesSliderCollectionView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomAndHeight(nil, 0, moviesTableView, 0, .fixed(500)))
        moviesSliderCollectionView.reloadData()

        // pager
        pageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(moviesSliderCollectionView, -75), H: .fixed(50))
        pageView.numberOfPages = movies.count
        pageView.currentPage = 0
        
        startTimer()
        
        // table view
        moviesTableView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomToSafeAreaAndHeight(moviesSliderCollectionView, 0, nil, 0, .fixed(1450)))
        moviesTableView.backgroundColor = Color.primary
        
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        moviesScrollView.delegate = self
        
    }
    
    fileprivate func startTimer() {
        // timer
        timerState = .playing
        self.sliderTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: true)
    }
    
    
    @objc func timerTick() {
        if timerState == .playing {
            slideImage()
        } else if timerState == .delaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { self.timerState = .playing } // delay slide image after 10 seconds
        } else {
            endTimer()
        }
    }
    
    
    fileprivate func slideImage() {
         if counter < movies.count {
             let index = IndexPath.init(item: counter, section: 0)
             self.moviesSliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
             pageView.currentPage = counter
             counter += 1
         } else {
             counter = 0
             let index = IndexPath.init(item: counter, section: 0)
             self.moviesSliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
             pageView.currentPage = counter
         }
        print("movies slider => \(counter)")
    }
    
    
    fileprivate func endTimer() {
        timerState = .ended
        sliderTimer?.invalidate()
        sliderTimer = nil
    }
    
    // stop timer in background and start again when comeback
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        timerState = .ended
    }

    @objc func applicationDidBecomeActive(_ notification: Notification) {
        timerState = .playing
    }
    
    fileprivate func addCustomNavBar() {
        customNavBar.delegate = self // custom delegation pattern
        customNavBar.backLabel.text = StringsKeys.movies.localized
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(customNavBar)
        customNavBar.layout(X: .center(nil), W: .equal(nil, 0.9), Y: .center(nil), H: .fixed(50))
    }
    
    @objc fileprivate func handleMoreTapped() {
        print("more tapped ...")
        let moreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MoreRootVC") as! UINavigationController
        moreVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(moreVC, animated: true, completion: nil)
    }
    
    fileprivate func loadBannerAd() {
       bannerAd.rootViewController = self
       view.addSubview(bannerAd)
       bannerAd.layout(XW: .leadingAndCenter(nil, 0), Y: .bottomToSafeArea(nil, 0), H: .fixed(60))
    }

    
    
    //MARK: - actions
    
    
}


//MARK: - extensions

//MARK: - CustomNavBar Delegate
extension MoviesVC: BackNavBarDelegate {
    // custom delegation pattern
    func handleBackTapped() {
        print("back tapped here from movies vc")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UIScrollView Delegate
extension MoviesVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("delay timer when end dragging")
        timerState = .delaying
       self.navigationController?.setNavigationBarHidden(velocity.y > 0, animated: true)
    }
}


// MARK: - UITableView Data Source
extension MoviesVC: UITableViewDataSource {

    // section
     func numberOfSections(in _: UITableView) -> Int {
        return MoviesTableSections.allCases.count
    }
    
    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
       let section = MoviesTableSections.allCases[section]
        return section.ui.sectionTitle
   }

    // row
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let section = TableSections.allCases[indexPath.section]
        var cell = tableView.dequeueReusableCell(withIdentifier: MainTableCell.identifier) as? MainTableCell
        
        if cell == nil {
            cell = MainTableCell(style: .default, reuseIdentifier: MainTableCell.identifier)
            cell?.collectionFlowLayout.scrollDirection = .horizontal
            cell?.selectionStyle = .none
        }
        return cell!
    }
}


// MARK: - UITableView Delegate
extension MoviesVC: UITableViewDelegate {
    
    // section
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
       return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // let currentSection = MoviesTableSections.allCases[section]
         let headerView = UIView()

         let sectionLabel = UILabel()
         headerView.addSubview(sectionLabel)

         sectionLabel.layout(X: .leading(nil, 8), W: .wrapContent, Y: .top(nil, 8), H: .fixed(20))
         sectionLabel.font = UIFont.boldSystemFont(ofSize: 18)
         sectionLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
         sectionLabel.textColor = Color.text
          
          let moreBtn = UIButton()
          headerView.addSubview(moreBtn)
          
          moreBtn.layout(X: .trailing(nil, 8), W: .wrapContent, Y: .top(nil, 8), H: .fixed(20))
          moreBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
          moreBtn.setTitle(StringsKeys.more.localized, for: .normal)
          moreBtn.setTitleColor(Color.secondary, for: .normal)
          moreBtn.titleLabel?.textAlignment = .center
          moreBtn.addTarget(self, action: #selector(handleMoreTapped), for: .touchUpInside)

         return headerView
    }
    
    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
       return 0
    }
    
     // row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = MoviesTableSections.allCases[indexPath.section]
        return section.ui.sectionHeight
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       guard let cell: MainTableCell = cell as? MainTableCell else { return }
       cell.setCollectionView(dataSource: self, delegate: self, indexPath: indexPath)
    }
}


// MARK: - UICollectionView Data Source
extension MoviesVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // let section = MoviesTableSections.allCases[collectionView.tag]
        
        if collectionView == moviesSliderCollectionView {
            return movies.count
        }

        return movies.count
        }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // let section = MoviesTableSections.allCases[collectionView.tag]
        
        if collectionView == moviesSliderCollectionView {
            let cell3 = collectionView.dequeue(indexPath: indexPath) as MainSliderCell
            cell3.backgroundColor = Color.secondary
            cell3.video = movies[indexPath.item]
            return cell3
        }

        let cell1 = collectionView.dequeue(indexPath: indexPath) as MovieCell
        cell1.backgroundColor = Color.secondary
        cell1.video = movies[indexPath.item]
        return cell1
   
    }
}


// MARK: - UICollectionView Delegate
extension MoviesVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == moviesSliderCollectionView {
            if pageView.currentPage == indexPath.row {
                guard let visible = moviesSliderCollectionView.visibleCells.first else { return }
                guard let index = moviesSliderCollectionView.indexPath(for: visible)?.row else { return }
                counter = index
                pageView.currentPage = counter
            }
        }
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // section
        let section = MoviesTableSections.allCases[collectionView.tag]
        print("section : \(section.ui.sectionTitle) => \(indexPath.item)")
        
        // movie
        let movie = movies[indexPath.item]
        
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.video = movie
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}


// MARK: - UICollectionViewDelegate Flow Layout
extension MoviesVC: UICollectionViewDelegateFlowLayout {
    // section
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        if collectionView == moviesSliderCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        if collectionView == moviesSliderCollectionView {
            return 0
        }
        return 10 // vertical spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0 // horizontal spacing
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        // let section = MoviesTableSections.allCases[collectionView.tag]
        
        if collectionView == moviesSliderCollectionView {
            let size = moviesSliderCollectionView.frame.size
            return CGSize(width: size.width, height: size.height)
        }
        
      
            return collectionView.size(rows: 1, columns: 3.5)
        
    }
}
