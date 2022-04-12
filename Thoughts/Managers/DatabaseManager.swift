//
//  DatabaseManager.swift
//  Thoughts
//
//  Created by Mikhail Kostylev on 06.04.2022.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Firestore.firestore()
    
    private init() {}
    
    public func insert(
        blogPost: BlogPost,
        email: String ,
        completion: @escaping (Bool) -> Void
    ) {
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let data: [String: Any] = [
            "id": blogPost.identifier,
            "title": blogPost.title,
            "body": blogPost.text,
            "created": blogPost.timestamp,
            "headerImageUrl": blogPost.headerImageUrl?.absoluteString ?? ""
        ]
        
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .document(blogPost.identifier)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    
    public func getAllPosts(
        completion: @escaping ([BlogPost]) -> Void
    ) {
        database
            .collection("users")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents.compactMap ({ $0.data() }),
                      error == nil else { return }
                
                let emails: [String] = documents.compactMap({ $0["email"] as? String })
                print(emails)
                
                guard !emails.isEmpty else {
                    completion([])
                    return
                }
                
                let group = DispatchGroup()
                var result: [BlogPost] = []
                
                for email in emails {
                    group.enter()
                    self?.getPosts(for: email, completion: { userPosts in
                        defer {
                            group.leave()
                        }
                        
                        result.append(contentsOf: userPosts)
                    })
                }
                
                group.notify(queue: .global()) {
                    print("Feed posts: \(result.count)")
                    completion(result)
                }
            }
    }
    
    public func getPosts(
        for email: String,
        completion: @escaping ([BlogPost]) -> Void
    ) {
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        database
            .collection("users")
            .document(userEmail)
            .collection("posts")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap ({ $0.data() }),
                      error == nil else { return }
                
                let posts: [BlogPost] = documents.compactMap({ dictionary in
                    
                    guard let id = dictionary["id"] as? String,
                          let title = dictionary["title"] as? String,
                          let body = dictionary["body"] as? String,
                          let created = dictionary["created"] as? TimeInterval,
                          let headerImageUrl = dictionary["headerImageUrl"] as? String
                    else { return nil }
                    
                    let post = BlogPost(
                        identifier: id,
                        title: title,
                        timestamp: created,
                        headerImageUrl: URL(string: headerImageUrl),
                        text: body
                    )
                    
                    return post
                })
                
                completion(posts)
            }
    }
    
    public func insert(
        user: User,
        completion: @escaping (Bool) -> Void
    ) {
        let documentId = user.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        let data = [
            "email": user.email,
            "name": user.name
        ]
        
        database
            .collection("users")
            .document(documentId)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    
    public func getUser(
        email: String,
        completion: @escaping (User?) -> Void) {
            let documentId = email
                .replacingOccurrences(of: ".", with: "_")
                .replacingOccurrences(of: "@", with: "_")
            
            database
                .collection("users")
                .document(documentId)
                .getDocument { snapshot, error in
                    guard let data = snapshot?.data() as? [String: Any],
                          let name = data["name"] as? String,
                          error == nil else { return }
                    
                    let ref = data["profile_photo"] as? String
                    let user = User(name: name, email: email, profilePictureRef: ref)
                    completion(user)
                }
        }
    
    public func updateProfilePhoto(
        email: String,
        completion: @escaping (Bool) -> Void
    ) {
        let path = email
            .replacingOccurrences(of: "@", with: "_")
            .replacingOccurrences(of: ".", with: "_")
        
        let photoReference = "profile_pictures/\(path)/photo.png"
        
        let databaseReference = database
            .collection("users")
            .document(path)
        
        databaseReference.getDocument { snapshot, error in
            guard var data = snapshot?.data(),
                  error == nil else { return }
            data["profile_photo"] = photoReference
            
            databaseReference.setData(data) { error in
                completion(error == nil)
            }
        }
    }
}
