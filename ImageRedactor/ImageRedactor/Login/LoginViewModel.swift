//
//  LoginView.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import Combine
import UIKit

@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var credentials = UserCredentials(email: .empty, password: .empty)
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var isRegistering: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var googleLoginIsLoading: Bool = false
    @Published var shouldNavigateToMain: Bool = false
    @Published var showResetPasswordSheet = false
    @Published var resetEmail: String = .empty
    @Published var successMessage: String = .empty
    @Published var infoMessage: String?
    
    private let router: Router
    
    init(router: Router) {
        self.router = router
    }
    
    func clearErrors() {
        emailError = nil
        passwordError = nil
    }
    
    func validateFields() -> Bool {
        var isValid = true
        
        if let emailValidation = ValidationService.validateEmail(credentials.email) {
            emailError = emailValidation.errorDescription
            isValid = false
        }
        
        if let passwordValidation = ValidationService.validatePassword(credentials.password) {
            passwordError = passwordValidation.errorDescription
            isValid = false
        }
        
        return isValid
    }
    
    func submit() async {
        clearErrors()
        
        guard validateFields() else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if isRegistering {
                try await AuthService.shared.register(email: credentials.email, password: credentials.password)
                infoMessage = "Письмо для подтверждения отправлено. Пожалуйста, проверьте почту."
            } else {
                try await AuthService.shared.signIn(email: credentials.email, password: credentials.password)
                router.navigate(to: .main)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signInWithGoogle(presentingVC: UIViewController) async {
        googleLoginIsLoading = true
        defer { googleLoginIsLoading = false }
        
        do {
            try await AuthService.shared.signInWithGoogle(presentingVC: presentingVC)
            router.navigate(to: .main)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func resetPassword() async {
        guard !resetEmail.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AuthService.shared.resetPassword(email: resetEmail)
            successMessage = "Письмо для сброса пароля отправлено на \(resetEmail)"
            resetEmail = ""
            showResetPasswordSheet = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
