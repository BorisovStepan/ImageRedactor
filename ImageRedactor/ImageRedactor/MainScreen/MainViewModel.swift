//
//  MainViewModel.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import SwiftUI
import FirebaseAuth

@MainActor
class MainViewModel: ObservableObject {
    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            router.reset()
        } catch {
            print("Ошибка выхода: \(error.localizedDescription)")
        }
    }
}
