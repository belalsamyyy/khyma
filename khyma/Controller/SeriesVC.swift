//
//  SeriesVC.swift
//  khyma
//
//  Created by Belal Samy on 22/09/2021.
//

import Network
import DesignX
import GoogleMobileAds
import SimpleAPI

class SeriesVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var seriesScrollView: UIScrollView!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var seriesTableView: MainTableView!
    
    @IBOutlet weak var seriesSliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    
    //MARK: - variables
    
    // The banner ad
    private var bannerAd1: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.SeriesVCbannerUP
      banner.load(GADRequest())
      return banner
    }()
    
    private var bannerAd2: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.SeriesVCbannerDown
      banner.load(GADRequest())
      return banner
    }()
    
    var sliderTimer: Timer?
    var counter = 0
    
    var timerState = TimerState.notStarted
    
    // pagination
    var currentCell = MainTableCell()
    var CURRENT_PAGE = 1

        
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
    
    // series -> seasons -> episodes
    var genres = [Genre?]()
    var series = [Series?]()
    var seriesDict = [String: [Series?]]()
    var sliderVideos = [Series?]()
    
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
        seriesSliderCollectionView.reloadData()
        startTimer()

        addCustomNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customNavBar.removeFromSuperview()
        timerState = .ended
    }
    
    override func viewDidLayoutSubviews() {
        seriesSliderCollectionView.reloadData()
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
                    print(genre?.ar_name ?? "")
                    self?.getVideos(page: 1, genreID: genre?._id ?? "")
                }
                DispatchQueue.main.async {
                    self?.seriesSliderCollectionView.reloadData()
                    self?.seriesTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    fileprivate func getVideos(page: Int, genreID: String) {
        CURRENT_PAGE = page
        Video.endpoint = "\(BASE_URL)/api/\(CategoryName.series)/genre/\(genreID)/\(CURRENT_PAGE)"
        API<Series>.list { [weak self] result in
            switch result {
            case .success(let data):
                //self?.seriesDict[genreID] = data
                if self?.CURRENT_PAGE == 1 {
                    self?.seriesDict[genreID] = data
                } else {
                    self?.seriesDict[genreID]?.append(contentsOf: data)
                }
                DispatchQueue.main.async {
                    self?.seriesSliderCollectionView.reloadData()
                    self?.seriesTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    fileprivate func getVideos(page: Int) {
        Series.endpoint = "\(BASE_URL)/api/\(CategoryName.series)?page=\(page)&nameEn=&nameAr="
        API<Series>.list { [weak self] result in
            switch result {
            case .success(let data):
//                self?.series = Array(data.prefix(50))
//                self?.sliderVideos = Array(data.shuffled().prefix(5))
                
                if page == 1 {
                    self?.sliderVideos = Array(data.shuffled().prefix(5))
                    self?.series = data
                } else {
                    self?.series.append(contentsOf: data)
                }
                
                DispatchQueue.main.async {
                    self?.pageView.numberOfPages = self?.sliderVideos.count ?? 0
                    self?.seriesSliderCollectionView.reloadData()
                    self?.startTimer()
                    self?.seriesTableView.reloadData()
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
        seriesScrollView.create(container: scrollContainer)

        seriesScrollView.backgroundColor = Color.primary
        scrollContainer.backgroundColor = Color.primary
        
        // posters slider
        seriesSliderCollectionView.backgroundColor = Color.primary
        seriesSliderCollectionView.delegate = self
        seriesSliderCollectionView.dataSource = self
        seriesSliderCollectionView.isPagingEnabled = true

        seriesSliderCollectionView.register(cell: MainSliderCell.self)
        seriesSliderCollectionView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomAndHeight(nil, 60, seriesTableView, 0, .fixed(600)))
        seriesSliderCollectionView.reloadData()

        // pager
        pageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(seriesSliderCollectionView, -75), H: .fixed(50))
        pageView.numberOfPages = series.count
        pageView.currentPage = 0
                
        // table view
        seriesTableView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomBothToSafeArea(seriesSliderCollectionView, 0, nil, 0))
        seriesTableView.backgroundColor = Color.primary
        
        seriesTableView.delegate = self
        seriesTableView.dataSource = self
        seriesScrollView.delegate = self
        
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
             self.seriesSliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
             pageView.currentPage = counter
             counter += 1
         } else {
             counter = 0
             let index = IndexPath.init(item: counter, section: 0)
             self.seriesSliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
             pageView.currentPage = counter
         }
        print("series slider => \(counter)")
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
        customNavBar.backLabel.text = StringsKeys.series.localized
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
        moreVC.categoryName = CategoryName.series
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

extension SeriesVC: HorizontalPaginationManagerDelegate {
    
    func refreshAll(completion: @escaping (Bool) -> Void) {
        refreshDelay(1.0) {
            // refresh all
            print("refresh all ...")
            self.CURRENT_PAGE = 1
            self.getVideos(page: self.CURRENT_PAGE)
            self.currentCell.collectionView.reloadData()
            completion(true)
        }
    }
    
    func loadMore(completion: @escaping (Bool) -> Void) {
        refreshDelay(1.0) {
            // load more
            print("load more ...")
            self.CURRENT_PAGE = self.CURRENT_PAGE + 1
            self.getVideos(page: self.CURRENT_PAGE)
            self.currentCell.collectionView.reloadData()
            completion(true)
        }
    }
    
}

//MARK: - CustomNavBar Delegate

extension SeriesVC: BackNavBarDelegate {
    // custom delegation pattern
    func handleBackTapped() {
        print("back tapped here from series vc")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UIScrollView Delegate

extension SeriesVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("delay timer when end dragging")
        timerState = .delaying
       self.navigationController?.setNavigationBarHidden(velocity.y > 0, animated: true)
    }
}


// MARK: - UITableView Data Source

extension SeriesVC: UITableViewDataSource {

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
extension SeriesVC: UITableViewDelegate {
    
    // section
    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return series.count == 0 ? CGFloat.leastNonzeroMagnitude : 50
        } else {
            let genre = genres[section - 1]
            let filteredVideos = series.filter { $0?.genreId == genre?._id }
            return filteredVideos.count == 0 ? CGFloat.leastNonzeroMagnitude : 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let sectionLabel = UILabel()
        headerView.addSubview(sectionLabel)
        sectionLabel.layout(X: .leading(nil, 15), W: .wrapContent, Y: .top(nil, 8), H: .fixed(20))
        sectionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        let moreBtn = MoreBtn()
        headerView.addSubview(moreBtn)
        moreBtn.layout(X: .trailing(nil, 15), W: .wrapContent, Y: .top(nil, 8), H: .fixed(20))
        moreBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        moreBtn.setTitle(StringsKeys.more.localized, for: .normal)
        moreBtn.setTitleColor(Color.secondary, for: .normal)
        moreBtn.titleLabel?.textAlignment = .center
        moreBtn.addTarget(self, action: #selector(handleMoreTapped), for: .touchUpInside)
        
       switch section {
       case 0:
           sectionLabel.text = series.count == 0 ? "" : self.tableView(tableView, titleForHeaderInSection: section)
           moreBtn.isHidden = true
       default:
           let genre = genres[section - 1]
           let filteredVideos = series.filter { $0?.genreId == genre?._id }
           sectionLabel.text = filteredVideos.count == 0 ? "" : self.tableView(tableView, titleForHeaderInSection: section)
           moreBtn.genreId = genre?._id
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
            return series.count == 0 ? CGFloat.leastNonzeroMagnitude : 200
        } else {
            let genre = genres[indexPath.section - 1]
            let filteredVideos = series.filter { $0?.genreId == genre?._id }
            return filteredVideos.count == 0 ? CGFloat.leastNonzeroMagnitude : 200
        }
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       guard let cell: MainTableCell = cell as? MainTableCell else { return }
       cell.setCollectionView(dataSource: self, delegate: self, indexPath: indexPath)
        
        // pagination
        cell.paginagationManager.delegate = self
        currentCell = cell
    }
}


// MARK: - UICollectionView Data Source
extension SeriesVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionIndex = collectionView.tag
        
        if collectionView == seriesSliderCollectionView {
            return sliderVideos.count
        }
        
        switch sectionIndex {
        case 0:
            // popular
            let popularSeries = Array(series.prefix(20))
            return popularSeries.count
        default:
            // genre
            let genre = genres[collectionView.tag - 1]
            let videosFromGenreID = seriesDict[genre?._id ?? ""] ?? []
            return videosFromGenreID.count == 0 ? 0 : videosFromGenreID.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionIndex = collectionView.tag

        if collectionView == seriesSliderCollectionView {
            let cell3 = collectionView.dequeue(indexPath: indexPath) as MainSliderCell
            cell3.backgroundColor = Color.secondary
            cell3.video = sliderVideos[indexPath.item]
           return cell3
        }
        
        switch sectionIndex {
        case 0:
            // popular
            let popularSeries = Array(series.prefix(20))
            let cell1 = collectionView.dequeue(indexPath: indexPath) as MovieCell
            cell1.backgroundColor = Color.secondary
            cell1.video = popularSeries[indexPath.item]
            return cell1
        default:
            // genre
            let genre = genres[collectionView.tag - 1]
            let videosFromGenreID = seriesDict[genre?._id ?? ""] ?? []
   
            let cell4 = collectionView.dequeue(indexPath: indexPath) as MovieCell
            cell4.backgroundColor = Color.secondary
            cell4.video = videosFromGenreID[indexPath.item]
            return cell4
        }
    }
}

// MARK: - UICollectionView Delegate
extension SeriesVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == seriesSliderCollectionView {
            if pageView.currentPage == indexPath.row {
                guard let visible = seriesSliderCollectionView.visibleCells.first else { return }
                guard let index = seriesSliderCollectionView.indexPath(for: visible)?.row else { return }
                counter = index
                pageView.currentPage = counter
            }
        }
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // section
        let sectionIndex = collectionView.tag
        
        if collectionView == seriesSliderCollectionView {
            // posters sliders
            let series = sliderVideos[indexPath.item]
            let episodesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EpisodesVC") as! EpisodesVC
            episodesVC.modalPresentationStyle = .fullScreen
            episodesVC.series = series
            guard navigationController?.topViewController == self else { return }
            self.navigationController?.pushViewController(episodesVC, animated: true)
        } else {
            switch sectionIndex {
            case 0:
                let popularSeries = Array(series.prefix(20))
                print("section : \(StringsKeys.popular.localized) => \(indexPath.item)")
                let series = popularSeries[indexPath.item]
                let episodesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EpisodesVC") as! EpisodesVC
                episodesVC.modalPresentationStyle = .fullScreen
                episodesVC.series = series
                guard navigationController?.topViewController == self else { return }
                self.navigationController?.pushViewController(episodesVC, animated: true)
                
            default:
                // other genre from api
                let genre = genres[collectionView.tag - 1]
                let videosFromGenreID = seriesDict[genre?._id ?? ""] ?? []
                print("genre : \(genre?.en_name ?? "") => \(indexPath.item)")

                let series = videosFromGenreID[indexPath.item]
                let episodesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EpisodesVC") as! EpisodesVC
                episodesVC.modalPresentationStyle = .fullScreen
                episodesVC.series = series
                guard navigationController?.topViewController == self else { return }
                self.navigationController?.pushViewController(episodesVC, animated: true)
            }
        }
    }
}


// MARK: - UICollectionViewDelegate Flow Layout
extension SeriesVC: UICollectionViewDelegateFlowLayout {
    // section
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        if collectionView == seriesSliderCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        if collectionView == seriesSliderCollectionView {
            return 0
        }
        return 10 // vertical spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0 // horizontal spacing
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        // let section = SeriesTableSections.allCases[collectionView.tag]
        
        if collectionView == seriesSliderCollectionView {
               let size = seriesSliderCollectionView.frame.size
               return CGSize(width: size.width, height: size.height)
           }
        
        return collectionView.size(rows: 1, columns: 3.5)
    }
}
