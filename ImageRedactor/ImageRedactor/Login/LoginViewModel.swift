import Combine
import UIKit

@MainActor
class LoginViewModel: ObservableObject {

    @Published var credentials = UserCredentials(email: .empty, password: .empty)
    @Published var isRegistering: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var googleLoginIsLoading: Bool = false
    @Published var shouldNavigateToMain: Bool = false

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func submit() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if isRegistering {
                try await AuthService.shared.register(email: credentials.email, password: credentials.password)
            } else {
                try await AuthService.shared.signIn(email: credentials.email, password: credentials.password)
            }
            router.navigate(to: .main)
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
}
