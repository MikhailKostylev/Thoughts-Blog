//
//  AuthManager.swift
//  Thoughts
//
//  Created by Mikhail Kostylev on 06.04.2022.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    
    static let shared = AuthManager()
    
    private let auth = Auth.auth()
    
    private init() {}
    
    public var isSignedIN: Bool {
        return auth.currentUser != nil
    }
    
    public func signUp(
        email: String,
        password: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else { return }
        
        auth.createUser(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            // Account created
            completion(true)
        }
    }
    
    public func signIn(
        email: String,
        password: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else { return }
        auth.signIn(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            // Successfully signed in
            completion(true)
        }
    }
    
    public func signOut(
        completion: (Bool) -> Void
    ) {
        do {
            try auth.signOut()
            completion(true)
        } catch let error {
            print(error.localizedDescription)
            completion(false)
        }
    }
}
