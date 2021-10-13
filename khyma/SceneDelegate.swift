//
//  SceneDelegate.swift
//  khyma
//
//  Created by aly hassan on 11/09/2021.
//

import UIKit
import GoogleMobileAds
import FBSDKCoreKit

// Facebook 
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: [UIApplication.OpenURLOptionsKey.annotation])
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Change to arabic (RTL)
        if Defaults.firstTime == true {
            Localizer.changeToArabic()
            Defaults.def.set(Date(), forKey: UserDefaultsKeys.everySixHoursReward)
            Defaults.firstTime = false
        }
        
        // every six hours reward
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rootVC")
        UIView.appearance().semanticContentAttribute = Language.currentLanguage == Lang.english.rawValue ? .forceLeftToRight : .forceRightToLeft
        
        // dark mode
        window?.overrideUserInterfaceStyle = Defaults.darkMode ? .dark : .light
        
        // Initialize Google Mobile Ads SDK
           GADMobileAds.sharedInstance().start(completionHandler: nil)
           
           // Defaults.deviceID = "RESET USER DEFAULTS"  // reset usesr defaults
           
           if Defaults.deviceID != UIDevice.current.identifierForVendor!.uuidString {
               Defaults.deviceID = UIDevice.current.identifierForVendor!.uuidString
               Defaults.coins = 3000
           }

        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

