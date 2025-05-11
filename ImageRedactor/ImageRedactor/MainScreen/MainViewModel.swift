//
//  MainViewModel.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine

@MainActor
class MainViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedItem: PhotosPickerItem?
    @Published var isEditorOpen = false
    
    private var cancellables = Set<AnyCancellable>()
    private let router: Router
    
    init(router: Router) {
        self.router = router
        setupBindings()
    }
    
    private func setupBindings() {
        $selectedItem
            .compactMap { $0 }
            .sink { [weak self] item in
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            self?.selectedImage = uiImage
                            self?.isEditorOpen = false
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        AuthService.shared.signOut()
        router.reset()
    }
}
