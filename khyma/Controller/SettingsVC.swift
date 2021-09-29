//
//  SettingsVC.swift
//  khyma
//
//  Created by Belal Samy on 20/09/2021.
//

import UIKit

class SettingsVC: UIViewController {
    
    //MARK: - outlets
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    //MARK: - variables
    
    
    //MARK: - constants
    
    let cellReuseIdentifier = "cell"
    
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = Color.primary
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationController?.navigationBar.topItem?.title = ""
//    }
    
    override func viewDidLayoutSubviews() {
       setupNavBar()
    }
    
    //MARK: - functions
    
    fileprivate func setupViews() {
        // nav bar
        setupNavBar()
        
        // tableView
        settingsTableView.register(cell: CoinsCell.self)
        settingsTableView.register(cell: ThemeCell.self)
        settingsTableView.register(cell: LanguageCell.self)
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self

        settingsTableView.separatorStyle = .none
        settingsTableView.backgroundColor = Color.primary
        settingsTableView.layout(shortcut: .fillToSafeArea(nil, 0, nil, 0))
    }

    fileprivate func setupNavBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = StringsKeys.settings.localized
    }
    
    //MARK: - functions - language
    
    fileprivate func changeLanguage() {
        let alertController = UIAlertController(title: StringsKeys.changeLangAlert.localized, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: StringsKeys.english.localized, style: .default, handler: { (_) in
            // change to english -----------------------------------
            print("change to english")
            Localizer.changeToEnglish()
            self.transition(.transitionFlipFromLeft) // Flip from left
            // ------------------------------------------------
        }))
        
        alertController.addAction(UIAlertAction(title: StringsKeys.arabic.localized, style: .default, handler: { (_) in
            // change to arabic -----------------------------------
            print("change to arabic")
            Localizer.changeToArabic()
            self.transition(.transitionFlipFromRight) // Flip from right
            // ------------------------------------------------
        }))
        
        alertController.addAction(UIAlertAction(title: StringsKeys.cancelAlert.localized, style: .cancel ))
        present(alertController, animated: true, completion: nil)
    }
    
    func transition(_ options: UIView.AnimationOptions) {
          let window = (self.view.window?.windowScene?.delegate as? SceneDelegate)?.window
          let sb = UIStoryboard(name: "Main", bundle: nil)
          window?.rootViewController = sb.instantiateViewController(withIdentifier: "rootVC")
          UIView.transition(with: window!, duration: 0.5, options: options, animations: nil, completion: nil)
      }
    
    //MARK: - actions
    
}

//MARK: - extensions

// MARK: - UITableView Data Source
extension SettingsVC: UITableViewDataSource {

    // section
     func numberOfSections(in _: UITableView) -> Int {
        return SettingsTableSections.allCases.count
    }
    
    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
       let section = SettingsTableSections.allCases[section]
        return section.ui.sectionTitle
   }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
   }

    // row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = SettingsTableSections.allCases[indexPath.section]
        switch section {
        case .coins:
            let cell = settingsTableView.dequeue() as CoinsCell
            return cell
            
        case .theme:
            let cell = settingsTableView.dequeue() as ThemeCell
            return cell
            
        case .language:
            let cell = settingsTableView.dequeue() as LanguageCell
            return cell
        }
       
    }
}


// MARK: - UITableView Delegate
extension SettingsVC: UITableViewDelegate {
    
    // section
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
       return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()

       let myLabel = UILabel()
       myLabel.frame = CGRect(x: 20, y: 8, width: 320, height: 30)
       myLabel.font = UIFont.boldSystemFont(ofSize: 18)
       myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
       myLabel.textColor = .lightGray

       headerView.addSubview(myLabel)
       return headerView
    }
    
    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
       return 0
    }
    
     // row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = SettingsTableSections.allCases[indexPath.section]
        return section.ui.sectionHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = SettingsTableSections.allCases[indexPath.section]
        if section == .language {
            changeLanguage()
        }
    }
    

}
