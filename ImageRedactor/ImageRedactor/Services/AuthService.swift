//
//  AuthService.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

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
 
    func signInWithGoogle(presentingVC: UIViewController) async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw URLError(.badServerResponse)
        }

        let config = GIDConfiguration(clientID: clientID)

        let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)

        guard let idToken = userAuthentication.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }

        let accessToken = userAuthentication.user.accessToken.tokenString

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        try await Auth.auth().signIn(with: credential)
    }
}
