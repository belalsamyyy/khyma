//
//  MainNavController.swift
//  khyma
//
//  Created by Belal Samy on 08/10/2021.
//

import UIKit

// preventing navController from pushing twice
class MainNavController: UINavigationController {
    var isPushing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = Color.primary
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !isPushing {
            isPushing = true
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.isPushing = false
            }
            super.pushViewController(viewController, animated: animated)
            CATransaction.commit()
        }
    }
}
