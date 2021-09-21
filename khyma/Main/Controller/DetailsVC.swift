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
    @IBOutlet weak var coinCountLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    //MARK: - variables
    
    // The video player
    var YoutubePlayer = YTPlayerView()
    var timerState = TimerState.notStarted
    var youtubeID: String!
    
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
      banner.backgroundColor = .lightGray
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
      let rewardFrequency = 5 // every 5 seconds
      
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup Views
        setupViews()
        
        // youtube video player
        loadYoutubeVideo(from: youtubeID)
          
        // Pause timer when application is backgrounded.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        // Resume timer when application is returned to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // admob ads
        loadBannerAd()
        
        if Defaults.coins <= 30 {
            presentRewardVideo()
        } else if Defaults.coins <= 50 {
            presentinterstitialAd()
        } else {
            print("you have enought coins to get rid of ads")
        }
    }
    
    override func viewDidLayoutSubviews() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    
    //MARK: - functions
    
    fileprivate func setupViews() {
        navigationController?.setNavigationBarHidden(false, animated: true)

        view.addSubview(YoutubePlayer)
        YoutubePlayer.layout(XW :.leadingAndCenter(nil, 0), Y: .topToSafeArea(nil, 0), H: .fixed(300))
        coinCountLabel.layout(XW: .leadingAndCenter(nil, 0), Y: .top(YoutubePlayer, 10), H: .fixed(50))
        timeRemainingLabel.layout(XW: .leadingAndCenter(nil, 0), Y: .top(coinCountLabel, 10), H: .fixed(50))
        
        coinCountLabel.text = "Coins: \(Defaults.coins)"
        coinCountLabel.textAlignment = .center
        coinCountLabel.textColor = .red
        timeRemainingLabel.textAlignment = .center
        
        view.backgroundColor = Color.primary
    }
    
    //MARK: - functions - Reward Timer
        
        func startTimer() {
            
            if timerState == .notStarted {
                getVideoDuration()
            }
            
            timerState = .playing
            rewardTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        }
        
        @objc func timerTick() {
            if timeRemaining > 0 {
                updateTimeRemaining()
            } else {
                endTimer()
            }
        }
        
        
        // convert seconds into minutes and seconds
        func minutesAndSeconds(from seconds: Int) -> (Int, Int) {
            return (seconds / 60, seconds % 60)
        }
        
        func updateTimeRemaining() {
            timeRemaining -= 1
            let (minutes, seconds) = minutesAndSeconds(from: timeRemaining)
            timeRemainingLabel.text = "time remaining: \(minutes.twoDigits()):\(seconds.twoDigits())"
            print("remaining => \(minutes.twoDigits()):\(seconds.twoDigits())")
            
            // reward the user every "n" seconds with "n" coins
            if seconds % rewardFrequency == 0 {
                earnCoins(rewardValue)
            }
        }
        
        func endTimer() {
            timerState = .ended
            print("The timer ends !")
            
            timeRemaining = 0
            timeRemainingLabel.text = "The timer ends !"
            
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
            self.YoutubePlayer.duration { result, error in
                self.timeRemaining = Int(result)
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
                 // the Ad failed to present .. show alert message
                 let alert = UIAlertController(title: "Interstitial ad isn't available yet.", message: "The Interstitial ad cannot be shown at this time",preferredStyle: .alert)
                 let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] action in
                     self?.loadInterstitialAd()
                 })
                 alert.addAction(alertAction)
                 self.present(alert, animated: true, completion: nil)
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
                   
                 // the Ad failed to present .. show alert message
                 let alert = UIAlertController(title: "Rewarded ad isn't available yet.", message: "The rewarded ad cannot be shown at this time",preferredStyle: .alert)
                 let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] action in
                     self?.loadRewardVideoAd()
                 })
                 alert.addAction(alertAction)
                 self.present(alert, animated: true, completion: nil)
               }
           })
        }

        
    
    //MARK: - functions - coins
      
      fileprivate func earnCoins(_ coins: NSInteger) {
          print("Reward received with \(coins) coins")
          Defaults.coins += coins
          coinCountLabel.text = "Coins: \(Defaults.coins)"
          let rewardMessage = coins == 1 ? " +\(coins) coin" : " +\(coins) coins"
          self.showToast(message: rewardMessage, font: .systemFont(ofSize: 18))
      }
        
     fileprivate func loseCoins(_ coins: NSInteger) {
        Defaults.coins -= coins
        coinCountLabel.text = "Coins: \(Defaults.coins)"
     }
        
    
    //MARK: - actions
    

}


//MARK: - extensions

// Admob ads
extension DetailsVC: GADFullScreenContentDelegate {
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) { print("ad presented.") }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) { print("Ad dismissed.") }

    func ad(_ ad: GADFullScreenPresentingAd,didFailToPresentFullScreenContentWithError error: Error) {
      print("Ad failed to present with error: \(error.localizedDescription).")
      let alert = UIAlertController(title: "Ad failed to present", message: "The Ad could not be presented.", preferredStyle: .alert)
      let alertAction = UIAlertAction(title: "Try Again", style: .cancel, handler: { [weak self] action in self?.loadRewardVideoAd() })
      alert.addAction(alertAction)
      self.present(alert, animated: true, completion: nil)
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
