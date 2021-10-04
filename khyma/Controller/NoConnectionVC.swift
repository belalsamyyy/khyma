//
//  NoConnectionVC.swift
//  khyma
//
//  Created by Belal Samy on 04/10/2021.
//

import Network
import UIKit
import DesignX

class NoConnectionVC: UIViewController {
    
    var gradientLayer = CAGradientLayer()
    var connectionColor = UIColor()
    let noConnectionImage = UIImageView()
    let noConnectinoLabel = UILabel()

    //MARK: - constants
    
    // check network
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
        checkConnection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkConnection()
    }
    
    override func viewDidLayoutSubviews() {
        self.gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = Color.primary
        
        view.addSubview(noConnectionImage)
        noConnectionImage.layout(X: .center(nil), W: .fixed(200), Y: .center(nil), H: .fixed(200))
        noConnectionImage.image = UIImage(named: "icon-no-connection")
        noConnectionImage.alpha = 0.50
        
        view.addSubview(noConnectinoLabel)
        noConnectinoLabel.layout(X: .center(nil), W: .equal(nil, 1), Y: .top(noConnectionImage, 20), H: .fixed(50))
        noConnectinoLabel.text = StringsKeys.noConnection.localized
        noConnectinoLabel.textColor = Color.text
        noConnectinoLabel.textAlignment = .center
        noConnectinoLabel.font = UIFont.boldSystemFont(ofSize: 25)
    }
    
    fileprivate func checkConnection() {
            self.monitor.pathUpdateHandler = { [weak self] pathUpdateHandler in
               if pathUpdateHandler.status == .satisfied {
                   print("Internet connection is on.")
                   DispatchQueue.main.async {
                       self?.noConnectionImage.isHidden =  true
                       self?.gradientLayer = self?.view.fill(gradient: [.color(.green), .color(.clear)], locations: [0, 0.03], opacity: 1) ?? CAGradientLayer()
                       self?.dismiss(animated: true)
                   }
                   
               } else {
                   print("There's no internet connection.")
                   DispatchQueue.main.async {
                       self?.noConnectionImage.isHidden =  false
                       self?.gradientLayer = self?.view.fill(gradient: [.color(.red), .color(.clear)], locations: [0, 0.03], opacity: 1) ?? CAGradientLayer()
                   }
               }
            }
            self.monitor.start(queue: self.queue)
    }
    
}
