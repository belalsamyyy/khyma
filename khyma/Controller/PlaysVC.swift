//
//  PlaysVC.swift
//  khyma
//
//  Created by Belal Samy on 22/09/2021.
//

import Network
import DesignX
import GoogleMobileAds
import SimpleAPI

class PlaysVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var playsScrollView: UIScrollView!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var playsTableView: MainTableView!
    
    @IBOutlet weak var playsSliderCollectionView: UICollectionView!
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
    //var playsTableViewHeight = NSLayoutConstraint()

        
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
    var plays = [Video?]()
    var sliderVideos = [Video?]()


    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        // check connection
        checkConnection()
        
        // API
        getGenres()
        getVideos()
        
        // stop timer when application is backgrounded.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        // start timer when application is returned to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check connection
        checkConnection()
        
        playsSliderCollectionView.reloadData()
        //playsTableViewHeight.constant = CGFloat(genres.count * 450)
        playsTableView.reloadData()
        startTimer()

        addCustomNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customNavBar.removeFromSuperview()
        timerState = .ended
    }
    
    override func viewDidLayoutSubviews() {
        playsSliderCollectionView.reloadData()
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
                DispatchQueue.main.async {
                    self?.playsSliderCollectionView.reloadData()
                    self?.playsTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    fileprivate func getVideos() {
        Video.endpoint = Endpoints.plays
        API<Video>.list { [weak self] result in
            switch result {
            case .success(let data):
                self?.plays = Array(data.prefix(50))
                self?.sliderVideos = Array(data.shuffled().prefix(5))
                DispatchQueue.main.async {
                    self?.pageView.numberOfPages = self?.sliderVideos.count ?? 0
                    self?.playsSliderCollectionView.reloadData()
                    self?.startTimer()
                    self?.playsTableView.reloadData()
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
        playsScrollView.create(container: scrollContainer)

        playsScrollView.backgroundColor = Color.primary
        scrollContainer.backgroundColor = Color.primary
        
        // posters slider
        playsSliderCollectionView.backgroundColor = Color.primary
        playsSliderCollectionView.delegate = self
        playsSliderCollectionView.dataSource = self
        playsSliderCollectionView.isPagingEnabled = true

        playsSliderCollectionView.register(cell: MainSliderCell.self)
        playsSliderCollectionView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomAndHeight(nil, 0, playsTableView, 0, .fixed(500)))
        playsSliderCollectionView.reloadData()

        // pager
        pageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(playsSliderCollectionView, -75), H: .fixed(50))
        pageView.numberOfPages = plays.count
        pageView.currentPage = 0
                
        // table view
        playsTableView.backgroundColor = Color.primary
        playsTableView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomBothToSafeArea(playsSliderCollectionView, 0, nil, 0))
        
//        playsTableViewHeight = NSLayoutConstraint(item: playsTableView!, attribute: .height, relatedBy: .equal,
//                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
//        //playsTableView.addConstraint(playsTableViewHeight)
        
        self.playsTableView.reloadData()
        self.playsTableView.layoutIfNeeded()
        
        playsTableView.delegate = self
        playsTableView.dataSource = self
        playsScrollView.delegate = self
        
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
             self.playsSliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
             pageView.currentPage = counter
             counter += 1
         } else {
             counter = 0
             let index = IndexPath.init(item: counter, section: 0)
             self.playsSliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
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
        customNavBar.backLabel.text = StringsKeys.plays.localized
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
        moreVC.categoryName = CategoryName.plays
        self.navigationController?.pushViewController(moreVC, animated: true)
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
extension PlaysVC: BackNavBarDelegate {
    // custom delegation pattern
    func handleBackTapped() {
        print("back tapped here from plays vc")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UIScrollView Delegate
extension PlaysVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
       print("delay timer when end dragging")
       timerState = .delaying
       self.navigationController?.setNavigationBarHidden(velocity.y > 0, animated: true)
    }
}


// MARK: - UITableView Data Source
extension PlaysVC: UITableViewDataSource {

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
extension PlaysVC: UITableViewDelegate {
    
    // section
    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return plays.count == 0 ? CGFloat.leastNonzeroMagnitude : 50
        } else {
            let genre = genres[section - 1]
            let filteredVideos = plays.filter { $0?.genreId == genre?._id }
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
           sectionLabel.text = plays.count == 0 ? "" : self.tableView(tableView, titleForHeaderInSection: section)
           moreBtn.isHidden = plays.count < 4 ? true : false
       default:
           let genre = genres[section - 1]
           let filteredVideos = plays.filter { $0?.genreId == genre?._id }
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
            return plays.count == 0 ? CGFloat.leastNonzeroMagnitude : 200
        } else {
            let genre = genres[indexPath.section - 1]
            let filteredVideos = plays.filter { $0?.genreId == genre?._id }
            return filteredVideos.count == 0 ? CGFloat.leastNonzeroMagnitude : 200
        }
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       guard let cell: MainTableCell = cell as? MainTableCell else { return }
       cell.setCollectionView(dataSource: self, delegate: self, indexPath: indexPath)
    }
}


// MARK: - UICollectionView Data Source
extension PlaysVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionIndex = collectionView.tag
        
        if collectionView == playsSliderCollectionView {
            return sliderVideos.count
        }
        
        switch sectionIndex {
        case 0:
            // popular
            return plays.count
        default:
            // genre
            let genre = genres[collectionView.tag - 1]
            let filteredVideos = plays.filter { $0?.genreId == genre?._id }
            return filteredVideos.count == 0 ? 0 : filteredVideos.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionIndex = collectionView.tag

        if collectionView == playsSliderCollectionView {
            let cell3 = collectionView.dequeue(indexPath: indexPath) as MainSliderCell
            cell3.backgroundColor = Color.secondary
            cell3.video = sliderVideos[indexPath.item]
           return cell3
        }
        
        switch sectionIndex {
        case 0:
            // popular
            let cell1 = collectionView.dequeue(indexPath: indexPath) as MovieCell
            cell1.backgroundColor = Color.secondary
            cell1.video = plays[indexPath.item]
            return cell1
        default:
            // genre
            let genre = genres[collectionView.tag - 1]
            let filteredVideos = plays.filter { $0?.genreId == genre?._id }

            let cell4 = collectionView.dequeue(indexPath: indexPath) as MovieCell
            cell4.backgroundColor = Color.secondary
            cell4.video = filteredVideos[indexPath.item]
            return cell4
        }
    }
}


// MARK: - UICollectionView Delegate
extension PlaysVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == playsSliderCollectionView {
            if pageView.currentPage == indexPath.row {
                guard let visible = playsSliderCollectionView.visibleCells.first else { return }
                guard let index = playsSliderCollectionView.indexPath(for: visible)?.row else { return }
                counter = index
                pageView.currentPage = counter
            }
        }
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // section
        let sectionIndex = collectionView.tag
        
        if collectionView == playsSliderCollectionView {
            // posters sliders
            let video = sliderVideos[indexPath.item]
            let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
            detailsVC.modalPresentationStyle = .fullScreen
            detailsVC.video = video
            detailsVC.watchableType = .play
            self.navigationController?.pushViewController(detailsVC, animated: true)
        } else {
            switch sectionIndex {
            case 0:
                print("section : \(StringsKeys.popular.localized) => \(indexPath.item)")
                let video = plays[indexPath.item]
                let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
                detailsVC.modalPresentationStyle = .fullScreen
                detailsVC.video = video
                detailsVC.watchableType = .play
                self.navigationController?.pushViewController(detailsVC, animated: true)
            default:
                // other genre from api
                let genre = genres[collectionView.tag - 1]
                let filteredVideos = plays.filter { $0?.genreId == genre?._id }
                print("genre : \(genre?.en_name ?? "") => \(indexPath.item)")

                let video = filteredVideos[indexPath.item]
                let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
                detailsVC.modalPresentationStyle = .fullScreen
                detailsVC.video = video
                detailsVC.watchableType = .play
                self.navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
    }
}


// MARK: - UICollectionViewDelegate Flow Layout
extension PlaysVC: UICollectionViewDelegateFlowLayout {
    // section
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        if collectionView == playsSliderCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        if collectionView == playsSliderCollectionView {
            return 0
        }
        return 10 // vertical spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0 // horizontal spacing
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        // let section = PlaysTableSections.allCases[collectionView.tag]
        
        if collectionView == playsSliderCollectionView {
            let size = playsSliderCollectionView.frame.size
            return CGSize(width: size.width, height: size.height)
        }
        
        return collectionView.size(rows: 1, columns: 3.5)
    }
}
