//
//  MoviesVC.swift
//  khyma
//
//  Created by Belal Samy on 22/09/2021.
//

import Network
import DesignX
import GoogleMobileAds
import SimpleAPI

class MoviesVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var moviesScrollView: UIScrollView!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var moviesTableView: MainTableView!

    @IBOutlet weak var moviesSliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    
    //MARK: - variables
    
    // The banner ad
    private var bannerAd1: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.MoviesVCbannerUP
      banner.load(GADRequest())
      return banner
    }()
    
    private var bannerAd2: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.MoviesVCbannerDown
      banner.load(GADRequest())
      return banner
    }()
    
    var sliderTimer: Timer?
    var counter = 0
    
    var timerState = TimerState.notStarted
    
    // pagination
    var CURRENT_TABLE_SECTION: Int?
    var CURRENT_GENRE_ID: String?
    var POPULAR_CURRENT_PAGE = 0

        
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
    
    var genres = [Genre?]()
    var movies = [Movie?]()
    var moviesDict = [String: [Movie?]]()
    var pagesDict = [String: Int]()

    var sliderVideos = [Movie?]()

    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        // check connection
        checkConnection()
        
        // API
        getGenres()
        getVideos(page: 1)
        
        // stop timer when application is backgrounded.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        // start timer when application is returned to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check connection
        checkConnection()
    
        moviesSliderCollectionView.reloadData()
        moviesTableView.reloadData()
        startTimer()

        addCustomNavBar()
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
    
    
    
    fileprivate func getGenres() {
        Genre.endpoint = Endpoints.genres
        API<Genre>.list { [weak self] result in
            switch result {
            case .success(let data):
                self?.genres = data
                data.forEach { genre in
                    var currentPage = self?.pagesDict[genre?._id ?? ""] ?? 0
                    currentPage = 1
                    self?.getVideos(page: currentPage, genreID: genre?._id ?? "")
                }
                DispatchQueue.main.async {
                    self?.moviesSliderCollectionView.reloadData()
                    self?.moviesTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    fileprivate func getVideos(page: Int, genreID: String) {
        pagesDict[genreID] = page
        Video.endpoint = "\(Defaults.BASE_URL)\(CategoryName.movies)/genre/\(genreID)/\(page)"
        API<Movie>.list { [weak self] result in
            switch result {
            case .success(let data):
                if page == 1 {
                    self?.moviesDict[genreID] = data
                } else {
                    self?.moviesDict[genreID]?.append(contentsOf: data)
                }
                DispatchQueue.main.async {
                    if page == 1 {
                        self?.moviesTableView.reloadData()
                    } else {
                        let currentSection = IndexPath(row: 0, section: self?.CURRENT_TABLE_SECTION ?? 0)
                        if let cell = self?.moviesTableView.cellForRow(at: currentSection) as? MainTableCell { cell.collectionView.reloadData() }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    fileprivate func getVideos(page: Int) {
        POPULAR_CURRENT_PAGE = page
        Movie.endpoint = "\(Defaults.BASE_URL)\(CategoryName.movies)?page=\(POPULAR_CURRENT_PAGE)&nameEn=&nameAr="
        API<Movie>.list { [weak self] result in
            switch result {
            case .success(let data):
                
                if page == 1 {
                    self?.sliderVideos = Array(data.shuffled().prefix(5))
                    self?.movies = data
                } else {
                    self?.movies.append(contentsOf: data)
                }
                
                DispatchQueue.main.async {
                    self?.pageView.numberOfPages = self?.sliderVideos.count ?? 0
                    self?.moviesSliderCollectionView.reloadData()
                    self?.startTimer()
                    
                    if page == 1 {
                        self?.moviesTableView.reloadData()
                    } else {
                        let currentSection = IndexPath(row: 0, section: self?.CURRENT_TABLE_SECTION ?? 0)
                        if let cell = self?.moviesTableView.cellForRow(at: currentSection) as? MainTableCell { cell.collectionView.reloadData() }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
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
        moviesSliderCollectionView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomAndHeight(nil, 60, moviesTableView, 0, .fixed(UIDevice.current.userInterfaceIdiom != .pad ? 600 : 1000)))
        moviesSliderCollectionView.reloadData()

        // pager
        pageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(moviesSliderCollectionView, -75), H: .fixed(50))
        // pageView.numberOfPages = movies.count
        pageView.currentPage = 0
        pageView.currentPageIndicatorTintColor = .white
                
        // table view
        moviesTableView.backgroundColor = Color.primary
        moviesTableView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomBothToSafeArea(moviesSliderCollectionView, 0, nil, 0))
        self.moviesTableView.reloadData()
        self.moviesTableView.layoutIfNeeded()
        
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        moviesScrollView.delegate = self
        
    }
    
    fileprivate func startTimer() {
        // timer
        if counter < sliderVideos.count {
        timerState = .playing
        self.sliderTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: true)
        }
    }
    
    
    @objc func timerTick() {
        if timerState == .playing {
            slideImage()
        } else if timerState == .delaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.timerState = .playing }
        } else {
            endTimer()
        }
    }
    
    
    fileprivate func slideImage() {
         if counter < sliderVideos.count {
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
    
    @objc fileprivate func handleMoreTapped(sender: MoreBtn) {
        print("more tapped ...")
        let genreID = sender.genreId
        let genreName = sender.genreName

        let moreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MoreVC") as! MoreVC
        moreVC.modalPresentationStyle = .fullScreen
        moreVC.genreID = genreID
        moreVC.genreName = genreName
        moreVC.categoryName = CategoryName.movies
        self.navigationController?.pushViewController(moreVC, animated: true)
    }
    
    fileprivate func loadBannerAd() {
       bannerAd1.rootViewController = self
       scrollContainer.addSubview(bannerAd1)
       bannerAd1.layout(XW: .leadingAndCenter(nil, 0), Y: .topToSafeArea(nil, 0), H: .fixed(60))
        
       bannerAd2.rootViewController = self
       view.addSubview(bannerAd2)
       bannerAd2.layout(XW: .leadingAndCenter(nil, 0), Y: .bottomToSafeArea(nil, 0), H: .fixed(60))
    }

    
    
    //MARK: - actions
    
    
}


//MARK: - extensions

extension MoviesVC: HorizontalPaginationManagerDelegate {
    
    func loadMore(completion: @escaping (Bool) -> Void) {
        refreshDelay(2.0) { [weak self] in
            // load more
            
            if self?.CURRENT_GENRE_ID == "" {
                //  popular videos
                var currentPage = self?.POPULAR_CURRENT_PAGE ?? 0
                currentPage = currentPage + 1
                print("load more for popular movies from page \(currentPage) ...")
                self?.getVideos(page: currentPage)
                
            } else {
                // load more videos from genre id
                var currentPage = self?.pagesDict[self?.CURRENT_GENRE_ID ?? ""] ?? 0
                currentPage = currentPage + 1
                print("load more for genre id \"\(self?.CURRENT_GENRE_ID ?? "")\" from page \(currentPage) ...")
                self?.getVideos(page: currentPage, genreID: self?.CURRENT_GENRE_ID ?? "")
            }
            
            completion(true)
        }
    }
    
}

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
        return 1 + genres.count
    }
    
    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return StringsKeys.popular.localized
        } else {
            let genre = genres[section - 1]
            return Language.currentLanguage == Lang.english.rawValue ? genre?.en_name : genre?.ar_name
        }
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
    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return movies.count == 0 ? CGFloat.leastNonzeroMagnitude : 50
        } else {
            let genre = genres[section - 1]
            let filteredVideos = movies.filter { $0?.genreId == genre?._id }
            return filteredVideos.count == 0 ? CGFloat.leastNonzeroMagnitude : 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let sectionLabel = UILabel()
        headerView.addSubview(sectionLabel)
        sectionLabel.layout(X: .leading(nil, 15), W: .wrapContent, Y: .top(nil, 8), H: .fixed(20))
        sectionLabel.font = UIFont.boldSystemFont(ofSize: UIDevice.current.userInterfaceIdiom != .pad ? 18 : 25)
        
        let moreBtn = MoreBtn()
        headerView.addSubview(moreBtn)
        moreBtn.layout(X: .trailing(nil, 15), W: .wrapContent, Y: .top(nil, 8), H: .fixed(20))
        moreBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIDevice.current.userInterfaceIdiom != .pad ? 18 : 25)
        moreBtn.setTitle(StringsKeys.more.localized, for: .normal)
        moreBtn.setTitleColor(Color.secondary, for: .normal)
        moreBtn.titleLabel?.textAlignment = .center
        moreBtn.addTarget(self, action: #selector(handleMoreTapped), for: .touchUpInside)
        
       switch section {
       case 0:
           sectionLabel.text = movies.count == 0 ? "" : self.tableView(tableView, titleForHeaderInSection: section)
           moreBtn.isHidden = true
       default:
           let genre = genres[section - 1]
           let filteredVideos = movies.filter { $0?.genreId == genre?._id }
           sectionLabel.text = filteredVideos.count == 0 ? "" : self.tableView(tableView, titleForHeaderInSection: section)
           moreBtn.genreId = genre?._id
           moreBtn.genreName = Language.currentLanguage == Lang.english.rawValue ? genre?.en_name : genre?.ar_name
           moreBtn.isHidden = filteredVideos.count < 4 ? true : false
       }
       return headerView
    }
    
    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
       return 0
    }
    
     // row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return movies.count == 0 ? CGFloat.leastNonzeroMagnitude : (UIDevice.current.userInterfaceIdiom != .pad ? 200 : 300)
        } else {
            let genre = genres[indexPath.section - 1]
            let filteredVideos = movies.filter { $0?.genreId == genre?._id }
            return filteredVideos.count == 0 ? CGFloat.leastNonzeroMagnitude : (UIDevice.current.userInterfaceIdiom != .pad ? 200 : 300)
        }
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       guard let cell: MainTableCell = cell as? MainTableCell else { return }
       cell.setCollectionView(dataSource: self, delegate: self, indexPath: indexPath)
        
        // pagination
        cell.paginagationManager.delegateH = self
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
        let sectionIndex = collectionView.tag
        
        if collectionView == moviesSliderCollectionView {
            return sliderVideos.count
        }
        
        switch sectionIndex {
        case 0:
            // popular
            let popularVideos = Array(movies.prefix(20))
            return popularVideos.count
        default:
            // genre
            let genre = genres[collectionView.tag - 1]
            let videosFromGenreID = moviesDict[genre?._id ?? ""] ?? []
            return videosFromGenreID.count == 0 ? 0 : videosFromGenreID.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionIndex = collectionView.tag
        CURRENT_TABLE_SECTION = collectionView.tag

        if collectionView == moviesSliderCollectionView {
            let cell3 = collectionView.dequeue(indexPath: indexPath) as MainSliderCell
            cell3.backgroundColor = Color.secondary
            cell3.video = sliderVideos[indexPath.item]
           return cell3
        }
        
        switch sectionIndex {
        case 0:
            // popular
            let popularVideos = Array(movies.prefix(20))
            let cell1 = collectionView.dequeue(indexPath: indexPath) as MovieCell
            cell1.backgroundColor = Color.secondary
            cell1.video = popularVideos[indexPath.item]
            return cell1
        default:
            // genre
            let genre = genres[collectionView.tag - 1]
            let videosFromGenreID = moviesDict[genre?._id ?? ""] ?? []

            let cell4 = collectionView.dequeue(indexPath: indexPath) as MovieCell
            cell4.backgroundColor = Color.secondary
            cell4.video = videosFromGenreID[indexPath.item]
            cell4.genreID = genre?._id
            return cell4
        }
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
        } else {
            guard let cell = collectionView.visibleCells.first as? MovieCell else { return }
            CURRENT_GENRE_ID = cell.genreID ?? ""
        }
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // section
        let sectionIndex = collectionView.tag
        
        if collectionView == moviesSliderCollectionView {
            // posters sliders
            let video = sliderVideos[indexPath.item]
            let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! VideoPlayerVC
            detailsVC.modalPresentationStyle = .fullScreen
            detailsVC.video = video
            detailsVC.watchableType = .movie
            self.navigationController?.pushViewController(detailsVC, animated: true)
        } else {
            switch sectionIndex {
            case 0:
                let popularVideos = Array(movies.prefix(20))
                print("section : \(StringsKeys.popular.localized) => \(indexPath.item)")
                let video = popularVideos[indexPath.item]
                let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! VideoPlayerVC
                detailsVC.modalPresentationStyle = .fullScreen
                detailsVC.video = video
                detailsVC.watchableType = .movie
                self.navigationController?.pushViewController(detailsVC, animated: true)
            default:
                // other genre from api
                let genre = genres[collectionView.tag - 1]
                let videosFromGenreID = moviesDict[genre?._id ?? ""] ?? []
                print("genre : \(genre?.en_name ?? "") => \(indexPath.item)")

                let video = videosFromGenreID[indexPath.item]
                let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! VideoPlayerVC
                detailsVC.modalPresentationStyle = .fullScreen
                detailsVC.video = video
                detailsVC.watchableType = .movie

                self.navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
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
        
        return collectionView.size(rows: 1, columns: UIDevice.current.userInterfaceIdiom != .pad ? 3.5 : 5.5)

    }
}
