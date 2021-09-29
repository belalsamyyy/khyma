//
//  EpisodesVC.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import UIKit

class EpisodesVC: UIViewController {
    
    //MARK: - outlets
    @IBOutlet weak var seasonsTableView: UITableView!
    
    //MARK: - variables
    
    var series: Watchable?
    
    //MARK: - constants
    
    let seasons = [Season(name: "\(StringsKeys.season.localized) 1",
                          posterImageUrl: "poster-movie-1",
                          episodes: [Episode(name: "\(StringsKeys.episode.localized) 1", posterUrl: "poster-movie-1",
                                             youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 2", posterUrl: "poster-movie-1",
                                             youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 3", posterUrl: "poster-movie-1",
                                             youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 4", posterUrl: "poster-movie-1",
                                             youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 5", posterUrl: "poster-movie-1",
                                             youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 6", posterUrl: "poster-movie-1",
                                             youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 7", posterUrl: "poster-movie-1",
                                             youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 8", posterUrl: "poster-movie-1",
                                             youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 9", posterUrl: "poster-movie-1",
                                             youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 10", posterUrl: "poster-movie-1",
                                             youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk")]),
                          
                   Season(name: "\(StringsKeys.season.localized) 2",
                         posterImageUrl: "poster-movie-2",
                          episodes: [Episode(name: "\(StringsKeys.episode.localized) 1", posterUrl: "poster-movie-2",
                                            youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 2", posterUrl: "poster-movie-2",
                                            youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 3", posterUrl: "poster-movie-2",
                                            youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 4", posterUrl: "poster-movie-2",
                                            youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 5", posterUrl: "poster-movie-2",
                                            youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 6", posterUrl: "poster-movie-2",
                                            youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                     Episode(name: "\(StringsKeys.episode.localized) 7", posterUrl: "poster-movie-2",
                                            youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk")]),
                        
                 Season(name: "\(StringsKeys.season.localized) 3",
                        posterImageUrl: "poster-movie-3",
                        episodes: [Episode(name: "\(StringsKeys.episode.localized) 1", posterUrl: "poster-movie-3",
                                           youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                   Episode(name: "\(StringsKeys.episode.localized) 2", posterUrl: "poster-movie-3",
                                           youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk"),
                                   Episode(name: "\(StringsKeys.episode.localized) 3", posterUrl: "poster-movie-3",
                                           youtubeUrl: "https://www.youtube.com/watch?v=x_me3xsvDgk")])]
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    override func viewDidLayoutSubviews() {
        setupNavBar()
    }
    
    
    //MARK: - functions
    
    fileprivate func setupViews() {
        view.backgroundColor = Color.primary
        setupNavBar()
        
        // table view
        seasonsTableView.layout(shortcut: .fillSuperView(0))
        seasonsTableView.backgroundColor = Color.primary
        
        seasonsTableView.delegate = self
        seasonsTableView.dataSource = self
    }
    
    fileprivate func setupNavBar() {
        self.navigationController?.navigationBar.topItem?.backButtonTitle = series?.name
        self.navigationController?.navigationBar.topItem?.title = ""
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // check if we have already saved this series in my list
        let savedSeries = Defaults.savedVideos()
        let isInMyList = savedSeries.firstIndex(where: {$0.name == series?.name}) != nil
        
            if isInMyList {
                // setting up our heart icon
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-favourite").withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
            } else {
                navigationItem.rightBarButtonItems = [
                    UIBarButtonItem(title: StringsKeys.add.localized, style: .plain, target: self, action: #selector(handleAddToMyList)),
                ]
            }
        }
    
    @objc fileprivate func handleAddToMyList() {
        
        let alertController = UIAlertController(title: series?.name, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: StringsKeys.addAlertAction.localized, style: .default, handler: { (_) in
            // add to my list ---------------------------------
            guard let video =  self.series else { return }
             
            do {
             var listOfVideos = Defaults.savedVideos()
                listOfVideos.append(video)
        
             // transform movie into data
             let data = try NSKeyedArchiver.archivedData(withRootObject: listOfVideos, requiringSecureCoding: true)
             UserDefaults.standard.set(data , forKey: UserDefaultsKeys.myList)
             self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-favourite").withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)

             
            } catch let error {
                print("Failed to save info into userDefaults : ", error)
            }
            // ------------------------------------------------
        }))
        
        alertController.addAction(UIAlertAction(title: StringsKeys.cancelAlert.localized, style: .cancel ))
        present(alertController, animated: true, completion: nil)

    }
    

    
    //MARK: - actions
    
    
}

//MARK: - extensions

// MARK: - UITableView Data Source

extension EpisodesVC: UITableViewDataSource {

    // section
     func numberOfSections(in _: UITableView) -> Int {
        return seasons.count
    }
    
    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
       let section = seasons[section]
        return section.name
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
extension EpisodesVC: UITableViewDelegate {
    
    // section
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
       return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let sectionLabel = UILabel()
        headerView.addSubview(sectionLabel)

        sectionLabel.layout(X: .leading(nil, 8), W: .wrapContent, Y: .top(nil, 8), H: .fixed(20))
        sectionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        sectionLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        sectionLabel.textColor = Color.text
        return headerView
    }
    
    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
       return 0
    }
    
     // row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       guard let cell: MainTableCell = cell as? MainTableCell else { return }
       cell.setCollectionView(dataSource: self, delegate: self, indexPath: indexPath)
    }
}


// MARK: - UICollectionView Data Source
extension EpisodesVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = seasons[collectionView.tag]
        return section.episodes?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let section = seasons[collectionView.tag]
            let cell = collectionView.dequeue(indexPath: indexPath) as EpisodeCell
            cell.posterImageView.image = UIImage(named: section.posterImageUrl ?? "")
            cell.episode = section.episodes?[indexPath.item]
            return cell
    }
}


// MARK: - UICollectionView Delegate
extension EpisodesVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // section
        let section = seasons[collectionView.tag]
        print("season : \(section.name ?? "") => \(indexPath.item)")

        // episode
        let episode = section.episodes?[indexPath.item]

        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.video = episode
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}


// MARK: - UICollectionViewDelegate Flow Layout
extension EpisodesVC: UICollectionViewDelegateFlowLayout {
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
        return collectionView.size(rows: 1, columns: 3)
    }
}
