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

public func refreshDelay(_ delay: Double, closure: @escaping () -> Void) {
    let deadline = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(
        deadline: deadline,
        execute: closure
    )
}

class HorizontalPaginationManager: NSObject {
    
    private var isLoading = false
    private var isObservingKeyPath: Bool = false
    private var scrollView: UIScrollView!
    private var moreLoader: UIView?
    var refreshViewColor: UIColor = .white
    var loaderColor: UIColor = .white
    
    weak var delegate: HorizontalPaginationManagerDelegate?
    
    init(scrollView: UIScrollView) {
        super.init()
        self.scrollView = scrollView
        self.addScrollViewOffsetObserver()
    }
    
    deinit {
        self.removeScrollViewOffsetObserver()
    }
    
    func initialLoad() {
        self.delegate?.loadMore(completion: {_ in })
    }
    
}

// MARK: More LOADER
extension HorizontalPaginationManager {
    
    private func addmoreLoaderControl() {
        let view = UIView()
        view.backgroundColor = self.refreshViewColor
        view.frame.origin = CGPoint(x: self.scrollView.contentSize.width, y: 0)
        view.frame.size = CGSize(width: 60, height: self.scrollView.bounds.height)
        let activity = UIActivityIndicatorView(style: .medium)
        activity.color = self.loaderColor
        activity.frame = view.bounds
        activity.startAnimating()
        view.addSubview(activity)
        self.scrollView.contentInset.right = view.frame.width
        self.moreLoader = view
        self.scrollView.addSubview(view)
    }
    
    func removeMoreLoader() {
        self.moreLoader?.removeFromSuperview()
        self.moreLoader = nil
    }
    
}

// MARK: OFFSET OBSERVER
extension HorizontalPaginationManager {
    
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
        let offsetX = offset.x
        let contentWidth = self.scrollView.contentSize.width
        let frameWidth = self.scrollView.bounds.size.width
        
        let diffX = contentWidth - frameWidth
        if contentWidth > frameWidth, offsetX > (diffX + 100) && !self.isLoading {
            self.isLoading = true
            self.addmoreLoaderControl()
            self.delegate?.loadMore { success in
                self.isLoading = false
                self.removeMoreLoader()
            }
        }
    }
    
}
