//
//  EditorViewModel.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

import SwiftUI
import PencilKit
import CoreImage
import CoreImage.CIFilterBuiltins

@MainActor
class EditorViewModel: ObservableObject {
    @Published var workingImage: UIImage
    @Published var canvasView = PKCanvasView()
    @Published var selectedTool: EditorTool = .transform
    @Published var drawingSettings = DrawingSettings()
    @Published var textSettings = EditableText()
    @Published var transformSettings = TransformSettings()
    @Published var showShareSheet = false
    @Published var originalImage: UIImage
    @Published var shouldDismissEditor = false
    @Published var showSaveErrorAlert = false

    private let context = CIContext()

    init(image: UIImage) {
        self.workingImage = image
        self.originalImage = image
    }

    func applySepia() {
        guard let ciImage = CIImage(image: workingImage) else { return }
        let filter = CIFilter.sepiaTone()
        filter.inputImage = ciImage
        filter.intensity = 0.8

        if let output = filter.outputImage,
           let cgimg = context.createCGImage(output, from: output.extent) {
            workingImage = UIImage(cgImage: cgimg)
        }
    }

    func applyInvert() {
        guard let ciImage = CIImage(image: workingImage) else { return }
        let filter = CIFilter.colorInvert()
        filter.inputImage = ciImage

        if let output = filter.outputImage,
           let cgimg = context.createCGImage(output, from: output.extent) {
            workingImage = UIImage(cgImage: cgimg)
        }
    }
    
    func resetImage() {
        workingImage = originalImage
    }
    
    func updateDrawingTool() {
        let tool = PKInkingTool(.pen, color: drawingSettings.color, width: drawingSettings.lineWidth)
        canvasView.tool = tool
    }

    func generateFilterPreview(type: PreviewFilterType) -> UIImage? {
        guard let ciImage = CIImage(image: workingImage) else { return nil }
        let filter: CIFilter

        switch type {
        case .sepia:
            let sepia = CIFilter.sepiaTone()
            sepia.inputImage = ciImage
            sepia.intensity = 0.8
            filter = sepia
        case .invert:
            let invert = CIFilter.colorInvert()
            invert.inputImage = ciImage
            filter = invert
        }

        if let output = filter.outputImage,
           let cgimg = context.createCGImage(output, from: output.extent) {
            let fullImage = UIImage(cgImage: cgimg)
            
            return fullImage.resize(to: CGSize(width: 60, height: 60))
        }

        return nil
    }

    func renderFinalImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: canvasView.bounds.size)
        return renderer.image { ctx in
            ctx.cgContext.saveGState()

            let center = CGPoint(x: canvasView.bounds.midX, y: canvasView.bounds.midY)
            ctx.cgContext.translateBy(x: center.x, y: center.y)
            ctx.cgContext.scaleBy(x: transformSettings.scale, y: transformSettings.scale)
            ctx.cgContext.rotate(by: CGFloat(transformSettings.rotation) * .pi / 180)
            ctx.cgContext.translateBy(x: -center.x, y: -center.y)

            workingImage.draw(in: canvasView.bounds)
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
            ctx.cgContext.restoreGState()

            if !textSettings.content.isEmpty {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: textSettings.size),
                    .foregroundColor: UIColor(textSettings.color)
                ]
                let text = NSAttributedString(string: textSettings.content, attributes: attributes)
                text.draw(at: textSettings.position)
            }
        }
    }
    
    func saveImage() {
        let renderedImage = renderFinalImage()
        PhotoSaver().save(renderedImage, onSuccess: {
            self.shouldDismissEditor = true
        }, onError: { error in
            self.showSaveErrorAlert = true
        })
    }
}
