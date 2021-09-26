//
//  MainTabBar.swift
//  khyma
//
//  Created by Belal Samy on 23/09/2021.
//

import DesignX
import GoogleMobileAds

class MainTabBar: UITabBarController {
    
    // The banner ad
    private var bannerAd: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.banner
      banner.load(GADRequest())
      return banner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadBannerAd()
    }
    
    fileprivate func loadBannerAd() {
       bannerAd.rootViewController = self
       view.addSubview(bannerAd)
        
       bannerAd.layout(XW: .leadingAndCenter(nil, 0), Y: .bottomToSafeArea(self.tabBar, 0), H: .fixed(60))
    }

}
