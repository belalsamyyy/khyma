//
//  DetailsVC.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import GoogleMobileAds
import youtube_ios_player_helper
import DesignX

class DetailsVC: UIViewController {
    
    //MARK: - outlets
    @IBOutlet weak var videoTitle: UILabel!
    
    //MARK: - variables
    
    // video object
    var video: Watchable?
    
    // The video player
    var YoutubePlayer = YTPlayerView()
    var timerState = TimerState.notStarted
    
    // The reward timer.
    var rewardTimer: Timer?
    var timeRemaining = 0 // in seconds
    
    var pauseDate: Date?
    var previousFireDate: Date?
    
    // The banner ad
    private var bannerAd: GADBannerView = {
      let banner = GADBannerView()
      banner.adUnitID = AdUnitKeys.banner
      banner.load(GADRequest())
      return banner
    }()
    
    // The interstitial ad
     var interstitialAd: GADInterstitialAd?
       
     // The rewarded video ad
     var rewardedAd: GADRewardedAd?
    
    //MARK: - constants

      // Timer state
      enum TimerState {
        case notStarted
        case playing
        case paused
        case ended
      }

      // reward
      let rewardValue = 5 // earn 5 coins
      let rewardFrequency = 10 // every 10 seconds
          
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup Views
        setupViews()
        
        // youtube video player
        let youtubeID = video?.youtubeUrl?.youtubeID ?? ""
        loadYoutubeVideo(from: youtubeID)
          
        // Pause timer when application is backgrounded.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        // Resume timer when application is returned to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // admob ads
        loadBannerAd()
        
        if Int.random(in: 1...10) % 2 == 0 {
            presentRewardVideo()
        } else {
            presentinterstitialAd()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerState = .ended
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    override func viewDidLayoutSubviews() {
        setupNavBar()
    }

    
    //MARK: - functions
    
    fileprivate func setupViews() {
        setupNavBar()
        
        view.addSubview(YoutubePlayer)
        YoutubePlayer.layout(XW :.leadingAndCenter(nil, 0), Y: .topToSafeArea(nil, 0), H: .fixed(300))
        videoTitle.layout(XW: .leadingAndCenter(nil, 0), Y: .top(YoutubePlayer, 10), H: .fixed(50))
        videoTitle.textAlignment = .center
        videoTitle.text = video?.name

    }
    
    fileprivate func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        self.navigationController?.navigationBar.topItem?.title = "\(StringsKeys.coins.localized): \(Defaults.coins)"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // check if we have already saved this movie in my list
        let savedVideos = Defaults.savedVideos()
        let isInMyList = savedVideos.firstIndex(where: {$0?.name == video?.name}) != nil
        
        if isInMyList {
            // setting up our heart icon
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-favourite").withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: StringsKeys.add.localized, style: .plain, target: self, action: #selector(handleAddToMyList)),
            ]
        }
    }
    
    @objc fileprivate func handleAddToMyList() {
        
        
        let alertController = UIAlertController(title: video?.name, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: StringsKeys.addAlertAction.localized, style: .default, handler: { (_) in
            // add to my list ---------------------------------
            guard let video =  self.video else { return }
             
            do {
             var listOfVideos = Defaults.savedVideos()
                listOfVideos.append(video)
        
             // transform movie into data
             let data = try NSKeyedArchiver.archivedData(withRootObject: listOfVideos, requiringSecureCoding: true)
             UserDefaults.standard.set(data , forKey: UserDefaultsKeys.myList)
             self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-favourite").withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)

             
            } catch let error {
                print("Failed to save info into userDefaults : ", error)
            }
            // ------------------------------------------------
        }))
        
        alertController.addAction(UIAlertAction(title: StringsKeys.cancelAlert.localized, style: .cancel ))
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func addToContinueWatching() {
        
        let continueWatching = Defaults.savedContinueWatching()
        let isInContinueWatching = continueWatching.firstIndex(where: {$0?.name == video?.name}) != nil
        
        if isInContinueWatching {
            // if it's in my contiue watching, do nothing
            
        } else {
            // add to my list ---------------------------------
            guard let video =  self.video else { return }
            
            do {
             var listOfVideos = Defaults.savedContinueWatching()
                listOfVideos.append(video)
        
             // transform movie into data
             let data = try NSKeyedArchiver.archivedData(withRootObject: listOfVideos, requiringSecureCoding: true)
             UserDefaults.standard.set(data , forKey: UserDefaultsKeys.continueWatching)
            
            } catch let error {
                print("Failed to save info into userDefaults : ", error)
            }
            // ------------------------------------------------
        }
    }
    
    fileprivate func deleteFromContinueWatching() {
        // if it's in my contiue watching, do nothing
        Defaults.deleteContinueWatching(video: video)
        UserDefaultsManager.shared.def.set(Float(0), forKey: video?.name ?? "")
    }
    
    //MARK: - functions - Reward Timer
        
        func startTimer() {
            
            if timerState == .notStarted {
                getVideoDuration()
                
                if let continueWatchingAt = UserDefaultsManager.shared.def.object(forKey: self.video?.name ?? "") {
                    YoutubePlayer.playVideo()
                    YoutubePlayer.seek(toSeconds: continueWatchingAt as! Float, allowSeekAhead: true)
                }
            }
            
            timerState = .playing
            rewardTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        }
        
        @objc func timerTick() {
            if timeRemaining > 0 {
                updateTimeRemaining()
                getCurrentTime()
            } else {
                endTimer()
            }
        }

        func updateTimeRemaining() {
            if timerState == .playing {
                timeRemaining -= 1
                let (hours, minutes, seconds) = timeRemaining.hoursAndMinutesAndSeconds()
                print("remaining => \(hours.twoDigits()):\(minutes.twoDigits()):\(seconds.twoDigits())")
                
                // reward the user every "n" seconds with "n" coins
                if seconds % rewardFrequency == 0 {
                    earnCoins(rewardValue)
                }
            }
        }
        
        func endTimer() {
            timerState = .ended
            print("The timer ends !")
            
            timeRemaining = 0
            //timeRemainingLabel.text = "The timer ends !"
            
            // fix timer issues after replay
            resetTimer()
            
            rewardTimer?.invalidate()
            rewardTimer = nil
        }
        
        func pauseTimer() {
            // Pause the timer if it is currently playing.
            if timerState != .playing {
              return
            }
            timerState = .paused

            // Record the relevant pause times.
            pauseDate = Date()
            previousFireDate = rewardTimer?.fireDate

            // Prevent the timer from firing while app is in background.
            rewardTimer?.fireDate = Date.distantFuture
        }
        
        func resumeTimer() {
            // Resume the timer if it is currently paused.
            if timerState != .paused {
              return
            }
            timerState = .playing

            // Calculate amount of time the app was paused.
            let pauseTime = (pauseDate?.timeIntervalSinceNow)! * -1

            // Set the timer to start firing again.
            rewardTimer?.fireDate = (previousFireDate?.addingTimeInterval(pauseTime))!
            
            pauseTimer()
        }
        

        func resetTimer() {
            timerState = .notStarted
            YoutubePlayer.stopVideo()
        }
        
        
        // Pause timer in background and resume when comeback
        
        @objc func applicationDidEnterBackground(_ notification: Notification) {
            self.pauseTimer()
        }

        @objc func applicationDidBecomeActive(_ notification: Notification) {
            self.resumeTimer()
        }
        
        
    //MARK: - functions - Youtube Video player
        
        func loadYoutubeVideo(from id: String) {
            // youtube video
            YoutubePlayer.delegate = self
            YoutubePlayer.load(withVideoId: id, playerVars: ["playsinline": "1"])
        }
        
        func getVideoDuration() {
            self.YoutubePlayer.duration { [weak self] duration, error in
                self?.timeRemaining = Int(duration)
                UserDefaultsManager.shared.def.set(Float(duration), forKey: "\(self?.video?.name ?? "") duration")
            }
        }
        
        func videoDuration() -> Double {
            var videoDuration: Double = 0
            self.YoutubePlayer.duration { duration, error in
                videoDuration = duration
            }
            return videoDuration
        }
    
        func getCurrentTime() {
            if timerState == .playing {
                self.YoutubePlayer.currentTime { [weak self] currentTime, error in
                    // save current time in user defaults
                    UserDefaultsManager.shared.def.set(currentTime, forKey: self?.video?.name ?? "")
                    
                    self?.YoutubePlayer.duration { [weak self] duration, error in
                        if currentTime >= 0.95 * Float(duration) {
                            // delete from continue watching after watching 95% of video
                            self?.deleteFromContinueWatching()
                        } else {
                            // add video to continue watching
                            self?.addToContinueWatching()
                        }
                    }
                }
            }
        }
    
    
    //MARK: - functions - admob ads
    
    fileprivate func loadBannerAd() {
       bannerAd.rootViewController = self
       view.addSubview(bannerAd)
       bannerAd.layout(XW: .leadingAndCenter(nil, 0), Y: .bottomToSafeArea(nil, 0), H: .fixed(60))
    }
    
    fileprivate func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AdUnitKeys.interstitial, request: request) { (ad, error) in
          if let error = error {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
            return
          }
          
          print("Interstitial Loading Succeeded")
          self.interstitialAd = ad
          self.interstitialAd?.fullScreenContentDelegate = self
        }
      }
      
        
      fileprivate func loadRewardVideoAd() {
        GADRewardedAd.load(withAdUnitID: AdUnitKeys.rewardVideo, request: GADRequest())  { (ad, error) in
            
          if let error = error {
            print("Rewarded ad failed to load with error: \(error.localizedDescription)")
            return
          }
            
          print("Reward Video Loading Succeeded")
          self.rewardedAd = ad
          self.rewardedAd?.fullScreenContentDelegate = self
        }
      }
        
        
        func presentinterstitialAd() {
           DispatchQueue.background(background: {
               // do something in background
               self.loadInterstitialAd()

           }, completion:{
               // when background job finished, do something in main thread
               if let ad = self.interstitialAd {
                   //success
                   ad.present(fromRootViewController: self)
               } else {
                 // the Ad failed to present .. try again
                   self.presentinterstitialAd()
               }
           })
        }
           
           
        func presentRewardVideo() {
           DispatchQueue.background(background: {
               // do something in background
               self.loadRewardVideoAd()

           }, completion:{
               // when background job finished, do something in main thread
               if let ad = self.rewardedAd {
                  // reward the user
                  ad.present(fromRootViewController: self) {
                }
                 
                } else {
                
                 // the Ad failed to present .. try again
                self.presentRewardVideo()

               }
           })
        }

        
    
    //MARK: - functions - coins
      
      fileprivate func earnCoins(_ coins: NSInteger) {
          print("Reward received with \(coins) coins")
          Defaults.coins += coins
          let rewardMessage = coins == 1 ? " +\(coins) coin" : " +\(coins) coins"
          self.showToast(message: rewardMessage, font: .systemFont(ofSize: 18))
      }
        
     fileprivate func loseCoins(_ coins: NSInteger) {
        Defaults.coins -= coins
     }
    
    //MARK: - actions
    
}


//MARK: - extensions

// Admob ads
extension DetailsVC: GADFullScreenContentDelegate {
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) { print("ad presented.") }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad dismissed.")
    }

    func ad(_ ad: GADFullScreenPresentingAd,didFailToPresentFullScreenContentWithError error: Error) {
      print("Ad failed to present with error: \(error.localizedDescription).")
    }
}

// youtube player
extension DetailsVC: YTPlayerViewDelegate {
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        return Color.secondary
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
      switch state {
          case .unstarted:
              print("unstarted")
              timerState = .notStarted
            
          case .ended:
              print("ended")
              endTimer()
          
          case .playing:
              print("playing")
              startTimer()
              
          case .paused:
              print("paused")
              pauseTimer()
              
          case .buffering:
              print("buffering")
              
          case .cued:
              print("cued")
              
          case .unknown:
              print("unknown")

          @unknown default:
              print("default")
          }
      }
}
