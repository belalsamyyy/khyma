//
//  Constants.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import Foundation
import UIKit

//MARK: - UserDefaults Keys

let BASE_URL = "https://polar-plateau-31663.herokuapp.com"

struct Endpoints {
    
    // images
    static let image = "\(BASE_URL)/"

    // list
    static let genres = "\(BASE_URL)/api/genres"
    static let categories = "\(BASE_URL)/api/categories"
    
    static let movies = "\(BASE_URL)/api/movies"
    static let series = "\(BASE_URL)/api/series"
    static let plays = "\(BASE_URL)/api/plays"

    // movies from specific genre id
    static let moviesFromGenreID = "\(BASE_URL)/api/movies/genre/"
    
}

struct UserDefaultsKeys {
    static let language = "language"
    static let deviceID = "deviceID"
    static let coins = "coins"
    static let darkMode = "darkMode"
    static let backToSettings = "backToSettings"
    static let myList = "myList"
    static let continueWatching = "continueWatching"
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

//MARK: - Strings
struct StringsKeys {
    //Connection
    static let noConnection = "noConnection"
    
    //Movies
    static let bodyGuard = "bodyGuard" // Body Guard
    static let avengers = "avengers" // Avengers: End Game
    static let weladRizk = "weladRizk" // Welad Rizk 2
    static let batman = "batman" // Batman Hush
    static let blueElephant = "blueElephant" // Blue Elephant 2
    
    //Main
    static let continueWatching = "continueWatching"
    static let popular = "popular"
    static let movies = "movies"
    static let series = "series"
    static let plays = "plays"
    static let anime = "anime"
    static let more = "more"
    
    // Series
    static let season = "season"
    static let episode = "episode"
    
    // Details
    static let add = "add"
    
    // Search
    static let search = "search"
    static let searchPlaceholder = "searchPlaceholder"
    
    // My List
    static let myList = "myList"
    static let removeAlertTitle = "removeAlertTitle"
    static let cancelAlert = "cancelAlert"
    static let removeAlertAction = "removeAlertAction"
    static let addAlertAction = "addAlertAction"
    
    // Settings
    static let settings = "settings"
    static let coins = "coins"
    static let theme = "theme"
    static let darkMode = "darkMode"
    static let language = "language"
    static let changeLangAlert = "changeLangAlert"
    static let english = "english"
    static let arabic = "arabic"
    static let currentLanguage = "currentLanguage"
    
    // movies category
    static let back = "back"
    
}
