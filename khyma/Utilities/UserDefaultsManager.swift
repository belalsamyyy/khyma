//
//  UserDefaultsManager.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import Foundation

var Defaults = UserDefaultsManager.shared

struct UserDefaultsManager {
    
    //MARK: - singleton manager
    
    static var shared = UserDefaultsManager()
    private init() {}
    let def = UserDefaults.standard
    
    //MARK: - computed properties
    
    // computed propery for deviceID
    var deviceID: String {
        set {
            def.set(newValue, forKey: UserDefaultsKeys.deviceID)
        } get {
            guard def.object(forKey: UserDefaultsKeys.deviceID) != nil else {
                return "deviceID not existing"
            }
            return def.object(forKey: UserDefaultsKeys.deviceID) as! String
        }
    }
    
    // computed propery for deviceID
    var coins: Int {
        set {
            def.set(newValue, forKey: UserDefaultsKeys.coins)
        } get {
            guard def.object(forKey: UserDefaultsKeys.coins) != nil else {
                return 0
            }
            return def.object(forKey: UserDefaultsKeys.coins) as! Int
        }
    }
    
    // computed propery for darkMode
    var darkMode: Bool {
        set {
            def.set(newValue, forKey: UserDefaultsKeys.darkMode)
        } get {
            guard def.object(forKey: UserDefaultsKeys.darkMode) != nil else {
                return true
            }
            return def.object(forKey: UserDefaultsKeys.darkMode) as! Bool
        }
    }
    
 
}
