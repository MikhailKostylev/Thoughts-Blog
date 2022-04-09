//
//  ProfileViewController.swift
//  Thoughts
//
//  Created by Mikhail Kostylev on 06.04.2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .done,
            target: self,
            action: #selector(didTapSignOut))
    }
    
    @objc private func didTapSignOut() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you'd like to sign out?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] success in
                if success {
                    UserDefaults.standard.set(nil, forKey: "email")
                    UserDefaults.standard.set(nil, forKey: "name")
                    
                    DispatchQueue.main.async {
                        let signInVC = SignInViewController()
                        signInVC.navigationItem.largeTitleDisplayMode = .always
                        
                        let navVC = UINavigationController(rootViewController: signInVC)
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.modalPresentationStyle = .fullScreen
                        
                        self?.present(navVC, animated: true)
                    }
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
