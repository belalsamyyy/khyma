//
//  FavouriteVC.swift
//  khyma
//
//  Created by Belal Samy on 20/09/2021.
//

import UIKit

class myListVC: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var myListCollectionView: UICollectionView!

    //MARK: - variables
    
    var movies = Defaults.savedVideos()
    
    //MARK: - constants
    
    
    //MARK: - lifecylce
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // nav bar
        setupNavBar()
        
        movies = Defaults.savedVideos()
        myListCollectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    override func viewDidLayoutSubviews() {
        // nav bar
        setupNavBar()
        
        movies = Defaults.savedVideos()
        myListCollectionView.reloadData()
    }
    
    
    //MARK: - functions
    fileprivate func setupViews() {
        view.backgroundColor = Color.primary
        
        // nav bar
        setupNavBar()
        
        // list collection view
        myListCollectionView.backgroundColor = Color.primary
        myListCollectionView.layout(shortcut: .fillSuperView(0))
        
        myListCollectionView.delegate = self
        myListCollectionView.dataSource = self
        myListCollectionView.register(cell: MovieCell.self)
        myListCollectionView.reloadData()
        
        // long press gesture
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        myListCollectionView.addGestureRecognizer(gesture)
    }
    
    fileprivate func setupNavBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = StringsKeys.myList.localized
    }
        
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer ) {
        print("Captured Long Press")
        let location = gesture.location(in: myListCollectionView)
        guard let selectedIndexPath = myListCollectionView.indexPathForItem(at: location) else { return }
        print(selectedIndexPath )
        
        let selectedMovie = self.movies[selectedIndexPath.item]
        print(selectedMovie)
        
        let alertTitle = StringsKeys.removeAlertTitle.localized("\(selectedMovie.name ?? "")")
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: StringsKeys.removeAlertAction.localized, style: .destructive, handler: { (_) in
            
            self.movies.remove(at: selectedIndexPath.item)
            self.myListCollectionView.deleteItems(at: [selectedIndexPath])
            Defaults.deleteVideos(video: selectedMovie)
            self.myListCollectionView.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(title: StringsKeys.cancelAlert.localized, style: .cancel ))
        present(alertController, animated: true, completion: nil)
    }
}


//MARK: - extensions


// MARK: - UICollectionView Data Source
extension myListVC: UICollectionViewDataSource {

    // section
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
    
    // item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(indexPath: indexPath) as MovieCell
        cell.backgroundColor = Color.secondary
        cell.movie = movies[indexPath.item]
        return cell
    }
}


// MARK: - UICollectionView Delegate
extension myListVC: UICollectionViewDelegate {
    // item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.item]
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailsVC") as! DetailsVC
        detailsVC.modalPresentationStyle = .fullScreen
        detailsVC.video = movie
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
}


// MARK: - UICollectionViewDelegate Flow Layout
extension myListVC: UICollectionViewDelegateFlowLayout {
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

