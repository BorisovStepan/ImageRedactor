//
//  EditorViewModel.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

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
    @Published var sepiaPreview: UIImage? = nil
    @Published var invertPreview: UIImage? = nil
    @Published var shareImage: UIImage? = nil
    
    private let context = CIContext()
    
    init(image: UIImage) {
        self.workingImage = image
        self.originalImage = image
    }
    
    func loadFilterPreviews() {
        Task {
            sepiaPreview = await generateFilterPreview(type: .sepia)
            invertPreview = await generateFilterPreview(type: .invert)
        }
    }
    
    func prepareShareImage() {
        Task {
            shareImage = await renderFinalImage()
            showShareSheet = true
        }
        
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
    
    func generateFilterPreview(type: PreviewFilterType) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let ciImage = CIImage(image: self.workingImage) else {
                    continuation.resume(returning: nil)
                    return
                }
                
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
                   let cgimg = self.context.createCGImage(output, from: output.extent) {
                    let fullImage = UIImage(cgImage: cgimg)
                    let resizedImage = fullImage.resize(to: CGSize(width: 60, height: 60))
                    continuation.resume(returning: resizedImage)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func renderFinalImage() async -> UIImage {
        let size = await MainActor.run {
            canvasView.bounds.size
        }

        return await MainActor.run {
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { ctx in
                ctx.cgContext.saveGState()
                
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                ctx.cgContext.translateBy(x: center.x, y: center.y)
                ctx.cgContext.scaleBy(x: transformSettings.scale, y: transformSettings.scale)
                ctx.cgContext.rotate(by: CGFloat(transformSettings.rotation) * .pi / 180)
                ctx.cgContext.translateBy(x: -center.x, y: -center.y)
                
                workingImage.draw(in: CGRect(origin: .zero, size: size))
                
                let canvasImage = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
                canvasImage.draw(in: CGRect(origin: .zero, size: size))
                
                ctx.cgContext.restoreGState()
                
                if !textSettings.content.isEmpty {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: textSettings.size),
                        .foregroundColor: UIColor(textSettings.color)
                    ]
                    let attributedText = NSAttributedString(string: textSettings.content, attributes: attributes)
                    attributedText.draw(at: textSettings.position)
                }
            }
        }
    }

    func saveImage() {
        Task {
            let renderedImage = await renderFinalImage()
            PhotoSaver().save(renderedImage, onSuccess: {
                self.shouldDismissEditor = true
            }, onError: { error in
                self.showSaveErrorAlert = true
            })
        }
    }
}
