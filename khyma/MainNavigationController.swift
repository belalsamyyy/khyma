//
//  MainNavController.swift
//  khyma
//
//  Created by Belal Samy on 08/10/2021.
//

import UIKit
import SimpleAPI

// preventing navController from pushing twice
class MainNavController: UINavigationController {
    var isPushing = false
    
    //MARK: - lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleEverySixHoursReward()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = Color.primary
        navigationBar.tintColor = Color.text        
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
    
    //MARK: - function
    fileprivate func handleEverySixHoursReward() {
        if let date = UserDefaults.standard.object(forKey: UserDefaultsKeys.everySixHoursReward) as? Date {
            if let diff = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, diff > 6 {
                print("earn 3000 coins every 6 hours")
                Defaults.def.set(Date(), forKey: UserDefaultsKeys.everySixHoursReward)
                Defaults.coins += 3000
                let message = " +3000 coins"
                let greenColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                self.showToast(duration: 6.0, color: greenColor, message: message, font: .systemFont(ofSize: 18))
            }
        }
    }
}
