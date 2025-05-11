//
//  AuthService.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import SwiftUI

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = Auth.auth().currentUser != nil
    
    private init() {}
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        
        guard result.user.isEmailVerified else {
            try Auth.auth().signOut()
            throw AuthError.emailNotVerified
        }
        
        isAuthenticated = true
    }
    
    func register(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        try await result.user.sendEmailVerification()
        
        try Auth.auth().signOut()
        isAuthenticated = false
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        isAuthenticated = false
    }
    
    func signInWithGoogle(presentingVC: UIViewController) async throws {
        guard (FirebaseApp.app()?.options.clientID) != nil else {
            throw URLError(.badServerResponse)
        }
        
        let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
        
        guard let idToken = userAuthentication.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = userAuthentication.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        try await Auth.auth().signIn(with: credential)
        isAuthenticated = true
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}

enum AuthError: LocalizedError {
    case emailNotVerified
    
    var errorDescription: String? {
        switch self {
        case .emailNotVerified:
            return "Email не подтвержден. Пожалуйста, проверьте почту."
        }
    }
}
