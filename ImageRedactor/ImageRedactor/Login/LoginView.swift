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
    static let okText = "Ок"
    static let errorText = "Ошибка"
    static let loginModeButtonText = "Уже есть аккаунт? Войти"
    static let registerModeButtonText = "Нет аккаунта? Регистрация"
    static let forgotPasswordButtonText = "Забыли пароль?"
    static let cancelButtonText = "Отмена"
    static let sendEmailText = "Отправить письмо"
    static let enterEmailText = "Введите email"
    static let resetPasswordText = "Восстановить пароль"
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

                    // Email
                    TextField(Constants.emailField, text: $viewModel.credentials.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.emailError == nil ? Color(.secondarySystemBackground) : Color.red, lineWidth: 2)
                        )
                        .onChange(of: viewModel.credentials.email) {
                            viewModel.emailError = nil
                        }

                    if let emailError = viewModel.emailError {
                        Text(emailError)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Password
                    SecureField(Constants.passwordField, text: $viewModel.credentials.password)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.passwordError == nil ? Color(.secondarySystemBackground) : Color.red, lineWidth: 2)
                        )
                        .onChange(of: viewModel.credentials.password) {
                            viewModel.passwordError = nil
                        }

                    if let passwordError = viewModel.passwordError {
                        Text(passwordError)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                ProgressButton(
                    title: viewModel.isRegistering ? Constants.createAccount : Constants.loginText,
                    backgroundColor: .blue,
                    textColor: .white,
                    isLoading: viewModel.isLoading,
                    isDisabled: false
                ) {
                    Task {
                        await viewModel.submit()
                    }
                }
                
                ProgressButton(
                    title: Constants.googleButtonText,
                    backgroundColor: .blue,
                    textColor: .white,
                    isLoading: viewModel.googleLoginIsLoading,
                    isDisabled: false
                ) {
                    if let rootVC = rootViewController {
                        Task {
                            await viewModel.signInWithGoogle(presentingVC: rootVC)
                        }
                    }
                }
                .background(
                    ViewControllerResolver { vc in
                        self.rootViewController = vc
                    }
                )
                
                Button(viewModel.isRegistering ? Constants.loginModeButtonText : Constants.registerModeButtonText) {
                    viewModel.isRegistering.toggle()
                }
                .font(.footnote)
                
                if !viewModel.isRegistering {
                    Button(Constants.forgotPasswordButtonText) {
                        viewModel.showResetPasswordSheet = true
                    }
                    .font(.footnote)
                    .padding(.top, 5)
                }
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
        .sheet(isPresented: $viewModel.showResetPasswordSheet) {
            VStack(spacing: 20) {
                Text(Constants.resetPasswordText)
                    .font(.title2)
                    .bold()
                
                TextField(Constants.enterEmailText, text: $viewModel.resetEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                ProgressButton(
                    title: Constants.sendEmailText,
                    backgroundColor: .blue,
                    textColor: .white,
                    isLoading: viewModel.isLoading,
                    isDisabled: viewModel.resetEmail.isEmpty
                ) {
                    Task {
                        await viewModel.resetPassword()
                    }
                }
                
                Button(Constants.cancelButtonText) {
                    viewModel.showResetPasswordSheet = false
                }
                .foregroundColor(.red)
            }
            .padding()
        }
    }
}
