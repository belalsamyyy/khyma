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
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var mainTableView: UITableView!
    
    //MARK: - variables
    
    var gradientLayer = CAGradientLayer()
    var navGradient = CAGradientLayer()
    
    // The banner ad
    private var bannerAd: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.banner
      banner.load(GADRequest())
      banner.backgroundColor = .lightGray
      return banner
    }()

        
    //MARK: - constants
    
    let continueWatching = [Movie(name: "Contiue Movie 1"), Movie(name: "Contiue Movie 2"),
                            Movie(name: "Contiue Movie 3"), Movie(name: "Contiue Movie 4")]
       
   let movies = [Movie(name: "Movie 1"), Movie(name: "Movie 2"), Movie(name: "Movie 3"),
                 Movie(name: "Movie 4"), Movie(name: "Movie 5"), Movie(name: "Movie 6"),
                 Movie(name: "Movie 7"), Movie(name: "Movie 8")]
    
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setupNavBar()
        changeTheme()
        setupViews()
        loadBannerAd()
    }
    
    override func viewDidLayoutSubviews() {
        changeTheme()
        gradientLayer.frame = posterImageView.bounds
    }
    
    override func viewWillLayoutSubviews() {
        changeTheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        changeTheme()
    }
    
    
    //MARK: - functions
    
    fileprivate func setupViews() {

        // scroll
        mainScrollView.create(container: scrollContainer)
        
        mainScrollView.backgroundColor = Color.primary
        scrollContainer.backgroundColor = Color.primary
        
        // poster
        posterImageView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomAndHeight(nil, 0, mainTableView, 0, .fixed(500)))
        gradientLayer = posterImageView.fill(gradient: [.color(.clear), .color(Color.primary)], locations: [0, 1], opacity: 1)

        posterImageView.image = #imageLiteral(resourceName: "poster")
        posterImageView.contentMode = .scaleAspectFill
        gradientLayer.frame = posterImageView.bounds
        
        // table view
        mainTableView.layout(XW: .leadingAndCenter(nil, 0), YH: .TopAndBottomToSafeAreaAndHeight(posterImageView, 0, nil, 0, .fixed(1600)))
        mainTableView.backgroundColor = Color.primary
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainScrollView.delegate = self
        
    }
    
    fileprivate func loadBannerAd() {
           bannerAd.rootViewController = self
           scrollContainer.addSubview(bannerAd)
           bannerAd.layout(XW: .leadingAndCenter(nil, 0), Y: .bottomToSafeArea(nil, 0), H: .fixed(60))
       }
    
    fileprivate func changeTheme() {
        // Dark mode or Light mode
        Defaults.darkMode = traitCollection.userInterfaceStyle == .light ? false : true
        view.setNeedsLayout()
    }
    
    fileprivate func setupNavBar() {
        let gradient = CAGradientLayer()
        let sizeLength = UIScreen.main.bounds.size.height * 2
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: sizeLength, height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [#colorLiteral(red: 0.7529411765, green: 0.262745098, blue: 0.2235294118, alpha: 1).cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 1]

        UINavigationBar.appearance().setBackgroundImage(self.convertGradientLayerIntoImage(fromLayer: gradient), for: .default)
    }
    
    fileprivate func convertGradientLayerIntoImage(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
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
        switch section {
        case .continueWatching:
            return 4
            
        case .popular, .Movies, .Series, .Plays, .games:
            return movies.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = TableSections.allCases[collectionView.tag]
        
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
        switch section {
        case .continueWatching:
            return collectionView.size(rows: 1, columns: 1.25)
      
        case .popular, .Movies, .Series, .Plays, .games:
            return collectionView.size(rows: 1, columns: 3.5)
        }
        
    }
}
