//
//  ThemeCell.swift
//  khyma
//
//  Created by Belal Samy on 25/09/2021.
//

import UIKit

class ThemeCell: UITableViewCell {
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var darkModeSwitcch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        darkModeLabel.layout(X: .leading(nil, 20), W: .wrapContent, Y: .top(nil, 0), H: .fixed(50))
        darkModeSwitch.layout(X: .trailing(nil, 20), W: .wrapContent, Y: .top(nil, 10), H: .fixed(50))
        darkModeSwitch.setOn(Defaults.darkMode, animated: true)
        darkModeLabel.text = StringsKeys.darkMode.localized

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func darkModeSwitch(_ sender: UISwitch) {
        let window = (self.contentView.window?.windowScene?.delegate as? SceneDelegate)?.window
        let sb = UIStoryboard(name: "Main", bundle: nil)
        window?.rootViewController = sb.instantiateViewController(withIdentifier: "rootVC")

        if darkModeSwitch.isOn {
            print("dark mode is on")
            window?.overrideUserInterfaceStyle = .dark
            Defaults.darkMode = true
            Defaults.backToSettings = true
            UIView.transition(with: window!, duration: 0.5, options: .transitionCurlDown, animations: nil, completion: nil)

            
        } else {
            print("dark mode is off")
            window?.overrideUserInterfaceStyle = .light
            Defaults.darkMode = false
            Defaults.backToSettings = true
            UIView.transition(with: window!, duration: 0.5, options: .transitionCurlUp, animations: nil, completion: nil)

        }
    }
    
    
    
}
