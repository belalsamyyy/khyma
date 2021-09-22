//
//  PlaysVC.swift
//  khyma
//
//  Created by Belal Samy on 22/09/2021.
//

import UIKit

class PlaysVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = Color.primary
        view.labelIt("Plays", 25, Color.text)
    }

}
