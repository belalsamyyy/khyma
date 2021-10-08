//
//  CollectionCell2.swift
//  khyma
//
//  Created by Belal Samy on 19/09/2021.
//

import UIKit
import DesignX

class ContinueWatchingCell: UICollectionViewCell {
        
    @IBOutlet weak var myLabel: UILabel!
    let seekLabel = UILabel()
    let progressBar = UIProgressView()
    
    var video: Watchable? {
         didSet {
             let name = UserDefaultsManager.shared.def.object(forKey: "\(video?._id ?? "") name") as? String
             myLabel.text = name
             // myLabel.text = Language.currentLanguage == Lang.english.rawValue ? video?.en_name : video?.ar_name
             
             let continueWatchingAt = UserDefaultsManager.shared.def.object(forKey: video?._id ?? "") as! Float
             let duration = UserDefaultsManager.shared.def.object(forKey: "\(video?._id ?? "") duration") as! Float
             let (hours, minutes, seconds) = Int(continueWatchingAt).hoursAndMinutesAndSeconds()
             seekLabel.text = "\(hours.twoDigits()):\(minutes.twoDigits()):\(seconds.twoDigits())"
             progressBar.progress = continueWatchingAt / duration

         }
     }

     override func awakeFromNib() {
         super.awakeFromNib()
         
         self.backgroundColor = Color.secondary
         
         myLabel.layout(XW: .leadingAndCenter(nil, 0), Y:.top(nil, 45), H: .wrapContent)
         myLabel.numberOfLines = 0
         myLabel.textColor = .white
         myLabel.textAlignment = .center
         myLabel.font = UIFont.systemFont(ofSize: 25)
         
         addSubview(seekLabel)
         seekLabel.layout(XW: .leadingAndCenter(nil, 0), Y: .top(myLabel, 5), H: .fixed(50))
         seekLabel.textColor = .white
         seekLabel.textAlignment = .center
         seekLabel.font = UIFont.systemFont(ofSize: 25)
         
         addSubview(progressBar)
         progressBar.layout(shortcut: .fillSuperView(0))
         progressBar.progressTintColor = Color.text
         progressBar.alpha = 0.10
        
         // Initialization code
         layer.masksToBounds = true
         layer.cornerRadius = 10
     }
    
    
 }
