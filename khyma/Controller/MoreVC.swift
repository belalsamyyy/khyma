//
//  MoreVC.swift
//  khyma
//
//  Created by Belal Samy on 26/09/2021.
//

import UIKit
import SimpleAPI

class MoreVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var moreCollectionView: UICollectionView!
    
    //MARK: - variables
    
    var videos = [Video?]()
    var categoryName: String?
    var genreID: String?
    var genreName: String?
    
    //MARK: - constants

    let customNavBar = MoreNavBar()
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
        getVideos()
        print("genre id is => \(genreID ?? "")")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addCustomNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        customNavBar.removeFromSuperview()
    }
    
    //MARK: - functions
    
    fileprivate func getVideos() {
        Video.endpoint = "\(BASE_URL)/api/\(categoryName ?? "")/genre/\(genreID ?? "")"
        API<Video>.list { [weak self] result in
            switch result {
            case .success(let data):
                self?.videos = data
                DispatchQueue.main.async {
                    self?.moreCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    fileprivate func setupViews() {
        addCustomNavBar()
        
        moreCollectionView.backgroundColor = Color.primary
        moreCollectionView.layout(shortcut: .fillSuperView(0))
        
        moreCollectionView.delegate = self
        moreCollectionView.dataSource = self
        moreCollectionView.register(cell: MovieCell.self)
        moreCollectionView.reloadData()
    }
    
    fileprivate func addCustomNavBar() {
        navigationController?.navigationBar.barTintColor = Color.primary
        customNavBar.delegate = self // custom delegation pattern
        customNavBar.moreLabel.text = genreName // StringsKeys.more.localized
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(customNavBar)
        customNavBar.layout(X: .center(nil), W: .equal(nil, 0.9), Y: .center(nil), H: .fixed(50))
    }
    
    
    //MARK: - actions
    
}

//MARK: - extensions

//MARK: - CustomNavBar Delegate

extension MoreVC: MoreNavBarDelegate {
    // custom delegation pattern
    func handleCancelTapped() {
        print("cancel tapped here from more vc")
        self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - UICollectionView Data Source
extension MoreVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(indexPath: indexPath) as MovieCell
        cell.backgroundColor = Color.secondary
        cell.video = videos[indexPath.item]
        return cell
    }
}


// MARK: - UICollectionView Delegate
extension MoreVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = videos[indexPath.item]
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.video = movie
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}


// MARK: - UICollectionViewDelegate Flow Layout
extension MoreVC: UICollectionViewDelegateFlowLayout {
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
        return collectionView.size(height: 200, columns: 3)
    }
}



