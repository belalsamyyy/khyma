//
//  MainTableView.swift
//  khyma
//
//  Created by Belal Samy on 07/10/2021.
//

import Foundation
import UIKit

final class MainTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height + 100)
    }
}
