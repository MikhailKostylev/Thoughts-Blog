//
//  ProfileViewController.swift
//  Thoughts
//
//  Created by Mikhail Kostylev on 06.04.2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    //MARK: - UI elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(PostPreviewCell.self,
                       forCellReuseIdentifier: PostPreviewCell.identifier)
        return table
    }()
    
    //MARK: - let/var
    private let currentEmail: String
    private var user: User?
    private var posts: [BlogPost] = []
    
    //MARK: - Init
    init(currentEmail: String) {
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground
        setupSignOutButton()
        setupTable()
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - Setup UI elements
    private func setupSignOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .done,
            target: self,
            action: #selector(didTapSignOut))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    private func setupTable() {
        let gradientView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: view.height
            )
        )
        
        gradientView.addGradient()
        tableView.backgroundView = gradientView
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setupTableHeader()
        fetchProfileData()
    }
    
    private func setupTableHeader(
        profilePhotoRef: String? = nil,
        name: String? = nil) {
            let headerView = UIView(frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: view.width/1.5))
            headerView.clipsToBounds = true
            headerView.isUserInteractionEnabled = true
            headerView.backgroundColor = .clear
            tableView.tableHeaderView = headerView
            
            // Profile picture
            let profilePhoto = UIImageView(image: UIImage(systemName: "person.circle"))
            profilePhoto.tintColor = .systemGray6
            profilePhoto.contentMode = .scaleAspectFit
            profilePhoto.frame = CGRect(
                x: (view.width-view.width/2)/2,
                y: (headerView.height-(view.width/2))/4,
                width: view.width/2,
                height: view.width/2)
            profilePhoto.layer.masksToBounds = true
            profilePhoto.layer.cornerRadius = profilePhoto.width/2
            profilePhoto.isUserInteractionEnabled = true
            headerView.addSubview(profilePhoto)
            let tapPhoto = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePhoto))
            profilePhoto.addGestureRecognizer(tapPhoto)
            
            // Email label
            let emailLabel = UILabel(frame: CGRect(
                x: 20,
                y: profilePhoto.bottom-20,
                width: view.width-40,
                height: 100))
            emailLabel.text = currentEmail
            emailLabel.textColor = .systemBlue
            emailLabel.textAlignment = .center
            emailLabel.font = .systemFont(ofSize: 24, weight: .light)
            headerView.addSubview(emailLabel)
            
            if let name = name {
                title = name
            }
            if let ref = profilePhotoRef {
                // Fetch Image
                StorageManager.shared.downloadUrlForProfilePicture(path: ref) { url in
                    guard let url = url else { return }
                    let _ = URLSession.shared.dataTask(with: url) { data, _, error in
                        guard let data = data, error == nil else { return }
                        DispatchQueue.main.async {
                            profilePhoto.image = UIImage(data: data)
                        }
                    }.resume()
                }
            }
        }
    
    //MARK: - Actions methods
    @objc private func didTapProfilePhoto() {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String,
              myEmail == currentEmail else {
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    /// Sign Out
    @objc private func didTapSignOut() {
        DispatchQueue.main.async {
            HapticsManager.shared.vibrate(for: .warning)
        }
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you'd like to sign out?",
            preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        alert.addAction(UIAlertAction(
            title: "Sign Out",
            style: .destructive,
            handler: { _ in
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
    
    //MARK: - Fetching data
    private func fetchProfileData() {
        DatabaseManager.shared.getUser(email: currentEmail) { [weak self] user in
            guard let user = user else { return }
            self?.user = user
            DispatchQueue.main.async {
                self?.setupTableHeader(
                    profilePhotoRef: user.profilePictureRef,
                    name: user.name)
            }
        }
    }
    
    private func fetchPosts() {
        DatabaseManager.shared.getPosts(for: currentEmail) { [weak self] posts in
            self?.posts = posts
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

//MARK: - TableView Methods
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
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

//MARK: - Image Picker Methods
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else { return }
        
        StorageManager.shared.uploadUserProfilePicture(email: currentEmail,
                                                       image: image) { [weak self] success in
            guard let strongSelf = self else { return }
            if success {
                // Update databse
                DatabaseManager.shared.updateProfilePhoto(email: strongSelf.currentEmail) { updated in
                    guard updated  else { return }
                    DispatchQueue.main.async {
                        strongSelf.fetchProfileData()
                        HapticsManager.shared.vibrate(for: .success)
                    }
                }
            }
        }
    }
}


