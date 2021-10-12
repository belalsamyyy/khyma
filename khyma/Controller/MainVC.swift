//
//  HomeVC.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import Network
import UIKit
import DesignX
import SimpleAPI

class MainVC: UIViewController {

    //MARK: - outlets
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var mainTableView: MainTableView!
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    
    //MARK: - variables
    
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
    
    let customNavBar = MainNavBar()
    
    var genres = [Genre?]()
    var videos = [Video?]()
    var sliderVideos = [Video?]()
    var continueWatching = Defaults.savedContinueWatching()
    
    //MARK: - lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
                
        // check connection
        checkConnection()
        getConfiguration()
        
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
        getConfiguration()
        
        continueWatching = Defaults.savedContinueWatching()
        sliderCollectionView.reloadData()
        startTimer()
        
        mainTableView.reloadData()
        self.navigationController?.navigationBar.topItem?.title = ""
        addCustomNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(viewWillDisappear)
        self.navigationController?.navigationBar.topItem?.title = ""
        customNavBar.removeFromSuperview()
        timerState = .ended
    }
    
    override func viewDidLayoutSubviews() {
        continueWatching = Defaults.savedContinueWatching()
        self.navigationController?.navigationBar.topItem?.title = ""
        sliderCollectionView.reloadData()
    }

    
    //MARK: - functions
    
    fileprivate func getConfiguration() {
        Config.endpoint = Endpoints.config
        API<Config>.object(.get(ConfigID)) { [weak self] result in
            switch result {
            case .success(let data):
                if data?.updateScreen == true {
                    DispatchQueue.main.async {
                        let updateScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UpdateScreenVC") as! UpdateScreenVC
                        updateScreen.modalPresentationStyle = .fullScreen
                        self?.present(updateScreen, animated: true)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    fileprivate func getGenres() {
        Genre.endpoint = Endpoints.genres
        API<Genre>.list { [weak self] result in
            switch result {
            case .success(let data):
                self?.genres = data
                DispatchQueue.main.async {
                    self?.sliderCollectionView.reloadData()
                    self?.mainTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    fileprivate func getVideos() {
        Video.endpoint = Endpoints.movies
        API<Video>.list { [weak self] result in
            switch result {
            case .success(let data):
                self?.videos = Array(data.prefix(50))
                self?.sliderVideos = Array(data.shuffled().prefix(5))
                DispatchQueue.main.async {
                    self?.pageView.numberOfPages = self?.sliderVideos.count ?? 0
                    self?.sliderCollectionView.reloadData()
                    self?.startTimer()
                    self?.mainTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
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
        
        // navigation bar
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        navigationItem.largeTitleDisplayMode = .never
        addCustomNavBar()
        
        // scroll
        mainScrollView.create(container: scrollContainer)
        mainScrollView.backgroundColor = Color.primary
        scrollContainer.backgroundColor = Color.primary
        
        // posters slider
        sliderCollectionView.backgroundColor = Color.primary
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        sliderCollectionView.isPagingEnabled = true
        
        sliderCollectionView.register(cell: MainSliderCell.self)
        sliderCollectionView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomAndHeight(nil, 0, mainTableView, 0, .fixed(500)))
        sliderCollectionView.reloadData()

        // pager
        pageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(sliderCollectionView, -75), H: .fixed(50))
        // pageView.numberOfPages = videos.count
        pageView.currentPage = 0
        pageView.currentPageIndicatorTintColor = .white
                
        // table view
        mainTableView.backgroundColor = Color.primary
        mainTableView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomBothToSafeArea(sliderCollectionView, 0, nil, 0))
        self.mainTableView.reloadData()
        self.mainTableView.layoutIfNeeded()
        
        self.view.layoutIfNeeded()
        
        
        mainTableView.reloadData()
        mainTableView.updateConstraints()
        scrollContainer.layoutIfNeeded()
                
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainScrollView.delegate = self
        
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
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageView.currentPage = counter
            counter += 1
        } else {
            counter = 0
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            pageView.currentPage = counter
        }
       print("main slider => \(counter)")
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
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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

    
    //MARK: - actions
    
    
}


//MARK: - extensions


//MARK: - CustomNavBar Delegate

extension MainVC: MainNavBarDelegate {
    // custom delegation pattern 
    
    func handleMoviesTapped() {
        print("movies tapped here from main vc")
        let moviesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MoviesRootVC") as! MainNavController
        moviesVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(moviesVC, animated: true, completion: nil)
    }
    
    func handleSeriesTapped() {
        print("series tapped here from main vc")
        let seriesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SeriesRootVC") as! MainNavController
        seriesVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(seriesVC, animated: true, completion: nil)
    }
    
    func handlePlaysTapped() {
        print("plays tapped here from main vc")
        let playsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlaysRootVC") as! MainNavController
        playsVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(playsVC, animated: true, completion: nil)
    }
}

//MARK: - ContinueWatching Delegate

extension MainVC: ContinueWatchingCellDelegate {
    func handleLongPressed(video: Watchable) {
        print("Captured Long Press \(video.ar_name ?? "no video")")
        let alertTitle = StringsKeys.removeFromContinueWatching.localized
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: StringsKeys.removeAlertAction.localized, style: .destructive, handler: { (_) in
            Defaults.deleteContinueWatching(video: video)
            UserDefaultsManager.shared.def.removeObject(forKey: video._id ?? "")
            self.mainTableView.reloadData()
        }))

        alertController.addAction(UIAlertAction(title: StringsKeys.cancelAlert.localized, style: .cancel ))
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UIScrollView Delegate

extension MainVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("delay timer when end dragging")
        timerState = .delaying
        self.navigationController?.setNavigationBarHidden(velocity.y < 0, animated: true)
    }
}



// MARK: - UITableView Data Source

extension MainVC: UITableViewDataSource {

    // section
     func numberOfSections(in _: UITableView) -> Int {
         return 2 + genres.count
    }
    
    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return continueWatching.count == 0 ? nil : StringsKeys.continueWatching.localized
        } else if section == 1 {
            return StringsKeys.popular.localized
        } else {
            let genre = genres[section - 2]
            return Language.currentLanguage == Lang.english.rawValue ? genre?.en_name : genre?.ar_name
        }
   }

    // row
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
extension MainVC: UITableViewDelegate {
    // section
    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return continueWatching.count == 0 ? CGFloat.leastNonzeroMagnitude : 50
        } else if section == 1 {
            return videos.count == 0 ? CGFloat.leastNonzeroMagnitude : 50
        } else {
            let genre = genres[section - 2]
            let filteredVideos = videos.filter { $0?.genreId == genre?._id }
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
           sectionLabel.text = videos.count == 0 ? "" : self.tableView(tableView, titleForHeaderInSection: section)
           moreBtn.isHidden = true
       case 1:
           sectionLabel.text = videos.count == 0 ? "" : self.tableView(tableView, titleForHeaderInSection: section)
           moreBtn.isHidden = true
       default:
           let genre = genres[section - 2]
           let filteredVideos = videos.filter { $0?.genreId == genre?._id }
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
            return continueWatching.count == 0 ? CGFloat.leastNonzeroMagnitude : 200
        } else if indexPath.section == 1 {
            return videos.count == 0 ? CGFloat.leastNonzeroMagnitude : 200
        } else {
            let genre = genres[indexPath.section - 2]
            let filteredVideos = videos.filter { $0?.genreId == genre?._id }
            return filteredVideos.count == 0 ? CGFloat.leastNonzeroMagnitude : 200
        }
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       guard let cell: MainTableCell = cell as? MainTableCell else { return }
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
        let sectionIndex = collectionView.tag
        
        if collectionView == sliderCollectionView {
            return sliderVideos.count
        }
        
        switch sectionIndex {
        case 0:
            // continue watching
            return continueWatching.count == 0 ? 0 : continueWatching.count
        case 1:
            // popular
            let popularVideos = Array(videos.prefix(20))
            return popularVideos.count
        default:
            // genre
            let genre = genres[collectionView.tag - 2]
            let filteredVideos = videos.filter { $0?.genreId == genre?._id }
            return filteredVideos.count == 0 ? 0 : filteredVideos.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionIndex = collectionView.tag

        if collectionView == sliderCollectionView {
            let cell3 = collectionView.dequeue(indexPath: indexPath) as MainSliderCell
            cell3.backgroundColor = Color.secondary
            cell3.video = sliderVideos[indexPath.item]
           return cell3
        }
        
        switch sectionIndex {
        case 0:
            // continue watching
            let cell2 = collectionView.dequeue(indexPath: indexPath) as ContinueWatchingCell
            cell2.backgroundColor = Color.secondary
            cell2.video = continueWatching[indexPath.item]
            cell2.delegate = self // so i can handle long press with delegation design pattern from main vc
            return cell2
        case 1:
            // popular
            let popularVideos = Array(videos.prefix(20))
            let cell1 = collectionView.dequeue(indexPath: indexPath) as MovieCell
            cell1.backgroundColor = Color.secondary
            cell1.video = popularVideos[indexPath.item]
            return cell1
        default:
            // genre
            let genre = genres[collectionView.tag - 2]
            let filteredVideos = videos.filter { $0?.genreId == genre?._id }

            let cell4 = collectionView.dequeue(indexPath: indexPath) as MovieCell
            cell4.backgroundColor = Color.secondary
            cell4.video = filteredVideos[indexPath.item]
            return cell4
        }
    }
}


// MARK: - UICollectionView Delegate
extension MainVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == sliderCollectionView {
            if pageView.currentPage == indexPath.row {
                guard let visible = sliderCollectionView.visibleCells.first else { return }
                guard let index = sliderCollectionView.indexPath(for: visible)?.row else { return }
                counter = index
                pageView.currentPage = counter
            }
        }
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // section
        let sectionIndex = collectionView.tag
        
        if collectionView == sliderCollectionView {
            // posters sliders
            let video = sliderVideos[indexPath.item]
            let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
            detailsVC.modalPresentationStyle = .fullScreen
            detailsVC.video = video
            detailsVC.watchableType = .movie
            self.navigationController?.pushViewController(detailsVC, animated: true)
        } else {
            switch sectionIndex {
            case 0:
                // continue watching
                print("section : \(StringsKeys.continueWatching.localized) => \(indexPath.item)")
                if continueWatching.count != 0 {
                    let video = continueWatching[indexPath.item]
                    let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
                    detailsVC.modalPresentationStyle = .fullScreen
                    detailsVC.video = video
                    detailsVC.watchableType = .movie
                    self.navigationController?.pushViewController(detailsVC, animated: true)
                }
                
            case 1:
                let popularVideos = Array(videos.prefix(20))
                print("section : \(StringsKeys.popular.localized) => \(indexPath.item)")
                let video = popularVideos[indexPath.item]
                let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
                detailsVC.modalPresentationStyle = .fullScreen
                detailsVC.video = video
                detailsVC.watchableType = .movie
                self.navigationController?.pushViewController(detailsVC, animated: true)
            default:
                // other genre from api
                let genre = genres[collectionView.tag - 2]
                let filteredVideos = videos.filter { $0?.genreId == genre?._id }
                print("genre : \(genre?.en_name ?? "") => \(indexPath.item)")

                let video = filteredVideos[indexPath.item]
                let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
                detailsVC.modalPresentationStyle = .fullScreen
                detailsVC.video = video
                detailsVC.watchableType = .movie
                self.navigationController?.pushViewController(detailsVC, animated: true)
            }
        }
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
        if collectionView == sliderCollectionView {
            return 0
        }
        return 10 // vertical spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0 // horizontal spacing
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let sectionIndex = collectionView.tag

        if collectionView == sliderCollectionView {
            let size = sliderCollectionView.frame.size
            return CGSize(width: size.width, height: size.height)
        }
        
        switch sectionIndex {
        case 0:
            return collectionView.size(rows: 1, columns: 1.25)
        default:
            return collectionView.size(rows: 1, columns: 3.5)
        }
    }
}
