//
//  EditorView.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 11.05.25.
//

import SwiftUI
import PencilKit
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

private enum Constants {
    static let editTitle = "Редактирование"
    static let saveButtonTitle = "Сохранить"
    static let shareButtonTitle = "Поделиться"
    static let originalTitle = "Оригинал"
    static let sepiaTitle = "Сепия"
    static let invertTitle = "Инверт"
    static let scaleLabel = "Масштаб"
    static let rotationLabel = "Поворот"
    static let penColorLabel = "Цвет пера"
    static let lineWidthLabel = "Толщина линии"
    static let textColorLabel = "Цвет текста"
    static let textSizeLabel = "Размер текста"
    static let enterTextPlaceholder = "Введите текст"
}

struct EditorView: View {
    @StateObject private var viewModel: EditorViewModel
    @Environment(\.dismiss) private var dismiss

    init(image: UIImage) {
        _viewModel = StateObject(wrappedValue: EditorViewModel(image: image))
    }

    var body: some View {
        content
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let shareImage = viewModel.shareImage {
                    ActivityView(items: [shareImage])
                }
            }
            .navigationTitle(Constants.editTitle)
            .onChange(of: viewModel.shouldDismissEditor) {
                if viewModel.shouldDismissEditor {
                    dismiss()
                }
            }
    }

    private var content: some View {
        VStack(spacing: 0) {
            editorCanvas
            toolSelection
            editorOptions
            Spacer()
            bottomButtons
        }
        .padding(.horizontal)
    }

    private var editorCanvas: some View {
        ZStack {
            Group {
                Image(uiImage: viewModel.workingImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(viewModel.transformSettings.scale)
                    .rotationEffect(.degrees(viewModel.transformSettings.rotation))
                    .clipped()
                
                DrawingCanvas(canvasView: $viewModel.canvasView)
                    .allowsHitTesting(viewModel.selectedTool == .draw)
            }
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4)
            
            if !viewModel.textSettings.content.isEmpty {
                Text(viewModel.textSettings.content)
                    .font(.system(size: viewModel.textSettings.size))
                    .foregroundColor(viewModel.textSettings.color)
                    .padding(6)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
                    .position(viewModel.textSettings.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if viewModel.selectedTool == .text {
                                    let minX: CGFloat = .zero
                                    let maxX: CGFloat = UIScreen.main.bounds.width
                                    let minY: CGFloat = .zero
                                    let maxY: CGFloat = UIScreen.main.bounds.height * 0.4
                                    let clampedX = min(max(value.location.x, minX), maxX)
                                    let clampedY = min(max(value.location.y, minY), maxY)
                                    viewModel.textSettings.position = CGPoint(x: clampedX, y: clampedY)
                                }
                            }
                    )
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.4)
        .padding(.vertical)
    }

    private var toolSelection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EditorTool.allCases, id: \.id) { tool in
                    Button(tool.rawValue) {
                        viewModel.selectedTool = tool
                        if tool == .filters {
                            viewModel.loadFilterPreviews()
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(viewModel.selectedTool == tool ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var editorOptions: some View {
        VStack(spacing: 16) {
            switch viewModel.selectedTool {
            case .transform:
                transformOptions
            case .draw:
                drawOptions
            case .text:
                textOptions
            case .filters:
                filterOptions
            }
        }
        .frame(maxHeight: 220)
    }

    private var transformOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Constants.scaleLabel)
                .font(.headline)
            Slider(value: $viewModel.transformSettings.scale, in: 0.5...2)

            Text(Constants.rotationLabel)
                .font(.headline)
            Slider(value: $viewModel.transformSettings.rotation, in: 0...360)
        }
        .padding()
    }

    private var drawOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            ColorPicker(Constants.penColorLabel, selection: Binding(
                get: { Color(viewModel.drawingSettings.color) },
                set: { newColor in
                    viewModel.drawingSettings.color = UIColor(newColor)
                    viewModel.updateDrawingTool()
                }
            ))

            VStack(alignment: .leading) {
                Text(Constants.lineWidthLabel)
                    .font(.subheadline)
                Slider(value: $viewModel.drawingSettings.lineWidth, in: 1...15, step: 1)
                    .onChange(of: viewModel.drawingSettings.lineWidth) {
                        viewModel.updateDrawingTool()
                    }
            }
        }
        .padding()
    }

    private var textOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField(Constants.enterTextPlaceholder, text: $viewModel.textSettings.content)
                .textFieldStyle(.roundedBorder)
            
            ColorPicker(Constants.textColorLabel, selection: $viewModel.textSettings.color)

            VStack(alignment: .leading) {
                Text(Constants.textSizeLabel)
                    .font(.subheadline)
                Slider(value: $viewModel.textSettings.size, in: 10...60, step: 1)
            }
        }
        .padding()
    }

    private var filterOptions: some View {
        HStack(spacing: 16) {
            filterButton(image: viewModel.originalImage, title: Constants.originalTitle) {
                viewModel.resetImage()
            }
            if let sepia = viewModel.sepiaPreview {
                filterButton(image: sepia, title: Constants.sepiaTitle) {
                    viewModel.applySepia()
                }
            }
            if let invert = viewModel.invertPreview {
                filterButton(image: invert, title: Constants.invertTitle) {
                    viewModel.applyInvert()
                }
            }
        }
        .padding(.horizontal)
    }

    private func filterButton(image: UIImage, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }

    private var bottomButtons: some View {
        HStack(spacing: 16) {
            Button(Constants.saveButtonTitle) {
                viewModel.saveImage()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button(Constants.shareButtonTitle) {
                viewModel.prepareShareImage()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
