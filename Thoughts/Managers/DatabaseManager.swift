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
        user: User,
        completion: @escaping (Bool) -> Void
    ) {
        
    }
    
    public func getAllPosts(
        completion: @escaping ([BlogPost]) -> Void
    ) {
        
    }
    
    public func getPosts(
        for user: User,
        completion: @escaping ([BlogPost]) -> Void
    ) {
        
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
