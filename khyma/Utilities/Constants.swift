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
let ConfigID = "61641f9fa2ee6a208c57990c"
let OneSignalID = "9529c9c9-90b7-41fc-9f4e-114e2863bf75"

struct UserDefaultsKeys {
    static let firstTime = "firstTime"
    static let everySixHoursReward = "everySixHoursReward"
    static let language = "language"
    static let deviceID = "deviceID"
    static let coins = "coins"
    static let darkMode = "darkMode"
    static let backToSettings = "backToSettings"
    static let myList = "myList"
    static let continueWatching = "continueWatching"
}

struct Endpoints {
    // images
    static let image = "\(BASE_URL)/"
    static let config = "\(BASE_URL)/api/configs/"
    
    // Categories and genres
    static let genres = "\(BASE_URL)/api/genres"
    static let categories = "\(BASE_URL)/api/categories"
    
    // movies
    static let movies = "\(BASE_URL)/api/movies?nameEn=&nameAr="
    static let movieFromID = "\(BASE_URL)/api/movies/" // with id
    static let moviesFromGenreID = "\(BASE_URL)/api/movies/genre/" // with genre id

    // series
    static let series = "\(BASE_URL)/api/series?nameEn=&nameAr="
    static let serieFromID = "\(BASE_URL)/api/series/" // with id
    static let seasons = "\(BASE_URL)/api/seasons/serie/" // with series id
    
    // plays
    static let plays = "\(BASE_URL)/api/plays?nameEn=&nameAr="
    static let playFromID = "\(BASE_URL)/api/plays/" // with id
}

struct CategoryName {
    static let movies = "movies"
    static let series = "series"
    static let plays = "plays"
}

struct CategoryID {
    static let movies = "615c27d1920678e0b8e502e0"
    static let series = "615c520085fd16ab63fc3e8d"
    static let plays = "615c5b8785fd16ab63fc3ec5"
}


//MARK: - Ad Units Keys

struct AdUnitKeys {
    //test Ids
    //static let banner = "ca-app-pub-3940256099942544/2934735716"
    //static let interstitial = "ca-app-pub-3940256099942544/4411468910"
    //static let rewardVideo = "ca-app-pub-3940256099942544/1712485313"
    
    //read Ids
    
    // TabBar
    static let MainVCbannerUp = "ca-app-pub-9037650239384734/3402324628"
    static let SearchVCbannerUP = "ca-app-pub-9037650239384734/3210752938"
    static let MyListVCbannerUP = "ca-app-pub-9037650239384734/9776161289"
    static let SettingsVCbannerUP = "ca-app-pub-9037650239384734/8475947085"
    
    static let tabBarbannerDown = "ca-app-pub-9037650239384734/1350876358"
        
    // ————————

    // More
    static let MoreVCbannerUP = "ca-app-pub-9037650239384734/4228321130"
    static let MoreVCbannerDown = "ca-app-pub-9037650239384734/7724713011"

    // ————————

    // MovieVC
    static let MoviesVCbannerUP = "ca-app-pub-9037650239384734/1159304668"
    static let MoviesVCbannerDown = "ca-app-pub-9037650239384734/3785468008"

    // SeriesVC
    static let SeriesVCbannerUP = "ca-app-pub-9037650239384734/9967732972"
    static let SeriesVCbannerDown = "ca-app-pub-9037650239384734/9097504435"

    // PlaysVC
    static let PlaysVCbannerUP = "ca-app-pub-9037650239384734/4910793828"
    static let PlaysVCbannerDown = "ca-app-pub-9037650239384734/7668819103"

    // ————————

    // VideoPlayerVC
    static let VideoPlayerVCbannerUP = "ca-app-pub-9037650239384734/1779387544"
    static let VideoPlayerVCbannerDown = "ca-app-pub-9037650239384734/3597712150"

    static let VideoPlayerVCInterstitial = "ca-app-pub-9037650239384734/1246233213"
    static let VideoPlayerVCRewardVideo = "ca-app-pub-9037650239384734/4276369008"

}

//MARK: - Colors

struct Color {
    static let primary = UIColor(named: "color-primary")!
    static let secondary = UIColor(named: "color-secondary")!
    static let text = UIColor(named: "color-text")!
}

//MARK: - Strings

struct StringsKeys {
    //Ads
    static let noAdsAlertTitle = "noAdsAlertTitle"
    static let noAdsAlertMessage = "noAdsAlertMessage"
    static let watchAd = "watchAd"
    static let wait = "wait"

    //Connection
    static let noConnection = "noConnection"
    static let update = "update"

    //Main
    static let continueWatching = "continueWatching"
    static let popular = "popular"
    static let movies = "movies"
    static let series = "series"
    static let plays = "plays"
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
    static let removeFromMyList = "removeFromMyList"
    static let removeFromContinueWatching = "removeFromContinueWatching"

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
