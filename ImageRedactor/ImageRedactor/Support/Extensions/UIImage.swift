//
//  UIImage.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageFile: Transferable {
    let image: UIImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .image) { imageFile in
            imageFile.image.pngData() ?? Data()
        }
    }
}
