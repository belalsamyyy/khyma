//
//  PlaysVC.swift
//  khyma
//
//  Created by Belal Samy on 22/09/2021.
//

import UIKit

class PlaysVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var playsScrollView: UIScrollView!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var playsTableView: UITableView!
    
    @IBOutlet weak var playsSliderCollectionView: UICollectionView!
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
    
    let continueWatching = [Movie(name: StringsKeys.bodyGuard.localized, posterUrl: "poster-movie-1"),
                            Movie(name: StringsKeys.avengers.localized, posterUrl: "poster-movie-2"),
                            Movie(name: StringsKeys.weladRizk.localized, posterUrl: "poster-movie-3"),
                            Movie(name: StringsKeys.batman.localized, posterUrl: "poster-movie-4"),
                            Movie(name: StringsKeys.blueElephant.localized, posterUrl: "poster-movie-5")]
    
    let movies = [Movie(name: StringsKeys.bodyGuard.localized, posterUrl: "poster-movie-1"),
                  Movie(name: StringsKeys.avengers.localized, posterUrl: "poster-movie-2"),
                  Movie(name: StringsKeys.weladRizk.localized, posterUrl: "poster-movie-3"),
                  Movie(name: StringsKeys.batman.localized, posterUrl: "poster-movie-4"),
                  Movie(name: StringsKeys.blueElephant.localized, posterUrl: "poster-movie-5")]

    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playsSliderCollectionView.reloadData()
        addCustomNavBar()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customNavBar.removeFromSuperview()
        timerState = .ended
    }
    
    override func viewDidLayoutSubviews() {
        playsSliderCollectionView.reloadData()
    }

    
    //MARK: - functions
    
    fileprivate func setupViews() {
        
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
        
        playsSliderCollectionView.register(cell: MainSliderCell.self)
        playsSliderCollectionView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomAndHeight(nil, 0, playsTableView, 0, .fixed(500)))
        playsSliderCollectionView.reloadData()

        // pager
        pageView.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(playsSliderCollectionView, -75), H: .fixed(50))
        pageView.numberOfPages = movies.count
        pageView.currentPage = 0
        
        startTimer()
        
        // table view
        playsTableView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomToSafeAreaAndHeight(playsSliderCollectionView, 0, nil, 0, .fixed(1600)))
        playsTableView.backgroundColor = Color.primary
        
        playsTableView.delegate = self
        playsTableView.dataSource = self
        playsScrollView.delegate = self
        
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
             self.playsSliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
             pageView.currentPage = counter
             counter += 1
         } else {
             counter = 0
             let index = IndexPath.init(item: counter, section: 0)
             self.playsSliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
             pageView.currentPage = counter
             counter = 1
         }
        print("plays slider => \(counter)")
    }
    
    
    fileprivate func endTimer() {
        sliderTimer?.invalidate()
        sliderTimer = nil
    }
    
    fileprivate func addCustomNavBar() {
        customNavBar.delegate = self // custom delegation pattern
        customNavBar.backLabel.text = StringsKeys.plays.localized
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(customNavBar)
        customNavBar.layout(X: .center(nil), W: .equal(nil, 0.9), Y: .center(nil), H: .fixed(50))
    }
    
    @objc fileprivate func handleMoreTapped() {
        print("more tapped ...")
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
       self.navigationController?.setNavigationBarHidden(velocity.y > 0, animated: true)
    }
}


// MARK: - UITableView Data Source

extension PlaysVC: UITableViewDataSource {

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
extension PlaysVC: UITableViewDelegate {
    
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
         
        case .popular, .Movies, .Series, .Plays, .games:
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
extension PlaysVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = MainTableSections.allCases[collectionView.tag]
        
        if collectionView == playsSliderCollectionView {
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
        let section = MainTableSections.allCases[collectionView.tag]
        
        if collectionView == playsSliderCollectionView {
            let cell3 = collectionView.dequeue(indexPath: indexPath) as MainSliderCell
            cell3.backgroundColor = Color.secondary
            cell3.movie = movies[indexPath.item]
            return cell3
        }
        
        switch section {
        case .popular, .Movies, .Series, .Plays, .games:
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
extension PlaysVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // section
        let section = MainTableSections.allCases[collectionView.tag]
        print("section : \(section.ui.sectionTitle) => \(indexPath.item)")
        
        // movie
        let movie = movies[indexPath.item]
        
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.movie = movie
        self.navigationController?.pushViewController(detailsVC, animated: true)
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
        return 10 // vertical spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0 // horizontal spacing
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let section = MainTableSections.allCases[collectionView.tag]
        
        if collectionView == playsSliderCollectionView {
            let size = playsSliderCollectionView.frame.size
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
