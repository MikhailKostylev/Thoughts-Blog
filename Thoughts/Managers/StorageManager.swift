//
//  StorageManager.swift
//  Thoughts
//
//  Created by Mikhail Kostylev on 06.04.2022.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let container = Storage.storage().reference()
    
    private init() {}
    
    public func uploadUserProfilePicture(
        email: String,
        image: UIImage?,
        completion: @escaping (Bool) -> Void
    ) {
        
    }
    
    public func downloadUrlForProfilePicture(
        user: User,
        completion: @escaping (URL?) -> Void
    ) {
        
    }
    
    public func uploadBlogHeaderImage(
        blogPost: BlogPost,
        image: UIImage?,
        completion: @escaping (Bool) -> Void
    ) {
        
    }
    
    public func downloadUrlForPostHeader(
        blogPost: BlogPost,
        completion: @escaping (URL?) -> Void
    ) {
        
    }
}
