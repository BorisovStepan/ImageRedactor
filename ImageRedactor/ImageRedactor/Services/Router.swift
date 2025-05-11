//
//  Router.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import SwiftUI

enum AppRoute: Hashable {
    case login
    case main
}

@MainActor
class Router: ObservableObject {
    @Published var path = NavigationPath()
    
    func reset() {
        path = NavigationPath()
    }
    
    func navigate(to route: AppRoute) {
        path.append(route)
    }
}

struct RootView: View {
    @EnvironmentObject var router: Router

    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView(router: router)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .login:
                    LoginView(router: router)
                case .main:
                    MainView(router: router)
                }
            }
        }
    }
}
