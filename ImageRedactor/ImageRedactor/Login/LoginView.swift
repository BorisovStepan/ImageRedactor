//
//  LoginView.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import SwiftUI

private enum Constants {
    static let registratingText = "Регистрация"
    static let loginText = "Войти"
    static let createAccount = "Создать аккаунт"
    static let emailField = "Email"
    static let passwordField = "Password"
    static let googleButtonText = "Войти через Google"
    static let okText = "Ok"
    static let errorText = "Ошибка"
    static let loginModeButtonText = "Уже есть аккаунт? Войти"
    static let registerModeButtonText = "Нет аккаунта? Регистрация"
}

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var rootViewController: UIViewController?
    
    init(router: Router) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(router: router))
    }
    
    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: 20) {
                Text(viewModel.isRegistering ? Constants.registratingText : Constants.loginText)
                    .font(.largeTitle)
                    .bold()

                TextField(Constants.emailField, text: $viewModel.credentials.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField(Constants.passwordField, text: $viewModel.credentials.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Button(viewModel.isRegistering ? Constants.createAccount : Constants.loginText) {
                        Task {
                            await viewModel.submit()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Button(Constants.googleButtonText) {
                    if let rootVC = rootViewController {
                        Task {
                            await viewModel.signInWithGoogle(presentingVC: rootVC)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .background(
                    ViewControllerResolver { vc in
                        self.rootViewController = vc
                    }
                )

                Button(viewModel.isRegistering ? Constants.loginModeButtonText : Constants.registerModeButtonText) {
                    viewModel.isRegistering.toggle()
                }
                .font(.footnote)
            }
            .padding()
        }
        .hideKeyboardOnTap()
        .alert(Constants.errorText, isPresented: .constant(viewModel.errorMessage != nil)) {
            Button(Constants.okText, role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? .empty)
        }
    }
}
