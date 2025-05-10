//
//  LoginView.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.isRegistering ? "Регистрация" : "Вход")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $viewModel.credentials.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Пароль", text: $viewModel.credentials.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            if viewModel.isLoading {
                ProgressView()
            } else {
                Button(viewModel.isRegistering ? "Создать аккаунт" : "Войти") {
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
            
            Button(viewModel.isRegistering ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Регистрация") {
                viewModel.isRegistering.toggle()
            }
            .font(.footnote)
        }
        .padding()
        .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("ОК", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Готово", isPresented: .constant(viewModel.successMessage != nil)) {
            Button("ОК", role: .cancel) {
                viewModel.successMessage = nil
            }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
    }
}
