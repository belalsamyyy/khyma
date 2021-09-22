//
//  Constants.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import Foundation
import UIKit

//MARK: - UserDefaults Keys

struct UserDefaultsKeys {
    static let deviceID = "deviceID"
    static let coins = "coins"
    static let darkMode = "darkMode"
}

//MARK: - Ad Units Keys

struct AdUnitKeys {
    static let banner = "ca-app-pub-3940256099942544/2934735716"
    static let interstitial = "ca-app-pub-3940256099942544/4411468910"
    static let rewardVideo = "ca-app-pub-3940256099942544/1712485313"
}

//MARK: - Colors

struct Color {
    static let primary = UIColor(named: "color-primary")!
    static let secondary = UIColor(named: "color-secondary")!
    static let text = UIColor(named: "color-text")!
}
