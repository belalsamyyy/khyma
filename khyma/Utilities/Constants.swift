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
    static let interstitial = "2"
    static let rewardVideo = "3"
}

//MARK: - Colors

struct Color {
    static var primary = Defaults.darkMode == true ? #colorLiteral(red: 0.09411764706, green: 0.07843137255, blue: 0.07843137255, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static var secondary = Defaults.darkMode == true ? #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    static var text = Defaults.darkMode == true ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static var tabBar = Defaults.darkMode == true ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
}
