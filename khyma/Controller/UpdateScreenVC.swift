//
//  UpdateScreenViewController.swift
//  khyma
//
//  Created by Belal Samy on 11/10/2021.
//

import Foundation
import UIKit
import SimpleAPI

class UpdateScreenVC: UIViewController {
    var updateTextLbl = UILabel()
    var updateLinkBtn = UIButton()
    var updateUrl: String?
    
    var config: Config? {
        didSet {
            guard let updateScreen = config?.updateScreen else { return }
            DispatchQueue.main.async {
                print("config change for update screen : \(updateScreen)")
                self.updateTextLbl.text = Language.currentLanguage == Lang.english.rawValue ? self.config?.textEnUpdateScreen : self.config?.textArUpdateScreen
                self.updateUrl = self.config?.linkUpdateScreen
                if updateScreen == false { self.dismiss(animated: true, completion: nil) }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getConfiguration()
        view.backgroundColor = Color.primary
        view.addSubview(updateTextLbl)
        view.addSubview(updateLinkBtn)
        
        updateTextLbl.layout(XW: .leadingAndCenter(nil, 20), Y: .center(nil), H: .wrapContent)
        updateTextLbl.numberOfLines = 0
        updateTextLbl.textAlignment = .center
        
        updateLinkBtn.layout(XW: .leadingAndCenter(nil, 20), Y: .top(updateTextLbl, 20), H: .fixed(50))
        updateLinkBtn.setTitle(StringsKeys.update.localized, for: .normal)
        updateLinkBtn.titleLabel?.textColor = Color.text
        updateLinkBtn.titleLabel?.textAlignment = .center
        updateLinkBtn.addTarget(self, action: #selector(handleLinkTapped), for: .touchUpInside)
    }
    
    @objc func handleLinkTapped() {
        print("\"\(self.updateUrl ?? "")\" tapped ... ")
        guard let myURL = self.updateUrl else { return }
        if let url = URL(string: myURL) {
            UIApplication.shared.open(url)
        }
    }
    
    fileprivate func getConfiguration() {
        Config.endpoint = Endpoints.config
        API<Config>.object(.get(ConfigID)) { [weak self] result in
            switch result {
            case .success(let data):
                print(data ?? "")
                self?.config = data
            case .failure(let error):
                print(error)
            }
        }
    }
}
