//
//  TabBarItems.swift
//  khyma
//
//  Created by Belal Samy on 20/09/2021.
//

import Foundation
import UIKit

enum TabBarItems: CaseIterable {
    case home
    case search
    case favourite
    case settings
    
    var ui: (viewController: UIViewController, icon: UIImage, title: String) {
        switch self {
        case .home:
            return (MainVC(), #imageLiteral(resourceName: "icon-home"), "Home")
        case .search:
            return (SearchVC(), #imageLiteral(resourceName: "icon-home"), "Search")
        case .favourite:
            return (FavouriteVC(), #imageLiteral(resourceName: "icon-home"), "Home")
        case .settings:
            return (SettingsVC(), #imageLiteral(resourceName: "icon-home"), "Home")
        }
    }
    
}
    
