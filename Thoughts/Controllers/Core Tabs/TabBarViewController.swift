//
//  TabBarViewController.swift
//  Thoughts
//
//  Created by Mikhail Kostylev on 06.04.2022.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpControllers()
    }
    
    private func setUpControllers() {
        let homeVC = HomeViewController()
        let profileVC = ProfileViewController()
        
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
}
