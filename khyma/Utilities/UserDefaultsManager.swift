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
    
    // computed propery for language
        var language: String {
            set {
                def.set(newValue, forKey: UserDefaultsKeys.language)
            } get {
                guard def.object(forKey: UserDefaultsKeys.language) != nil else {
                    return "language not specified"
                }
                return def.object(forKey: UserDefaultsKeys.language) as! String
            }
        }
    
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
    
    // computed propery for coins
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
    
    // computed propery for backToSettings
    var backToSettings: Bool {
        set {
            def.set(newValue, forKey: UserDefaultsKeys.backToSettings)
        } get {
            guard def.object(forKey: UserDefaultsKeys.backToSettings) != nil else {
                return false
            }
            return def.object(forKey: UserDefaultsKeys.backToSettings) as! Bool
        }
    }
    
    // function to return saved videos in my list
    func savedVideos() -> [Watchable?] {
        do {
            guard let savedVideossData = UserDefaults.standard.data(forKey: UserDefaultsKeys.myList) else { return [] }
            guard let savedVideos = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedVideossData) as? [Watchable?] else { return [] }
            return savedVideos
        } catch {
            return []
        }
    }
    
    
    // function to delete a video from my list
    func deleteVideos(video: Watchable?) {
          let videos = savedVideos()
          let filteredVideos = videos.filter { (m) -> Bool in
              return m?.name != video?.name
          }
            
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: filteredVideos, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.myList)
        } catch let error {
            print(error)
        }
    }
    
    
    // function to return saved continue Watching
    func savedContinueWatching() -> [Watchable?] {
        do {
            guard let savedVideossData = UserDefaults.standard.data(forKey: UserDefaultsKeys.continueWatching) else { return [] }
            guard let savedVideos = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedVideossData) as? [Watchable?] else { return [] }
            return savedVideos
        } catch {
            return []
        }
    }
    
    
    // function to delete a continue Watching
    func deleteContinueWatching(video: Watchable?) {
          let videos = savedContinueWatching()
          let filteredVideos = videos.filter { (m) -> Bool in
              return m?.name != video?.name
          }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: filteredVideos, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.continueWatching)
        } catch let error {
            print(error)
        }
    }
    
    
    
}
