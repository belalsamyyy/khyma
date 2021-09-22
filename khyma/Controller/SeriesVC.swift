//
//  SeriesVC.swift
//  khyma
//
//  Created by Belal Samy on 22/09/2021.
//

import UIKit

class SeriesVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = Color.primary
        view.labelIt("Series", 25, Color.text)
    }
    

}
