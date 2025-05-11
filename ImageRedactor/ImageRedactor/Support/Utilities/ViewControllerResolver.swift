//
//  ViewControllerResolver.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import SwiftUI
import UIKit

struct ViewControllerResolver: UIViewControllerRepresentable {
    var onResolve: (UIViewController) -> Void

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            onResolve(controller)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
