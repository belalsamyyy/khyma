//
//  SeriesVC.swift
//  khyma
//
//  Created by Belal Samy on 22/09/2021.
//

import UIKit

class SeriesVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var seriesScrollView: UIScrollView!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var seriesTableView: UITableView!
    
    @IBOutlet weak var seriesSliderCollectionView: UICollectionView!
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
      case ended
    }
    
    let customNavBar = BackNavBar()
    
    let continueWatching = [Movie(name: StringsKeys.bodyGuard.localized,
                                           posterUrl: "poster-movie-1",
                                           youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     
                                     Movie(name: StringsKeys.avengers.localized,
                                           posterUrl: "poster-movie-2",
                                           youtubeUrl: "https://www.youtube.com/watch?v=dEiS_WpFuc0"),
                                     
                                     Movie(name: StringsKeys.weladRizk.localized,
                                           posterUrl: "poster-movie-3",
                                           youtubeUrl: "https://www.youtube.com/watch?v=hqkSGmqx5tM"),
                                     
                                     Movie(name: StringsKeys.batman.localized,
                                           posterUrl: "poster-movie-4",
                                           youtubeUrl: "https://www.youtube.com/watch?v=OEqLipY4new&list=PLRYXdAxk10I4rWNxWyelz7cXyGR94Q0eY"),
                                     
                                     Movie(name: StringsKeys.blueElephant.localized,
                                           posterUrl: "poster-movie-5",
                                           youtubeUrl: "https://www.youtube.com/watch?v=miH5SCH9at8")]
    
    let movies = [Movie(name: StringsKeys.bodyGuard.localized,
                                 posterUrl: "poster-movie-1",
                                 youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                           
                           Movie(name: StringsKeys.avengers.localized,
                                 posterUrl: "poster-movie-2",
                                 youtubeUrl: "https://www.youtube.com/watch?v=dEiS_WpFuc0"),
                           
                           Movie(name: StringsKeys.weladRizk.localized,
                                 posterUrl: "poster-movie-3",
                                 youtubeUrl: "https://www.youtube.com/watch?v=hqkSGmqx5tM"),
                           
                           Movie(name: StringsKeys.batman.localized,
                                 posterUrl: "poster-movie-4",
                                 youtubeUrl: "https://www.youtube.com/watch?v=OEqLipY4new&list=PLRYXdAxk10I4rWNxWyelz7cXyGR94Q0eY"),
                           
                           Movie(name: StringsKeys.blueElephant.localized,
                                 posterUrl: "poster-movie-5",
                                 youtubeUrl: "https://www.youtube.com/watch?v=miH5SCH9at8")]

    
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
        seriesSliderCollectionView.reloadData()
        addCustomNavBar()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customNavBar.removeFromSuperview()
        timerState = .ended
    }
    
    override func viewDidLayoutSubviews() {
        seriesSliderCollectionView.reloadData()
    }

    
    //MARK: - functions
    
    fileprivate func setupViews() {
        
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
        
        seriesSliderCollectionView.register(cell: MainSliderCell.self)
        seriesSliderCollectionView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomAndHeight(nil, 0, seriesTableView, 0, .fixed(500)))
        seriesSliderCollectionView.reloadData()

        // pager
        pageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(seriesSliderCollectionView, -75), H: .fixed(50))
        pageView.numberOfPages = movies.count
        pageView.currentPage = 0
        
        startTimer()
        
        // table view
        seriesTableView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomToSafeAreaAndHeight(seriesSliderCollectionView, 0, nil, 0, .fixed(1600)))
        seriesTableView.backgroundColor = Color.primary
        
        seriesTableView.delegate = self
        seriesTableView.dataSource = self
        seriesScrollView.delegate = self
        
    }
    
    fileprivate func startTimer() {
        // timer
        timerState = .playing
        self.sliderTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: true)
    }
    
    
    @objc func timerTick() {
        if timerState == .playing {
            slideImage()
        } else {
            endTimer()
        }
    }
    
    fileprivate func slideImage() {
         if counter < movies.count {
             let index = IndexPath.init(item: counter, section: 0)
             self.seriesSliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
             pageView.currentPage = counter
             counter += 1
         } else {
             counter = 0
             let index = IndexPath.init(item: counter, section: 0)
             self.seriesSliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
             pageView.currentPage = counter
             counter = 1
         }
        print("series slider => \(counter)")
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
        customNavBar.backLabel.text = StringsKeys.series.localized
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
       self.navigationController?.setNavigationBarHidden(velocity.y > 0, animated: true)
    }
}


// MARK: - UITableView Data Source

extension SeriesVC: UITableViewDataSource {

    // section
     func numberOfSections(in _: UITableView) -> Int {
        return MainTableSections.allCases.count
    }
    
    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
       let section = MainTableSections.allCases[section]
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
extension SeriesVC: UITableViewDelegate {
    
    // section
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
       return 50
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
         sectionLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
         sectionLabel.textColor = Color.text
         
         return headerView
         
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
        return section.ui.sectionHeight
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       guard let cell: MainTableCell = cell as? MainTableCell else { return }
       cell.setCollectionView(dataSource: self, delegate: self, indexPath: indexPath)
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
        let section = MainTableSections.allCases[collectionView.tag]
        
        if collectionView == seriesSliderCollectionView {
            return movies.count
        }
        
        switch section {
        case .continueWatching:
            return 4
            
        case .popular, .Movies, .Series, .Plays, .anime:
            return movies.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = MainTableSections.allCases[collectionView.tag]
        
        if collectionView == seriesSliderCollectionView {
            let cell3 = collectionView.dequeue(indexPath: indexPath) as MainSliderCell
            cell3.backgroundColor = Color.secondary
            cell3.movie = movies[indexPath.item]
            return cell3
        }
        
        switch section {
        case .popular, .Movies, .Series, .Plays, .anime:
            let cell1 = collectionView.dequeue(indexPath: indexPath) as MovieCell
            cell1.backgroundColor = Color.secondary
            cell1.movie = movies[indexPath.item]
            return cell1
            
        case .continueWatching:
            let cell2 = collectionView.dequeue(indexPath: indexPath) as ContinueWatchingCell
            cell2.backgroundColor = Color.secondary
            cell2.movie = continueWatching[indexPath.item]
            return cell2
        }
   
    }
}

// MARK: - UICollectionView Delegate
extension SeriesVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // section
        let section = MainTableSections.allCases[collectionView.tag]
        print("section : \(section.ui.sectionTitle) => \(indexPath.item)")
        
        // movie
        let series = movies[indexPath.item]
        
        let episodesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EpisodesVC") as! EpisodesVC
        episodesVC.modalPresentationStyle = .fullScreen
        episodesVC.series = series
        episodesVC.navigationController?.navigationBar.topItem?.title = series.name
        self.navigationController?.pushViewController(episodesVC, animated: true)
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
        return 10 // vertical spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0 // horizontal spacing
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let section = MainTableSections.allCases[collectionView.tag]
        
        if collectionView == seriesSliderCollectionView {
            let size = seriesSliderCollectionView.frame.size
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
