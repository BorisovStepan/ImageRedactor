//
//  LoginViewModel.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import Foundation

private enum Constants {
    static let successSignInMessage: String = "Вход выполнен"
    static let successRegisterMessage: String = "Вход выполнен"
}

@MainActor
class LoginViewModel: ObservableObject {

    @Published var credentials = UserCredentials(email: "", password: "")
    @Published var isRegistering: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var successMessage: String?

    func submit() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if isRegistering {
                try await AuthService.shared.register(email: credentials.email, password: credentials.password)
                successMessage = Constants.successRegisterMessage
            } else {
                try await AuthService.shared.signIn(email: credentials.email, password: credentials.password)
                successMessage = Constants.successSignInMessage
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
