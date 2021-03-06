//
//  ViewController.swift
//  Thoughts
//
//  Created by Mikhail Kostylev on 06.04.2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    //MARK: - UI elements
    private let composeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.setImage(UIImage(systemName: "square.and.pencil",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)),
                        for: .normal)
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: -3, height: 3)
        return button
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(PostPreviewCell.self,
                       forCellReuseIdentifier: PostPreviewCell.identifier)
        return table
    }()
    
    //MARK: - let/var
    private var posts: [BlogPost] = []
    private var postObserver: NSObjectProtocol?

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(composeButton)
        setupSignOutButton()
        composeButton.addTarget(self, action: #selector(didTapCompose), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        fetchAllPosts()
        postObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("post"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let stongSelf = self else {
                return
            }
            
            stongSelf.fetchAllPosts()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        composeButton.frame = CGRect(
            x: view.width-60-15,
            y: view.height-60-15-view.safeAreaInsets.bottom,
            width: 60,
            height: 60
        )
        tableView.frame = view.bounds
    }
    
    deinit {
        if let observer = postObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    //MARK: - Setup UI elements
    private func setupSignOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .done,
            target: self,
            action: #selector(didTapCompose))
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }
    
    //MARK: - Action methods
    @objc private func didTapCompose() {
        HapticsManager.shared.vibrateForSelection()
        let vc = CreateNewPostViewController()
        vc.title = "Create Post"
        vc.modalPresentationStyle = .fullScreen
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    //MARK: Fetch Home Feed
    private func fetchAllPosts() {
        DatabaseManager.shared.getAllPosts { [weak self] posts in
            self?.posts = posts
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

//MARK: - Table methods
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostPreviewCell.identifier, for: indexPath) as? PostPreviewCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
        cell.configure(with: .init(title: post.title, imageUrl: post.headerImageUrl))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HapticsManager.shared.vibrateForSelection()
        
        let vc = ViewPostViewController(post: posts[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }
}
