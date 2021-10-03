//
//  HomeVC.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import DesignX

class MainVC: UIViewController {

    //MARK: - outlets
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    
    //MARK: - variables
    
    var sliderTimer: Timer?
    var counter = 0
    var timerState = TimerState.notStarted
        
    //MARK: - constants
    
    // Timer state
    enum TimerState {
      case notStarted
      case playing
      case delaying
      case ended
    }
    
    let customNavBar = MainNavBar()
    
    // for every ( movies / plays ) sub category 
    let videos = [Video(name: StringsKeys.bodyGuard.localized,
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
    
    var continueWatching = Defaults.savedContinueWatching()
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
          
        // stop timer when application is backgrounded.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        // start timer when application is returned to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        continueWatching = Defaults.savedContinueWatching()
        sliderCollectionView.reloadData()
        mainTableView.reloadData()
        self.navigationController?.navigationBar.topItem?.title = ""
        addCustomNavBar()
        startTimer()
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
        pageView.numberOfPages = videos.count
        pageView.currentPage = 0
        
        startTimer()
        
        // table view
        mainTableView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomToSafeAreaAndHeight(sliderCollectionView, 0, nil, 0, .fixed(1700)))
        mainTableView.backgroundColor = Color.primary
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainScrollView.delegate = self
        
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
         if counter < videos.count {
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
        print("main slider => \(counter)")
    }
    
    
    fileprivate func endTimer() {
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
    
    @objc fileprivate func handleMoreTapped() {
        print("more tapped ...")
        let moreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MoreRootVC") as! UINavigationController
        moreVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(moreVC, animated: true, completion: nil)
    }

    
    //MARK: - actions
    
    
}


//MARK: - extensions


//MARK: - CustomNavBar Delegate

extension MainVC: MainNavBarDelegate {
    // custom delegation pattern 
    
    func handleMoviesTapped() {
        print("movies tapped here from main vc")
        let moviesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MoviesRootVC") as! UINavigationController
        moviesVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(moviesVC, animated: true, completion: nil)
    }
    
    func handleSeriesTapped() {
        print("series tapped here from main vc")
        let seriesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SeriesRootVC") as! UINavigationController
        seriesVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(seriesVC, animated: true, completion: nil)
    }
    
    func handlePlaysTapped() {
        print("plays tapped here from main vc")
        let playsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlaysRootVC") as! UINavigationController
        playsVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(playsVC, animated: true, completion: nil)
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
        return MainTableSections.allCases.count
    }
    // return continuewatching
    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
       let section = MainTableSections.allCases[section]
        
        if section == .continueWatching {
            return continueWatching.count == 0 ? nil : section.ui.sectionTitle
        } else {
            return section.ui.sectionTitle
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
extension MainVC: UITableViewDelegate {
    
    // section
    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = MainTableSections.allCases[section]
        switch section {
        case .continueWatching:
            return continueWatching.count == 0 ? CGFloat.leastNonzeroMagnitude : 50
        case .popular, .Movies, .Series, .Plays, .anime:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let currentSection = MainTableSections.allCases[section]
        
           switch currentSection {
           case .continueWatching:
            
            let headerView = UIView()
            let sectionLabel = UILabel()
            headerView.addSubview(sectionLabel)
            sectionLabel.layout(X: .leading(nil, 8), W: .wrapContent, Y: .top(nil, 8), H: .fixed(20))
            sectionLabel.font = UIFont.boldSystemFont(ofSize: 18)
            sectionLabel.text = continueWatching.count == 0 ? "" : self.tableView(tableView, titleForHeaderInSection: section)
            sectionLabel.textColor = Color.text
            return continueWatching.count == 0 ? nil : headerView
            
           case .popular, .Movies, .Series, .Plays, .anime:
            
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
    }
    
    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
       return 0
    }
    
     // row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = MainTableSections.allCases[indexPath.section]
        switch section {
        case .continueWatching:
            return continueWatching.count == 0 ? CGFloat.leastNonzeroMagnitude : section.ui.sectionHeight
        case .popular, .Movies, .Series, .Plays, .anime:
            return section.ui.sectionHeight
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
        let section = MainTableSections.allCases[collectionView.tag]
        
        if collectionView == sliderCollectionView {
            return videos.count
        }
        
        switch section {
        case .continueWatching:
            return continueWatching.count == 0 ? 0 : continueWatching.count
            
        case .popular, .Movies, .Series, .Plays, .anime:
            return videos.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = MainTableSections.allCases[collectionView.tag]
        
        if collectionView == sliderCollectionView {
            let cell3 = collectionView.dequeue(indexPath: indexPath) as MainSliderCell
            cell3.backgroundColor = Color.secondary
            cell3.video = videos[indexPath.item]
            
            // slide image
            counter = indexPath.item
            pageView.currentPage = counter
            
            return cell3
        }
        
        switch section {
        case .popular, .Movies, .Series, .Plays, .anime:
            let cell1 = collectionView.dequeue(indexPath: indexPath) as MovieCell
            cell1.backgroundColor = Color.secondary
            cell1.video = videos[indexPath.item]
            return cell1
            
        case .continueWatching:
            let cell2 = collectionView.dequeue(indexPath: indexPath) as ContinueWatchingCell
            cell2.backgroundColor = Color.secondary
            cell2.video = continueWatching[indexPath.item]
            return cell2
        }
   
    }
}


// MARK: - UICollectionView Delegate
extension MainVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // section
        let section = MainTableSections.allCases[collectionView.tag]
        print("section : \(section.ui.sectionTitle) => \(indexPath.item)")
        
        if collectionView == sliderCollectionView {
            let video = videos[indexPath.item]
            let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
            detailsVC.modalPresentationStyle = .fullScreen
            detailsVC.video = video
            self.navigationController?.pushViewController(detailsVC, animated: true)
            
        } else {
            
            switch section {
                
            case .continueWatching:
                let video = continueWatching[indexPath.item]
                let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
                detailsVC.modalPresentationStyle = .fullScreen
                detailsVC.video = video
                self.navigationController?.pushViewController(detailsVC, animated: true)
                
            case .popular, .Movies, .Series, .Plays, .anime:
                let video = videos[indexPath.item]
                let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
                detailsVC.modalPresentationStyle = .fullScreen
                detailsVC.video = video
                self.navigationController?.pushViewController(detailsVC, animated: true)        }
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
        let section = MainTableSections.allCases[collectionView.tag]
        
        if collectionView == sliderCollectionView {
            let size = sliderCollectionView.frame.size
            return CGSize(width: size.width, height: size.height)
        }
        
        switch section {
        case .continueWatching:
            return collectionView.size(rows: 1, columns: 1.25)
      
        case .popular, .Movies, .Series, .Plays, .anime:
            return collectionView.size(rows: 1, columns: 3.5)
        }
        
    }
}
