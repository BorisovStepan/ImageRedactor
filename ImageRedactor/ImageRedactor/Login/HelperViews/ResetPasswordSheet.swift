//
//  ResetPasswordSheet.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

import SwiftUI


private enum Constants {
    static let cancelButtonText = "Отмена"
    static let sendEmailText = "Отправить письмо"
    static let enterEmailText = "Введите email"
    static let resetPasswordText = "Восстановить пароль"
}

struct ResetPasswordSheet: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
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
