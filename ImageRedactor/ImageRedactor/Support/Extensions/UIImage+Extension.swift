//
//  UIImage+Extension.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

import UIKit

extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
