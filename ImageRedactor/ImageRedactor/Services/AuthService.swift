//
//  AuthService.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import Foundation
import FirebaseAuth

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = Auth.auth().currentUser != nil
    
    private init() {}
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
        isAuthenticated = true
    }
    
    func register(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        try await result.user.sendEmailVerification()
        isAuthenticated = true
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        isAuthenticated = false
    }
}
