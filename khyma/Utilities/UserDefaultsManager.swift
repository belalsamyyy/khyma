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
    
    // function to return saved movies in my list
    func savedMovies() -> [Movie] {
        do {
            guard let savedMoviesData = UserDefaults.standard.data(forKey: UserDefaultsKeys.myList) else { return [] }
            guard let savedMovies = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedMoviesData) as? [Movie] else { return [] }
            return savedMovies
        } catch {
            return []
        }
    }
    
    
    // function to delete a movie from my list
    func deleteMovie(movie: Movie) {
          let movies = savedMovies()
          let filteredMovies = movies.filter { (m) -> Bool in
            return m.name != movie.name
          }
            
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: filteredMovies, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.myList)
        } catch let error {
            print(error)
        }
    }
    
}
