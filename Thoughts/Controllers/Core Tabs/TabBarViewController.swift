//
//  TabBarViewController.swift
//  Thoughts
//
//  Created by Mikhail Kostylev on 06.04.2022.
//

import UIKit
import WhatsNewKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWhatsNew()
        UserDefaults.setAppWasLaunched()
    }
    
    private func setUpControllers() {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let homeVC = HomeViewController()
        let profileVC = ProfileViewController(currentEmail: currentUserEmail)
        
        homeVC.title = "Home"
        profileVC.title = "Profile"
        
        homeVC.navigationItem.largeTitleDisplayMode = .always
        profileVC.navigationItem.largeTitleDisplayMode = .always
        
        let navHomeVC = UINavigationController(rootViewController: homeVC)
        let navProfileVC = UINavigationController(rootViewController: profileVC)
        
        navHomeVC.navigationBar.prefersLargeTitles = true
        navProfileVC.navigationBar.prefersLargeTitles = true
        
        navHomeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 2)
        
        setViewControllers([navHomeVC, navProfileVC], animated: true)
    }
    
    func showWhatsNew() {
        let whatsNew = WhatsNew(title: "What's New",
                                items: [
                                    WhatsNew.Item(title: "Add Favorites",
                                                  subtitle: "Now you can add favorites posts",
                                                  image: UIImage(systemName: "star")),
                                    WhatsNew.Item(title: "Share",
                                                  subtitle: "Share your blogs with friends!",
                                                  image: UIImage(systemName: "square.and.arrow.up")),
                                    WhatsNew.Item(title: "Enjoy",
                                                  subtitle: "See the most interesting posts!",
                                                  image: UIImage(systemName: "sparkles.tv")),
                                    WhatsNew.Item(title: "Choose",
                                                  subtitle: "Change your profile picture!",
                                                  image: UIImage(systemName: "person.crop.circle")),
                                    WhatsNew.Item(title: "Settings",
                                                  subtitle: "Improved performance",
                                                  image: UIImage(systemName: "gear"))
                                ])
        
        if !UserDefaults.wasAppLaunched() {
            guard let vc = WhatsNewViewController(
                whatsNew: whatsNew,
                theme: .blue,
                versionStore: KeyValueWhatsNewVersionStore()) else {
                return
            }
            
            present(vc, animated: true)
        }
    }
}
