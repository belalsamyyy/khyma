//
//  TableCell.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import UIKit

extension UICollectionViewFlowLayout {
    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return Language.currentLanguage == Lang.english.rawValue ? false : true
    }
}

//MARK: - CollectionView
class CollectionView: UICollectionView {
    var indexPath: IndexPath!
}

//MARK: - TableView Cell
class MainTableCell: UITableViewCell {
    static let identifier = "MainTableCell"
    var collectionView: CollectionView!
    var collectionFlowLayout = UICollectionViewFlowLayout()
    var paginagationManager: PaginationManager!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        //collectionFlowLayout.scrollDirection = .horizontal
        collectionView = CollectionView(frame: .zero, collectionViewLayout: collectionFlowLayout)
        
        // register
        collectionView.register(cell: MovieCell.self)
        collectionView.register(cell: ContinueWatchingCell.self)
        collectionView.register(cell: VideoCell.self)
        
        collectionView.backgroundColor = Color.primary
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        collectionView.isDirectionalLockEnabled = true
        collectionView.isMultipleTouchEnabled = false
        collectionView.isOpaque = true
        collectionView.alwaysBounceHorizontal = true
        
        // Pagination manager
        paginagationManager = PaginationManager(scrollView: collectionView, direction: .horizontal)
        paginagationManager.refreshViewColor = .clear
        paginagationManager.loaderColor = Color.text
        
        collectionView.reloadData()
        contentView.addSubview(collectionView)
    }

    
    //MARK: - init
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    final override func layoutSubviews() {
        super.layoutSubviews()
        guard collectionView.frame != contentView.bounds else { return }
        collectionView.frame = contentView.bounds
        collectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    //MARK: - setCollectionView
    
    final func setCollectionView(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate, indexPath: IndexPath) {
        collectionView.indexPath = indexPath
        collectionView.tag = indexPath.section
        
        if collectionView.dataSource == nil {
            collectionView.dataSource = dataSource
        }

        if collectionView.delegate == nil {
            collectionView.delegate = delegate
        }

        collectionView.reloadData()
    }
}

