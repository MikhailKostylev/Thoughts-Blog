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
        
    }
}
