//
//  HorizontalPaginationManager.swift
//  khyma
//
//  Created by Belal Samy on 20/10/2021.
//

import Foundation
import UIKit

protocol HorizontalPaginationManagerDelegate: AnyObject {
    func loadMore(completion: @escaping (Bool) -> Void)
}

protocol VerticalPaginationManagerDelegate: AnyObject {
    func loadMore(completion: @escaping (Bool) -> Void)
}

public func refreshDelay(_ delay: Double, closure: @escaping () -> Void) {
    let deadline = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(
        deadline: deadline,
        execute: closure
    )
}

enum PaginationDirection {
    case horizontal
    case vertical
}

class PaginationManager: NSObject {
    
    private var isLoading = false
    private var isObservingKeyPath: Bool = false
    private var scrollView: UIScrollView!
    
    private var horizontalLoader: UIView?
    private var verticalLoader: UIView?

    var paginationDirection: PaginationDirection = .horizontal
    var refreshViewColor: UIColor = .white
    var loaderColor: UIColor = .white
    
    weak var delegateH: HorizontalPaginationManagerDelegate?
    weak var delegateV: VerticalPaginationManagerDelegate?

    init(scrollView: UIScrollView, direction: PaginationDirection) {
        super.init()
        self.scrollView = scrollView
        self.addScrollViewOffsetObserver()
        self.paginationDirection = direction
    }
    
    deinit {
        self.removeScrollViewOffsetObserver()
    }
    
    func initialLoad() {
        self.delegateH?.loadMore(completion: {_ in })
    }
}

// MARK: Horizontal LOADER
extension PaginationManager {
    
    private func addHorizontalLoaderControl() {
        let view = UIView()
        view.backgroundColor = self.refreshViewColor
        view.frame.origin = CGPoint(x: self.scrollView.contentSize.width, y: 0)
        view.frame.size = CGSize(width: 60, height: self.scrollView.bounds.height)
        let activity = UIActivityIndicatorView(style: .large)
        activity.color = self.loaderColor
        activity.frame = view.bounds
        activity.startAnimating()
        view.addSubview(activity)
        self.scrollView.contentInset.right = view.frame.width
        self.horizontalLoader = view
        self.scrollView.addSubview(view)
    }
    
    func removeHorizontalLoader() {
        self.horizontalLoader?.removeFromSuperview()
        self.horizontalLoader = nil
    }
    
}

// MARK: VERTICAL LOADER
extension PaginationManager {
    
    private func addVerticalLoaderControl() {
        let view = UIView()
        view.backgroundColor = self.refreshViewColor
        view.frame.origin = CGPoint(x: 0, y: self.scrollView.contentSize.height)
        view.frame.size = CGSize(width: self.scrollView.bounds.width, height: 60)
        let activity = UIActivityIndicatorView(style: .large)
        activity.color = self.loaderColor
        activity.frame = view.bounds
        activity.startAnimating()
        view.addSubview(activity)
        self.scrollView.contentInset.bottom = 60
        self.verticalLoader = view
        self.scrollView.addSubview(view)
    }
    
    func removeVerticalLoader() {
        self.verticalLoader?.removeFromSuperview()
        self.verticalLoader = nil
    }
    
}


// MARK: OFFSET OBSERVER
extension PaginationManager {
    
    private func addScrollViewOffsetObserver() {
        if self.isObservingKeyPath { return }
        self.scrollView.addObserver(
            self,
            forKeyPath: "contentOffset",
            options: [.new],
            context: nil
        )
        self.isObservingKeyPath = true
    }
    
    private func removeScrollViewOffsetObserver() {
        if self.isObservingKeyPath {
            self.scrollView.removeObserver(self,
                                           forKeyPath: "contentOffset")
        }
        self.isObservingKeyPath = false
    }
    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        guard let object = object as? UIScrollView,
            let keyPath = keyPath,
            let newValue = change?[.newKey] as? CGPoint,
            object == self.scrollView, keyPath == "contentOffset" else { return }
        self.setContentOffSet(newValue)
    }
    
    private func setContentOffSet(_ offset: CGPoint) {
        
        switch paginationDirection {
        case .horizontal:
            let offsetX = offset.x
            let contentWidth = self.scrollView.contentSize.width
            let frameWidth = self.scrollView.bounds.size.width
            
            let diffX = contentWidth - frameWidth
            if contentWidth > frameWidth, offsetX > (diffX + 50) && !self.isLoading {
                self.isLoading = true
                self.addHorizontalLoaderControl()
                self.delegateH?.loadMore { success in
                    self.isLoading = false
                    self.removeHorizontalLoader()
                }
            }
            
        case .vertical:
            let offsetY = offset.y
            let contentHeight = self.scrollView.contentSize.height
            let frameHeight = self.scrollView.bounds.size.height
            
            let diffY = contentHeight - frameHeight
            if contentHeight > frameHeight, offsetY > (diffY + 100) && !self.isLoading {
                self.isLoading = true
                self.addVerticalLoaderControl()
                self.delegateV?.loadMore { success in
                    self.isLoading = false
                    self.removeVerticalLoader()
                }
            }
        }
        
    }
    
}
