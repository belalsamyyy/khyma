//
//  MainTabBarVC.swift
//  khyma
//
//  Created by Belal Samy on 20/09/2021.
//

import UIKit

class MainTabBarVC: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        view.backgroundColor = Color.primary
    }
    
    fileprivate func templateNavController(unselected: UIImage, selected: UIImage,
                                               rootViewController: UIViewController = UIViewController() ) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselected
        navController.tabBarItem.selectedImage = selected
        return navController
    }

}
