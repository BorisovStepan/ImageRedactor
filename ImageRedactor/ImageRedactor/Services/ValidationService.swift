//
//  ValidationService.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

import Foundation

enum ValidationError: LocalizedError {
    case invalidEmail
    case shortPassword

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Некорректный email адрес"
        case .shortPassword:
            return "Пароль должен содержать минимум 6 символов"
        }
    }
}

struct ValidationService {
    static func validateEmail(_ email: String) -> ValidationError? {
        guard email.contains("@") else {
            return .invalidEmail
        }
        return nil
    }

    static func validatePassword(_ password: String) -> ValidationError? {
        guard password.count >= 6 else {
            return .shortPassword
        }
        return nil
    }
}
