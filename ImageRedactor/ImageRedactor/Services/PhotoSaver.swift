//
//  PhotoSaver.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

import UIKit

final class PhotoSaver: NSObject {
    private var onSaveSuccess: (() -> Void)?
    private var onSaveError: ((Error) -> Void)?

    func save(_ image: UIImage,
              onSuccess: @escaping () -> Void,
              onError: @escaping (Error) -> Void)
    {
        self.onSaveSuccess = onSuccess
        self.onSaveError = onError
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            onSaveError?(error)
        } else {
            onSaveSuccess?()
        }
    }
}
